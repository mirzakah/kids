import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class ShadowMatchingGameScreen extends StatefulWidget {
  final int level;

  const ShadowMatchingGameScreen({super.key, required this.level});

  @override
  State<ShadowMatchingGameScreen> createState() =>
      _ShadowMatchingGameScreenState();
}

class _ShadowMatchingGameScreenState extends State<ShadowMatchingGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late AnimationController _glowController;
  late AnimationController _progressController;
  late AnimationController _objectRevealController;
  late AnimationController _shadowRevealController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _objectRevealAnimation;
  late Animation<double> _shadowRevealAnimation;

  List<ShadowMatchingItem> _availableObjects = [];
  ShadowMatchingItem? _currentObject;
  List<ShadowOption> _currentShadows = [];
  String? _selectedShadow;

  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  bool _isProcessing = false;
  bool _showCelebration = false;
  bool _gameCompleted = false;
  bool _roundCompleted = false;
  bool _showingResult = false;

  String _currentInstruction = "";

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeObjects();
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

    _celebrationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _objectRevealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shadowRevealController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut));

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _celebrationController, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _progressController, curve: Curves.easeOutCubic));

    _objectRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _objectRevealController, curve: Curves.easeOutBack));

    _shadowRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _shadowRevealController, curve: Curves.easeOutBack));
  }

  void _initializeObjects() {
    // Initialize objects with their shadow paths
    // You'll replace these with actual image paths
    _availableObjects = [
      ShadowMatchingItem(
        id: 'apple',
        name: 'Jabuka',
        objectImagePath: 'assets/images/shadow_matching/objects/apple.png',
        correctShadowPath:
            'assets/images/shadow_matching/shadows/apple_correct.png',
        wrongShadowPaths: [
          'assets/images/shadow_matching/shadows/apple_wrong_1.png',
          'assets/images/shadow_matching/shadows/apple_wrong_2.png',
        ],
        color: Colors.red,
      ),
      ShadowMatchingItem(
        id: 'banana',
        name: 'Banana',
        objectImagePath: 'assets/images/shadow_matching/objects/banana.png',
        correctShadowPath:
            'assets/images/shadow_matching/shadows/banana_correct.png',
        wrongShadowPaths: [
          'assets/images/shadow_matching/shadows/banana_wrong_1.png',
          'assets/images/shadow_matching/shadows/banana_wrong_2.png',
        ],
        color: Colors.yellow,
      ),
      ShadowMatchingItem(
        id: 'car',
        name: 'Auto',
        objectImagePath: 'assets/images/shadow_matching/objects/car.png',
        correctShadowPath:
            'assets/images/shadow_matching/shadows/car_correct.png',
        wrongShadowPaths: [
          'assets/images/shadow_matching/shadows/car_wrong_1.png',
          'assets/images/shadow_matching/shadows/car_wrong_2.png',
        ],
        color: Colors.blue,
      ),
      ShadowMatchingItem(
        id: 'star',
        name: 'Zvezda',
        objectImagePath: 'assets/images/shadow_matching/objects/star.png',
        correctShadowPath:
            'assets/images/shadow_matching/shadows/star_correct.png',
        wrongShadowPaths: [
          'assets/images/shadow_matching/shadows/star_wrong_1.png',
          'assets/images/shadow_matching/shadows/star_wrong_2.png',
        ],
        color: Colors.amber,
      ),
      ShadowMatchingItem(
        id: 'house',
        name: 'Kuća',
        objectImagePath: 'assets/images/shadow_matching/objects/house.png',
        correctShadowPath:
            'assets/images/shadow_matching/shadows/house_correct.png',
        wrongShadowPaths: [
          'assets/images/shadow_matching/shadows/house_wrong_1.png',
          'assets/images/shadow_matching/shadows/house_wrong_2.png',
        ],
        color: Colors.brown,
      ),
      ShadowMatchingItem(
        id: 'tree',
        name: 'Drvo',
        objectImagePath: 'assets/images/shadow_matching/objects/tree.png',
        correctShadowPath:
            'assets/images/shadow_matching/shadows/tree_correct.png',
        wrongShadowPaths: [
          'assets/images/shadow_matching/shadows/tree_wrong_1.png',
          'assets/images/shadow_matching/shadows/tree_wrong_2.png',
        ],
        color: Colors.green,
      ),
      ShadowMatchingItem(
        id: 'balloon',
        name: 'Balon',
        objectImagePath: 'assets/images/shadow_matching/objects/balloon.png',
        correctShadowPath:
            'assets/images/shadow_matching/shadows/balloon_correct.png',
        wrongShadowPaths: [
          'assets/images/shadow_matching/shadows/balloon_wrong_1.png',
          'assets/images/shadow_matching/shadows/balloon_wrong_2.png',
        ],
        color: Colors.purple,
      ),
      ShadowMatchingItem(
        id: 'flower',
        name: 'Cvet',
        objectImagePath: 'assets/images/shadow_matching/objects/flower.png',
        correctShadowPath:
            'assets/images/shadow_matching/shadows/flower_correct.png',
        wrongShadowPaths: [
          'assets/images/shadow_matching/shadows/flower_wrong_1.png',
          'assets/images/shadow_matching/shadows/flower_wrong_2.png',
        ],
        color: Colors.pink,
      ),
    ];
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic('shadow_matching_background.mp3',
        loop: true);
    _audioHelper.setBackgroundMusicVolume(0.20);
    _audioHelper.setSoundEffectsVolume(0.75);
  }

  void _initializeGame() {
    switch (widget.level) {
      case 1:
        _totalRounds = 8;
        break;
      case 2:
        _totalRounds = 10;
        break;
      case 3:
        _totalRounds = 12;
        break;
      default:
        _totalRounds = 8;
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
      _showingResult = false;
      _selectedShadow = null;
      _currentRound++;
      _generateRound();
    });

    _progressController.reset();
    _progressController.forward();

    await _audioHelper.playSoundSequence([
      'shadow_matching_instrukcija.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 800));

    // Reveal object first
    _objectRevealController.forward();

    await Future.delayed(const Duration(milliseconds: 1000));

    // Then reveal shadows
    _shadowRevealController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    await _audioHelper.playSound('pronadi_sjenu.mp3');
  }

  void _generateRound() {
    // Select object for this round
    _currentObject =
        _availableObjects[_currentRound % _availableObjects.length];

    _currentInstruction = "Pronađi sjenu za: ${_currentObject!.name}";

    // Create shadow options
    _currentShadows = [
      ShadowOption(
        id: 'correct',
        imagePath: _currentObject!.correctShadowPath,
        isCorrect: true,
      ),
      ShadowOption(
        id: 'wrong_1',
        imagePath: _currentObject!.wrongShadowPaths[0],
        isCorrect: false,
      ),
      ShadowOption(
        id: 'wrong_2',
        imagePath: _currentObject!.wrongShadowPaths[1],
        isCorrect: false,
      ),
    ];

    // Shuffle shadows
    _currentShadows.shuffle();
  }

  void _onShadowTapped(String shadowId) async {
    if (_isProcessing || _roundCompleted) return;

    setState(() {
      _selectedShadow = shadowId;
      _isProcessing = true;
    });

    await _audioHelper.playSound('shadow_tap.mp3');
    await Future.delayed(const Duration(milliseconds: 300));

    _checkAnswer(shadowId);
  }

  void _checkAnswer(String selectedShadowId) async {
    final selectedShadow =
        _currentShadows.firstWhere((s) => s.id == selectedShadowId);
    final isCorrect = selectedShadow.isCorrect;

    setState(() {
      _showingResult = true;
    });

    if (isCorrect) {
      await _onCorrectAnswer();
    } else {
      await _onWrongAnswer();
    }
  }

  Future<void> _onCorrectAnswer() async {
    await _audioHelper.playSoundSequence([
      'shadow_correct.mp3',
      'bravo.mp3',
    ]);

    setState(() {
      _roundCompleted = true;
      _showCelebration = true;
    });

    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    _celebrationController.forward().then((_) {
      _celebrationController.reset();
      setState(() {
        _showCelebration = false;
      });
    });

    final baseScore = [25, 30, 40][widget.level - 1];
    setState(() {
      _score += baseScore;
    });

    await Future.delayed(const Duration(milliseconds: 2500));
    _startNewRound();
  }

  Future<void> _onWrongAnswer() async {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });

    await _audioHelper.playSoundSequence([
      'shadow_wrong.mp3',
      'pokusaj_ponovo.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _showingResult = false;
      _isProcessing = false;
      _selectedShadow = null;
    });
  }

  void _resetRound() async {
    if (_isProcessing) return;

    await _audioHelper.playSound('reset_sound.mp3');

    setState(() {
      _selectedShadow = null;
      _showingResult = false;
      _isProcessing = false;
    });

    _objectRevealController.reset();
    _shadowRevealController.reset();

    await Future.delayed(const Duration(milliseconds: 300));

    _objectRevealController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _shadowRevealController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    await _audioHelper.playSound('pronadi_sjenu.mp3');
  }

  void _showWinDialog() async {
    await _progressTracker.saveModuleProgress(
        'shadow_matching', widget.level, 3);
    await _progressTracker.saveHighScore('shadow_matching', _score);
    await _progressTracker.incrementAttempts('shadow_matching');

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
              Colors.grey.shade100,
              Colors.blueGrey.shade50,
              Colors.indigo.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
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
                color: Colors.indigo,
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
                color: Colors.indigo.shade600,
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
                    context.go('/shadow_matching?level=${widget.level + 1}');
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
    final maxScore = _totalRounds * [25, 30, 40][widget.level - 1];
    if (_score >= maxScore * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    final maxScore = _totalRounds * [25, 30, 40][widget.level - 1];
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
                  Colors.grey.shade50,
                  Colors.blueGrey.shade50,
                  Colors.indigo.shade50,
                  Colors.blue.shade50,
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
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTopBarButton(
            icon: Icons.arrow_back_rounded,
            color: Colors.indigo,
            onTap: () async {
              await _audioHelper.stopBackgroundMusic();
              if (context.mounted) {
                context.go('/shadow_matching-levels');
              }
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pronađi sjenu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade700,
                  ),
                ),
                Text(
                  'Level ${widget.level}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.indigo.shade500,
                  ),
                ),
              ],
            ),
          ),
          _buildTopBarButton(
            icon: _audioHelper.isBackgroundMusicPlaying
                ? Icons.volume_up
                : Icons.volume_off,
            color: Colors.blueGrey,
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
            color: Colors.blue,
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
                  'Bodovi', _score.toString(), Colors.indigo, Icons.star)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Runda', '$_currentRound/$_totalRounds',
                  Colors.blueGrey, Icons.flag)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Level', widget.level.toString(),
                  Colors.blue, Icons.trending_up)),
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
                colors: [Colors.indigo.shade400, Colors.blue.shade400],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.3),
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
                  child: const Icon(Icons.visibility,
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
    if (_currentObject == null) return const SizedBox.shrink();

    return Column(
      children: [
        // Object display area
        Expanded(
          flex: 2,
          child: _buildObjectArea(),
        ),

        const SizedBox(height: 20),

        // Shadows selection area
        Expanded(
          flex: 2,
          child: _buildShadowsArea(),
        ),
      ],
    );
  }

  Widget _buildObjectArea() {
    return AnimatedBuilder(
      animation: _objectRevealAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _objectRevealAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                  color: _currentObject!.color.withOpacity(0.3), width: 3),
              boxShadow: [
                BoxShadow(
                  color: _currentObject!.color.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Image.asset(
                _currentObject!.objectImagePath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image not found
                  return Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: _currentObject!.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      _getIconForObject(_currentObject!.id),
                      size: 80,
                      color: _currentObject!.color,
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShadowsArea() {
    return AnimatedBuilder(
      animation: _shadowRevealAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: _currentShadows.asMap().entries.map((entry) {
              final index = entry.key;
              final shadow = entry.value;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildShadowCard(shadow, index),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildShadowCard(ShadowOption shadow, int index) {
    final isSelected = _selectedShadow == shadow.id;
    final isCorrect = _showingResult && shadow.isCorrect;
    final isWrong = _showingResult && isSelected && !shadow.isCorrect;

    return AnimatedBuilder(
      animation: _shadowRevealAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _shadowRevealAnimation.value,
          child: GestureDetector(
            onTap: () => _onShadowTapped(shadow.id),
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isCorrect
                          ? [Colors.green.shade300, Colors.green.shade400]
                          : isWrong
                              ? [Colors.red.shade300, Colors.red.shade400]
                              : isSelected
                                  ? [
                                      Colors.indigo.shade300,
                                      Colors.indigo.shade400
                                    ]
                                  : [Colors.white, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green.shade500
                          : isWrong
                              ? Colors.red.shade500
                              : isSelected
                                  ? Colors.indigo.shade500
                                  : Colors.grey.shade300,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isCorrect
                            ? Colors.green.withOpacity(0.4)
                            : isWrong
                                ? Colors.red.withOpacity(0.4)
                                : isSelected
                                    ? Colors.indigo.withOpacity(0.4)
                                    : Colors.grey.withOpacity(
                                        0.1 + _glowAnimation.value * 0.2),
                        blurRadius: 15 + _glowAnimation.value * 10,
                        offset: const Offset(0, 5),
                        spreadRadius: _glowAnimation.value * 2,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      shadow.imagePath,
                      fit: BoxFit.contain,
                      color: Colors.black87,
                      colorBlendMode: BlendMode.multiply,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback shadow representation
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 40,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForObject(String objectId) {
    switch (objectId) {
      case 'apple':
        return Icons.apple;
      case 'banana':
        return Icons.set_meal;
      case 'car':
        return Icons.directions_car;
      case 'star':
        return Icons.star;
      case 'house':
        return Icons.home;
      case 'tree':
        return Icons.nature;
      case 'balloon':
        return Icons.celebration;
      case 'flower':
        return Icons.local_florist;
      default:
        return Icons.help_outline;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _objectRevealController.dispose();
    _shadowRevealController.dispose();
    _audioHelper.stopBackgroundMusic();
    super.dispose();
  }
}

// Model classes
class ShadowMatchingItem {
  final String id;
  final String name;
  final String objectImagePath;
  final String correctShadowPath;
  final List<String> wrongShadowPaths;
  final Color color;

  ShadowMatchingItem({
    required this.id,
    required this.name,
    required this.objectImagePath,
    required this.correctShadowPath,
    required this.wrongShadowPaths,
    required this.color,
  });
}

class ShadowOption {
  final String id;
  final String imagePath;
  final bool isCorrect;

  ShadowOption({
    required this.id,
    required this.imagePath,
    required this.isCorrect,
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

    for (int i = 0; i < 40; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -50.0;
      final endY = size.height + 50;
      final y = startY + (endY - startY) * progress;

      paint.color = [
        Colors.indigo.withOpacity(1 - progress),
        Colors.blueGrey.withOpacity(1 - progress),
        Colors.blue.withOpacity(1 - progress),
        Colors.grey.withOpacity(1 - progress),
      ][i % 4];

      if (i % 4 == 0) {
        canvas.drawCircle(Offset(x, y), 6, paint);
      } else if (i % 4 == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 10, height: 10),
          paint,
        );
      } else if (i % 4 == 2) {
        // Draw shadow-like shape
        final path = Path();
        path.addOval(
            Rect.fromCenter(center: Offset(x, y), width: 12, height: 8));
        canvas.drawPath(path, paint);
      } else {
        // Draw diamond
        final path = Path();
        path.moveTo(x, y - 6);
        path.lineTo(x + 4, y);
        path.lineTo(x, y + 6);
        path.lineTo(x - 4, y);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
