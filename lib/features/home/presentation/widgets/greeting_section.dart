import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GreetingSection extends StatelessWidget {
  final User user;

  const GreetingSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hi, ${user.displayName ?? "User"} 👋',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(user.email ?? '', style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
