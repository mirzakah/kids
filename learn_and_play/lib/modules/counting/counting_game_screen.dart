import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class CountingGameScreen extends StatefulWidget {
  const CountingGameScreen({super.key});

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
  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _starAnimation;

  // Vrste objekata za brojanje
  final List<CountingObject> _objectTypes = [
    CountingObject(
      type: 'apple',
      imagePath: 'assets/images/apple.png',
      color: Colors.red.shade300,
    ),
    CountingObject(
      type: 'star',
      imagePath: 'assets/images/star.png',
      color: Colors.yellow.shade600,
    ),
    CountingObject(
      type: 'flower',
      imagePath: 'assets/images/flower.png',
      color: Colors.pink.shade300,
    ),
    CountingObject(
      type: 'ball',
      imagePath: 'assets/images/ball.png',
      color: Colors.blue.shade400,
    ),
  ];

  CountingObject? _currentObject;
  int _correctCount = 0;
  List<int> _options = [];
  int _score = 0;
  int _rounds = 0;
  bool _isWaitingForAnswer = false;
  bool _showStars = false;
  List<Offset> _objectPositions = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _progressTracker.init().then((_) {
      _startNewRound();
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

  List<Offset> _generateNonOverlappingPositions(int count) {
    final positions = <Offset>[];
    const minDistance = 0.2; // Minimalna udaljenost između objekata
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
        final gridX = (i % 3) * 0.3 + 0.2;
        final gridY = (i ~/ 3) * 0.3 + 0.2;
        positions.add(Offset(gridX, gridY));
      }
    }

    return positions;
  }

  void _startNewRound() async {
    if (_rounds >= 5) {
      _showResultDialog();
      return;
    }

    setState(() {
      _isWaitingForAnswer = true;
      _currentObject = _objectTypes[_random.nextInt(_objectTypes.length)];
      _correctCount = _random.nextInt(5) + 1; // 1-5 objekata

      // Generiši pozicije objekata bez preklapanja
      _objectPositions = _generateNonOverlappingPositions(_correctCount);

      // Generiši opcije
      _options = [_correctCount];
      while (_options.length < 3) {
        final option = _random.nextInt(5) + 1;
        if (!_options.contains(option)) {
          _options.add(option);
        }
      }
      _options.shuffle();
    });

    // Pusti zvuk pitanja
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioHelper.playSound('koliko_ima.mp3');
  }

  void _checkAnswer(int selected) async {
    if (!_isWaitingForAnswer) return;

    _isWaitingForAnswer = false;

    if (selected == _correctCount) {
      // Tačan odgovor
      await _audioHelper.playSound('bravo.mp3');

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
        _score += 10;
        _rounds++;
      });

      _startNewRound();
    } else {
      // Netačan odgovor
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      await _audioHelper.playSound('pokusaj_ponovo.mp3');
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isWaitingForAnswer = true;
      });
    }
  }

  void _showResultDialog() async {
    // Spremi napredak
    await _progressTracker.saveModuleProgress('counting', _rounds, 5);
    await _progressTracker.saveHighScore('counting', _score);
    await _progressTracker.incrementAttempts('counting');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.teal.shade50,
        title: Text(
          _score >= 40 ? 'Odlično! 🌟' : 'Dobro! 👏',
          style: TextStyle(fontSize: 28, color: Colors.teal.shade700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _score >= 40 ? Icons.star : Icons.thumb_up,
              size: 80,
              color: _score >= 40 ? Colors.amber : Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'Osvojili ste $_score bodova!',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _score = 0;
                _rounds = 0;
                _startNewRound();
              });
            },
            child: const Text('Nova igra', style: TextStyle(fontSize: 18)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Početni ekran', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Koliko ima?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal.shade300,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () => context.go('/'),
        ),
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
                  // Bodovi i runde
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoCard(
                            'Bodovi', _score.toString(), Colors.teal),
                        _buildInfoCard('Runda', '$_rounds / 5', Colors.orange),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
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
      default:
        return Icons.circle;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _starController.dispose();
    _audioHelper.dispose();
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
  final Random random = Random();

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
