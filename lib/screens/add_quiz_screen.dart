import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authentication/widgets/form_helpers.dart';
class AddQuizScreen extends StatefulWidget {
  final String courseId;
  const AddQuizScreen({super.key, required this.courseId});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _questionController = TextEditingController();
  final _answerController = TextEditingController();

  void _submitQuiz() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('quizzes')
        .add({
      'question': _questionController.text.trim(),
      'answer': _answerController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      context,
      title: "Add Quiz Question",
      children: [
        buildTextField("Question", _questionController),
        buildTextField("Answer", _answerController),
        buildButton("Add Quiz", _submitQuiz),
      ],
    );
  }
}
