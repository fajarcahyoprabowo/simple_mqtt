import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_cubit.dart';
import 'package:simple_mqtt/core/mqtt/mqtt_state.dart';

class AppBarWithStatus extends AppBar {
  final bool showStatus;
  final String titleText;

  AppBarWithStatus({
    super.key,
    this.showStatus = true,
    required this.titleText,
    super.actions,
  });

  @override
  Widget? get title {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titleText,
          style: const TextStyle(fontSize: 16),
        ),
        if (showStatus) ...[
          BlocBuilder<MqttCubit, MqttState>(
            builder: (_, state) {
              String word = "Disconnected";
              if (state is Connected) word = "Connected";
              return Text(
                word,
                style: const TextStyle(fontSize: 12),
              );
            },
          ),
        ],
      ],
    );
  }
}
