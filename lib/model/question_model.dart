import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String id;
  final String categoryId;
  final String questionText;
  final String? imageAsset;
  final String choiceA;
  final String choiceB;
  final String choiceC;
  final String choiceD;
  final String correctAnswer;
  final String difficultyLevel;

  const QuestionModel({
    required this.id,
    required this.categoryId,
    required this.questionText,
    this.imageAsset,
    required this.choiceA,
    required this.choiceB,
    required this.choiceC,
    required this.choiceD,
    required this.correctAnswer,
    required this.difficultyLevel,
  });

  factory QuestionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final asset = data['imageAsset'] as String?;
    return QuestionModel(
      id: doc.id,
      categoryId: data['categoryId'] as String? ?? '',
      questionText: data['questionText'] as String? ?? '',
      imageAsset: (asset != null && asset.isNotEmpty) ? asset : null,
      choiceA: data['choiceA'] as String? ?? '',
      choiceB: data['choiceB'] as String? ?? '',
      choiceC: data['choiceC'] as String? ?? '',
      choiceD: data['choiceD'] as String? ?? '',
      correctAnswer: data['correctAnswer'] as String? ?? '',
      difficultyLevel: data['difficultyLevel'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'categoryId': categoryId,
      'questionText': questionText,
      'imageAsset': imageAsset,
      'choiceA': choiceA,
      'choiceB': choiceB,
      'choiceC': choiceC,
      'choiceD': choiceD,
      'correctAnswer': correctAnswer,
      'difficultyLevel': difficultyLevel,
    };
  }
}
