import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:authentication/widgets/form_helpers.dart';
class AddNoteScreen extends StatefulWidget {
  final String courseId;
  const AddNoteScreen({super.key, required this.courseId});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _noteController = TextEditingController();

  void _submitNote() async {
    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .collection('notes')
        .add({
      'note': _noteController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return buildScaffold(
      context,
      title: "Add Note",
      children: [
        buildTextField("Note", _noteController, maxLines: 5),
        buildButton("Save Note", _submitNote),
      ],
    );
  }
}
