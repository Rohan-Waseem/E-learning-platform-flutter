import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  Future<DocumentSnapshot?> getUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _firestore.collection('users').doc(user.uid).get();
  }

  void _goToEditProfile(Map<String, dynamic> data) async {
    // Push and wait for result to return
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditProfileScreen(userData: data)),
    );
    // Trigger rebuild after returning
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/bg.jpg", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.5)),
          FutureBuilder<DocumentSnapshot?>(
            future: getUserData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (!snapshot.hasData || !snapshot.data!.exists) {
                return const Center(child: Text("User data not found.", style: TextStyle(color: Colors.white)));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Profile", style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white),
                              onPressed: _logout,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.white24,
                          backgroundImage: data['profilePic'] != null && data['profilePic'] != ""
                              ? NetworkImage(data['profilePic'])
                              : null,
                          child: data['profilePic'] == null || data['profilePic'] == ""
                              ? Text(
                            data['name'][0].toUpperCase(),
                            style: const TextStyle(fontSize: 40, color: Colors.white),
                          )
                              : null,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit Profile", style: TextStyle(fontSize: 16)),
                          onPressed: () => _goToEditProfile(data),
                        ),
                        const SizedBox(height: 20),
                        buildInfoCard("Name", data['name']),
                        buildInfoCard("Username", data['username']),
                        buildInfoCard("Email", data['email']),
                        buildInfoCard("Date of Birth", data['dob']),
                        buildInfoCard("Bio", data['bio']),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildInfoCard(String title, String value) {
    return Card(
      color: Colors.white.withOpacity(0.9),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        leading: const Icon(Icons.info_outline),
      ),
    );
  }
}
