import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LessonListScreen extends StatelessWidget {
  final String courseId;
  final String courseTitle;
  final String courseDescription;

  const LessonListScreen({
    super.key,
    required this.courseId,
    required this.courseTitle,
    required this.courseDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(courseTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // 🔹 Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/bg.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.6)),

          // 🔸 Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('courses')
                    .doc(courseId)
                    .collection('lessons')
                    .orderBy('createdAt', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.white));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  return ListView(
                    children: [
                      Text(
                        courseTitle,
                        style: const TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        courseDescription,
                        style: const TextStyle(fontSize: 16, color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Lessons",
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      if (docs.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text("No lessons available", style: TextStyle(color: Colors.white70)),
                          ),
                        )
                      else
                        ...docs.map((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final title = data['title'] ?? 'Untitled';
                          final description = data['content'] ?? 'No description';

                          return Card(
                            color: Colors.white.withOpacity(0.9),
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                            elevation: 5,
                            child: ListTile(
                              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(description),
                              isThreeLine: true,
                              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                              onTap: () => _showLessonOptions(context, title),
                            ),
                          );
                        }).toList(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLessonOptions(BuildContext context, String lessonTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey[900],
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                lessonTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 20),
              buildOption(context, Icons.note, "Notes"),
              buildOption(context, Icons.quiz, "Quiz"),
              buildOption(context, Icons.forum, "Discussion"),
            ],
          ),
        );
      },
    );
  }

  Widget buildOption(BuildContext context, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Navigate to $label")),
        );
        // TODO: Implement navigation
      },
    );
  }
}
