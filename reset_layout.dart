// فقط یک بار اجرا کنید تا layout reset بشه
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('dashboard_layout');
  print('Layout cache cleared!');
}
