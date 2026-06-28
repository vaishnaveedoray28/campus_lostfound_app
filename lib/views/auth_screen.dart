import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import 'dashboard_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoginMode = true;
  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _matricController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  String _selectedRole = "Student";
  String _selectedInasis = "Inasis MAS"; 

  final List<String> _inasisOptions = [
    "Inasis MAS", "Inasis Bank Rakyat", "Inasis Proton", "Inasis Tradewinds", 
    "Inasis Petronas", "Inasis Sime Darby", "Inasis MISC", "Inasis BSN"
  ];

  final String baseApiUrl = "http://10.0.2.2/lost_found_api";

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() { isLoading = true; });
    final String endpoint = isLoginMode ? 'login.php' : 'register.php';
    final Uri url = Uri.parse('$baseApiUrl/$endpoint');

    final Map<String, dynamic> requestBody = isLoginMode
        ? {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          }
        : {
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'matric_no': _matricController.text.trim(),
            'inasis': _selectedInasis,
            'phone': _phoneController.text.trim(),
            'password': _passwordController.text,
            'role': _selectedRole,
          };

    try {
      final response = await http.post(url, headers: {"Content-Type": "application/json"}, body: jsonEncode(requestBody));
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || responseData['status'] == 'success') {
        _showSnackBar(responseData['message'] ?? 'Success!', Colors.green);

        if (isLoginMode) {
          UserModel userSession = UserModel.fromJson(responseData['user']);
          if (!mounted) return;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen(user: userSession)));
        } else {
          setState(() { isLoginMode = true; });
          _nameController.clear(); _emailController.clear(); _matricController.clear(); _phoneController.clear(); _passwordController.clear();
        }
      } else {
        _showSnackBar(responseData['message'] ?? 'Authentication failed.', Colors.red);
      }
    } catch (error) {
      _showSnackBar("Cannot link to server. Check if XAMPP Apache is running.", Colors.orange);
    } finally {
      if (mounted) { setState(() { isLoading = false; }); }
    }
  }

  void _showSnackBar(String text, Color background) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text), backgroundColor: background, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLoginMode ? 'UUM Rewards Sign In' : 'Create Student Account'), backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white, centerTitle: true, elevation: 0),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 6, //shadow
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.find_in_page_rounded, size: 65, color: Color(0xFF1E3A8A)),
                    const SizedBox(height: 10),
                    const Text("Sintok Lost & Found Hub", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                    const SizedBox(height: 25),
                    
                    if (!isLoginMode) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline), border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your full name' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _matricController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'UUM Matric Card Number', prefixIcon: Icon(Icons.badge_outlined), border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Please enter your Matric Number' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedInasis,
                        decoration: const InputDecoration(labelText: 'Current Inasis (Hostel)', prefixIcon: Icon(Icons.home_work_outlined), border: OutlineInputBorder()),
                        items: _inasisOptions.map((String value) => DropdownMenuItem<String>(value: value, child: Text(value))).toList(),
                        onChanged: (val) => setState(() => _selectedInasis = val!),
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email_outlined), border: OutlineInputBorder()),
                      validator: (value) => (value == null || !value.contains('@')) ? 'Enter a valid email address' : null,
                    ),
                    const SizedBox(height: 16),

                    if (!isLoginMode) ...[
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone_android), border: OutlineInputBorder()),
                        validator: (value) => (value == null || value.trim().isEmpty) ? 'Enter your mobile number' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()),
                      validator: (value) => (value == null || value.length < 6) ? 'Password must be 6+ characters' : null,
                    ),
                    const SizedBox(height: 24),

                    isLoading
                        ? const CircularProgressIndicator(color: Color(0xFF1E3A8A))
                        : ElevatedButton(
                            onPressed: _submitAuthForm,
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: Text(isLoginMode ? 'Login' : 'Register Account'),
                          ),
                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: () { setState(() { isLoginMode = !isLoginMode; }); },
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB)),
                      child: Text(isLoginMode ? 'New to the app? Register here' : 'Already registered? Log in here'),
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