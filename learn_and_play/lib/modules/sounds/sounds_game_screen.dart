import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_models.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class SoundsGameScreen extends StatefulWidget {
  final int level;

  const SoundsGameScreen({super.key, required this.level});

  @override
  State<SoundsGameScreen> createState() => _SoundsGameScreenState();
}

class _SoundsGameScreenState extends State<SoundsGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _confettiController;
  late AnimationController _correctAnswerController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _confettiAnimation;

  // Lista svih životinja sa zvukovima
  final List<AnimalSound> _allAnimals = [
    const AnimalSound(
      id: 'dog',
      name: 'Pas',
      imagePath: 'assets/images/animals/dog.png',
      soundPath: 'pas_laje.wav',
    ),
    const AnimalSound(
      id: 'cat',
      name: 'Mačka',
      imagePath: 'assets/images/animals/cat.png',
      soundPath: 'macka_mjauce.wav',
    ),
    const AnimalSound(
      id: 'cow',
      name: 'Krava',
      imagePath: 'assets/images/animals/cow.png',
      soundPath: 'krava_muče.wav',
    ),
    const AnimalSound(
      id: 'bird',
      name: 'Ptica',
      imagePath: 'assets/images/animals/bird.png',
      soundPath: 'ptica_pjeva.wav',
    ),
    const AnimalSound(
      id: 'sheep',
      name: 'Ovca',
      imagePath: 'assets/images/animals/sheep.png',
      soundPath: 'ovca_bleje.wav',
    ),
    const AnimalSound(
      id: 'horse',
      name: 'Konj',
      imagePath: 'assets/images/animals/horse.png',
      soundPath: 'konj_rzanje.wav',
    ),
    const AnimalSound(
      id: 'pig',
      name: 'Svinja',
      imagePath: 'assets/images/animals/pig.png',
      soundPath: 'svinja_grokce.wav',
    ),
    const AnimalSound(
      id: 'duck',
      name: 'Patka',
      imagePath: 'assets/images/animals/duck.png',
      soundPath: 'patka_kvace.wav',
    ),
  ];

  List<AnimalSound> _animals = [];
  AnimalSound? _currentAnimal;
  List<AnimalSound> _options = [];
  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  int _optionsCount = 3;
  bool _isWaitingForAnswer = false;
  bool _showConfetti = false;
  bool _gameCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _progressTracker.init().then((_) {
      _initializeGame();
      _startBackgroundMusic();
    });
  }

  void _initializeAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _correctAnswerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeInOut,
    ));
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic(
      'sounds_background.mp3', // Dodajte ovaj fajl u assets/audio/
      loop: true,
    );

    // Postavite volume nivoe
    _audioHelper.setBackgroundMusicVolume(0.2); // Još tiša background muzika
    _audioHelper.setSoundEffectsVolume(0.9); // Glasniji sound effects
  }

  void _initializeGame() {
    // Konfiguriši igru na osnovu levela
    switch (widget.level) {
      case 1:
        _animals = _allAnimals.take(3).toList(); // 3 životinje
        _totalRounds = 5;
        _optionsCount = 3;
        break;
      case 2:
        _animals = _allAnimals.take(5).toList(); // 5 životinja
        _totalRounds = 7;
        _optionsCount = 4;
        break;
      case 3:
        _animals = _allAnimals.take(7).toList(); // 7 životinja
        _totalRounds = 10;
        _optionsCount = 5;
        break;
      default:
        _animals = _allAnimals.take(3).toList();
        _totalRounds = 5;
        _optionsCount = 3;
    }

    _score = 0;
    _currentRound = 0;
    _gameCompleted = false;
    _startNewRound();
  }

  void _startNewRound() async {
    if (_currentRound >= _totalRounds) {
      _gameCompleted = true;
      await Future.delayed(const Duration(milliseconds: 500));
      _showWinDialog();
      return;
    }

    setState(() {
      _isWaitingForAnswer = true;
      _currentRound++;
      _currentAnimal = _animals[Random().nextInt(_animals.length)];

      // Generiši opcije (uključujući tačan odgovor)
      _options = [_currentAnimal!];
      while (_options.length < _optionsCount &&
          _options.length < _animals.length) {
        final randomAnimal = _animals[Random().nextInt(_animals.length)];
        if (!_options.any((a) => a.id == randomAnimal.id)) {
          _options.add(randomAnimal);
        }
      }
      _options.shuffle();
    });

    // Uvodni zvuk i instrukcija
    await _audioHelper.playSoundSequence([
      'poslusaj_i_odaberi.mp3', // "Poslušaj zvuk i odaberi životinja"
    ]);

    // Pusti zvuk životinje nakon kratke pauze
    await Future.delayed(const Duration(milliseconds: 800));
    await _audioHelper.playSound(_currentAnimal!.soundPath);
  }

  void _checkAnswer(AnimalSound selected) async {
    if (!_isWaitingForAnswer || _gameCompleted) return;

    _isWaitingForAnswer = false;

    if (selected.id == _currentAnimal!.id) {
      // Tačan odgovor
      await _audioHelper.playSoundSequence([
        'correct_sound.mp3', // Novi zvuk za tačan odgovor
        'bravo.mp3',
      ]);

      // Animacija konfeta
      setState(() {
        _showConfetti = true;
      });
      _confettiController.forward().then((_) {
        _confettiController.reset();
        setState(() {
          _showConfetti = false;
        });
      });

      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });

      setState(() {
        _score += (10 * widget.level); // Više bodova za teži level
      });

      await Future.delayed(const Duration(milliseconds: 1500));
      _startNewRound();
    } else {
      // Netačan odgovor
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      await _audioHelper.playSoundSequence([
        'wrong_sound.mp3', // Kratka "buzz" melodija
        'pokusaj_ponovo.mp3',
      ]);

      await Future.delayed(const Duration(milliseconds: 1000));

      // Ponovi zvuk
      await _audioHelper.playSound(_currentAnimal!.soundPath);
      setState(() {
        _isWaitingForAnswer = true;
      });
    }
  }

  void _replayCurrentSound() async {
    if (_currentAnimal != null && !_gameCompleted) {
      await _audioHelper.playSound(_currentAnimal!.soundPath);
      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });
    }
  }

  void _showWinDialog() async {
    // Spremamo napredak
    await _progressTracker.saveModuleProgress('sounds', widget.level, 3);
    await _progressTracker.saveHighScore('sounds', _score);
    await _progressTracker.incrementAttempts('sounds');

    // Triumfalna sekvenca zvukova
    await _audioHelper.playSoundSequence([
      'game_complete.mp3',
      'bravo.mp3',
    ]);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.green.shade50,
        title: Text(
          _getWinTitle(),
          style: const TextStyle(fontSize: 28, color: Colors.green),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getWinIcon(),
              size: 80,
              color: Colors.amber,
            ),
            const SizedBox(height: 20),
            Text(
              'Osvojili ste $_score bodova!',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Level ${widget.level} završen!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            // Audio kontrole u win dialog
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    await _audioHelper.pauseBackgroundMusic();
                  },
                  icon: const Icon(Icons.pause, size: 30),
                  tooltip: 'Pauziraj muziku',
                ),
                IconButton(
                  onPressed: () async {
                    await _audioHelper.resumeBackgroundMusic();
                  },
                  icon: const Icon(Icons.play_arrow, size: 30),
                  tooltip: 'Nastavi muziku',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _initializeGame();
              });
            },
            child: const Text(
              'Nova igra',
              style: TextStyle(fontSize: 18),
            ),
          ),
          if (widget.level < 3)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/sounds?level=${widget.level + 1}');
              },
              child: const Text(
                'Sljedeći level',
                style: TextStyle(fontSize: 18),
              ),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text(
              'Početni ekran',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  String _getWinTitle() {
    final maxScore = _totalRounds * 10 * widget.level;
    if (_score >= maxScore * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    final maxScore = _totalRounds * 10 * widget.level;
    if (_score >= maxScore * 0.8) {
      return Icons.star;
    } else if (_score >= maxScore * 0.6) {
      return Icons.thumb_up;
    } else {
      return Icons.emoji_emotions;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ko to govori? - Level ${widget.level}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade300,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () async {
            await _audioHelper.stopBackgroundMusic();
            if (context.mounted) {
              context.go('/sounds-levels');
            }
          },
        ),
        // Audio kontrole u AppBar
        actions: [
          IconButton(
            onPressed: () async {
              if (_audioHelper.isBackgroundMusicPlaying) {
                await _audioHelper.pauseBackgroundMusic();
              } else {
                await _audioHelper.resumeBackgroundMusic();
              }
              setState(() {});
            },
            icon: Icon(
              _audioHelper.isBackgroundMusicPlaying
                  ? Icons.volume_up
                  : Icons.volume_off,
              size: 30,
            ),
            tooltip: 'Uključi/isključi muziku',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.green.shade100,
                  Colors.green.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Info panel
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                            'Bodovi', _score.toString(), Colors.green),
                        _buildInfoCard('Runda',
                            '$_currentRound / $_totalRounds', Colors.blue),
                        _buildInfoCard(
                            'Level', widget.level.toString(), Colors.purple),
                      ],
                    ),
                  ),

                  // Audio status indicator
                  if (_audioHelper.isSoundEffectPlaying)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.volume_up,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 5),
                          Text(
                            'Reprodukuje se zvuk (${_audioHelper.soundQueueLength} u redu)',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),

                  // Dugme za ponovno slušanje
                  ScaleTransition(
                    scale: _bounceAnimation,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: IconButton(
                        iconSize: 60,
                        icon: const Icon(Icons.volume_up_rounded),
                        color: Colors.green.shade600,
                        onPressed: _replayCurrentSound,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Opcije
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(sin(_shakeAnimation.value) * 2, 0),
                          child: GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: widget.level == 3
                                  ? 3
                                  : 3, // Možete prilagoditi layout
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                            itemCount: _options.length,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return _buildAnimalOption(_options[index]);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konfeti
          if (_showConfetti)
            AnimatedBuilder(
              animation: _confettiAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(_confettiAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalOption(AnimalSound animal) {
    return Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => _checkAnswer(animal),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Image.asset(
                  animal.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.pets,
                      size: 50,
                      color: Colors.green.shade300,
                    );
                  },
                ),
              ),
              const SizedBox(height: 5),
              Text(
                animal.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    _correctAnswerController.dispose();

    // VAŽNO: Ne dispose-uj AudioHelper jer je singleton!
    // Samo zaustavi background muziku za ovaj ekran
    _audioHelper.stopBackgroundMusic();

    super.dispose();
  }
}

// ConfettiPainter klasa za animaciju konfeta
class ConfettiPainter extends CustomPainter {
  final double animationProgress;

  ConfettiPainter(this.animationProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random(42); // Fixed seed za konzistentnost

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * animationProgress;
      final color =
          [Colors.red, Colors.blue, Colors.yellow, Colors.green][i % 4];

      paint.color = color;
      canvas.drawCircle(Offset(x, y), 3, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
