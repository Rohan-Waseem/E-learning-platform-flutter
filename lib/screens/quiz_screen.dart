import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizScreen extends StatefulWidget {
  final String courseId;
  final String quizId;

  const QuizScreen({super.key, required this.courseId, required this.quizId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  List<QueryDocumentSnapshot>? questions;
  bool showResult = false;
  int correctCount = 0;

  void _checkAnswer(String selectedAnswer) {
    final correctAnswer = questions![currentQuestionIndex]['answer'];
    if (selectedAnswer.trim().toLowerCase() == correctAnswer.trim().toLowerCase()) {
      correctCount++;
    }

    if (currentQuestionIndex < questions!.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        showResult = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text("Quiz: ${widget.quizId}"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay
          Container(color: Colors.black.withOpacity(0.7)),

          // Main content
          FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('courses')
                .doc(widget.courseId)
                .collection('quizzes')
                .doc(widget.quizId)
                .collection('questions')
                .orderBy('createdAt')
                .get(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              questions = snapshot.data!.docs;

              if (questions!.isEmpty) {
                return const Center(
                  child: Text("No questions available.", style: TextStyle(color: Colors.white)),
                );
              }

              if (showResult) {
                return Center(
                  child: Card(
                    margin: const EdgeInsets.all(24),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    color: Colors.white.withOpacity(0.95),
                    elevation: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("🎉 Quiz Completed!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text("Your Score: $correctCount / ${questions!.length}", style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.arrow_back),
                            label: const Text("Back to Course"),
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              final questionData = questions![currentQuestionIndex].data() as Map<String, dynamic>;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Question ${currentQuestionIndex + 1}/${questions!.length}",
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          questionData['question'] ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ..._buildOptions(questionData['answer']),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildOptions(String correctAnswer) {
    List<String> fakeOptions = ["Flutter", "Dart", "Firebase"];
    if (!fakeOptions.contains(correctAnswer)) fakeOptions[0] = correctAnswer;
    fakeOptions.shuffle();

    return fakeOptions.map((option) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          title: Text(option, style: const TextStyle(fontWeight: FontWeight.w500)),
          leading: const Icon(Icons.circle_outlined),
          onTap: () => _checkAnswer(option),
        ),
      );
    }).toList();
  }
}
