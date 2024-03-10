import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_mqtt/core/injection.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_cubit.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_state.dart';
import 'package:simple_mqtt/data/hive_config.dart';
import 'package:simple_mqtt/data/objects/message_object.dart';
import 'package:simple_mqtt/pages/publish_message/publish_message_page.dart';
import 'package:simple_mqtt/widgets/appbar_with_status.dart';
import 'package:simple_mqtt/widgets/messages_item.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = ScrollController();

    void onTapConnect() {
      final cubit = context.read<MqttCubit>();
      if (cubit.state is Disconnected) {
        cubit.connect(
          url: getIt<Box>().get(HiveConfig.URL_KEY),
          port: getIt<Box>().get(HiveConfig.PORT_KEY),
        );
      } else if (cubit.state is Connected) {
        cubit.disconnect();
      }
    }

    void onTapPublishMessage() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const PublishMessagePage(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBarWithStatus(
        titleText: getIt<Box>().get(HiveConfig.URL_KEY)?.toString() ?? "-",
        actions: [
          BlocBuilder<MqttCubit, MqttState>(
            builder: (context, state) {
              Widget icon = const Center(
                child: SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              );
              if (state is Disconnected) {
                icon = const Icon(Icons.play_arrow);
              } else if (state is Connected) {
                icon = const Icon(Icons.stop);
              }

              return InkWell(
                onTap: onTapConnect,
                child: icon,
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                BlocBuilder<MqttCubit, MqttState>(
                  builder: (_, state) {
                    final isEnable = state is Connected;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: isEnable ? onTapPublishMessage : null,
                      child: const Text("PUBLISH MESSAGE"),
                    );
                  },
                ),
                const Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    getIt<Box<MessageObject>>().clear();
                  },
                  child: const Text("CLEAR"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<MessageObject>>(
              valueListenable: getIt<Box<MessageObject>>().listenable(),
              builder: (_, box, __) {
                if (box.values.isEmpty) {
                  return const Center(child: Text("No Messages"));
                }

                return ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: box.values.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (_, index) {
                    final message = box.getAt(index);
                    return MessagesItem(
                      topic: message!.topic,
                      message: message.message,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
