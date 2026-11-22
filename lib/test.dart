import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'controller/firebase_connector.dart';
import 'firebase_options.dart';
import 'model/category_model.dart';
import 'model/game_session_model.dart';
import 'model/question_model.dart';
import 'model/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await runCrudTests();
}

Future<void> runCrudTests() async {
  final db = FirebaseFirestore.instance;
  final connector = FirebaseConnector();

  const testUserId = 'test_user_crud_001';
  const testCategoryId = 'test_category_crud_001';
  const testQuestionId = 'test_question_crud_001';
  String? testSessionId;

  debugPrint('================ START CRUD TESTS ================');

  try {
    // ---------------------------------------------------------
    // 1. UserModel CRUD (via FirebaseConnector + Firestore)
    // ---------------------------------------------------------
    final newUser = UserModel(
      uid: testUserId,
      username: 'juan_test',
      fullName: 'Juan Dela Cruz',
      skillLevel: 'Beginner',
    );
    await connector.saveUser(newUser);
    debugPrint('[PASS] User CREATE');

    final fetchedUser = await connector.getUser(testUserId);
    assert(fetchedUser != null && fetchedUser.username == 'juan_test');
    debugPrint('[PASS] User READ: ${fetchedUser?.fullName}');

    final updatedUser = UserModel(
      uid: testUserId,
      username: 'juan_test',
      fullName: 'Juan Dela Cruz',
      skillLevel: 'Intermediate',
    );
    await connector.saveUser(updatedUser);
    final reFetchedUser = await connector.getUser(testUserId);
    assert(reFetchedUser?.skillLevel == 'Intermediate');
    debugPrint('[PASS] User UPDATE: skillLevel = ${reFetchedUser?.skillLevel}');

    await db.collection('users').doc(testUserId).delete();
    final deletedUser = await connector.getUser(testUserId);
    assert(deletedUser == null);
    debugPrint('[PASS] User DELETE');

    // ---------------------------------------------------------
    // 2. CategoryModel CRUD
    // ---------------------------------------------------------
    final newCategory = CategoryModel(
      id: testCategoryId,
      name: 'Test Geometry',
      description: 'Temporary test category',
    );
    await db
        .collection('categories')
        .doc(testCategoryId)
        .set(newCategory.toMap());
    debugPrint('[PASS] Category CREATE');

    final categories = await connector.getCategories();
    final foundCategory = categories
        .where((c) => c.id == testCategoryId)
        .firstOrNull;
    assert(foundCategory != null && foundCategory.name == 'Test Geometry');
    debugPrint('[PASS] Category READ: ${foundCategory?.name}');

    await db.collection('categories').doc(testCategoryId).update({
      'description': 'Updated test description',
    });
    final updatedCatDoc = await db
        .collection('categories')
        .doc(testCategoryId)
        .get();
    final updatedCat = CategoryModel.fromFirestore(updatedCatDoc);
    assert(updatedCat.description == 'Updated test description');
    debugPrint('[PASS] Category UPDATE: ${updatedCat.description}');

    await db.collection('categories').doc(testCategoryId).delete();
    debugPrint('[PASS] Category DELETE');

    // ---------------------------------------------------------
    // 3. QuestionModel CRUD (with assets/geometry/... path)
    // ---------------------------------------------------------
    final newQuestion = QuestionModel(
      id: testQuestionId,
      categoryId: testCategoryId,
      questionText: 'What is the sum of angles in a triangle?',
      imageAsset: 'assets/geometry/triangle_01.png',
      choiceA: '90',
      choiceB: '180',
      choiceC: '270',
      choiceD: '360',
      correctAnswer: 'B',
      difficultyLevel: 'Easy',
    );
    await db
        .collection('questions')
        .doc(testQuestionId)
        .set(newQuestion.toMap());
    debugPrint('[PASS] Question CREATE');

    final questions = await connector.getQuestionsByCategory(testCategoryId);
    assert(
      questions.isNotEmpty &&
          questions.first.imageAsset == 'assets/geometry/triangle_01.png',
    );
    debugPrint('[PASS] Question READ: ${questions.first.imageAsset}');

    await db.collection('questions').doc(testQuestionId).update({
      'difficultyLevel': 'Medium',
    });
    final updatedQDoc = await db
        .collection('questions')
        .doc(testQuestionId)
        .get();
    final updatedQ = QuestionModel.fromFirestore(updatedQDoc);
    assert(updatedQ.difficultyLevel == 'Medium');
    debugPrint('[PASS] Question UPDATE: ${updatedQ.difficultyLevel}');

    await db.collection('questions').doc(testQuestionId).delete();
    debugPrint('[PASS] Question DELETE');

    // ---------------------------------------------------------
    // 4. GameSessionModel CRUD
    // ---------------------------------------------------------
    final newSession = GameSessionModel(
      userId: testUserId,
      categoryId: testCategoryId,
      score: 18,
      timeTakenSeconds: 45,
      username: 'juan_test',
      categoryName: 'Test Geometry',
    );
    await connector.saveGameSession(newSession);
    debugPrint('[PASS] GameSession CREATE');

    final sessionSnap = await db
        .collection('game_sessions')
        .where('userId', isEqualTo: testUserId)
        .limit(1)
        .get();
    assert(sessionSnap.docs.isNotEmpty);
    final fetchedSession = GameSessionModel.fromFirestore(
      sessionSnap.docs.first,
    );
    testSessionId = fetchedSession.id;
    assert(fetchedSession.score == 18);
    debugPrint('[PASS] GameSession READ: score = ${fetchedSession.score}');

    await db.collection('game_sessions').doc(testSessionId).update({
      'score': 20,
    });
    final updatedSessionDoc = await db
        .collection('game_sessions')
        .doc(testSessionId)
        .get();
    final updatedSession = GameSessionModel.fromFirestore(updatedSessionDoc);
    assert(updatedSession.score == 20);
    debugPrint('[PASS] GameSession UPDATE: score = ${updatedSession.score}');

    await db.collection('game_sessions').doc(testSessionId).delete();
    debugPrint('[PASS] GameSession DELETE');

    debugPrint('================ ALL CRUD TESTS PASSED ================');
  } catch (e, stack) {
    debugPrint('[FAIL] CRUD Test Error: $e');
    debugPrint('$stack');
  }
}
