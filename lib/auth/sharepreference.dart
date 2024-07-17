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

  static Future<void> removeUserRole() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(userRoleKey);
  }
}