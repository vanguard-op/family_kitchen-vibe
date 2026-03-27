import 'package:flutter/material.dart';

/// Member management screen
class MemberManagementScreen extends StatefulWidget {
  const MemberManagementScreen({Key? key}) : super(key: key);

  @override
  State<MemberManagementScreen> createState() => _MemberManagementScreenState();
}

class _MemberManagementScreenState extends State<MemberManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Members'),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 3,
        itemBuilder: (context, index) {
          final roles = ['King', 'Chef', 'Prince'];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text('Member ${index + 1}'),
              subtitle: Text(roles[index]),
              trailing: PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'change_role',
                    child: Text('Change Role'),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text('Remove'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
