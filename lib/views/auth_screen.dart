import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoginMode = true;
  bool isLoading = false;

  // Input text field controllers mapping to the lecturer's backend keys
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = "Student";

  // Android Emulator loopback IP to communicate with local XAMPP Apache
  final String baseApiUrl = "http://10.0.2.2/lost_found_api";

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    final String endpoint = isLoginMode ? 'login.php' : 'register.php';
    final Uri url = Uri.parse('$baseApiUrl/$endpoint');

    // Payloads matching the requirements of your lecturer's PHP scripts
    final Map<String, dynamic> requestBody = isLoginMode
        ? {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }
        : {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'phone': _phoneController.text.trim(),
            'password': _passwordController.text,
            'role': _selectedRole,
          };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || responseData['status'] == 'success') {
        _showSnackBar(responseData['message'] ?? 'Success!', Colors.green);

        if (isLoginMode) {
          // Parse raw JSON object directly into our structured UserModel data object
          UserModel userSession = UserModel.fromJson(responseData['user']);
          
          print("Login Session Authorized for: ${userSession.name} with ${userSession.points} pts");
          
          if (!mounted) return;
          // Cleanly transition to the Main Dashboard View page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreenPlaceholder(user: userSession),
            ),
          );
        } else {
          // Switch UI layout smoothly back to Login mode upon registration success
          setState(() {
            isLoginMode = true;
          });
          _nameController.clear();
          _emailController.clear();
          _phoneController.clear();
          _passwordController.clear();
        }
      } else {
        _showSnackBar(responseData['message'] ?? 'Authentication failed.', Colors.red);
      }
    } catch (error) {
      _showSnackBar("Cannot link to server. Check if XAMPP Apache is running.", Colors.orange);
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String text, Color background) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isLoginMode ? 'UUM Rewards Sign In' : 'Create Student Account'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars, size: 65, color: Colors.teal),
                    const SizedBox(height: 10),
                    const Text(
                      "Sintok Lost & Found Hub",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 25),
                    
                    // Full Name Field (Registration Mode Only)
                    if (!isLoginMode) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your full name' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email address' : null,
                    ),
                    const SizedBox(height: 16),

                    // Phone and Role Fields (Registration Mode Only)
                    if (!isLoginMode) ...[
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone_android),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter your mobile number' : null,
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Account Role',
                          prefixIcon: Icon(Icons.supervised_user_circle_outlined),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: "Student", child: Text("Student")),
                          DropdownMenuItem(value: "Admin", child: Text("Admin/Staff")),
                        ],
                        onChanged: (val) => setState(() => _selectedRole = val!),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.length < 6) ? 'Password must be 6+ characters' : null,
                    ),
                    const SizedBox(height: 24),

                    // Active Action Button UI Component
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _submitAuthForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: Text(isLoginMode ? 'Login' : 'Register Account'),
                          ),
                    const SizedBox(height: 12),

                    // Toggle Button Layout Selector Link
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isLoginMode = !isLoginMode;
                        });
                      },
                      child: Text(isLoginMode 
                        ? 'New to the app? Register here' 
                        : 'Already registered? Log in here'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Temporary Placeholder to allow clean project compilation until we build dashboard_screen.dart next
class DashboardScreenPlaceholder extends StatelessWidget {
  final UserModel user;
  const DashboardScreenPlaceholder({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Placeholder'), backgroundColor: Colors.teal),
      body: Center(
        child: Text('Welcome, ${user.name}!\nPoints Balance: ${user.points} PTS\nAuthentication Successful.'),
      ),
    );
  }
}