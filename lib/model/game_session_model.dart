import 'package:cloud_firestore/cloud_firestore.dart';

class GameSessionModel {
  final String id;
  final String userId;
  final String categoryId;
  final int score;
  final int timeTakenSeconds;
  final DateTime? playedAt;
  final String username;
  final String categoryName;

  const GameSessionModel({
    this.id = '',
    required this.userId,
    required this.categoryId,
    required this.score,
    required this.timeTakenSeconds,
    this.playedAt,
    required this.username,
    required this.categoryName,
  });

  factory GameSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return GameSessionModel(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      score: (data['score'] as num?)?.toInt() ?? 0,
      timeTakenSeconds: (data['timeTakenSeconds'] as num?)?.toInt() ?? 0,
      playedAt: (data['playedAt'] as Timestamp?)?.toDate(),
      username: data['username'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'categoryId': categoryId,
      'score': score,
      'timeTakenSeconds': timeTakenSeconds,
      'playedAt': playedAt != null
          ? Timestamp.fromDate(playedAt!)
          : FieldValue.serverTimestamp(),
      'username': username,
      'categoryName': categoryName,
    };
  }
}
