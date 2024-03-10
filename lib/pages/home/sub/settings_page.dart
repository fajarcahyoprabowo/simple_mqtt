import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simple_mqtt/core/injection.dart';
import 'package:simple_mqtt/data/hive_config.dart';
import 'package:simple_mqtt/pages/mqtt_broker/mqtt_broker_page.dart';
import 'package:simple_mqtt/pages/topics/topics_page.dart';
import 'package:simple_mqtt/widgets/appbar_with_status.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithStatus(titleText: "Settings"),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ListTile(
            title: const Text("MQTT Broker"),
            subtitle: const Text(
              "Config your mqtt broker.",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MQTTBrokerPage()),
            ),
          ),
          ListTile(
            title: const Text("Topics"),
            subtitle: const Text(
              "Manage your topic subscriptions.",
              style: TextStyle(fontSize: 12),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TopicsPage()),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: getIt<Box>().listenable(),
            builder: (_, box, __) {
              final isDarkMode = box.get(HiveConfig.DARK_MODE_KEY);
              return SwitchListTile.adaptive(
                title: const Text("Dark Mode"),
                subtitle: const Text(
                  "Switch between light and dark mode.",
                  style: TextStyle(fontSize: 12),
                ),
                value: isDarkMode ?? false,
                onChanged: (value) {
                  box.put(HiveConfig.DARK_MODE_KEY, value);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
