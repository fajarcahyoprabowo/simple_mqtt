// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:hive/hive.dart';

part 'topics_object.g.dart';

@HiveType(typeId: 0)
class TopicsObject extends HiveObject {
  @HiveField(0)
  String name;

  TopicsObject({
    required this.name,
  });
}
