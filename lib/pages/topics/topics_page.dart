import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:simple_mqtt/core/decorations/app_field_decoration.dart';
import 'package:simple_mqtt/core/injection.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_cubit.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_state.dart';
import 'package:simple_mqtt/data/hive_config.dart';
import 'package:simple_mqtt/data/objects/topics_object.dart';
import 'package:simple_mqtt/widgets/appbar_with_status.dart';
import 'package:simple_mqtt/widgets/snackbar_error.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key});

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  final topicTextField = TextEditingController();

  @override
  void dispose() {
    topicTextField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithStatus(titleText: "Subscribed Topics"),
      body: BlocListener<MqttCubit, MqttState>(
        listener: (context, state) {
          if (state is Disconnected) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackbarError(
                content: Text(state.errorMessage!),
              ));
            }
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: topicTextField,
                      decoration: const AppFieldDecoration(
                        labelText: "Topic",
                      ).copyWith(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (topicTextField.text.trim().isEmpty) return;
                      context
                          .read<MqttCubit>()
                          .subscribeTopic(topic: topicTextField.text.trim());
                      topicTextField.text = "";
                    },
                    child: const Text("Subscribe"),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<Box<TopicsObject>>(
                valueListenable: getIt<Box<TopicsObject>>().listenable(),
                builder: (_, box, child) {
                  if (box.values.isEmpty) {
                    return const Center(
                      child: Text("No Subscribed Topics"),
                    );
                  }

                  Color? iconColor;
                  if (getIt<Box>().get(HiveConfig.DARK_MODE_KEY) == true) {
                    iconColor = Colors.white;
                  }

                  return ListView.builder(
                    itemCount: box.values.length,
                    itemBuilder: (_, index) {
                      final topic = box.getAt(index);
                      return ListTile(
                        horizontalTitleGap: 8,
                        title: Text(topic!.name),
                        trailing: InkWell(
                          onTap: () {
                            context
                                .read<MqttCubit>()
                                .unsubscribeTopic(topic: topic.name);
                          },
                          child: Icon(Icons.delete, color: iconColor),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
