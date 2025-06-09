import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class CountingTapGameScreen extends StatefulWidget {
  final int level;

  const CountingTapGameScreen({super.key, required this.level});

  @override
  State<CountingTapGameScreen> createState() => _CountingTapGameScreenState();
}

class _CountingTapGameScreenState extends State<CountingTapGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _celebrationController;
  late AnimationController _counterController;
  late AnimationController _objectSpawnController;
  late AnimationController _shakeController;
  late AnimationController _progressController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _counterAnimation;
  late Animation<double> _objectSpawnAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _progressAnimation;

  List<TappableObject> _objects = [];
  List<AnimationController> _tapControllers = [];

  int _targetCount = 3;
  int _tappedCount = 0;
  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  bool _isProcessing = false;
  bool _showCelebration = false;
  bool _gameCompleted = false;
  bool _roundCompleted = false;
  bool _hasExceeded = false;

  String _currentInstruction = "";
  String _currentObjectType = "";

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

    _celebrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _counterController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _objectSpawnController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _celebrationController, curve: Curves.easeInOut));

    _counterAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
        CurvedAnimation(parent: _counterController, curve: Curves.elasticOut));

    _objectSpawnAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _objectSpawnController, curve: Curves.easeOutBack));

    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _progressController, curve: Curves.easeOutCubic));
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic('counting_tap_background.mp3', loop: true);
    _audioHelper.setBackgroundMusicVolume(0.18);
    _audioHelper.setSoundEffectsVolume(0.75);
  }

  void _initializeGame() {
    switch (widget.level) {
      case 1:
        _totalRounds = 6;
        break;
      case 2:
        _totalRounds = 8;
        break;
      case 3:
        _totalRounds = 10;
        break;
      default:
        _totalRounds = 6;
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
      _isProcessing = false;
      _roundCompleted = false;
      _hasExceeded = false;
      _currentRound++;
      _tappedCount = 0;
      _generateRound();
    });

    _progressController.reset();
    _progressController.forward();

    // Dispose old controllers
    for (var controller in _tapControllers) {
      controller.dispose();
    }
    _tapControllers.clear();

    await _audioHelper.playSoundSequence([
      'counting_tap_instrukcija.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 800));

    // Spawn objects with animation
    _objectSpawnController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));
    await _audioHelper.playSound('tapni_${_getNumberWord(_targetCount)}.mp3');
  }

  void _generateRound() {
    // Determine target count based on level and round
    switch (widget.level) {
      case 1:
        _targetCount = 3; // Always 3 for babies
        break;
      case 2:
        _targetCount = 3 + (_currentRound % 3); // 3, 4, 5
        break;
      case 3:
        _targetCount = 4 + (_currentRound % 4); // 4, 5, 6, 7
        break;
    }

    // Select object type for this round
    final objectTypes = [
      'banana',
      'apple',
      'star',
      'heart',
      'balloon',
      'cookie'
    ];
    _currentObjectType = objectTypes[_currentRound % objectTypes.length];

    _currentInstruction =
        "Tapni tačno $_targetCount ${_getObjectPlural(_currentObjectType)}!";

    _generateObjects();
  }

  void _generateObjects() {
    _objects.clear();

    // Create extra objects (more than needed) to make it challenging
    final totalObjects =
        _targetCount + 2 + Random().nextInt(3); // 2-4 extra objects

    final screenSize = MediaQuery.of(context).size;
    final safeArea = EdgeInsets.fromLTRB(
      60, 200, 60, 150, // Leave space for UI elements
    );

    final objectData = _getObjectData(_currentObjectType);

    for (int i = 0; i < totalObjects; i++) {
      double x, y;
      bool validPosition = false;
      int attempts = 0;

      // Find non-overlapping position
      do {
        x = safeArea.left +
            Random().nextDouble() *
                (screenSize.width - safeArea.horizontal - 80);
        y = safeArea.top +
            Random().nextDouble() *
                (screenSize.height - safeArea.vertical - 80);

        validPosition = _objects.every((obj) {
          final distance = sqrt(pow(obj.x - x, 2) + pow(obj.y - y, 2));
          return distance > 100; // Minimum distance between objects
        });

        attempts++;
      } while (!validPosition && attempts < 20);

      final object = TappableObject(
        id: 'object_$i',
        x: x,
        y: y,
        emoji: objectData['emoji']!,
        color: objectData['color']!,
        isTapped: false,
      );

      _objects.add(object);

      // Create animation controller for this object
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      _tapControllers.add(controller);
    }
  }

  Map<String, dynamic> _getObjectData(String type) {
    switch (type) {
      case 'banana':
        return {'emoji': '🍌', 'color': Colors.yellow};
      case 'apple':
        return {'emoji': '🍎', 'color': Colors.red};
      case 'star':
        return {'emoji': '⭐', 'color': Colors.amber};
      case 'heart':
        return {'emoji': '❤️', 'color': Colors.pink};
      case 'balloon':
        return {'emoji': '🎈', 'color': Colors.blue};
      case 'cookie':
        return {'emoji': '🍪', 'color': Colors.brown};
      default:
        return {'emoji': '🍌', 'color': Colors.yellow};
    }
  }

  String _getObjectPlural(String type) {
    switch (type) {
      case 'banana':
        return 'banana';
      case 'apple':
        return 'jabuka';
      case 'star':
        return 'zvezda';
      case 'heart':
        return 'srca';
      case 'balloon':
        return 'balona';
      case 'cookie':
        return 'kolačića';
      default:
        return 'objekata';
    }
  }

  String _getNumberWord(int number) {
    switch (number) {
      case 1:
        return 'jedan';
      case 2:
        return 'dva';
      case 3:
        return 'tri';
      case 4:
        return 'četiri';
      case 5:
        return 'pet';
      case 6:
        return 'šest';
      case 7:
        return 'sedam';
      default:
        return number.toString();
    }
  }

  void _onObjectTapped(int index) async {
    if (_isProcessing || _roundCompleted || _objects[index].isTapped) return;

    setState(() {
      _objects[index].isTapped = true;
      _tappedCount++;
    });

    // Animate tap
    _tapControllers[index].forward();
    _counterController.forward().then((_) => _counterController.reverse());

    // Play counting sound
    await _audioHelper.playSoundSequence([
      'tap_sound.mp3',
      '${_getNumberWord(_tappedCount)}.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 400));

    // Check if target reached
    if (_tappedCount == _targetCount) {
      _onTargetReached();
    } else if (_tappedCount > _targetCount) {
      _onExceededTarget();
    }
  }

  void _onTargetReached() async {
    setState(() {
      _roundCompleted = true;
      _showCelebration = true;
      _isProcessing = true;
    });

    await _audioHelper.playSoundSequence([
      'counting_correct.mp3',
      'bravo.mp3',
    ]);

    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    _celebrationController.forward().then((_) {
      _celebrationController.reset();
      setState(() {
        _showCelebration = false;
      });
    });

    final baseScore = [15, 20, 25][widget.level - 1];
    setState(() {
      _score += baseScore;
    });

    await Future.delayed(const Duration(milliseconds: 2500));
    _startNewRound();
  }

  void _onExceededTarget() async {
    setState(() {
      _hasExceeded = true;
      _isProcessing = true;
    });

    _shakeController.forward().then((_) {
      _shakeController.reset();
    });

    await _audioHelper.playSoundSequence([
      'counting_wrong.mp3',
      'previše.mp3', // "Too many"
    ]);

    await Future.delayed(const Duration(milliseconds: 1500));

    // Reset round
    setState(() {
      _hasExceeded = false;
      _isProcessing = false;
    });

    _resetRound();
  }

  void _resetRound() async {
    await _audioHelper.playSound('reset_sound.mp3');

    // Reset object states
    setState(() {
      for (var object in _objects) {
        object.isTapped = false;
      }
      _tappedCount = 0;
      _hasExceeded = false;
      _isProcessing = false;
    });

    // Reset animations
    for (var controller in _tapControllers) {
      controller.reset();
    }

    _objectSpawnController.reset();
    _objectSpawnController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    await _audioHelper.playSound('tapni_${_getNumberWord(_targetCount)}.mp3');
  }

  void _showWinDialog() async {
    await _progressTracker.saveModuleProgress('counting_tap', widget.level, 3);
    await _progressTracker.saveHighScore('counting_tap', _score);
    await _progressTracker.incrementAttempts('counting_tap');

    await _audioHelper.playSoundSequence(['game_complete.mp3', 'bravo.mp3']);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildWinDialog(),
    );
  }

  Widget _buildWinDialog() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade100,
              Colors.teal.shade50,
              Colors.cyan.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getWinTitle(),
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Icon(_getWinIcon(), size: 80, color: Colors.amber),
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
            const SizedBox(height: 30),
            Wrap(
              spacing: 10,
              children: [
                _buildDialogButton('Nova igra', Colors.green, () {
                  Navigator.of(context).pop();
                  setState(() {
                    _initializeGame();
                  });
                }),
                if (widget.level < 3)
                  _buildDialogButton('Sljedeći level', Colors.blue, () {
                    Navigator.of(context).pop();
                    context.go('/counting_tap?level=${widget.level + 1}');
                  }),
                _buildDialogButton('Početni ekran', Colors.orange, () {
                  Navigator.of(context).pop();
                  context.go('/');
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogButton(String text, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        elevation: 5,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _getWinTitle() {
    final maxScore = _totalRounds * [15, 20, 25][widget.level - 1];
    if (_score >= maxScore * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    final maxScore = _totalRounds * [15, 20, 25][widget.level - 1];
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
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.green.shade50,
                  Colors.teal.shade50,
                  Colors.cyan.shade50,
                  Colors.lightGreen.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  _buildProgressSection(),
                  _buildInstructionCard(),
                  Expanded(child: _buildGameArea()),
                ],
              ),
            ),
          ),
          if (_showCelebration)
            AnimatedBuilder(
              animation: _celebrationAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: CelebrationPainter(_celebrationAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTopBarButton(
            icon: Icons.arrow_back_rounded,
            color: Colors.green,
            onTap: () async {
              await _audioHelper.stopBackgroundMusic();
              if (context.mounted) {
                context.go('/counting_tap-levels');
              }
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brojanje sa kretanjem',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                Text(
                  'Level ${widget.level}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green.shade500,
                  ),
                ),
              ],
            ),
          ),
          _buildTopBarButton(
            icon: _audioHelper.isBackgroundMusicPlaying
                ? Icons.volume_up
                : Icons.volume_off,
            color: Colors.teal,
            onTap: () async {
              if (_audioHelper.isBackgroundMusicPlaying) {
                await _audioHelper.pauseBackgroundMusic();
              } else {
                await _audioHelper.resumeBackgroundMusic();
              }
              setState(() {});
            },
          ),
          const SizedBox(width: 12),
          _buildTopBarButton(
            icon: Icons.refresh_rounded,
            color: Colors.cyan,
            onTap: _resetRound,
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: _buildStatCard(
                  'Bodovi', _score.toString(), Colors.green, Icons.star)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Runda', '$_currentRound/$_totalRounds',
                  Colors.teal, Icons.flag)),
          const SizedBox(width: 12),
          Expanded(child: _buildCounterCard()),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, Color color, IconData icon) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * _progressAnimation.value),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounterCard() {
    return AnimatedBuilder(
      animation: _counterAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _counterAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: _hasExceeded
                  ? Border.all(color: Colors.red, width: 3)
                  : _tappedCount == _targetCount
                      ? Border.all(color: Colors.green, width: 3)
                      : null,
              boxShadow: [
                BoxShadow(
                  color: _hasExceeded
                      ? Colors.red.withOpacity(0.3)
                      : _tappedCount == _targetCount
                          ? Colors.green.withOpacity(0.3)
                          : Colors.cyan.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.touch_app,
                  color: _hasExceeded
                      ? Colors.red
                      : _tappedCount == _targetCount
                          ? Colors.green
                          : Colors.cyan,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  '$_tappedCount/$_targetCount',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _hasExceeded
                        ? Colors.red
                        : _tappedCount == _targetCount
                            ? Colors.green
                            : Colors.cyan,
                  ),
                ),
                Text(
                  'Tapnuto',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.cyan.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionCard() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - _progressAnimation.value)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade400, Colors.teal.shade400],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.touch_app,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    _currentInstruction,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameArea() {
    return AnimatedBuilder(
      animation: _objectSpawnAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(
                _hasExceeded ? sin(_shakeAnimation.value) * 3 : 0,
                0,
              ),
              child: Container(
                width: double.infinity,
                height: double.infinity,
                child: Stack(
                  children: _objects.asMap().entries.map((entry) {
                    final index = entry.key;
                    final object = entry.value;
                    return _buildTappableObject(object, index);
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTappableObject(TappableObject object, int index) {
    return Positioned(
      left: object.x,
      top: object.y,
      child: AnimatedBuilder(
        animation: _objectSpawnAnimation,
        builder: (context, child) {
          return AnimatedBuilder(
            animation: _tapControllers.length > index
                ? _tapControllers[index]
                : AnimationController(vsync: this, duration: Duration.zero),
            builder: (context, child) {
              final tapValue = _tapControllers.length > index
                  ? _tapControllers[index].value
                  : 0.0;
              final spawnScale = _objectSpawnAnimation.value;
              final tapScale = object.isTapped ? (1.0 - tapValue) : 1.0;
              final opacity = object.isTapped
                  ? (1.0 - tapValue)
                  : _objectSpawnAnimation.value;

              return Transform.scale(
                scale: spawnScale * tapScale,
                child: Opacity(
                  opacity: opacity,
                  child: GestureDetector(
                    onTap: () => _onObjectTapped(index),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: object.isTapped
                            ? Colors.grey.shade200
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: object.isTapped
                              ? Colors.grey.shade300
                              : object.color.withOpacity(0.3),
                          width: 3,
                        ),
                        boxShadow: [
                          if (!object.isTapped)
                            BoxShadow(
                              color: object.color.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                              spreadRadius: 2,
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          object.emoji,
                          style: const TextStyle(
                            fontSize: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _celebrationController.dispose();
    _counterController.dispose();
    _objectSpawnController.dispose();
    _shakeController.dispose();
    _progressController.dispose();

    for (var controller in _tapControllers) {
      controller.dispose();
    }

    _audioHelper.stopBackgroundMusic();
    super.dispose();
  }
}

// Model class
class TappableObject {
  final String id;
  final double x;
  final double y;
  final String emoji;
  final Color color;
  bool isTapped;

  TappableObject({
    required this.id,
    required this.x,
    required this.y,
    required this.emoji,
    required this.color,
    this.isTapped = false,
  });
}

// Celebration painter
class CelebrationPainter extends CustomPainter {
  final double progress;
  final Random random = Random(42);

  CelebrationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -50.0;
      final endY = size.height + 50;
      final y = startY + (endY - startY) * progress;

      paint.color = [
        Colors.green.withOpacity(1 - progress),
        Colors.teal.withOpacity(1 - progress),
        Colors.cyan.withOpacity(1 - progress),
        Colors.lightGreen.withOpacity(1 - progress),
      ][i % 4];

      if (i % 5 == 0) {
        canvas.drawCircle(Offset(x, y), 8, paint);
      } else if (i % 5 == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 12, height: 12),
          paint,
        );
      } else if (i % 5 == 2) {
        // Draw heart shape
        final path = Path();
        path.moveTo(x, y + 6);
        path.cubicTo(x - 6, y - 3, x - 12, y + 3, x, y + 12);
        path.cubicTo(x + 12, y + 3, x + 6, y - 3, x, y + 6);
        canvas.drawPath(path, paint);
      } else if (i % 5 == 3) {
        // Draw star
        final path = Path();
        for (int j = 0; j < 5; j++) {
          final angle = (j * 144 - 90) * pi / 180;
          final radius = j % 2 == 0 ? 8.0 : 4.0;
          final px = x + cos(angle) * radius;
          final py = y + sin(angle) * radius;
          if (j == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      } else {
        // Draw triangle
        final path = Path();
        path.moveTo(x, y - 6);
        path.lineTo(x - 6, y + 6);
        path.lineTo(x + 6, y + 6);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
