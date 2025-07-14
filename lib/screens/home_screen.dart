import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'courses_screen.dart';
import 'chatbot_screen.dart';
import 'profile_screen.dart';
import 'progress_screen.dart';
import 'enrolled_courses_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String userName = "";
  String? profilePic;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          userName = data['name'];
          profilePic = data['profilePic'];
        });
      }
    }
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.asset('assets/bg.jpg', fit: BoxFit.cover, width: double.infinity, height: double.infinity),
          Container(color: Colors.black.withOpacity(0.5)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and profile
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Welcome,\n${userName.isNotEmpty ? userName : 'User'}",
                        style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      GestureDetector(
                        onTap: () => _navigate(context, const ProfileScreen()),
                        child: CircleAvatar(
                          backgroundImage: profilePic != null && profilePic != ''
                              ? NetworkImage(profilePic!)
                              : null,
                          radius: 26,
                          backgroundColor: Colors.white24,
                          child: profilePic == null || profilePic == ''
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Updated Progress section
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('courses')
                        .where('enrolledStudents', arrayContains: _auth.currentUser?.uid)
                        .limit(2)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }

                      final courses = snapshot.data!.docs;
                      if (courses.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            "You haven’t enrolled in any courses yet.",
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }

                      return Column(
                        children: courses.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'Untitled Course';
                          final double progress = 0.6; // Hardcoded progress for now

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("📈 Progress", style: TextStyle(color: Colors.white, fontSize: 18)),
                                const SizedBox(height: 10),
                                LinearProgressIndicator(
                                  value: progress,
                                  color: Colors.green,
                                  backgroundColor: Colors.white30,
                                  minHeight: 8,
                                ),
                                const SizedBox(height: 5),
                                Text("${(progress * 100).toStringAsFixed(0)}% completed",
                                    style: const TextStyle(color: Colors.white70)),
                                const SizedBox(height: 5),
                                Text("📘 $title",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Navigation Buttons
                  buildNavButton(context, "📚 Browse Courses", Colors.blue, const CoursesScreen()),
                  buildNavButton(context, "💬 Ask AI Chatbot", Colors.teal, const ChatbotScreen()),
                  buildNavButton(context, "📊 View Progress", Colors.orange, const ProgressScreen()),
                  buildNavButton(context, "📝 Enrolled Courses", Colors.purple, const EnrolledCoursesScreen()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavButton(BuildContext context, String label, Color color, Widget screen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _navigate(context, screen),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: color.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
      ),
    );
  }
}
