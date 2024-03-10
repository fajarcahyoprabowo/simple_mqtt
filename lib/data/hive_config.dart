// ignore_for_file: constant_identifier_names

import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_mqtt/data/objects/message_object.dart';
import 'package:simple_mqtt/data/objects/topics_object.dart';

abstract class HiveConfig {
  static const String URL_KEY = 'url';
  static const String PORT_KEY = 'port';
  static const String DARK_MODE_KEY = 'dark_mode';

  static Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    Hive.registerAdapter(TopicsObjectAdapter());
    Hive.registerAdapter(MessageObjectAdapter());
  }
}
