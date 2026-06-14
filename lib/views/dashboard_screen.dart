
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'auth_screen.dart';

class DashboardScreen extends StatefulWidget {
  final UserModel user;
  const DashboardScreen({super.key, required this.user});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int currentPoints;

  @override
  void initState() {
    super.initState();
    currentPoints = widget.user.points;
  }

  void _simulateRedemption() {
    if (currentPoints >= 100) {
      setState(() {
        currentPoints -= 100;
      });
      _showVoucherDialog();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Incomplete Points! You need at least 100 PTS for a Thailicious voucher."),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showVoucherDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.local_cafe, color: Colors.amber),
            SizedBox(width: 10),
            Text("Voucher Unlocked!"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Present this claim token at the Varsity Mall Thailicious counter:",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.teal),
              ),
              child: const Text(
                "THAI-FREE-DRINK-UUM",
                style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.5),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Awesome", style: TextStyle(color: Colors.teal)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Sintok Hub Dashboard'),
        backgroundColor: const Color.fromARGB(255, 186, 1, 100),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Container(
              color:const Color.fromARGB(255, 186, 1, 100),
              padding: const EdgeInsets.only(bottom: 30, left: 20, right: 20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome, ${widget.user.name}!',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Role: ${widget.user.role} | ${widget.user.email}',
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber, width: 1.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                            Text(
                              '$currentPoints PTS',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Campus Quick Actions",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening Lost Item Form...')),
                            );
                          },
                          child: Card(
                            color: Colors.red[50],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), 
                              side: BorderSide(color: Colors.red[200]!, width: 1)
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Column(
                                children: [
                                  Icon(Icons.assignment_late_outlined, size: 45, color: Colors.red),
                                  SizedBox(height: 12),
                                  Text(
                                    "I Lost Something",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening Found items Feed Board...')),
                            );
                          },
                          child: Card(
                            color: Colors.green[50],
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15), 
                              side: BorderSide(color: Colors.green[200]!, width: 1)
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24.0),
                              child: Column(
                                children: [
                                  Icon(Icons.gpp_good_outlined, size: 45, color: Colors.green),
                                  SizedBox(height: 12),
                                  Text(
                                    "I Found Something",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "Sintok Active Feed Summary",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.teal[300]),
                              const SizedBox(width: 10),
                              const Text("Live System Tracking Info", style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const Divider(height: 20),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Active Unresolved Claims:", style: TextStyle(color: Colors.black54)),
                              Text("2 Items Pending", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Your Successful Returns:", style: TextStyle(color: Colors.black54)),
                              Text("0 Items Closed", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton.icon(
                    onPressed: _simulateRedemption,
                    icon: const Icon(Icons.local_cafe_rounded),
                    label: const Text("Redeem Thailicious Voucher (Costs 100 PTS)", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 186, 1, 100),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 2,
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
}