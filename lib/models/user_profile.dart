import 'package:flutter/foundation.dart';

class UserProfile extends ChangeNotifier {
  int _streak = 0;
  int _level = 1;
  int _xp = 0;
  int _totalTasksCompleted = 0;
  DateTime? _lastCompleted;
  int _currentEnergy = 100;
  String _motivationStyle = 'energetic';
  
  int get streak => _streak;
  int get level => _level;
  int get xp => _xp;
  int get totalTasksCompleted => _totalTasksCompleted;
  DateTime? get lastCompleted => _lastCompleted;
  int get currentEnergy => _currentEnergy;
  String get motivationStyle => _motivationStyle;
  
  void completeTask() {
    _totalTasksCompleted++;
    _xp += 10;
    _lastCompleted = DateTime.now();
    _streak++;
    notifyListeners();
  }
  
  void resetStreak() {
    _streak = 0;
    notifyListeners();
  }
}