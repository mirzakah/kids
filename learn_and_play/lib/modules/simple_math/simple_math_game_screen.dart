import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class SimpleMathGameScreen extends StatefulWidget {
  final int level;

  const SimpleMathGameScreen({super.key, required this.level});

  @override
  State<SimpleMathGameScreen> createState() => _SimpleMathGameScreenState();
}

class _SimpleMathGameScreenState extends State<SimpleMathGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late AnimationController _glowController;
  late AnimationController _progressController;
  late AnimationController _equationController;
  late AnimationController _keyboardController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _equationAnimation;
  late Animation<double> _keyboardAnimation;

  MathEquation? _currentEquation;
  List<int> _answerChoices = [];
  String _userAnswer = "";

  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  bool _isProcessing = false;
  bool _showCelebration = false;
  bool _gameCompleted = false;
  bool _roundCompleted = false;
  bool _showingResult = false;

  String _currentInstruction = "";
  int? _selectedChoice;

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _equationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _keyboardController = AnimationController(
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

    _equationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _equationController, curve: Curves.easeOutBack));

    _keyboardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _keyboardController, curve: Curves.easeOutBack));
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic('simple_math_background.mp3', loop: true);
    _audioHelper.setBackgroundMusicVolume(0.20);
    _audioHelper.setSoundEffectsVolume(0.80);
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
      _currentRound++;
      _userAnswer = "";
      _selectedChoice = null;
      _generateEquation();
    });

    _progressController.reset();
    _progressController.forward();

    await _audioHelper.playSoundSequence([
      'simple_math_instrukcija.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 800));

    // Animate equation appearance
    _equationController.forward();

    await Future.delayed(const Duration(milliseconds: 500));

    if (widget.level < 3) {
      // Show answer choices for levels 1 & 2
      await _audioHelper.playSound('odaberi_odgovor.mp3');
    } else {
      // Show keyboard for level 3
      _keyboardController.forward();
      await _audioHelper.playSound('ukucaj_odgovor.mp3');
    }
  }

  void _generateEquation() {
    final random = Random();

    switch (widget.level) {
      case 1:
        _generateLevel1Equation(random);
        _currentInstruction = "Reši zadatak i odaberi odgovor!";
        break;
      case 2:
        _generateLevel2Equation(random);
        _currentInstruction = "Izračunaj i odaberi tačan odgovor!";
        break;
      case 3:
        _generateLevel3Equation(random);
        _currentInstruction = "Reši zadatak i ukucaj odgovor!";
        break;
    }

    if (widget.level < 3) {
      _generateAnswerChoices();
    }
  }

  void _generateLevel1Equation(Random random) {
    // Level 1: Simple addition and subtraction (1-10)
    final operations = ['+', '-'];
    final operation = operations[random.nextInt(operations.length)];

    int num1, num2, result;

    if (operation == '+') {
      num1 = 1 + random.nextInt(9); // 1-9
      num2 = 1 + random.nextInt(10 - num1); // Ensure result ≤ 10
      result = num1 + num2;
    } else {
      num1 = 2 + random.nextInt(9); // 2-10
      num2 = 1 + random.nextInt(num1); // 1 to num1
      result = num1 - num2;
    }

    _currentEquation = MathEquation(
      num1: num1,
      num2: num2,
      operation: operation,
      result: result,
    );
  }

  void _generateLevel2Equation(Random random) {
    // Level 2: Addition, subtraction, multiplication (1-20)
    final operations = ['+', '-', '×'];
    final operation = operations[random.nextInt(operations.length)];

    int num1, num2, result;

    switch (operation) {
      case '+':
        num1 = 5 + random.nextInt(11); // 5-15
        num2 = 1 + random.nextInt(min(10, 20 - num1)); // Ensure result ≤ 20
        result = num1 + num2;
        break;
      case '-':
        num1 = 6 + random.nextInt(15); // 6-20
        num2 = 1 + random.nextInt(min(10, num1)); // 1 to min(10, num1)
        result = num1 - num2;
        break;
      case '×':
        num1 = 2 + random.nextInt(6); // 2-7
        num2 = 2 + random.nextInt(5); // 2-6
        if (num1 * num2 > 30) {
          num1 = 2 + random.nextInt(4); // Reduce if too large
          num2 = 2 + random.nextInt(4);
        }
        result = num1 * num2;
        break;
      default:
        _generateLevel1Equation(random);
        return;
    }

    _currentEquation = MathEquation(
      num1: num1,
      num2: num2,
      operation: operation,
      result: result,
    );
  }

  void _generateLevel3Equation(Random random) {
    // Level 3: All operations including division (1-50)
    final operations = ['+', '-', '×', '÷'];
    final operation = operations[random.nextInt(operations.length)];

    int num1, num2, result;

    switch (operation) {
      case '+':
        num1 = 10 + random.nextInt(21); // 10-30
        num2 = 5 + random.nextInt(16); // 5-20
        result = num1 + num2;
        break;
      case '-':
        num1 = 15 + random.nextInt(36); // 15-50
        num2 = 3 + random.nextInt(min(15, num1 - 1)); // Ensure positive result
        result = num1 - num2;
        break;
      case '×':
        num1 = 3 + random.nextInt(7); // 3-9
        num2 = 2 + random.nextInt(6); // 2-7
        result = num1 * num2;
        break;
      case '÷':
        // Generate division that results in whole numbers
        result = 2 + random.nextInt(9); // 2-10
        num2 = 2 + random.nextInt(6); // 2-7
        num1 = result * num2;
        break;
      default:
        _generateLevel2Equation(random);
        return;
    }

    _currentEquation = MathEquation(
      num1: num1,
      num2: num2,
      operation: operation,
      result: result,
    );
  }

  void _generateAnswerChoices() {
    if (_currentEquation == null) return;

    final correctAnswer = _currentEquation!.result;
    final random = Random();
    final choices = <int>{correctAnswer};

    // Generate 3 wrong answers
    while (choices.length < 4) {
      int wrongAnswer;

      if (widget.level == 1) {
        // For level 1, keep wrong answers close but reasonable
        wrongAnswer = max(0, correctAnswer + random.nextInt(7) - 3);
      } else {
        // For level 2, slightly wider range
        wrongAnswer = max(0, correctAnswer + random.nextInt(11) - 5);
      }

      if (wrongAnswer != correctAnswer && wrongAnswer >= 0) {
        choices.add(wrongAnswer);
      }
    }

    _answerChoices = choices.toList()..shuffle();
  }

  void _onChoiceSelected(int choice) async {
    if (_isProcessing || _roundCompleted) return;

    setState(() {
      _selectedChoice = choice;
      _isProcessing = true;
    });

    await _audioHelper.playSound('choice_select.mp3');
    await Future.delayed(const Duration(milliseconds: 500));

    _checkAnswer(choice);
  }

  void _onKeyboardInput(String input) {
    if (_isProcessing || _roundCompleted) return;

    setState(() {
      if (input == 'backspace') {
        if (_userAnswer.isNotEmpty) {
          _userAnswer = _userAnswer.substring(0, _userAnswer.length - 1);
        }
      } else if (input == 'enter') {
        if (_userAnswer.isNotEmpty) {
          _submitAnswer();
        }
      } else if (_userAnswer.length < 3) {
        // Limit to 3 digits
        _userAnswer += input;
      }
    });

    _audioHelper.playSound('key_press.mp3');
  }

  void _submitAnswer() async {
    final userNum = int.tryParse(_userAnswer);
    if (userNum == null) return;

    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    _checkAnswer(userNum);
  }

  void _checkAnswer(int answer) async {
    final isCorrect = answer == _currentEquation!.result;

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
      'correct_math.mp3',
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

    final baseScore = [10, 15, 25][widget.level - 1];
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
      'wrong_math.mp3',
      'pokusaj_ponovo.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 2000));

    setState(() {
      _showingResult = false;
      _isProcessing = false;
      _selectedChoice = null;
      _userAnswer = "";
    });
  }

  void _resetRound() async {
    if (_isProcessing) return;

    await _audioHelper.playSound('reset_sound.mp3');

    setState(() {
      _selectedChoice = null;
      _userAnswer = "";
      _showingResult = false;
      _isProcessing = false;
    });

    _equationController.reset();
    _keyboardController.reset();

    await Future.delayed(const Duration(milliseconds: 300));
    _startNewRound();
  }

  void _showWinDialog() async {
    await _progressTracker.saveModuleProgress('simple_math', widget.level, 3);
    await _progressTracker.saveHighScore('simple_math', _score);
    await _progressTracker.incrementAttempts('simple_math');

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
              Colors.blue.shade100,
              Colors.cyan.shade50,
              Colors.teal.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
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
                color: Colors.blue,
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
                color: Colors.blue.shade600,
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
                    context.go('/simple_math?level=${widget.level + 1}');
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
    final maxScore = _totalRounds * [10, 15, 25][widget.level - 1];
    if (_score >= maxScore * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    final maxScore = _totalRounds * [10, 15, 25][widget.level - 1];
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
                  Colors.blue.shade50,
                  Colors.cyan.shade50,
                  Colors.teal.shade50,
                  Colors.lightBlue.shade50,
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
            color: Colors.blue.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTopBarButton(
            icon: Icons.arrow_back_rounded,
            color: Colors.blue,
            onTap: () async {
              await _audioHelper.stopBackgroundMusic();
              if (context.mounted) {
                context.go('/simple_math-levels');
              }
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jednostavna matematika',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
                Text(
                  'Level ${widget.level}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade500,
                  ),
                ),
              ],
            ),
          ),
          _buildTopBarButton(
            icon: _audioHelper.isBackgroundMusicPlaying
                ? Icons.volume_up
                : Icons.volume_off,
            color: Colors.cyan,
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
            color: Colors.teal,
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
                  'Bodovi', _score.toString(), Colors.blue, Icons.star)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Runda', '$_currentRound/$_totalRounds',
                  Colors.cyan, Icons.flag)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Level', widget.level.toString(),
                  Colors.teal, Icons.trending_up)),
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
                colors: [Colors.blue.shade400, Colors.cyan.shade400],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
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
                  child: const Icon(Icons.calculate,
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
    return Column(
      children: [
        Expanded(flex: 2, child: _buildEquationArea()),
        const SizedBox(height: 16),
        Expanded(flex: 3, child: _buildAnswerArea()),
      ],
    );
  }

  Widget _buildEquationArea() {
    if (_currentEquation == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _equationAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _equationAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildNumberCard(
                      _currentEquation!.num1.toString(), Colors.blue),
                  const SizedBox(width: 20),
                  _buildOperatorCard(_currentEquation!.operation),
                  const SizedBox(width: 20),
                  _buildNumberCard(
                      _currentEquation!.num2.toString(), Colors.cyan),
                  const SizedBox(width: 20),
                  _buildOperatorCard('='),
                  const SizedBox(width: 20),
                  _buildAnswerCard(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNumberCard(String number, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        number,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildOperatorCard(String operator) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Text(
        operator,
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildAnswerCard() {
    String displayText = '?';
    Color backgroundColor = Colors.grey.shade100;
    Color textColor = Colors.grey.shade600;

    if (_showingResult) {
      displayText = _currentEquation!.result.toString();
      backgroundColor = Colors.green.shade100;
      textColor = Colors.green.shade700;
    } else if (widget.level == 3 && _userAnswer.isNotEmpty) {
      displayText = _userAnswer;
      backgroundColor = Colors.orange.shade100;
      textColor = Colors.orange.shade700;
    }

    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color:
                  _showingResult ? Colors.green.shade300 : Colors.grey.shade300,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _showingResult
                    ? Colors.green.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1 + _glowAnimation.value * 0.2),
                blurRadius: 8 + _glowAnimation.value * 5,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerArea() {
    if (widget.level < 3) {
      return _buildChoicesArea();
    } else {
      return _buildKeyboardArea();
    }
  }

  Widget _buildChoicesArea() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2,
        ),
        itemCount: _answerChoices.length,
        itemBuilder: (context, index) {
          final choice = _answerChoices[index];
          final isSelected = _selectedChoice == choice;
          final isCorrect =
              _showingResult && choice == _currentEquation!.result;
          final isWrong = _showingResult &&
              isSelected &&
              choice != _currentEquation!.result;

          return GestureDetector(
            onTap: () => _onChoiceSelected(choice),
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isCorrect
                          ? [Colors.green.shade300, Colors.green.shade400]
                          : isWrong
                              ? [Colors.red.shade300, Colors.red.shade400]
                              : isSelected
                                  ? [Colors.blue.shade300, Colors.blue.shade400]
                                  : [Colors.white, Colors.grey.shade50],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isCorrect
                          ? Colors.green.shade500
                          : isWrong
                              ? Colors.red.shade500
                              : isSelected
                                  ? Colors.blue.shade500
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
                                    ? Colors.blue.withOpacity(0.4)
                                    : Colors.grey.withOpacity(
                                        0.1 + _glowAnimation.value * 0.2),
                        blurRadius: 10 + _glowAnimation.value * 8,
                        offset: const Offset(0, 5),
                        spreadRadius: _glowAnimation.value * 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      choice.toString(),
                      style: TextStyle(
                        fontSize: 28,
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
          );
        },
      ),
    );
  }

  Widget _buildKeyboardArea() {
    return AnimatedBuilder(
      animation: _keyboardAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, 100 * (1 - _keyboardAnimation.value)),
          child: Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Number pad
                Expanded(
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 10, // 0-9
                    itemBuilder: (context, index) {
                      // Arrange numbers like phone keypad: 1,2,3,4,5,6,7,8,9,0
                      final number = index == 9 ? 0 : index + 1;
                      return _buildKeyboardButton(
                        number.toString(),
                        Colors.blue,
                        () => _onKeyboardInput(number.toString()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildKeyboardButton(
                        '⌫',
                        Colors.orange,
                        () => _onKeyboardInput('backspace'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKeyboardButton(
                        '✓',
                        Colors.green,
                        () => _onKeyboardInput('enter'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildKeyboardButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3 + _glowAnimation.value * 0.2),
                  blurRadius: 8 + _glowAnimation.value * 5,
                  offset: const Offset(0, 4),
                  spreadRadius: _glowAnimation.value,
                ),
              ],
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _equationController.dispose();
    _keyboardController.dispose();
    _audioHelper.stopBackgroundMusic();
    super.dispose();
  }
}

// Model class
class MathEquation {
  final int num1;
  final int num2;
  final String operation;
  final int result;

  MathEquation({
    required this.num1,
    required this.num2,
    required this.operation,
    required this.result,
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
        Colors.blue.withOpacity(1 - progress),
        Colors.cyan.withOpacity(1 - progress),
        Colors.teal.withOpacity(1 - progress),
        Colors.lightBlue.withOpacity(1 - progress),
      ][i % 4];

      if (i % 4 == 0) {
        canvas.drawCircle(Offset(x, y), 6, paint);
      } else if (i % 4 == 1) {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 10, height: 10),
          paint,
        );
      } else if (i % 4 == 2) {
        // Draw plus sign
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 2),
          paint,
        );
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 2, height: 8),
          paint,
        );
      } else {
        // Draw multiplication sign
        final path = Path();
        path.moveTo(x - 4, y - 4);
        path.lineTo(x + 4, y + 4);
        path.moveTo(x + 4, y - 4);
        path.lineTo(x - 4, y + 4);
        canvas.drawPath(
            path,
            paint
              ..strokeWidth = 2
              ..style = PaintingStyle.stroke);
        paint.style = PaintingStyle.fill;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
