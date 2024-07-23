// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// class AppLocalizations {
//   // Placeholder for your localization logic
//   static const LocalizationsDelegate<AppLocalizations> delegate =
//       _AppLocalizationsDelegate();

//   static AppLocalizations of(BuildContext context) {
//     return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
//   }

//   // Add your localized strings here
//   String get hello => 'Hello'; // Example string
// }

// class _AppLocalizationsDelegate
//     extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();

//   @override
//   bool isSupported(Locale locale) {
//     return ['en', 'ja', 'my', 'id'].contains(locale.languageCode);
//   }

//   @override
//   Future<AppLocalizations> load(Locale locale) {
//     return SynchronousFuture<AppLocalizations>(AppLocalizations());
//   }

//   @override
//   bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
//     return false;
//   }
// }
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';

// // Add your localized strings here
// class AppLocalizations {
//   static const LocalizationsDelegate<AppLocalizations> delegate =
//       _AppLocalizationsDelegate();

//   String get hello => 'Hello'; // Example string

//   static AppLocalizations of(BuildContext context) {
//     return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
//   }
// }

// class _AppLocalizationsDelegate
//     extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();

//   @override
//   bool isSupported(Locale locale) {
//     return ['en', 'ja', 'my', 'id'].contains(locale.languageCode);
//   }

//   @override
//   Future<AppLocalizations> load(Locale locale) {
//     return SynchronousFuture<AppLocalizations>(AppLocalizations());
//   }

//   @override
//   bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
//     return false;
//   }
// }
