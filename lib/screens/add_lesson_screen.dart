import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authentication/widgets/form_helpers.dart';

class AddLessonScreen extends StatefulWidget {
  final String courseId;
  const AddLessonScreen({super.key, required this.courseId});

  @override
  State<AddLessonScreen> createState() => _AddLessonScreenState();
}

class _AddLessonScreenState extends State<AddLessonScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  void _submitLesson() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('lessons')
        .add({
      'title': title,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Lesson added successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('assets/bg.jpg', fit: BoxFit.cover)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Lesson",
                      style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  buildTextField("Lesson Title", _titleController),
                  buildTextField("Lesson Content", _contentController, maxLines: 5),
                  const SizedBox(height: 20),
                  buildButton("Add Lesson", _submitLesson),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
