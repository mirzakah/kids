import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class MissingGameScreen extends StatefulWidget {
  const MissingGameScreen({super.key});

  @override
  State<MissingGameScreen> createState() => _MissingGameScreenState();
}

class _MissingGameScreenState extends State<MissingGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _revealController;
  late AnimationController _starController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _starAnimation;

  // Lista zadataka sa nedostajućim elementima
  final List<MissingPuzzle> _allPuzzles = [
    MissingPuzzle(
      id: 'face_mouth',
      mainImage: 'assets/images/face_no_mouth.png',
      missingPart: 'mouth',
      missingPartName: 'usta',
      missingPartImage: 'assets/images/mouth.png',
      options: [
        MissingOption(
            id: 'mouth', image: 'assets/images/mouth.png', name: 'Usta'),
        MissingOption(id: 'nose', image: 'assets/images/nose.png', name: 'Nos'),
        MissingOption(id: 'eye', image: 'assets/images/eye.png', name: 'Oko'),
      ],
      soundPath: 'nedostaju_usta.mp3',
    ),
    MissingPuzzle(
      id: 'car_wheel',
      mainImage: 'assets/images/car_no_wheel.png',
      missingPart: 'wheel',
      missingPartName: 'točak',
      missingPartImage: 'assets/images/wheel.png',
      options: [
        MissingOption(
            id: 'wheel', image: 'assets/images/wheel.png', name: 'Točak'),
        MissingOption(
            id: 'steering', image: 'assets/images/steering.png', name: 'Volan'),
        MissingOption(
            id: 'door', image: 'assets/images/door.png', name: 'Vrata'),
      ],
      soundPath: 'nedostaje_tocak.mp3',
    ),
    MissingPuzzle(
      id: 'cake_candle',
      mainImage: 'assets/images/cake_no_candle.png',
      missingPart: 'candle',
      missingPartName: 'svijeća',
      missingPartImage: 'assets/images/candle.png',
      options: [
        MissingOption(
            id: 'candle', image: 'assets/images/candle.png', name: 'Svijeća'),
        MissingOption(
            id: 'fork', image: 'assets/images/fork.png', name: 'Viljuška'),
        MissingOption(
            id: 'plate', image: 'assets/images/plate.png', name: 'Tanjir'),
      ],
      soundPath: 'nedostaje_svijeca.mp3',
    ),
    MissingPuzzle(
      id: 'tree_leaves',
      mainImage: 'assets/images/tree_no_leaves.png',
      missingPart: 'leaves',
      missingPartName: 'lišće',
      missingPartImage: 'assets/images/leaves.png',
      options: [
        MissingOption(
            id: 'leaves', image: 'assets/images/leaves.png', name: 'Lišće'),
        MissingOption(
            id: 'flower', image: 'assets/images/flower.png', name: 'Cvijet'),
        MissingOption(
            id: 'bird', image: 'assets/images/bird.png', name: 'Ptica'),
      ],
      soundPath: 'nedostaje_lisce.mp3',
    ),
    MissingPuzzle(
      id: 'dog_tail',
      mainImage: 'assets/images/dog_no_tail.png',
      missingPart: 'tail',
      missingPartName: 'rep',
      missingPartImage: 'assets/images/tail.png',
      options: [
        MissingOption(id: 'tail', image: 'assets/images/tail.png', name: 'Rep'),
        MissingOption(
            id: 'bone', image: 'assets/images/bone.png', name: 'Kost'),
        MissingOption(
            id: 'collar', image: 'assets/images/collar.png', name: 'Ogrlica'),
      ],
      soundPath: 'nedostaje_rep.mp3',
    ),
  ];

  MissingPuzzle? _currentPuzzle;
  int _score = 0;
  int _rounds = 0;
  bool _isWaitingForAnswer = false;
  bool _showMissingPart = false;
  bool _showStars = false;

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
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _starController = AnimationController(
      duration: const Duration(seconds: 2),
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

    _revealAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeInOut,
    ));

    _starAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.easeOut,
    ));
  }

  void _startNewRound() async {
    if (_rounds >= 5) {
      _showResultDialog();
      return;
    }

    setState(() {
      _isWaitingForAnswer = true;
      _showMissingPart = false;
      _allPuzzles.shuffle();
      _currentPuzzle = _allPuzzles[_rounds % _allPuzzles.length];

      // Promiješaj opcije
      _currentPuzzle!.options.shuffle();
    });

    await Future.delayed(const Duration(milliseconds: 500));
    await _audioHelper.playSound('sta_nedostaje.mp3');
  }

  void _checkAnswer(MissingOption selected) async {
    if (!_isWaitingForAnswer) return;

    _isWaitingForAnswer = false;

    if (selected.id == _currentPuzzle!.missingPart) {
      // Tačan odgovor
      await _audioHelper.playSound('bravo.mp3');

      // Pokaži nedostajući dio
      setState(() {
        _showMissingPart = true;
      });
      _revealController.forward();

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

      // Pusti zvuk koji objašnjava šta je nedostajalo
      await Future.delayed(const Duration(milliseconds: 500));
      await _audioHelper.playSound(_currentPuzzle!.soundPath);

      setState(() {
        _score += 10;
        _rounds++;
      });

      await Future.delayed(const Duration(seconds: 2));
      _revealController.reset();
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
    await _progressTracker.saveModuleProgress('missing', _rounds, 5);
    await _progressTracker.saveHighScore('missing', _score);
    await _progressTracker.incrementAttempts('missing');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.amber.shade50,
        title: Text(
          _score >= 40 ? 'Odlično! 🌟' : 'Dobro! 👏',
          style: TextStyle(fontSize: 28, color: Colors.amber.shade700),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Šta nedostaje?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber.shade300,
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
                  Colors.amber.shade100,
                  Colors.amber.shade50,
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
                            'Bodovi', _score.toString(), Colors.amber),
                        _buildInfoCard('Runda', '$_rounds / 5', Colors.indigo),
                      ],
                    ),
                  ),
                  // Glavna slika
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Osnovna slika
                          if (_currentPuzzle != null)
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                _currentPuzzle!.mainImage,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.help_outline,
                                          size: 80,
                                          color: Colors.amber.shade300,
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                          'Slika sa nedostajućim dijelom',
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Colors.amber.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          // Nedostajući dio (animiran)
                          if (_showMissingPart && _currentPuzzle != null)
                            Positioned(
                              child: AnimatedBuilder(
                                animation: _revealAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _revealAnimation.value,
                                    child: Opacity(
                                      opacity: _revealAnimation.value,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(20),
                                        child: Image.asset(
                                          _currentPuzzle!.missingPartImage,
                                          width: 100,
                                          height: 100,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            return Icon(
                                              Icons.check_circle,
                                              size: 60,
                                              color: Colors.green,
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Opcije za odgovor
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(sin(_shakeAnimation.value) * 2, 0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: _currentPuzzle?.options.map((option) {
                                    return _buildOptionButton(option);
                                  }).toList() ??
                                  [],
                            ),
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

  Widget _buildOptionButton(MissingOption option) {
    final isCorrect = option.id == _currentPuzzle?.missingPart;

    return ScaleTransition(
      scale: isCorrect && _showMissingPart
          ? _bounceAnimation
          : const AlwaysStoppedAnimation(1.0),
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => _checkAnswer(option),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCorrect && _showMissingPart
                    ? Colors.green
                    : Colors.amber.shade300,
                width: 3,
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Image.asset(
                    option.image,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image,
                        size: 40,
                        color: Colors.amber.shade300,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  option.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _revealController.dispose();
    _starController.dispose();
    _audioHelper.dispose();
    super.dispose();
  }
}

// Modeli za igru
class MissingPuzzle {
  final String id;
  final String mainImage;
  final String missingPart;
  final String missingPartName;
  final String missingPartImage;
  final List<MissingOption> options;
  final String soundPath;

  MissingPuzzle({
    required this.id,
    required this.mainImage,
    required this.missingPart,
    required this.missingPartName,
    required this.missingPartImage,
    required this.options,
    required this.soundPath,
  });
}

class MissingOption {
  final String id;
  final String image;
  final String name;

  const MissingOption({
    required this.id,
    required this.image,
    required this.name,
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

    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -50.0;
      final endY = size.height + 50;
      final y = startY + (endY - startY) * progress;

      paint.color = Colors.amber.withOpacity(1 - progress);

      // Nacrtaj zvjezdicu
      final path = Path();
      const radius = 12.0;
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
