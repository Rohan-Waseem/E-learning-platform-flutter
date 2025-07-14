import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_detail_screen.dart'; // ✅ Lesson detail
import 'quiz_screen.dart'; // ✅ Quiz screen
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
class EnrolledCourseScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;
  final String courseDescription;

  const EnrolledCourseScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.courseDescription,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(courseTitle),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Lessons'),
              Tab(text: 'Quizzes'),
              Tab(text: 'Notes'),
              Tab(text: 'Discussion'),
            ],
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/bg.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(color: Colors.black.withOpacity(0.6)),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 60),
                child: TabBarView(
                  children: [
                    _LessonsTab(courseId: courseId),
                    _QuizzesTab(courseId: courseId),
                    _NotesTab(courseId: courseId),
                    _DiscussionTab(courseId: courseId),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 📘 Lessons Tab
class _LessonsTab extends StatelessWidget {
  final String courseId;
  const _LessonsTab({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('lessons')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(
            child: Text("No lessons available.", style: TextStyle(color: Colors.white70)),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final title = data['title'] ?? 'Untitled';
            final content = data['content'] ?? '';

            return Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 5,
              child: ListTile(
                title: Text(title),
                subtitle: Text(
                  content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonDetailScreen(title: title, content: content),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// 🧪 Quizzes Tab
class _QuizzesTab extends StatelessWidget {
  final String courseId;
  const _QuizzesTab({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(courseId)
          .collection('quizzes')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        final quizzes = snapshot.data!.docs;
        if (quizzes.isEmpty) {
          return const Center(child: Text("No quizzes found", style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final quizId = quiz.id;
            final quizTitle = quiz['title'] ?? 'Untitled';

            return Card(
              color: Colors.white.withOpacity(0.9),
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                title: Text(quizTitle),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(courseId: courseId, quizId: quizId),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

// 📒 Notes Tab
class _NotesTab extends StatelessWidget {
  final String courseId;

  const _NotesTab({required this.courseId});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background
        Positioned.fill(
          child: Image.asset('assets/bg.jpg', fit: BoxFit.cover),
        ),
        Container(color: Colors.black.withOpacity(0.6)),

        // Notes List
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('courses')
              .doc(courseId)
              .collection('notes')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final notes = snapshot.data!.docs;
            if (notes.isEmpty) {
              return const Center(
                child: Text("No notes yet.", style: TextStyle(color: Colors.white)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final data = notes[index].data() as Map<String, dynamic>;
                final title = data['title'] ?? '';
                final content = data['content'] ?? '';
                final fileType = data['fileType'];
                final fileUrl = data['fileUrl'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87)),
                      const SizedBox(height: 6),
                      if (content.isNotEmpty)
                        Text(content, style: const TextStyle(color: Colors.black87)),
                      if (fileUrl != null) ...[
                        const SizedBox(height: 10),
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
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}


// 💬 Discussion Tab
class _DiscussionTab extends StatelessWidget {
  final String courseId;
  const _DiscussionTab({required this.courseId});

  @override
  Widget build(BuildContext context) {
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


