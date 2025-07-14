import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'package:intl/intl.dart';
import 'teacher_dashboard_screen.dart'; // Add this

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _bioController = TextEditingController();
  final _auth = AuthService();

  String? _dobFormatted;
  DateTime? _selectedDob;
  String _selectedRole = 'student';

  void _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2005),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobFormatted = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void _signup(BuildContext context) async {
    if (_dobFormatted == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please select Date of Birth")));
      return;
    }

    final user = await _auth.signUpWithEmail(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
      dob: _dobFormatted!,
      bio: _bioController.text.trim(),
      role: _selectedRole,
    );

    if (user != null) {
      if (_selectedRole == 'teacher') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TeacherDashboardScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
      }
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Signup failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/bg.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassmorphicContainer(
                child: Column(
                  children: [
                    const Text("Sign Up", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),
                    buildTextField("Full Name", _nameController),
                    buildTextField("Username", _usernameController),
                    buildTextField("Email", _emailController),
                    buildTextField("Password", _passwordController, obscure: true),
                    buildDobField(context),
                    buildRoleDropdown(),
                    buildTextField("Bio", _bioController, maxLines: 3),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () => _signup(context),
                      child: const Text("Create Account"),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Already have an account? Login"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, TextEditingController controller, {bool obscure = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget buildDobField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => _pickDate(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(15),
            color: Colors.white.withOpacity(0.6),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _dobFormatted ?? 'Select Date of Birth',
                style: TextStyle(color: _dobFormatted == null ? Colors.grey : Colors.black),
              ),
              const Icon(Icons.calendar_today, size: 20, color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoleDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedRole,
        decoration: InputDecoration(
          labelText: 'Role',
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
        items: const [
          DropdownMenuItem(value: 'student', child: Text('Student')),
          DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
        ],
        onChanged: (value) => setState(() => _selectedRole = value!),
      ),
    );
  }
}

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  const GlassmorphicContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: child,
    );
  }
}
