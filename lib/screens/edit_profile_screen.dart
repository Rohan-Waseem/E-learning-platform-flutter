import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const EditProfileScreen({super.key, required this.userData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final picker = ImagePicker();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  File? _newProfileImage;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.userData['name'];
    _usernameController.text = widget.userData['username'];
    _bioController.text = widget.userData['bio'];
  }

  Future<void> _pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() => _newProfileImage = File(picked.path));
    }
  }

  Future<String?> _uploadProfilePic(String uid) async {
    if (_newProfileImage == null) return widget.userData['profilePic'];

    final ref = _storage.ref().child("profile_pics/$uid.jpg");
    await ref.putFile(_newProfileImage!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveChanges() async {
    setState(() => _uploading = true);
    final uid = _auth.currentUser!.uid;
    final profilePicUrl = await _uploadProfilePic(uid);

    await _firestore.collection('users').doc(uid).update({
      'name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'bio': _bioController.text.trim(),
      'profilePic': profilePicUrl ?? '',
    });

    setState(() => _uploading = false);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currentPic = widget.userData['profilePic'];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/bg.jpg", fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.6)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Edit Profile",
                    style: TextStyle(fontSize: 26, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white24,
                        backgroundImage: _newProfileImage != null
                            ? FileImage(_newProfileImage!)
                            : (currentPic != null && currentPic != '')
                            ? NetworkImage(currentPic)
                            : null,
                        child: (_newProfileImage == null && (currentPic == null || currentPic == ''))
                            ? Text(
                          widget.userData['name'][0].toUpperCase(),
                          style: const TextStyle(fontSize: 40, color: Colors.white),
                        )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 18,
                            child: Icon(Icons.camera_alt, color: Colors.deepPurple, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  buildField("Full Name", _nameController),
                  buildField("Username", _usernameController),
                  buildField("Bio", _bioController, maxLines: 3),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _uploading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: _uploading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text("Save Changes", style: TextStyle(fontSize: 16)),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: Colors.white.withOpacity(0.2),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
