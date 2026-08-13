import 'package:flutter/material.dart';
import 'package:remind_circle/features/groups/domain/models/group.dart';
import 'package:remind_circle/features/groups/presentation/screens/group_details_screen.dart';

class GroupsSection extends StatelessWidget {
  final List<Group> groups;

  const GroupsSection({
    super.key,
    required this.groups,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Groups',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        if (groups.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'No groups yet.\nTap + to create one.',
                textAlign: TextAlign.center,
              ),
            ),
          )
        else
          ListView.builder(
            itemCount: groups.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, index) {
              final group = groups[index];

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.groups),
                  ),
                  title: Text(group.name),
                  subtitle: Text(
                    'Invite Code: ${group.inviteCode}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            GroupDetailsScreen(group: group),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
