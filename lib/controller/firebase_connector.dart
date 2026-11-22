import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../model/category_model.dart';
import '../model/game_session_model.dart';
import '../model/question_model.dart';
import '../model/user_model.dart';

class FirebaseConnector {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;

  Future<List<CategoryModel>> getCategories() async {
    final snapshot = await _db.collection('categories').get();
    return snapshot.docs.map(CategoryModel.fromFirestore).toList();
  }

  Future<List<QuestionModel>> getQuestionsByCategory(String categoryId) async {
    final snapshot = await _db
        .collection('questions')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return snapshot.docs.map(QuestionModel.fromFirestore).toList();
  }

  Future<void> saveGameSession(GameSessionModel session) async {
    await _db.collection('game_sessions').add(session.toMap());
  }

  Future<UserModel?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> saveUser(UserModel user) async {
    await _db
        .collection('users')
        .doc(user.uid)
        .set(user.toMap(), SetOptions(merge: true));
  }
}
