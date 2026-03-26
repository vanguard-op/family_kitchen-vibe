import 'package:flutter/material.dart';

/// Kingdom setup screen
class KingdomSetupScreen extends StatefulWidget {
  const KingdomSetupScreen({Key? key}) : super(key: key);

  @override
  State<KingdomSetupScreen> createState() => _KingdomSetupScreenState();
}

class _KingdomSetupScreenState extends State<KingdomSetupScreen> {
  String _mode = 'solo';
  late TextEditingController _kingdomNameController;

  @override
  void initState() {
    super.initState();
    _kingdomNameController = TextEditingController();
  }

  @override
  void dispose() {
    _kingdomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Kingdom'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Mode',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            RadioListTile<String>(
              title: const Text('Solo'),
              subtitle: const Text('Just me'),
              value: 'solo',
              groupValue: _mode,
              onChanged: (value) {
                setState(() => _mode = value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Family'),
              subtitle: const Text('Multiple household members'),
              value: 'family',
              groupValue: _mode,
              onChanged: (value) {
                setState(() => _mode = value!);
              },
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _kingdomNameController,
              decoration: InputDecoration(
                labelText: 'Kingdom Name',
                hintText: 'My Kitchen',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/allergy-setup');
                },
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
