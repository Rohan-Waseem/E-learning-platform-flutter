import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔐 Login method
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  // 📝 Signup method with full user profile
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required String username,
    required String dob,
    required String role, // ✅ add this
    String profilePicUrl = '',
    String bio = '',
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'name': name,
        'email': email,
        'username': username,
        'dob': dob,
        'profilePic': profilePicUrl,
        'bio': bio,
        'role': role, // ✅ use the selected role instead of hardcoded 'student'
        'createdAt': FieldValue.serverTimestamp(),
        'enrolledCourses': [],
        'quizScores': {},
      });

      return cred.user;
    } catch (e) {
      print("Signup error: $e");
      return null;
    }
  }
  Future<DocumentSnapshot?> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

}
