import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class OddOneOutGameScreen extends StatefulWidget {
  final int level;

  const OddOneOutGameScreen({super.key, required this.level});

  @override
  State<OddOneOutGameScreen> createState() => _OddOneOutGameScreenState();
}

class _OddOneOutGameScreenState extends State<OddOneOutGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late AnimationController _glowController;
  late AnimationController _progressController;
  late AnimationController _revealController;
  late AnimationController _pulseController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _revealAnimation;
  late Animation<double> _pulseAnimation;

  List<GameCategory> _allCategories = [];
  List<GameObjectItem> _currentObjects = [];
  GameObjectItem? _oddOneOut;

  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  bool _isProcessing = false;
  bool _showCelebration = false;
  bool _gameCompleted = false;
  bool _roundCompleted = false;
  bool _showingAnswer = false;

  String _currentInstruction = "";
  List<bool> _objectRevealed = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeCategories();
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

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    _shakeAnimation = Tween<double>(begin: 0.0, end: 15.0).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut));

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _celebrationController, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _progressController, curve: Curves.easeOutCubic));

    _revealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _revealController, curve: Curves.easeOutBack));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  void _initializeCategories() {
    _allCategories = [
      // Voće
      GameCategory(
        id: 'fruits',
        name: 'voće',
        items: [
          GameObjectItem(
              id: 'apple', name: 'jabuka', icon: '🍎', color: Colors.red),
          GameObjectItem(
              id: 'banana', name: 'banana', icon: '🍌', color: Colors.yellow),
          GameObjectItem(
              id: 'orange', name: 'narandža', icon: '🍊', color: Colors.orange),
          GameObjectItem(
              id: 'grapes', name: 'grožđe', icon: '🍇', color: Colors.purple),
          GameObjectItem(
              id: 'strawberry', name: 'jagoda', icon: '🍓', color: Colors.red),
        ],
      ),

      // Životinje
      GameCategory(
        id: 'animals',
        name: 'životinje',
        items: [
          GameObjectItem(
              id: 'dog', name: 'pas', icon: '🐕', color: Colors.brown),
          GameObjectItem(
              id: 'cat', name: 'mačka', icon: '🐱', color: Colors.orange),
          GameObjectItem(
              id: 'bird', name: 'ptica', icon: '🐦', color: Colors.blue),
          GameObjectItem(
              id: 'fish', name: 'riba', icon: '🐟', color: Colors.lightBlue),
          GameObjectItem(
              id: 'rabbit', name: 'zec', icon: '🐰', color: Colors.grey),
        ],
      ),

      // Vozila
      GameCategory(
        id: 'vehicles',
        name: 'vozila',
        items: [
          GameObjectItem(
              id: 'car', name: 'auto', icon: '🚗', color: Colors.blue),
          GameObjectItem(
              id: 'plane', name: 'avion', icon: '✈️', color: Colors.grey),
          GameObjectItem(
              id: 'boat', name: 'brod', icon: '⛵', color: Colors.cyan),
          GameObjectItem(
              id: 'bike', name: 'bicikl', icon: '🚲', color: Colors.red),
          GameObjectItem(
              id: 'train', name: 'voz', icon: '🚂', color: Colors.green),
        ],
      ),

      // Igračke
      GameCategory(
        id: 'toys',
        name: 'igračke',
        items: [
          GameObjectItem(
              id: 'ball', name: 'lopta', icon: '⚽', color: Colors.green),
          GameObjectItem(
              id: 'doll', name: 'lutka', icon: '🎎', color: Colors.pink),
          GameObjectItem(
              id: 'blocks', name: 'kocke', icon: '🧱', color: Colors.orange),
          GameObjectItem(
              id: 'teddy', name: 'meda', icon: '🧸', color: Colors.brown),
          GameObjectItem(
              id: 'puzzle', name: 'slagalica', icon: '🧩', color: Colors.blue),
        ],
      ),

      // Hrana
      GameCategory(
        id: 'food',
        name: 'hrana',
        items: [
          GameObjectItem(
              id: 'bread', name: 'hleb', icon: '🍞', color: Colors.brown),
          GameObjectItem(
              id: 'cheese', name: 'sir', icon: '🧀', color: Colors.yellow),
          GameObjectItem(
              id: 'meat', name: 'meso', icon: '🥩', color: Colors.red),
          GameObjectItem(
              id: 'cake', name: 'torta', icon: '🎂', color: Colors.pink),
          GameObjectItem(
              id: 'pizza', name: 'pica', icon: '🍕', color: Colors.orange),
        ],
      ),

      // Namještaj
      GameCategory(
        id: 'furniture',
        name: 'namještaj',
        items: [
          GameObjectItem(
              id: 'chair', name: 'stolica', icon: '🪑', color: Colors.brown),
          GameObjectItem(
              id: 'table', name: 'sto', icon: '🪑', color: Colors.brown),
          GameObjectItem(
              id: 'bed', name: 'krevet', icon: '🛏️', color: Colors.blue),
          GameObjectItem(
              id: 'lamp', name: 'lampa', icon: '💡', color: Colors.yellow),
          GameObjectItem(
              id: 'sofa', name: 'sofa', icon: '🛋️', color: Colors.grey),
        ],
      ),

      // Odjeća
      GameCategory(
        id: 'clothes',
        name: 'odjeća',
        items: [
          GameObjectItem(
              id: 'shirt', name: 'majica', icon: '👕', color: Colors.blue),
          GameObjectItem(
              id: 'pants', name: 'pantalone', icon: '👖', color: Colors.indigo),
          GameObjectItem(
              id: 'shoes', name: 'cipele', icon: '👟', color: Colors.red),
          GameObjectItem(
              id: 'hat', name: 'šešir', icon: '🎩', color: Colors.black),
          GameObjectItem(
              id: 'socks', name: 'čarape', icon: '🧦', color: Colors.grey),
        ],
      ),

      // Skolski pribor
      GameCategory(
        id: 'school',
        name: 'školski pribor',
        items: [
          GameObjectItem(
              id: 'pen', name: 'olovka', icon: '✏️', color: Colors.yellow),
          GameObjectItem(
              id: 'book', name: 'knjiga', icon: '📚', color: Colors.blue),
          GameObjectItem(
              id: 'ruler', name: 'lenjir', icon: '📏', color: Colors.grey),
          GameObjectItem(
              id: 'scissors', name: 'makaze', icon: '✂️', color: Colors.white),
          GameObjectItem(
              id: 'bag', name: 'torba', icon: '🎒', color: Colors.green),
        ],
      ),
    ];
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic('odd_one_out_background.mp3', loop: true);
    _audioHelper.setBackgroundMusicVolume(0.22);
    _audioHelper.setSoundEffectsVolume(0.85);
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
      _showingAnswer = false;
      _currentRound++;
      _objectRevealed = [false, false, false, false];
      _generateRoundObjects();
    });

    _progressController.reset();
    _progressController.forward();

    await _audioHelper.playSoundSequence([
      'odd_one_out_instrukcija.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 1000));

    // Reveal objects one by one with animation
    for (int i = 0; i < 4; i++) {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        _objectRevealed[i] = true;
      });
      await _audioHelper.playSound('object_reveal.mp3');
    }

    await Future.delayed(const Duration(milliseconds: 500));
    await _audioHelper.playSound('koji_ne_pripada.mp3');
  }

  void _generateRoundObjects() {
    _currentObjects.clear();

    // Select main category (3 objects from this category)
    final availableCategories = List<GameCategory>.from(_allCategories);
    availableCategories.shuffle();
    final mainCategory = availableCategories.first;

    // Select 3 objects from main category
    final mainObjects = List<GameObjectItem>.from(mainCategory.items);
    mainObjects.shuffle();
    final selectedMainObjects = mainObjects.take(3).toList();

    // Select odd one out from different category
    GameObjectItem oddObject;

    switch (widget.level) {
      case 1:
        // Level 1: Very different categories (easy)
        oddObject = _selectObviousOddOne(mainCategory);
        _currentInstruction = "Koji objekat ne pripada grupi?";
        break;
      case 2:
        // Level 2: Somewhat similar but different categories
        oddObject = _selectModerateOddOne(mainCategory);
        _currentInstruction = "Pažljivo pogledaj - koji je drugačiji?";
        break;
      case 3:
        // Level 3: Subtle differences
        oddObject = _selectSubtleOddOne(mainCategory, selectedMainObjects);
        _currentInstruction = "Vrlo pažljivo - koji ne pripada?";
        break;
      default:
        oddObject = _selectObviousOddOne(mainCategory);
        _currentInstruction = "Koji objekat ne pripada grupi?";
    }

    // Combine objects and shuffle
    _currentObjects = [...selectedMainObjects, oddObject];
    _currentObjects.shuffle();
    _oddOneOut = oddObject;
  }

  GameObjectItem _selectObviousOddOne(GameCategory mainCategory) {
    // Select from completely different category
    final differentCategories =
        _allCategories.where((cat) => cat.id != mainCategory.id).toList();
    differentCategories.shuffle();

    final oddCategory = differentCategories.first;
    final oddItems = List<GameObjectItem>.from(oddCategory.items);
    oddItems.shuffle();

    return oddItems.first;
  }

  GameObjectItem _selectModerateOddOne(GameCategory mainCategory) {
    // Try to select from somewhat related but different category
    final differentCategories =
        _allCategories.where((cat) => cat.id != mainCategory.id).toList();
    differentCategories.shuffle();

    final oddCategory = differentCategories.first;
    final oddItems = List<GameObjectItem>.from(oddCategory.items);
    oddItems.shuffle();

    return oddItems.first;
  }

  GameObjectItem _selectSubtleOddOne(
      GameCategory mainCategory, List<GameObjectItem> mainObjects) {
    // For level 3, try to create subtle differences within similar items
    final differentCategories =
        _allCategories.where((cat) => cat.id != mainCategory.id).toList();
    differentCategories.shuffle();

    final oddCategory = differentCategories.first;
    final oddItems = List<GameObjectItem>.from(oddCategory.items);
    oddItems.shuffle();

    return oddItems.first;
  }

  void _onObjectTapped(GameObjectItem object, int index) async {
    if (_isProcessing || _roundCompleted || _showingAnswer) return;

    setState(() {
      _isProcessing = true;
    });

    await _audioHelper.playSound('object_tap.mp3');

    if (object.id == _oddOneOut!.id) {
      // Correct answer!
      await _onCorrectAnswer(index);
    } else {
      // Wrong answer
      await _onWrongAnswer(index);
    }
  }

  Future<void> _onCorrectAnswer(int index) async {
    await _audioHelper.playSoundSequence([
      'correct_answer.mp3',
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

    setState(() {
      _score += (20 * widget.level);
    });

    await Future.delayed(const Duration(milliseconds: 2500));
    _startNewRound();
  }

  Future<void> _onWrongAnswer(int index) async {
    _shakeController.forward().then((_) {
      _shakeController.reset();
    });

    await _audioHelper.playSoundSequence([
      'wrong_answer.mp3',
      'pokusaj_ponovo.mp3',
    ]);

    // Show the correct answer briefly
    setState(() {
      _showingAnswer = true;
    });

    _pulseController.repeat(reverse: true);

    await Future.delayed(const Duration(milliseconds: 2000));

    _pulseController.stop();
    _pulseController.reset();

    setState(() {
      _showingAnswer = false;
      _isProcessing = false;
    });
  }

  void _resetRound() async {
    if (_isProcessing) return;

    await _audioHelper.playSound('reset_sound.mp3');
    _startNewRound();
  }

  void _showWinDialog() async {
    await _progressTracker.saveModuleProgress('odd_one_out', widget.level, 3);
    await _progressTracker.saveHighScore('odd_one_out', _score);
    await _progressTracker.incrementAttempts('odd_one_out');

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
              Colors.amber.shade100,
              Colors.orange.shade50,
              Colors.red.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(0.3),
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
                color: Colors.amber,
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
                color: Colors.amber.shade600,
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
                    context.go('/odd_one_out?level=${widget.level + 1}');
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
    final maxScore = _totalRounds * 20 * widget.level;
    if (_score >= maxScore * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    final maxScore = _totalRounds * 20 * widget.level;
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
                  Colors.amber.shade50,
                  Colors.orange.shade50,
                  Colors.red.shade50,
                  Colors.purple.shade50,
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
            color: Colors.amber.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTopBarButton(
            icon: Icons.arrow_back_rounded,
            color: Colors.amber,
            onTap: () async {
              await _audioHelper.stopBackgroundMusic();
              if (context.mounted) {
                context.go('/odd_one_out-levels');
              }
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Koji ne pripada?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
                ),
                Text(
                  'Level ${widget.level}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.amber.shade500,
                  ),
                ),
              ],
            ),
          ),
          _buildTopBarButton(
            icon: _audioHelper.isBackgroundMusicPlaying
                ? Icons.volume_up
                : Icons.volume_off,
            color: Colors.blue,
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
            color: Colors.orange,
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
                  'Bodovi', _score.toString(), Colors.amber, Icons.star)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Runda', '$_currentRound/$_totalRounds',
                  Colors.red, Icons.flag)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Level', widget.level.toString(),
                  Colors.purple, Icons.trending_up)),
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
                colors: [Colors.amber.shade400, Colors.orange.shade400],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
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
                  child:
                      const Icon(Icons.search, color: Colors.white, size: 24),
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
    return Container(
      margin: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = min(constraints.maxWidth, constraints.maxHeight) / 2.2;
          return Center(
            child: SizedBox(
              width: size * 2,
              height: size * 2,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  if (index >= _currentObjects.length) {
                    return const SizedBox.shrink();
                  }
                  return _buildObjectCard(_currentObjects[index], index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildObjectCard(GameObjectItem object, int index) {
    final isOddOne = object.id == _oddOneOut?.id;
    final isRevealed = _objectRevealed[index];

    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _isProcessing && !_roundCompleted
                            ? sin(_shakeAnimation.value) * 2
                            : 0,
                        0,
                      ),
                      child: Transform.scale(
                        scale: isRevealed ? 1.0 : 0.0,
                        child: Transform.scale(
                          scale: _showingAnswer && isOddOne
                              ? _pulseAnimation.value
                              : 1.0,
                          child: GestureDetector(
                            onTap: () => _onObjectTapped(object, index),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _showingAnswer && isOddOne
                                      ? [
                                          Colors.green.shade300,
                                          Colors.green.shade400
                                        ]
                                      : [
                                          Colors.white,
                                          Colors.white,
                                          object.color.withOpacity(0.1),
                                        ],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                border: _showingAnswer && isOddOne
                                    ? Border.all(color: Colors.green, width: 4)
                                    : Border.all(
                                        color: object.color.withOpacity(0.3),
                                        width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: _showingAnswer && isOddOne
                                        ? Colors.green.withOpacity(0.4)
                                        : object.color.withOpacity(
                                            0.2 + _glowAnimation.value * 0.3),
                                    blurRadius: _showingAnswer && isOddOne
                                        ? 25
                                        : 15 + _glowAnimation.value * 10,
                                    offset: const Offset(0, 5),
                                    spreadRadius: _showingAnswer && isOddOne
                                        ? 3
                                        : _glowAnimation.value * 2,
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: object.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      object.icon,
                                      style: const TextStyle(
                                        fontSize: 48,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    object.name,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: object.color.withOpacity(0.8),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _revealController.dispose();
    _pulseController.dispose();
    _audioHelper.stopBackgroundMusic();
    super.dispose();
  }
}

// Model classes
class GameCategory {
  final String id;
  final String name;
  final List<GameObjectItem> items;

  GameCategory({
    required this.id,
    required this.name,
    required this.items,
  });
}

class GameObjectItem {
  final String id;
  final String name;
  final String icon;
  final Color color;

  GameObjectItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameObjectItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Celebration painter
class CelebrationPainter extends CustomPainter {
  final double progress;
  final Random random = Random(42);

  CelebrationPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final startY = -50.0;
      final endY = size.height + 50;
      final y = startY + (endY - startY) * progress;

      paint.color = [
        Colors.amber.withOpacity(1 - progress),
        Colors.orange.withOpacity(1 - progress),
        Colors.red.withOpacity(1 - progress),
        Colors.purple.withOpacity(1 - progress),
      ][i % 4];

      if (i % 4 == 0) {
        canvas.drawCircle(Offset(x, y), 6, paint);
      } else if (i % 4 == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 8),
          paint,
        );
      } else if (i % 4 == 2) {
        final path = Path();
        path.moveTo(x, y - 6);
        path.lineTo(x - 5, y + 4);
        path.lineTo(x + 5, y + 4);
        path.close();
        canvas.drawPath(path, paint);
      } else {
        final rect = RRect.fromLTRBR(
            x - 4, y - 4, x + 4, y + 4, const Radius.circular(2));
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
