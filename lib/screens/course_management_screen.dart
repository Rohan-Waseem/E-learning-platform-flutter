import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'add_lesson_screen.dart';
import 'add_note_screen.dart';
import 'add_quiz_screen.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class CourseManagementScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;

  const CourseManagementScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(child: Image.asset('assets/bg.jpg', fit: BoxFit.cover)),
            SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    color: Colors.black.withOpacity(0.7),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Expanded(
                          child: Text(
                            'Manage "$courseTitle"',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const TabBar(
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    tabs: [
                      Tab(text: 'Lessons'),
                      Tab(text: 'Quizzes'),
                      Tab(text: 'Notes'),
                      Tab(text: 'Discussion'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildLessonsTab(context),
                        _buildQuizzesTab(context),
                        _buildNotesTab(context),
                        _buildDiscussionTab(context)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _styledButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurpleAccent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 16)),
      ),
    );
  }

  Widget _buildLessonsTab(BuildContext context) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController contentController = TextEditingController();

    Future<void> _submitLesson() async {
      final title = titleController.text.trim();
      final content = contentController.text.trim();

      if (title.isEmpty || content.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill in all fields")),
        );
        return;
      }

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .add({
        'title': title,
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
      });

      titleController.clear();
      contentController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lesson added")),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add New Lesson", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Lesson Title",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Lesson Content",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _submitLesson,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Add", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .collection('lessons')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final lessons = snapshot.data!.docs;
                if (lessons.isEmpty) {
                  return const Center(child: Text("No lessons added yet", style: TextStyle(color: Colors.white)));
                }
                return ListView.builder(
                  itemCount: lessons.length,
                  itemBuilder: (context, index) {
                    final data = lessons[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(data['content'] ?? ''),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuizzesTab(BuildContext context) {
    final quizTitleController = TextEditingController();
    final questionController = TextEditingController();
    final answerController = TextEditingController();

    void _addQuiz() async {
      final title = quizTitleController.text.trim();
      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter quiz title")));
        return;
      }

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('quizzes')
          .add({
        'title': title,
        'createdAt': FieldValue.serverTimestamp(),
      });

      quizTitleController.clear();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Quiz created")));
    }

    void _addQuestion(String quizId) async {
      final question = questionController.text.trim();
      final answer = answerController.text.trim();

      if (question.isEmpty || answer.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Both fields required")));
        return;
      }

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('quizzes')
          .doc(quizId)
          .collection('questions')
          .add({
        'question': question,
        'answer': answer,
        'createdAt': FieldValue.serverTimestamp(),
      });

      questionController.clear();
      answerController.clear();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Create New Quiz", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 10),
                TextField(
                  controller: quizTitleController,
                  decoration: InputDecoration(
                    labelText: "Quiz Title",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _addQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Create Quiz", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .collection('quizzes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final quizzes = snapshot.data!.docs;

                if (quizzes.isEmpty) {
                  return const Center(child: Text("No quizzes yet", style: TextStyle(color: Colors.white)));
                }

                return ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    final quizId = quiz.id;
                    final quizTitle = quiz['title'];

                    return ExpansionTile(
                      title: Text(quizTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.white.withOpacity(0.1),
                      collapsedBackgroundColor: Colors.white.withOpacity(0.1),
                      textColor: Colors.white,
                      iconColor: Colors.white,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              TextField(
                                controller: questionController,
                                decoration: const InputDecoration(labelText: "Question"),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: answerController,
                                decoration: const InputDecoration(labelText: "Answer"),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton(
                                onPressed: () => _addQuestion(quizId),
                                child: const Text("Add Question"),
                              ),
                              const SizedBox(height: 12),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('courses')
                                    .doc(courseId)
                                    .collection('quizzes')
                                    .doc(quizId)
                                    .collection('questions')
                                    .orderBy('createdAt')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) return const CircularProgressIndicator();
                                  final questions = snapshot.data!.docs;
                                  return ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: questions.length,
                                    itemBuilder: (context, i) {
                                      final q = questions[i].data() as Map<String, dynamic>;
                                      return ListTile(
                                        title: Text(q['question'] ?? ''),
                                        subtitle: Text("Answer: ${q['answer'] ?? ''}"),
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildNotesTab(BuildContext context) {
    final TextEditingController noteTitleController = TextEditingController();
    final TextEditingController noteContentController = TextEditingController();
    File? pickedFile;
    String? fileName;

    Future<void> _pickFile() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
      );
      if (result != null && result.files.single.path != null) {
        pickedFile = File(result.files.single.path!);
        fileName = result.files.single.name;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Selected file: $fileName")));
      }
    }

    Future<void> _submitNote() async {
      final title = noteTitleController.text.trim();
      final content = noteContentController.text.trim();

      if (title.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Title is required")));
        return;
      }

      String? fileUrl;
      String? fileType;

      if (pickedFile != null) {
        final fileExt = fileName!.split('.').last;
        fileType = fileExt == 'pdf' ? 'pdf' : 'image';

        final ref = FirebaseStorage.instance
            .ref()
            .child('notes/${DateTime.now().millisecondsSinceEpoch}_$fileName');
        await ref.putFile(pickedFile!);
        fileUrl = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('notes')
          .add({
        'title': title,
        'content': content,
        'fileUrl': fileUrl,
        'fileType': fileType,
        'createdAt': FieldValue.serverTimestamp(),
      });

      noteTitleController.clear();
      noteContentController.clear();
      pickedFile = null;
      fileName = null;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Note added")),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add New Note", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                TextField(
                  controller: noteTitleController,
                  decoration: InputDecoration(
                    labelText: "Note Title",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: noteContentController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Note Content (Optional)",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.attach_file),
                      label: const Text("Attach File"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (fileName != null)
                      Expanded(child: Text(fileName!, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _submitNote,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Add", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('courses')
                  .doc(courseId)
                  .collection('notes')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final notes = snapshot.data!.docs;
                if (notes.isEmpty) {
                  return const Center(child: Text("No notes yet", style: TextStyle(color: Colors.white)));
                }
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final data = notes[index].data() as Map<String, dynamic>;
                    final fileType = data['fileType'];
                    final fileUrl = data['fileUrl'];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(data['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (data['content'] != null && data['content'].toString().isNotEmpty)
                                Text(data['content']),
                              if (fileUrl != null) ...[
                                const SizedBox(height: 6),
                                fileType == 'image'
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(fileUrl, height: 150, fit: BoxFit.cover),
                                )
                                    : TextButton.icon(
                                  onPressed: () => launchUrl(Uri.parse(fileUrl)),
                                  icon: const Icon(Icons.picture_as_pdf),
                                  label: const Text("Open PDF"),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDiscussionTab(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final TextEditingController messageController = TextEditingController();
    final ScrollController scrollController = ScrollController();

    Future<void> _sendMessage() async {
      final text = messageController.text.trim();
      if (text.isEmpty) return;

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('discussion')
          .add({
        'senderId': user!.uid,
        'senderName': user.displayName ?? 'User',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });

      messageController.clear();
      scrollController.animateTo(
        scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    return Column(
      children: [
        Expanded(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('courses')
                .doc(courseId)
                .collection('discussion')
                .orderBy('createdAt')
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              final messages = snapshot.data!.docs;

              return ListView.builder(
                controller: scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index].data() as Map<String, dynamic>;
                  final isMe = msg['senderId'] == user?.uid;
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.deepPurple : Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['senderName'] ?? '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            msg['text'] ?? '',
                            style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.black.withOpacity(0.2),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.deepPurpleAccent),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }

}
