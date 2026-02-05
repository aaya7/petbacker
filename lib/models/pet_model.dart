import 'dart:convert';

class PetModel {
  final String title;
  final String description;
  final List<MediaModel> medias;
  final List<PetQuestion> questions;
  final bool isJsonDescription;

  PetModel({
    required this.title,
    required this.description,
    required this.medias,
    required this.questions,
    required this.isJsonDescription,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    final rawDescription = json['description'] ?? '';
    List<PetQuestion> parsedQuestions = [];
    bool wasJson = false;

    if (rawDescription.trim().startsWith('{')) {
      try {
        final decoded = jsonDecode(rawDescription);
        if (decoded['question'] != null) {
          parsedQuestions = (decoded['question'] as List)
              .map((q) => PetQuestion.fromJson(q))
              .toList();
          wasJson = true;
        }
      } catch (e) {
        wasJson = false;
      }
    }

    return PetModel(
      title: json['title'] ?? '',
      description: rawDescription,
      medias: (json['medias'] as List? ?? [])
          .map((m) => MediaModel.fromJson(m))
          .toList(),
      questions: parsedQuestions,
      isJsonDescription: wasJson,
    );
  }
}

class MediaModel {
  final String mediaFilename;
  MediaModel({required this.mediaFilename});
  factory MediaModel.fromJson(Map<String, dynamic> json) =>
      MediaModel(mediaFilename: json['media_filename'] ?? '');
}

class PetQuestion {
  final int questionId;
  final String type;
  final String content;
  final String? listingDisplay;
  final String? reply;

  PetQuestion({
    required this.questionId,
    required this.type,
    required this.content,
    this.listingDisplay,
    this.reply,
  });

  factory PetQuestion.fromJson(Map<String, dynamic> json) {
    return PetQuestion(
      questionId: int.tryParse(json['questionId']?.toString() ?? '0') ?? 0,
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      listingDisplay: json['listingDisplay'],
      reply: json['reply'],
    );
  }

  bool get hasValue =>
      reply != null && reply!.isNotEmpty && reply != "Invalid date";
}
