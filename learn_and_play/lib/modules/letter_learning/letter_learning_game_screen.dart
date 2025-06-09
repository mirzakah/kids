import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class LetterLearningGameScreen extends StatefulWidget {
  final int level;

  const LetterLearningGameScreen({super.key, required this.level});

  @override
  State<LetterLearningGameScreen> createState() =>
      _LetterLearningGameScreenState();
}

class _LetterLearningGameScreenState extends State<LetterLearningGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late AnimationController _glowController;
  late AnimationController _progressController;
  late AnimationController _letterRevealController;
  late AnimationController _pulseController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _letterRevealAnimation;
  late Animation<double> _pulseAnimation;

  List<String> _availableLetters = [];
  List<String> _currentRoundLetters = [];
  String _targetLetter = '';
  String? _selectedLetter;

  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  bool _isProcessing = false;
  bool _showCelebration = false;
  bool _gameCompleted = false;
  bool _roundCompleted = false;
  bool _showingResult = false;

  String _currentInstruction = "";
  GameMode _currentMode = GameMode.audioRecognition;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeLetters();
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

    _letterRevealController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _letterRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _letterRevealController, curve: Curves.easeOutBack));

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  void _initializeLetters() {
    // Full alphabet for learning
    _availableLetters = [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
      'G',
      'H',
      'I',
      'J',
      'K',
      'L',
      'M',
      'N',
      'O',
      'P',
      'Q',
      'R',
      'S',
      'T',
      'U',
      'V',
      'W',
      'X',
      'Y',
      'Z'
    ];
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic('letter_learning_background.mp3',
        loop: true);
    _audioHelper.setBackgroundMusicVolume(0.18);
    _audioHelper.setSoundEffectsVolume(0.75);
  }

  void _initializeGame() {
    switch (widget.level) {
      case 1:
        _totalRounds = 10;
        break;
      case 2:
        _totalRounds = 12;
        break;
      case 3:
        _totalRounds = 15;
        break;
      default:
        _totalRounds = 10;
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
      _selectedLetter = null;
      _currentRound++;
      _generateRound();
    });

    _progressController.reset();
    _progressController.forward();

    await _audioHelper.playSoundSequence([
      'letter_learning_instrukcija.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 800));

    // Reveal letters with animation
    _letterRevealController.forward();

    await Future.delayed(const Duration(milliseconds: 600));

    // Give specific instruction based on mode
    await _giveRoundInstruction();
  }

  void _generateRound() {
    switch (widget.level) {
      case 1:
        _generateLevel1Round();
        break;
      case 2:
        _generateLevel2Round();
        break;
      case 3:
        _generateLevel3Round();
        break;
    }
  }

  void _generateLevel1Round() {
    // Level 1: Uppercase letters - audio recognition
    _currentMode = GameMode.audioRecognition;

    // Select target letter
    _targetLetter = _availableLetters[_currentRound % _availableLetters.length];

    // Create set of letters including target + 5 random others
    final otherLetters =
        _availableLetters.where((l) => l != _targetLetter).toList();
    otherLetters.shuffle();

    _currentRoundLetters = [_targetLetter, ...otherLetters.take(5)];
    _currentRoundLetters.shuffle();

    _currentInstruction = "Tapni slovo koje čuješ!";
  }

  void _generateLevel2Round() {
    // Level 2: Lowercase letters - audio recognition
    _currentMode = GameMode.audioRecognition;

    // Select target letter (convert to lowercase)
    final upperTarget =
        _availableLetters[_currentRound % _availableLetters.length];
    _targetLetter = upperTarget.toLowerCase();

    // Create set of lowercase letters
    final otherLetters = _availableLetters
        .where((l) => l != upperTarget)
        .map((l) => l.toLowerCase())
        .toList();
    otherLetters.shuffle();

    _currentRoundLetters = [_targetLetter, ...otherLetters.take(5)];
    _currentRoundLetters.shuffle();

    _currentInstruction = "Tapni malo slovo koje čuješ!";
  }

  void _generateLevel3Round() {
    // Level 3: Mixed case - matching game
    if (_currentRound % 2 == 0) {
      _generateMatchingRound();
    } else {
      _generateMixedRecognitionRound();
    }
  }

  void _generateMatchingRound() {
    // Matching: Show uppercase, find lowercase (or vice versa)
    _currentMode = GameMode.matching;

    final baseLetter =
        _availableLetters[_currentRound % _availableLetters.length];
    final showUppercase = Random().nextBool();

    if (showUppercase) {
      _targetLetter = baseLetter; // Show uppercase
      // Create options with lowercase letters
      final otherLetters = _availableLetters
          .where((l) => l != baseLetter)
          .map((l) => l.toLowerCase())
          .toList();
      otherLetters.shuffle();

      _currentRoundLetters = [
        baseLetter.toLowerCase(),
        ...otherLetters.take(5)
      ];
      _currentRoundLetters.shuffle();

      _currentInstruction = "Pronađi malo slovo za: $_targetLetter";
    } else {
      _targetLetter = baseLetter.toLowerCase(); // Show lowercase
      // Create options with uppercase letters
      final otherLetters =
          _availableLetters.where((l) => l != baseLetter).toList();
      otherLetters.shuffle();

      _currentRoundLetters = [baseLetter, ...otherLetters.take(5)];
      _currentRoundLetters.shuffle();

      _currentInstruction = "Pronađi veliko slovo za: $_targetLetter";
    }
  }

  void _generateMixedRecognitionRound() {
    // Mixed recognition: Random upper/lower case
    _currentMode = GameMode.audioRecognition;

    final baseLetter =
        _availableLetters[_currentRound % _availableLetters.length];
    final useUppercase = Random().nextBool();

    _targetLetter = useUppercase ? baseLetter : baseLetter.toLowerCase();

    // Mix of upper and lower case letters
    final upperOthers =
        _availableLetters.where((l) => l != baseLetter).toList();
    final lowerOthers = upperOthers.map((l) => l.toLowerCase()).toList();
    final allOthers = [...upperOthers, ...lowerOthers];
    allOthers.shuffle();

    _currentRoundLetters = [_targetLetter, ...allOthers.take(5)];
    _currentRoundLetters.shuffle();

    _currentInstruction = "Tapni slovo koje čuješ!";
  }

  Future<void> _giveRoundInstruction() async {
    switch (_currentMode) {
      case GameMode.audioRecognition:
        await Future.delayed(const Duration(milliseconds: 500));
        await _audioHelper
            .playSound('slovo_${_targetLetter.toLowerCase()}.mp3');
        break;
      case GameMode.matching:
        // Already given in instruction
        break;
    }
  }

  void _onLetterTapped(String letter) async {
    if (_isProcessing || _roundCompleted) return;

    setState(() {
      _selectedLetter = letter;
      _isProcessing = true;
    });

    await _audioHelper.playSound('letter_tap.mp3');
    await Future.delayed(const Duration(milliseconds: 300));

    _checkAnswer(letter);
  }

  void _checkAnswer(String selectedLetter) async {
    bool isCorrect = false;

    switch (_currentMode) {
      case GameMode.audioRecognition:
        isCorrect = selectedLetter == _targetLetter;
        break;
      case GameMode.matching:
        // Check if selected letter is the matching case
        isCorrect =
            selectedLetter.toLowerCase() == _targetLetter.toLowerCase() &&
                selectedLetter != _targetLetter;
        break;
    }

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
      'letter_correct.mp3',
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

    final baseScore = [20, 25, 35][widget.level - 1];
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
      'letter_wrong.mp3',
      'pokusaj_ponovo.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _showingResult = false;
      _isProcessing = false;
      _selectedLetter = null;
    });
  }

  void _resetRound() async {
    if (_isProcessing) return;

    await _audioHelper.playSound('reset_sound.mp3');

    setState(() {
      _selectedLetter = null;
      _showingResult = false;
      _isProcessing = false;
    });

    _letterRevealController.reset();
    await Future.delayed(const Duration(milliseconds: 300));
    _letterRevealController.forward();

    await Future.delayed(const Duration(milliseconds: 600));
    await _giveRoundInstruction();
  }

  void _showWinDialog() async {
    await _progressTracker.saveModuleProgress(
        'letter_learning', widget.level, 3);
    await _progressTracker.saveHighScore('letter_learning', _score);
    await _progressTracker.incrementAttempts('letter_learning');

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
              Colors.purple.shade100,
              Colors.indigo.shade50,
              Colors.blue.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
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
                color: Colors.purple,
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
                color: Colors.purple.shade600,
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
                    context.go('/letter_learning?level=${widget.level + 1}');
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
    final maxScore = _totalRounds * [20, 25, 35][widget.level - 1];
    if (_score >= maxScore * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    final maxScore = _totalRounds * [20, 25, 35][widget.level - 1];
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
                  Colors.purple.shade50,
                  Colors.indigo.shade50,
                  Colors.blue.shade50,
                  Colors.cyan.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  _buildProgressSection(),
                  _buildInstructionCard(),
                  if (_currentMode == GameMode.matching)
                    _buildTargetLetterCard(),
                  Expanded(child: _buildLettersGrid()),
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
            color: Colors.purple.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTopBarButton(
            icon: Icons.arrow_back_rounded,
            color: Colors.purple,
            onTap: () async {
              await _audioHelper.stopBackgroundMusic();
              if (context.mounted) {
                context.go('/letter_learning-levels');
              }
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Učimo slova',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                Text(
                  'Level ${widget.level}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.purple.shade500,
                  ),
                ),
              ],
            ),
          ),
          _buildTopBarButton(
            icon: _audioHelper.isBackgroundMusicPlaying
                ? Icons.volume_up
                : Icons.volume_off,
            color: Colors.indigo,
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
                  'Bodovi', _score.toString(), Colors.purple, Icons.star)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Runda', '$_currentRound/$_totalRounds',
                  Colors.indigo, Icons.flag)),
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
                colors: [Colors.purple.shade400, Colors.indigo.shade400],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
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
                  child: const Icon(Icons.abc, color: Colors.white, size: 24),
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

  Widget _buildTargetLetterCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.purple.shade300, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _targetLetter,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [Colors.purple.shade600, Colors.indigo.shade600],
              ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildLettersGrid() {
    return AnimatedBuilder(
      animation: _letterRevealAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.all(16),
          child: GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: _currentRoundLetters.length,
            itemBuilder: (context, index) {
              final letter = _currentRoundLetters[index];
              return _buildLetterCard(letter, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildLetterCard(String letter, int index) {
    final isSelected = _selectedLetter == letter;
    final isCorrect = _showingResult && _checkIfCorrectLetter(letter);
    final isWrong =
        _showingResult && isSelected && !_checkIfCorrectLetter(letter);

    return AnimatedBuilder(
      animation: _letterRevealAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _letterRevealAnimation.value,
          child: GestureDetector(
            onTap: () => _onLetterTapped(letter),
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
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
                                      Colors.purple.shade300,
                                      Colors.purple.shade400
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
                                  ? Colors.purple.shade500
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
                                    ? Colors.purple.withOpacity(0.4)
                                    : Colors.grey.withOpacity(
                                        0.1 + _glowAnimation.value * 0.2),
                        blurRadius: 15 + _glowAnimation.value * 10,
                        offset: const Offset(0, 5),
                        spreadRadius: _glowAnimation.value * 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      letter,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isCorrect || isWrong || isSelected
                            ? Colors.white
                            : Colors.grey.shade700,
                      ),
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

  bool _checkIfCorrectLetter(String letter) {
    switch (_currentMode) {
      case GameMode.audioRecognition:
        return letter == _targetLetter;
      case GameMode.matching:
        return letter.toLowerCase() == _targetLetter.toLowerCase() &&
            letter != _targetLetter;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _letterRevealController.dispose();
    _pulseController.dispose();
    _audioHelper.stopBackgroundMusic();
    super.dispose();
  }
}

// Enums
enum GameMode { audioRecognition, matching }

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
        Colors.purple.withOpacity(1 - progress),
        Colors.indigo.withOpacity(1 - progress),
        Colors.blue.withOpacity(1 - progress),
        Colors.cyan.withOpacity(1 - progress),
      ][i % 4];

      // Draw letter-like shapes
      if (i % 5 == 0) {
        canvas.drawCircle(Offset(x, y), 6, paint);
      } else if (i % 5 == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 10, height: 12),
          paint,
        );
      } else if (i % 5 == 2) {
        // Draw A-like shape
        final path = Path();
        path.moveTo(x, y + 6);
        path.lineTo(x - 4, y - 6);
        path.lineTo(x + 4, y - 6);
        path.close();
        canvas.drawPath(path, paint);
      } else if (i % 5 == 3) {
        // Draw letter-like rectangle
        canvas.drawRRect(
          RRect.fromLTRBR(x - 3, y - 6, x + 3, y + 6, const Radius.circular(2)),
          paint,
        );
      } else {
        // Draw cross
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 2),
          paint,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 2, height: 8),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
