import 'package:json_annotation/json_annotation.dart';

part 'story_model.g.dart';

@JsonSerializable()
class StoryModel {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final double? lat;
  final double? lon;
  final DateTime createdAt;

  StoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    this.lat,
    this.lon,
    required this.createdAt,
  });

  factory StoryModel.fromJson(Map<String, dynamic> json) =>
      _$StoryModelFromJson(json);

  Map<String, dynamic> toJson() => _$StoryModelToJson(this);
}
