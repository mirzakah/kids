import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class AudioHelper {
  static final AudioHelper _instance = AudioHelper._internal();
  factory AudioHelper() => _instance;
  AudioHelper._internal();

  // Odvojeni playeri za različite tipove audio sadržaja
  AudioPlayer? _soundEffectsPlayer;
  AudioPlayer? _backgroundMusicPlayer;

  // Queue sistem za sound effects
  final List<String> _soundQueue = [];
  bool _isProcessingQueue = false;

  // Kontrola background music
  bool _backgroundMusicPlaying = false;
  String? _currentBackgroundMusic;

  // Disposed state tracking
  bool _isDisposed = false;

  // Lazy initialization of players
  AudioPlayer get _soundPlayer {
    if (_soundEffectsPlayer == null || _isDisposed) {
      _soundEffectsPlayer = AudioPlayer();
    }
    return _soundEffectsPlayer!;
  }

  AudioPlayer get _musicPlayer {
    if (_backgroundMusicPlayer == null || _isDisposed) {
      _backgroundMusicPlayer = AudioPlayer();
    }
    return _backgroundMusicPlayer!;
  }

  /// Reprodukuje sound effect - čeka da se prethodni završi
  Future<void> playSound(String soundFile) async {
    if (_isDisposed) return;
    _soundQueue.add(soundFile);
    _processSoundQueue();
  }

  /// Reprodukuje sound effect odmah (prekida prethodni)
  Future<void> playSoundImmediate(String soundFile) async {
    if (_isDisposed) return;
    try {
      await _soundPlayer.stop();
      await _soundPlayer.play(AssetSource('audio/$soundFile'));
    } catch (e) {
      print('Greška pri reprodukovanju zvuka: $e');
    }
  }

  /// Procesira queue zvukova jedan po jedan
  Future<void> _processSoundQueue() async {
    if (_isProcessingQueue || _soundQueue.isEmpty || _isDisposed) return;

    _isProcessingQueue = true;

    while (_soundQueue.isNotEmpty && !_isDisposed) {
      final soundFile = _soundQueue.removeAt(0);
      await _playSingleSound(soundFile);
    }

    _isProcessingQueue = false;
  }

  /// Reprodukuje jedan zvuk i čeka da se završi
  Future<void> _playSingleSound(String soundFile) async {
    if (_isDisposed) return;

    try {
      // Kreiramo Completer koji će se kompletirati kada se zvuk završi
      final Completer<void> soundCompleter = Completer<void>();

      // Postavljamo listener samo jednom
      late StreamSubscription subscription;
      subscription = _soundPlayer.onPlayerStateChanged.listen((state) {
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          if (!soundCompleter.isCompleted) {
            soundCompleter.complete();
          }
          subscription.cancel(); // Importante: kancellujemo subscription
        }
      });

      // Reprodukujemo zvuk - PROMENJENA PUTANJA na 'audio/'
      await _soundPlayer.play(AssetSource('audio/$soundFile'));

      // Čekamo da se završi ili timeout nakon 10 sekundi
      await soundCompleter.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          subscription.cancel();
          if (!_isDisposed) {
            _soundPlayer.stop();
          }
        },
      );
    } catch (e) {
      print('Greška pri reprodukovanju zvuka: $e');
    }
  }

  /// Reprodukuje background music
  Future<void> playBackgroundMusic(String musicFile, {bool loop = true}) async {
    if (_isDisposed) return;

    try {
      // Ako je već ista muzika, ne radi ništa
      if (_backgroundMusicPlaying && _currentBackgroundMusic == musicFile) {
        return;
      }

      await _musicPlayer.stop();
      await _musicPlayer
          .setReleaseMode(loop ? ReleaseMode.loop : ReleaseMode.release);

      // PROMENJENA PUTANJA na 'audio/'
      await _musicPlayer.play(AssetSource('audio/$musicFile'));
      _backgroundMusicPlaying = true;
      _currentBackgroundMusic = musicFile;
    } catch (e) {
      print('Greška pri reprodukovanju background music: $e');
    }
  }

  /// Zaustavlja background music
  Future<void> stopBackgroundMusic() async {
    if (_isDisposed) return;

    try {
      await _musicPlayer.stop();
      _backgroundMusicPlaying = false;
      _currentBackgroundMusic = null;
    } catch (e) {
      print('Greška pri zaustavljanju background music: $e');
    }
  }

  /// Pauzira background music
  Future<void> pauseBackgroundMusic() async {
    if (_isDisposed) return;

    try {
      await _musicPlayer.pause();
    } catch (e) {
      print('Greška pri pauziranju background music: $e');
    }
  }

  /// Nastavlja background music
  Future<void> resumeBackgroundMusic() async {
    if (_isDisposed) return;

    try {
      await _musicPlayer.resume();
    } catch (e) {
      print('Greška pri nastavku background music: $e');
    }
  }

  /// Zaustavlja sve sound effects
  Future<void> stopAllSounds() async {
    if (_isDisposed) return;

    try {
      _soundQueue.clear();
      await _soundPlayer.stop();
      _isProcessingQueue = false;
    } catch (e) {
      print('Greška pri zaustavljanju svih zvukova: $e');
    }
  }

  /// Zaustavlja sve audio (i sound effects i background music)
  Future<void> stopAll() async {
    if (_isDisposed) return;

    await Future.wait([
      stopAllSounds(),
      stopBackgroundMusic(),
    ]);
  }

  /// Postavlja volume za sound effects (0.0 - 1.0)
  Future<void> setSoundEffectsVolume(double volume) async {
    if (_isDisposed) return;

    try {
      await _soundPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Greška pri podešavanju volume sound effects: $e');
    }
  }

  /// Postavlja volume za background music (0.0 - 1.0)
  Future<void> setBackgroundMusicVolume(double volume) async {
    if (_isDisposed) return;

    try {
      await _musicPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (e) {
      print('Greška pri podešavanju volume background music: $e');
    }
  }

  // Getteri za status
  bool get isSoundEffectPlaying =>
      !_isDisposed && (_isProcessingQueue || _soundQueue.isNotEmpty);
  bool get isBackgroundMusicPlaying => !_isDisposed && _backgroundMusicPlaying;
  int get soundQueueLength => _soundQueue.length;
  String? get currentBackgroundMusic => _currentBackgroundMusic;

  /// Reprodukuje listu zvukova u sekvenci
  Future<void> playSoundSequence(List<String> soundFiles) async {
    if (_isDisposed) return;

    for (final soundFile in soundFiles) {
      await playSound(soundFile);
    }
  }

  /// Reprodukuje zvuk sa delay-om
  Future<void> playSoundWithDelay(String soundFile, Duration delay) async {
    if (_isDisposed) return;

    await Future.delayed(delay);
    await playSound(soundFile);
  }

  /// ČISTI sve resurse - pozovi samo na kraju aplikacije
  void disposeAll() {
    _isDisposed = true;
    _soundQueue.clear();
    _isProcessingQueue = false;
    _backgroundMusicPlaying = false;
    _currentBackgroundMusic = null;

    _soundEffectsPlayer?.dispose();
    _backgroundMusicPlayer?.dispose();
    _soundEffectsPlayer = null;
    _backgroundMusicPlayer = null;
  }

  /// Reset playere bez dispose-a - za restart
  Future<void> resetPlayers() async {
    try {
      await stopAll();
      _isDisposed = false;
    } catch (e) {
      print('Greška pri reset playera: $e');
    }
  }
}
