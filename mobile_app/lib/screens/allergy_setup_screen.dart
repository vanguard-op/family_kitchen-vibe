import 'package:flutter/material.dart';

/// Allergy setup screen
class AllergySetupScreen extends StatefulWidget {
  const AllergySetupScreen({Key? key}) : super(key: key);

  @override
  State<AllergySetupScreen> createState() => _AllergySetupScreenState();
}

class _AllergySetupScreenState extends State<AllergySetupScreen> {
  final List<String> _commonAllergens = [
    'Nuts',
    'Shellfish',
    'Dairy',
    'Gluten',
    'Eggs',
    'Soy',
    'Sesame',
  ];
  final Set<String> _selectedAllergens = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Allergies'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Select any allergies for your household',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ..._commonAllergens.map((allergen) {
            return CheckboxListTile(
              title: Text(allergen),
              value: _selectedAllergens.contains(allergen),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    _selectedAllergens.add(allergen);
                  } else {
                    _selectedAllergens.remove(allergen);
                  }
                });
              },
            );
          }),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/home');
              },
              child: const Text('Complete Setup'),
            ),
          ),
        ],
      ),
    );
  }
}
