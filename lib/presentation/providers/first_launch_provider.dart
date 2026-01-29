import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// First launch provider
final firstLaunchProvider = StateNotifierProvider<FirstLaunchNotifier, bool>((ref) {
  return FirstLaunchNotifier();
});

class FirstLaunchNotifier extends StateNotifier<bool> {
  FirstLaunchNotifier() : super(true) {
    _checkFirstLaunch();
  }

  Future<void> _checkFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
      state = isFirstLaunch;
    } catch (e) {
      state = true; // Default to true if there's an error
    }
  }

  Future<void> completeFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_launch', false);
      state = false;
    } catch (e) {
      // Continue even if saving fails
    }
  }
}
