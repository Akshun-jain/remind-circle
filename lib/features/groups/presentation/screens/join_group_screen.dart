import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:remind_circle/features/groups/presentation/providers/group_controller.dart';
import 'package:flutter/services.dart';

class JoinGroupScreen extends ConsumerStatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  ConsumerState<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends ConsumerState<JoinGroupScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final inviteCode = _controller.text.trim().toUpperCase();

    if (inviteCode.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invite code must be 6 characters.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;

    debugPrint('JOIN DEBUG - Firebase Auth UID: ${user.uid}');
    debugPrint('JOIN DEBUG - Invite Code: $inviteCode');

    try {
      await ref
          .read(groupControllerProvider.notifier)
          .joinGroup(inviteCode: inviteCode, userId: user.uid);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined group!')),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loading = ref.watch(groupControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Join Group')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              maxLength: 6,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              ],
              decoration: const InputDecoration(
                labelText: 'Invite Code',
                hintText: 'Enter 6-character code',
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _joinGroup,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Join Group'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
