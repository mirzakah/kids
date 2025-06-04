import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AudioHelper {
  static final AudioHelper _instance = AudioHelper._internal();
  factory AudioHelper() => _instance;
  AudioHelper._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Completer<void>? _currentSoundCompleter;

  Future<void> playSound(String soundFile) async {
    try {
      // Čekamo da se trenutni zvuk završi
      if (_isPlaying && _currentSoundCompleter != null) {
        await _currentSoundCompleter!.future;
      }

      // Zaustavljamo prethodni zvuk ako je još uvijek aktivan
      await _audioPlayer.stop();

      _isPlaying = true;
      _currentSoundCompleter = Completer<void>();

      // Postavljamo listener za završetak zvuka
      StreamSubscription? subscription;
      subscription = _audioPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          _isPlaying = false;
          if (_currentSoundCompleter != null &&
              !_currentSoundCompleter!.isCompleted) {
            _currentSoundCompleter!.complete();
          }
          subscription?.cancel();
        }
      });

      // Reprodukujemo zvuk
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));

      // Čekamo da se zvuk završi
      await _currentSoundCompleter!.future;
    } catch (e) {
      print('Greška pri reprodukovanju zvuka: $e');
      _isPlaying = false;
      if (_currentSoundCompleter != null &&
          !_currentSoundCompleter!.isCompleted) {
        _currentSoundCompleter!.complete();
      }
    }
  }

  Future<void> playBackgroundMusic(String musicFile, {bool loop = true}) async {
    try {
      await _audioPlayer
          .setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);
      await _audioPlayer.play(AssetSource('sounds/$musicFile'));
    } catch (e) {
      print('Greška pri reprodukovanju muzike: $e');
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      if (_currentSoundCompleter != null &&
          !_currentSoundCompleter!.isCompleted) {
        _currentSoundCompleter!.complete();
      }
    } catch (e) {
      print('Greška pri zaustavljanju zvuka: $e');
    }
  }

  Future<void> pauseSound() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print('Greška pri pauziranju zvuka: $e');
    }
  }

  Future<void> resumeSound() async {
    try {
      await _audioPlayer.resume();
    } catch (e) {
      print('Greška pri nastavku zvuka: $e');
    }
  }

  bool get isPlaying => _isPlaying;

  void dispose() {
    _audioPlayer.dispose();
  }
}
