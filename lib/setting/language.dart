// import 'package:flutter/material.dart';

// class LanguageSettings extends StatefulWidget {
//   const LanguageSettings({super.key});

//   @override
//   LanguageSettingsState createState() => LanguageSettingsState();
// }

// class LanguageSettingsState extends State<LanguageSettings> {
//   String _selectedLanguage = 'English'; // Default language

//   // List of languages
//   final List<String> _languages = ['Burmese', 'English', 'Japanese', 'Bahasa'];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Language Settings'),
//       ),
//       body: ListView(
//         children: _languages.map((language) {
//           return ListTile(
//             title: Text(language),
//             leading: Radio<String>(
//               value: language,
//               groupValue: _selectedLanguage,
//               onChanged: (String? value) {
//                 setState(() {
//                   _selectedLanguage = value!;
//                 });
//                 // Save the selected language to user preferences or database
//               },
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }
import 'package:codehunt/main.dart';
import 'package:flutter/material.dart';


class LanguageSettings extends StatefulWidget {
  const LanguageSettings({super.key});

  @override
  _LanguageSettingsState createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  String _selectedLanguage = 'en'; // Default language

  // List of languages
  final Map<String, String> _languages = {
    'Burmese': 'my',
    'English': 'en',
    'Japanese': 'ja',
    'Bahasa': 'id'
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
      ),
      body: ListView(
        children: _languages.entries.map((entry) {
          return ListTile(
            title: Text(entry.key),
            leading: Radio<String>(
              value: entry.value,
              groupValue: _selectedLanguage,
              onChanged: (String? value) {
                setState(() {
                  _selectedLanguage = value!;
                  // Update language preference
                  // For example, use shared_preferences to save the language
                });

                // Reload the app to apply language changes
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyApp(), // Restart the app
                  ),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
