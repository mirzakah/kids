import 'package:shared_preferences/shared_preferences.dart';

/// Klasa za praćenje napretka djeteta kroz module
/// Koristi SharedPreferences za lokalno spremanje podataka
class ProgressTracker {
  late SharedPreferences _prefs;

  // Ključevi za spremanje podataka
  static const String _keyPrefix = 'edukativna_igra_';

  /// Inicijalizacija progress trackera
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Sprema broj završenih nivoa za određeni modul
  Future<void> saveModuleProgress(
      String moduleId, int completedLevels, int totalLevels) async {
    await _prefs.setInt('${_keyPrefix}${moduleId}_completed', completedLevels);
    await _prefs.setInt('${_keyPrefix}${moduleId}_total', totalLevels);

    // Ako su svi nivoi završeni, označi modul kao završen
    if (completedLevels >= totalLevels) {
      await _prefs.setBool('${_keyPrefix}${moduleId}_finished', true);
    }
  }

  /// Dobiva broj završenih nivoa za modul
  int getCompletedLevels(String moduleId) {
    return _prefs.getInt('${_keyPrefix}${moduleId}_completed') ?? 0;
  }

  /// Dobiva ukupan broj nivoa za modul
  int getTotalLevels(String moduleId) {
    return _prefs.getInt('${_keyPrefix}${moduleId}_total') ?? 1;
  }

  /// Dobiva progres modula kao procenat (0.0 - 1.0)
  double getModuleProgress(String moduleId) {
    final completed = getCompletedLevels(moduleId);
    final total = getTotalLevels(moduleId);

    if (total == 0) return 0.0;
    return (completed / total).clamp(0.0, 1.0);
  }

  /// Provjerava je li modul završen
  bool isModuleCompleted(String moduleId) {
    return _prefs.getBool('${_keyPrefix}${moduleId}_finished') ?? false;
  }

  /// Označava modul kao završen
  Future<void> markModuleAsCompleted(String moduleId) async {
    await _prefs.setBool('${_keyPrefix}${moduleId}_finished', true);
  }

  /// Resetuje progres modula
  Future<void> resetModuleProgress(String moduleId) async {
    await _prefs.remove('${_keyPrefix}${moduleId}_completed');
    await _prefs.remove('${_keyPrefix}${moduleId}_total');
    await _prefs.remove('${_keyPrefix}${moduleId}_finished');
  }

  /// Resetuje sav progres
  Future<void> resetAllProgress() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Sprema highscore za modul
  Future<void> saveHighScore(String moduleId, int score) async {
    final currentHighScore = getHighScore(moduleId);
    if (score > currentHighScore) {
      await _prefs.setInt('${_keyPrefix}${moduleId}_highscore', score);
    }
  }

  /// Dobiva highscore za modul
  int getHighScore(String moduleId) {
    return _prefs.getInt('${_keyPrefix}${moduleId}_highscore') ?? 0;
  }

  /// Sprema vrijeme posljednje igre
  Future<void> saveLastPlayedTime(String moduleId) async {
    await _prefs.setInt(
      '${_keyPrefix}${moduleId}_last_played',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Dobiva vrijeme posljednje igre
  DateTime? getLastPlayedTime(String moduleId) {
    final timestamp = _prefs.getInt('${_keyPrefix}${moduleId}_last_played');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Sprema broj pokušaja za modul
  Future<void> incrementAttempts(String moduleId) async {
    final currentAttempts = getAttempts(moduleId);
    await _prefs.setInt(
        '${_keyPrefix}${moduleId}_attempts', currentAttempts + 1);
  }

  /// Dobiva broj pokušaja za modul
  int getAttempts(String moduleId) {
    return _prefs.getInt('${_keyPrefix}${moduleId}_attempts') ?? 0;
  }

  /// Dobiva statistiku za sve module
  Map<String, Map<String, dynamic>> getAllStats() {
    final modules = [
      'memory',
      'colors',
      'sounds',
      'counting',
      'matching',
      'missing'
    ];
    final stats = <String, Map<String, dynamic>>{};

    for (final module in modules) {
      stats[module] = {
        'completed': isModuleCompleted(module),
        'progress': getModuleProgress(module),
        'highScore': getHighScore(module),
        'attempts': getAttempts(module),
        'lastPlayed': getLastPlayedTime(module),
      };
    }

    return stats;
  }
}
