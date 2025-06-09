import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class MissingGameScreen extends StatefulWidget {
  final int level;

  const MissingGameScreen({super.key, required this.level});

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
  late AnimationController _correctAnswerController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _starAnimation;

  // Lista svih zadataka sa nedostajućim elementima
  final List<MissingPuzzle> _allPuzzles = [
    // Level 1 - Jednostavni
    MissingPuzzle(
      id: 'face_mouth',
      level: 1,
      mainImage: 'assets/images/parts/face_no_mouth.png',
      missingPart: 'mouth',
      missingPartName: 'usta',
      missingPartImage: 'assets/images/parts/mouth.png',
      options: [
        const MissingOption(
            id: 'mouth', image: 'assets/images/parts/mouth.png', name: 'Usta'),
        const MissingOption(
            id: 'nose', image: 'assets/images/parts/nose.png', name: 'Nos'),
        const MissingOption(
            id: 'eye', image: 'assets/images/parts/eye.png', name: 'Oko'),
      ],
      soundPath: 'nedostaju_usta.mp3',
    ),
    MissingPuzzle(
      id: 'car_wheel',
      level: 1,
      mainImage: 'assets/images/parts/car_no_wheel.png',
      missingPart: 'wheel',
      missingPartName: 'točak',
      missingPartImage: 'assets/images/parts/wheel.png',
      options: [
        const MissingOption(
            id: 'wheel', image: 'assets/images/parts/wheel.png', name: 'Točak'),
        const MissingOption(
            id: 'steering',
            image: 'assets/images/parts/steering.png',
            name: 'Volan'),
        const MissingOption(
            id: 'door', image: 'assets/images/parts/door.png', name: 'Vrata'),
      ],
      soundPath: 'nedostaje_tocak.mp3',
    ),
    MissingPuzzle(
      id: 'dog_tail',
      level: 1,
      mainImage: 'assets/images/parts/dog_no_tail.png',
      missingPart: 'tail',
      missingPartName: 'rep',
      missingPartImage: 'assets/images/parts/tail.png',
      options: [
        const MissingOption(
            id: 'tail', image: 'assets/images/parts/tail.png', name: 'Rep'),
        const MissingOption(
            id: 'bone', image: 'assets/images/parts/bone.png', name: 'Kost'),
        const MissingOption(
            id: 'collar',
            image: 'assets/images/parts/collar.png',
            name: 'Ogrlica'),
      ],
      soundPath: 'nedostaje_rep.mp3',
    ),

    // Level 2 - Srednji
    MissingPuzzle(
      id: 'clock_hand',
      level: 2,
      mainImage: 'assets/images/parts/clock_no_hand.png',
      missingPart: 'hand',
      missingPartName: 'kazaljka',
      missingPartImage: 'assets/images/parts/clock_hand.png',
      options: [
        const MissingOption(
            id: 'hand',
            image: 'assets/images/parts/clock_hand.png',
            name: 'Kazaljka'),
        const MissingOption(
            id: 'spoon',
            image: 'assets/images/parts/spoon.png',
            name: 'Kašika'),
        const MissingOption(
            id: 'toothbrush',
            image: 'assets/images/parts/toothbrush.png',
            name: 'Četkica'),
      ],
      soundPath: 'nedostaje_kazaljka.mp3',
    ),
    MissingPuzzle(
      id: 'tree_leaves',
      level: 2,
      mainImage: 'assets/images/parts/tree_no_leaves.png',
      missingPart: 'leaves',
      missingPartName: 'lišće',
      missingPartImage: 'assets/images/parts/leaves.png',
      options: [
        const MissingOption(
            id: 'leaves',
            image: 'assets/images/parts/leaves.png',
            name: 'Lišće'),
        const MissingOption(
            id: 'flower',
            image: 'assets/images/parts/flower.png',
            name: 'Cvijet'),
        const MissingOption(
            id: 'bird', image: 'assets/images/parts/bird.png', name: 'Ptica'),
      ],
      soundPath: 'nedostaje_lisce.mp3',
    ),
    MissingPuzzle(
      id: 'house_door',
      level: 2,
      mainImage: 'assets/images/parts/house_no_door.png',
      missingPart: 'door',
      missingPartName: 'vrata',
      missingPartImage: 'assets/images/parts/house_door.png',
      options: [
        const MissingOption(
            id: 'door',
            image: 'assets/images/parts/house_door.png',
            name: 'Vrata'),
        const MissingOption(
            id: 'window',
            image: 'assets/images/parts/window.png',
            name: 'Prozor'),
        const MissingOption(
            id: 'chimney',
            image: 'assets/images/parts/chimney.png',
            name: 'Dimnjak'),
      ],
      soundPath: 'nedostaju_vrata.mp3',
    ),

    // Level 3 - Složeni
    MissingPuzzle(
      id: 'bicycle_chain',
      level: 3,
      mainImage: 'assets/images/parts/bicycle_no_chain.png',
      missingPart: 'chain',
      missingPartName: 'lanac',
      missingPartImage: 'assets/images/parts/bicycle_chain.png',
      options: [
        const MissingOption(
            id: 'chain',
            image: 'assets/images/parts/bicycle_chain.png',
            name: 'Lanac'),
        const MissingOption(
            id: 'pump', image: 'assets/images/parts/pump.png', name: 'Pumpa'),
        const MissingOption(
            id: 'bell', image: 'assets/images/parts/bell.png', name: 'Zvono'),
        const MissingOption(
            id: 'basket',
            image: 'assets/images/parts/basket.png',
            name: 'Korpa'),
      ],
      soundPath: 'nedostaje_lanac.mp3',
    ),
    MissingPuzzle(
      id: 'flower_petals',
      level: 3,
      mainImage: 'assets/images/parts/flower_no_petals.png',
      missingPart: 'petals',
      missingPartName: 'latica',
      missingPartImage: 'assets/images/parts/petals.png',
      options: [
        const MissingOption(
            id: 'petals',
            image: 'assets/images/parts/petals.png',
            name: 'Latice'),
        const MissingOption(
            id: 'stem',
            image: 'assets/images/parts/stem.png',
            name: 'Stabljika'),
        const MissingOption(
            id: 'pot', image: 'assets/images/parts/pot.png', name: 'Saksija'),
        const MissingOption(
            id: 'bee', image: 'assets/images/parts/bee.png', name: 'Pčela'),
      ],
      soundPath: 'nedostaju_latice.mp3',
    ),
    MissingPuzzle(
      id: 'robot_antenna',
      level: 3,
      mainImage: 'assets/images/parts/robot_no_antenna.png',
      missingPart: 'antenna',
      missingPartName: 'antena',
      missingPartImage: 'assets/images/parts/antenna.png',
      options: [
        const MissingOption(
            id: 'antenna',
            image: 'assets/images/parts/antenna.png',
            name: 'Antena'),
        const MissingOption(
            id: 'battery',
            image: 'assets/images/parts/battery.png',
            name: 'Baterija'),
        const MissingOption(
            id: 'remote',
            image: 'assets/images/parts/remote.png',
            name: 'Daljinski'),
        const MissingOption(
            id: 'cable', image: 'assets/images/parts/cable.png', name: 'Kabl'),
      ],
      soundPath: 'nedostaje_antena.mp3',
    ),
  ];

  List<MissingPuzzle> _levelPuzzles = [];
  MissingPuzzle? _currentPuzzle;
  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  int _optionsCount = 3;
  bool _isWaitingForAnswer = false;
  bool _showMissingPart = false;
  bool _showStars = false;
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
    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic(
      'missing_background.mp3', // Dodajte ovaj fajl u assets/audio/
      loop: true,
    );

    // Postavite volume nivoe
    _audioHelper.setBackgroundMusicVolume(0.22); // Između counting i sounds
    _audioHelper.setSoundEffectsVolume(0.87); // Malo glasniji sound effects
  }

  void _initializeGame() {
    // Konfiguriši igru na osnovu levela
    switch (widget.level) {
      case 1:
        _levelPuzzles =
            _allPuzzles.where((p) => p.level <= 1).toList(); // Jednostavni
        _totalRounds = 5;
        _optionsCount = 3;
        break;
      case 2:
        _levelPuzzles = _allPuzzles
            .where((p) => p.level <= 2)
            .toList(); // Jednostavni + srednji
        _totalRounds = 7;
        _optionsCount = 3;
        break;
      case 3:
        _levelPuzzles = _allPuzzles; // Svi puzzles
        _totalRounds = 10;
        _optionsCount = 4;
        break;
      default:
        _levelPuzzles = _allPuzzles.where((p) => p.level <= 1).toList();
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
      _showMissingPart = false;
      _currentRound++;

      // Shuffle puzzles i uzmi random
      _levelPuzzles.shuffle();
      _currentPuzzle = _levelPuzzles[_currentRound % _levelPuzzles.length];

      // Promiješaj opcije i ograniči broj opcija na osnovu levela
      final shuffledOptions = List<MissingOption>.from(_currentPuzzle!.options);
      shuffledOptions.shuffle();

      // Za level 3, koristi više opcija ako su dostupne
      final optionsToShow = widget.level == 3 && shuffledOptions.length >= 4
          ? shuffledOptions.take(4).toList()
          : shuffledOptions.take(3).toList();

      _currentPuzzle = MissingPuzzle(
        id: _currentPuzzle!.id,
        level: _currentPuzzle!.level,
        mainImage: _currentPuzzle!.mainImage,
        missingPart: _currentPuzzle!.missingPart,
        missingPartName: _currentPuzzle!.missingPartName,
        missingPartImage: _currentPuzzle!.missingPartImage,
        options: optionsToShow,
        soundPath: _currentPuzzle!.soundPath,
      );
    });

    // Uvodni zvuk i instrukcija
    await _audioHelper.playSoundSequence([
      'missing_instrukcija.mp3', // "Pogledaj sliku i odaberi šta nedostaje"
    ]);

    await Future.delayed(const Duration(milliseconds: 800));
    await _audioHelper.playSound('sta_nedostaje.mp3');
  }

  void _checkAnswer(MissingOption selected) async {
    if (!_isWaitingForAnswer || _gameCompleted) return;

    _isWaitingForAnswer = false;

    if (selected.id == _currentPuzzle!.missingPart) {
      // Tačan odgovor
      await _audioHelper.playSoundSequence([
        'missing_correct.mp3', // Novi zvuk za tačan odgovor u missing igri
        'bravo.mp3',
      ]);

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
        _score += (10 * widget.level); // Više bodova za teži level
      });

      await Future.delayed(const Duration(seconds: 2));
      _revealController.reset();
      _startNewRound();
    } else {
      // Netačan odgovor
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      await _audioHelper.playSoundSequence([
        'missing_wrong.mp3', // Kratka "buzz" melodija za pogrešan odgovor
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
    await _progressTracker.saveModuleProgress('missing', widget.level, 3);
    await _progressTracker.saveHighScore('missing', _score);
    await _progressTracker.incrementAttempts('missing');

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
        backgroundColor: Colors.amber.shade50,
        title: Text(
          _getWinTitle(),
          style: const TextStyle(fontSize: 28, color: Colors.amber),
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
                color: Colors.amber.shade600,
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
                context.go('/missing?level=${widget.level + 1}');
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
          'Šta nedostaje? - Level ${widget.level}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber.shade300,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () async {
            await _audioHelper.stopBackgroundMusic();
            if (context.mounted) {
              context.go('/missing-levels');
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
                  Colors.amber.shade100,
                  Colors.amber.shade50,
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
                            'Bodovi', _score.toString(), Colors.amber),
                        _buildInfoCard('Runda',
                            '$_currentRound / $_totalRounds', Colors.indigo),
                        _buildInfoCard('Level', widget.level.toString(),
                            Colors.deepOrange),
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
                                            return const Icon(
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
                            child: widget.level == 3 &&
                                    _currentPuzzle?.options.length == 4
                                ? GridView.count(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 15,
                                    crossAxisSpacing: 15,
                                    childAspectRatio: 1.0,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    children:
                                        _currentPuzzle?.options.map((option) {
                                              return _buildOptionButton(option);
                                            }).toList() ??
                                            [],
                                  )
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children:
                                        _currentPuzzle?.options.map((option) {
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

  Widget _buildOptionButton(MissingOption option) {
    final isCorrect = option.id == _currentPuzzle?.missingPart;
    final isLevel3 = widget.level == 3 && _currentPuzzle?.options.length == 4;

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
            width: isLevel3 ? null : 100,
            height: isLevel3 ? null : 100,
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
                    fontSize: isLevel3 ? 12 : 14,
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
    _correctAnswerController.dispose();

    // VAŽNO: Ne dispose-uj AudioHelper jer je singleton!
    // Samo zaustavi background muziku za ovaj ekran
    _audioHelper.stopBackgroundMusic();

    super.dispose();
  }
}

// Modeli za igru
class MissingPuzzle {
  final String id;
  final int level;
  final String mainImage;
  final String missingPart;
  final String missingPartName;
  final String missingPartImage;
  final List<MissingOption> options;
  final String soundPath;

  MissingPuzzle({
    required this.id,
    required this.level,
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
  final Random random = Random(42); // Fixed seed za konzistentnost

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
