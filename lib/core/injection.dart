import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_cubit.dart';
import 'package:simple_mqtt/data/hive_config.dart';
import 'package:simple_mqtt/data/objects/message_object.dart';
import 'package:simple_mqtt/data/objects/topics_object.dart';

final getIt = GetIt.instance;

Future<void> initDepedencies() async {
  await HiveConfig.init();

  final appBox = await Hive.openBox('app_box');
  final messagesBox = await Hive.openBox<MessageObject>('message_object');
  final topicsBox = await Hive.openBox<TopicsObject>('topics_object');
  getIt.registerFactory<Box>(() => appBox);
  getIt.registerFactory<Box<MessageObject>>(() => messagesBox);
  getIt.registerFactory<Box<TopicsObject>>(() => topicsBox);

  getIt.registerFactory<MqttServerClient>(() {
    final client = MqttServerClient('', '');
    client.keepAlivePeriod = 60;
    client.secure = false;
    client.logging(on: true);
    return client;
  });

  getIt.registerFactory<MqttCubit>(() {
    return MqttCubit(getIt(), getIt(), getIt(), getIt());
  });
}
