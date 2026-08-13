import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:remind_circle/features/groups/presentation/screens/create_group_screen.dart';
import 'package:remind_circle/features/home/presentation/providers/my_groups_provider.dart';

import 'package:remind_circle/features/groups/presentation/screens/join_group_screen.dart';

//import 'package:remind_circle/features/groups/presentation/screens/group_details_screen.dart';

import 'package:remind_circle/core/providers/auth_provider.dart';
import 'package:remind_circle/features/auth/presentation/providers/auth_controller.dart';

import 'package:remind_circle/features/home/presentation/widgets/greeting_section.dart';
import 'package:remind_circle/features/home/presentation/widgets/groups_section.dart';

import 'package:remind_circle/features/home/presentation/widgets/upcoming_events_section.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider)!;
    final groups = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('RemindCircle'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value != 'signOut') return;

              final shouldSignOut = await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  );
                },
              );

              if (shouldSignOut != true) return;

              await ref.read(authControllerProvider.notifier).signOut();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'signOut', child: Text('Sign Out')),
            ],
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'join',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
              );
            },
            child: const Icon(Icons.group_add),
          ),

          const SizedBox(height: 16),

          FloatingActionButton(
            heroTag: 'create',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: groups.when(
          data: (list) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GreetingSection(user: user),

                  const SizedBox(height: 32),

                  const UpcomingEventsSection(),

                  const SizedBox(height: 32),

                  GroupsSection(groups: list),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
