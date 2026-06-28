import 'package:flutter/material.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  final UserModel user;
  const ProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 50,
              // ignore: deprecated_member_use
              backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
              child: const Icon(Icons.account_circle, size: 100, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 16),
            Text(
              user.name.toUpperCase(),
              style: const TextStyle(fontSize: 22, fontStyle: FontStyle.normal, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const Text(
              "Universiti Utara Malaysia (UUM)",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildProfileRow(Icons.badge_outlined, "Matric Number", user.matricNo),
                    const Divider(),
                    _buildProfileRow(Icons.email_outlined, "Campus Email", user.email),
                    const Divider(),
                    _buildProfileRow(Icons.phone_android_outlined, "Phone Number", user.phone),
                    const Divider(),
                    _buildProfileRow(Icons.home_work_outlined, "Inasis Residence", user.inasis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3B82F6), size: 24),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
        ],
      ),
    );
  }
}