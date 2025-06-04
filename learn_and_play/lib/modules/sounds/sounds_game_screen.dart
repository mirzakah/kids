import 'dart:math';
import 'package:edukativna_igra/modules/colors/colors_game_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_models.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class SoundsGameScreen extends StatefulWidget {
  const SoundsGameScreen({super.key});

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
  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;

  // Lista životinja sa zvukovima
  final List<AnimalSound> _animals = [
    const AnimalSound(
      id: 'dog',
      name: 'Pas',
      imagePath: 'assets/images/dog.png',
      soundPath: 'pas_laje.wav',
    ),
    const AnimalSound(
      id: 'cat',
      name: 'Mačka',
      imagePath: 'assets/images/cat.png',
      soundPath: 'macka_mjauce.wav',
    ),
    const AnimalSound(
      id: 'cow',
      name: 'Krava',
      imagePath: 'assets/images/cow.png',
      soundPath: 'krava_muče.wav',
    ),
    const AnimalSound(
      id: 'bird',
      name: 'Ptica',
      imagePath: 'assets/images/bird.png',
      soundPath: 'ptica_pjeva.wav',
    ),
    const AnimalSound(
      id: 'sheep',
      name: 'Ovca',
      imagePath: 'assets/images/sheep.png',
      soundPath: 'ovca_bleje.wav',
    ),
  ];

  AnimalSound? _currentAnimal;
  List<AnimalSound> _options = [];
  int _score = 0;
  int _rounds = 0;
  bool _isWaitingForAnswer = false;
  bool _showConfetti = false;

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
    _confettiController = AnimationController(
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
  }

  void _startNewRound() async {
    if (_rounds >= 5) {
      _showResultDialog();
      return;
    }

    setState(() {
      _isWaitingForAnswer = true;
      _currentAnimal = _animals[Random().nextInt(_animals.length)];

      // Generiši opcije (uključujući tačan odgovor)
      _options = [_currentAnimal!];
      while (_options.length < 3) {
        final randomAnimal = _animals[Random().nextInt(_animals.length)];
        if (!_options.any((a) => a.id == randomAnimal.id)) {
          _options.add(randomAnimal);
        }
      }
      _options.shuffle();
    });

    // Pusti zvuk životinje nakon kratke pauze
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioHelper.playSound(_currentAnimal!.soundPath);
  }

  void _checkAnswer(AnimalSound selected) async {
    if (!_isWaitingForAnswer) return;

    _isWaitingForAnswer = false;

    if (selected.id == _currentAnimal!.id) {
      // Tačan odgovor
      await _audioHelper.playSound('bravo.mp3');

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

      // Ponovi zvuk
      await _audioHelper.playSound(_currentAnimal!.soundPath);
      setState(() {
        _isWaitingForAnswer = true;
      });
    }
  }

  void _showResultDialog() async {
    // Spremi napredak
    await _progressTracker.saveModuleProgress('sounds', _rounds, 5);
    await _progressTracker.saveHighScore('sounds', _score);
    await _progressTracker.incrementAttempts('sounds');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.green.shade50,
        title: Text(
          _score >= 40 ? 'Odlično! 🌟' : 'Dobro! 👏',
          style: TextStyle(fontSize: 28, color: Colors.green.shade700),
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
          'Ko to govori?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade300,
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
                  Colors.green.shade100,
                  Colors.green.shade50,
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
                            'Bodovi', _score.toString(), Colors.green),
                        _buildInfoCard('Runda', '$_rounds / 5', Colors.blue),
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
                        onPressed: _currentAnimal != null
                            ? () async {
                                await _audioHelper
                                    .playSound(_currentAnimal!.soundPath);
                                _bounceController.forward().then((_) {
                                  _bounceController.reverse();
                                });
                              }
                            : null,
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
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
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
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(_confettiController.value),
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
    _audioHelper.dispose();
    super.dispose();
  }
}
