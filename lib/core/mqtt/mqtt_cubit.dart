import 'dart:async';
import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_state.dart';
import 'package:simple_mqtt/data/hive_config.dart';
import 'package:simple_mqtt/data/objects/message_object.dart';
import 'package:simple_mqtt/data/objects/topics_object.dart';
import 'package:uuid/uuid.dart';

class MqttCubit extends Cubit<MqttState> {
  final MqttServerClient client;
  final Box mqttBox;
  final Box<MessageObject> messageBox;
  final Box<TopicsObject> topicBox;

  StreamSubscription<List<MqttReceivedMessage<MqttMessage>>>?
      onReceiveMessageListener;

  MqttCubit(
    this.client,
    this.mqttBox,
    this.messageBox,
    this.topicBox,
  ) : super(const Disconnected());

  void init() {
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.onUnsubscribed = onUnsubscribed;
  }

  void onConnected() {
    onReceiveMessageListener = client.updates?.listen(onListenUpdate);
    emit(const Connected(errorMessage: null));
  }

  void onDisconnected() {
    onReceiveMessageListener?.cancel();
    onReceiveMessageListener = null;
    emit(const Disconnected(errorMessage: null));
  }

  void onSubscribed(String topic) {
    final field = TopicsObject(name: topic);
    topicBox.put(field.name, field);
  }

  void onSubscribeFail(String topic) {
    final field = TopicsObject(name: topic);
    topicBox.delete(field.name);
  }

  void onUnsubscribed(String? topic) {
    if (topic == null) return;
    final field = TopicsObject(name: topic);
    topicBox.delete(field.name);
  }

  void onListenUpdate(List<MqttReceivedMessage<MqttMessage>> event) {
    final mqttMessage = event[0].payload as MqttPublishMessage;
    final message = MqttPublishPayload.bytesToStringAsString(
      mqttMessage.payload.message,
    );
    final field = MessageObject(
      topic: event[0].topic,
      message: message,
      qos: mqttMessage.payload.header?.qos.name ?? '-',
    );
    messageBox.add(field);
  }

  Future<bool> connect({required String url, required int port}) async {
    try {
      emit(Connecting());
      client.server = url;
      client.clientIdentifier = "mirae:${const Uuid().v4()}";
      client.port = port;

      if (url != mqttBox.get(HiveConfig.URL_KEY) ||
          port != mqttBox.get(HiveConfig.PORT_KEY)) {
        await messageBox.clear();
      }

      await Future.wait([
        mqttBox.put(HiveConfig.URL_KEY, url),
        mqttBox.put(HiveConfig.PORT_KEY, port),
      ]);
      final status = await client.connect();
      if (status?.state != MqttConnectionState.connected) return false;

      for (var element in topicBox.values) {
        client.subscribe(element.name, MqttQos.atLeastOnce);
      }

      return true;
    } on SocketException {
      emit(const Disconnected(errorMessage: "Cannot connecting to MQTT"));
    } catch (e) {
      emit(const Disconnected(errorMessage: 'Oops, something went wrong'));
    }
    return false;
  }

  Future<void> disconnect() async {
    bool isRecentConnected = state is Connected;

    try {
      client.disconnect();
      emit(const Disconnected());
      client.onDisconnected = () => emit(const Disconnected());
    } catch (e) {
      if (isRecentConnected) {
        emit(const Connected());
      } else {
        emit(const Disconnected());
      }
    }
  }

  void subscribeTopic({required String topic}) async {
    if (state is! Connected) {
      emit(const Disconnected(errorMessage: "MQTT not connected"));
      return;
    }
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void unsubscribeTopic({required String topic}) async {
    if (state is! Connected) {
      emit(const Disconnected(errorMessage: "MQTT not connected"));
      return;
    }
    client.unsubscribe(topic);
  }

  bool publishMessage({required String topic, required String message}) {
    subscribeTopic(topic: topic);
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    var res = client.publishMessage(
      topic,
      MqttQos.atLeastOnce,
      builder.payload!,
    );
    if (res > 0) return true;
    return false;
  }
}
