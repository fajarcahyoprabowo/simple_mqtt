// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

part 'message_object.g.dart';

@HiveType(typeId: 1)
class MessageObject extends HiveObject {
  @HiveField(0)
  String topic;

  @HiveField(1)
  String message;

  @HiveField(2)
  String qos;

  MessageObject({
    required this.topic,
    required this.message,
    required this.qos,
  });
}
