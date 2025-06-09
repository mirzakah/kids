import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class CountingGameScreen extends StatefulWidget {
  final int level;

  const CountingGameScreen({super.key, required this.level});

  @override
  State<CountingGameScreen> createState() => _CountingGameScreenState();
}

class _CountingGameScreenState extends State<CountingGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();
  final Random _random = Random();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _starController;
  late AnimationController _correctAnswerController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _starAnimation;

  // Vrste objekata za brojanje
  final List<CountingObject> _objectTypes = [
    CountingObject(
      type: 'apple',
      imagePath: 'assets/images/objects/apple.jpeg',
      color: Colors.red.shade300,
    ),
    CountingObject(
      type: 'star',
      imagePath: 'assets/images/objects/star.jpeg',
      color: Colors.yellow.shade600,
    ),
    CountingObject(
      type: 'flower',
      imagePath: 'assets/images/objects/flower.jpeg',
      color: Colors.pink.shade300,
    ),
    CountingObject(
      type: 'ball',
      imagePath: 'assets/images/objects/ball.jpeg',
      color: Colors.blue.shade400,
    ),
    CountingObject(
      type: 'heart',
      imagePath: 'assets/images/objects/heart.jpeg',
      color: Colors.purple.shade400,
    ),
    CountingObject(
      type: 'butterfly',
      imagePath: 'assets/images/objects/butterfly.jpeg',
      color: Colors.orange.shade400,
    ),
    CountingObject(
      type: 'diamond',
      imagePath: 'assets/images/objects/diamond.jpeg',
      color: Colors.cyan.shade400,
    ),
  ];

  CountingObject? _currentObject;
  int _correctCount = 0;
  List<int> _options = [];
  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  int _maxCount = 3;
  int _optionsCount = 3;
  bool _isWaitingForAnswer = false;
  bool _showStars = false;
  bool _gameCompleted = false;
  List<Offset> _objectPositions = [];

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
    _starController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _correctAnswerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
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

    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.easeOut,
    ));
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic(
      'counting_background.mp3', // Dodajte ovaj fajl u assets/audio/
      loop: true,
    );

    // Postavite volume nivoe
    _audioHelper.setBackgroundMusicVolume(0.25); // Malo glasnija od sounds
    _audioHelper.setSoundEffectsVolume(0.85); // Malo tiši sound effects
  }

  void _initializeGame() {
    // Konfiguriši igru na osnovu levela
    switch (widget.level) {
      case 1:
        _maxCount = 3; // Broji do 3
        _totalRounds = 6;
        _optionsCount = 3;
        break;
      case 2:
        _maxCount = 5; // Broji do 5
        _totalRounds = 8;
        _optionsCount = 4;
        break;
      case 3:
        _maxCount = 7; // Broji do 7
        _totalRounds = 10;
        _optionsCount = 5;
        break;
      default:
        _maxCount = 3;
        _totalRounds = 6;
        _optionsCount = 3;
    }

    _score = 0;
    _currentRound = 0;
    _gameCompleted = false;
    _startNewRound();
  }

  List<Offset> _generateNonOverlappingPositions(int count) {
    final positions = <Offset>[];
    const minDistance = 0.15; // Minimalna udaljenost između objekata
    const maxAttempts = 100;

    for (int i = 0; i < count; i++) {
      bool validPosition = false;
      int attempts = 0;

      while (!validPosition && attempts < maxAttempts) {
        final newPosition = Offset(
          _random.nextDouble() * 0.7 + 0.15,
          _random.nextDouble() * 0.7 + 0.15,
        );

        // Provjeri da li je nova pozicija dovoljno udaljena od postojećih
        validPosition = true;
        for (final existingPos in positions) {
          final distance = (newPosition - existingPos).distance;
          if (distance < minDistance) {
            validPosition = false;
            break;
          }
        }

        if (validPosition) {
          positions.add(newPosition);
        }
        attempts++;
      }

      // Ako ne možemo naći validnu poziciju, dodaj je na grid
      if (!validPosition) {
        final gridX = (i % 3) * 0.25 + 0.2;
        final gridY = (i ~/ 3) * 0.25 + 0.2;
        positions.add(Offset(gridX, gridY));
      }
    }

    return positions;
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
      _currentObject = _objectTypes[_random.nextInt(_objectTypes.length)];
      _correctCount = _random.nextInt(_maxCount) + 1; // 1 do _maxCount objekata

      // Generiši pozicije objekata bez preklapanja
      _objectPositions = _generateNonOverlappingPositions(_correctCount);

      // Generiši opcije
      _options = [_correctCount];
      while (_options.length < _optionsCount) {
        final option = _random.nextInt(_maxCount) + 1;
        if (!_options.contains(option)) {
          _options.add(option);
        }
      }
      _options.shuffle();
    });

    // Uvodni zvuk i instrukcija
    await _audioHelper.playSoundSequence([
      'brojanje_instrukcija.mp3', // "Prebroj objekte i odaberi tačan broj"
    ]);

    await Future.delayed(const Duration(milliseconds: 800));
    await _audioHelper.playSound('koliko_ima.mp3');
  }

  void _checkAnswer(int selected) async {
    if (!_isWaitingForAnswer || _gameCompleted) return;

    _isWaitingForAnswer = false;

    if (selected == _correctCount) {
      // Tačan odgovor
      await _audioHelper.playSoundSequence([
        'counting_correct.mp3', // Novi zvuk za tačan odgovor u brojanju
        'bravo.mp3',
      ]);

      // Animacija zvjezdica
      setState(() {
        _showStars = true;
      });
      _starController.forward().then((_) {
        _starController.reset();
        setState(() {
          _showStars = false;
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
        'counting_wrong.mp3', // Kratka "buzz" melodija za pogrešan odgovor
        'pokusaj_ponovo.mp3',
      ]);

      await Future.delayed(const Duration(milliseconds: 1000));

      setState(() {
        _isWaitingForAnswer = true;
      });
    }
  }

  void _showWinDialog() async {
    // Spremamo napredak
    await _progressTracker.saveModuleProgress('counting', widget.level, 3);
    await _progressTracker.saveHighScore('counting', _score);
    await _progressTracker.incrementAttempts('counting');

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
        backgroundColor: Colors.teal.shade50,
        title: Text(
          _getWinTitle(),
          style: const TextStyle(fontSize: 28, color: Colors.teal),
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
                color: Colors.teal.shade600,
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
                context.go('/counting?level=${widget.level + 1}');
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
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Koliko ima? - Level ${widget.level}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () async {
            await _audioHelper.stopBackgroundMusic();
            if (context.mounted) {
              context.go('/counting-levels');
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
                  Colors.teal.shade100,
                  Colors.teal.shade50,
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
                            'Bodovi', _score.toString(), Colors.teal),
                        _buildInfoCard('Runda',
                            '$_currentRound / $_totalRounds', Colors.orange),
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

                  // Oblast za prikaz objekata
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Prikaži objekte
                          if (_currentObject != null)
                            ...List.generate(_correctCount, (index) {
                              final position = _objectPositions[index];
                              return Positioned(
                                left: position.dx * (screenSize.width - 120),
                                top: position.dy * 200,
                                child: ScaleTransition(
                                  scale: _bounceAnimation,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: _currentObject!.color
                                          .withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Icon(
                                        _getIconForObject(_currentObject!.type),
                                        size: 40,
                                        color: _currentObject!.color,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                        ],
                      ),
                    ),
                  ),

                  // Opcije brojeva
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(sin(_shakeAnimation.value) * 2, 0),
                          child: Wrap(
                            alignment: WrapAlignment.spaceEvenly,
                            spacing: 15,
                            runSpacing: 15,
                            children: _options.map((number) {
                              return _buildNumberOption(number);
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Animacija zvjezdica
          if (_showStars)
            AnimatedBuilder(
              animation: _starAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarsPainter(_starAnimation.value),
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

  Widget _buildNumberOption(int number) {
    return Material(
      elevation: 5,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: () => _checkAnswer(number),
        customBorder: const CircleBorder(),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.teal.shade400,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForObject(String type) {
    switch (type) {
      case 'apple':
        return Icons.apple;
      case 'star':
        return Icons.star;
      case 'flower':
        return Icons.local_florist;
      case 'ball':
        return Icons.sports_soccer;
      case 'heart':
        return Icons.favorite;
      case 'butterfly':
        return Icons.flutter_dash;
      case 'diamond':
        return Icons.diamond;
      default:
        return Icons.circle;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _starController.dispose();
    _correctAnswerController.dispose();

    // VAŽNO: Ne dispose-uj AudioHelper jer je singleton!
    // Samo zaustavi background muziku za ovaj ekran
    _audioHelper.stopBackgroundMusic();

    super.dispose();
  }
}

// Model za objekte brojanja
class CountingObject {
  final String type;
  final String imagePath;
  final Color color;

  const CountingObject({
    required this.type,
    required this.imagePath,
    required this.color,
  });
}

// Painter za zvjezdice
class StarsPainter extends CustomPainter {
  final double progress;
  final Random random = Random(42); // Fixed seed za konzistentnost

  StarsPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -50.0;
      final endY = size.height + 50;
      final y = startY + (endY - startY) * progress;

      paint.color = Colors.amber.withOpacity(1 - progress);

      // Nacrtaj zvjezdicu
      final path = Path();
      const radius = 15.0;
      for (int j = 0; j < 5; j++) {
        final angle = (j * 144 - 90) * pi / 180;
        final x1 = x + radius * cos(angle);
        final y1 = y + radius * sin(angle);
        if (j == 0) {
          path.moveTo(x1, y1);
        } else {
          path.lineTo(x1, y1);
        }
      }
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
