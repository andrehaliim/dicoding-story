import 'package:json_annotation/json_annotation.dart';
import 'story_model.dart';

part 'story_response.g.dart';

@JsonSerializable()
class StoryResponse {
  final bool error;
  final String message;
  final List<StoryModel> listStory;

  StoryResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory StoryResponse.fromJson(Map<String, dynamic> json) =>
      _$StoryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$StoryResponseToJson(this);
}
