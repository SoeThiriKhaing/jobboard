import 'package:codehunt/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharePreferenceService {
  static const String userRoleKey = 'USERROLE';

  static Future<void> saveUserRole(String role) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString(userRoleKey, role);
  }

  static Future<String?> getUseRole() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    final userRole = pref.getString(userRoleKey);
    return userRole;
  }

  static Future<LoginForm> removeUserRole() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(userRoleKey);
    return const LoginForm();
  }
  Future<void> _setLanguage(String languageCode) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('language_code', languageCode);
}

Future<String?> _getLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('language_code');
}
}
