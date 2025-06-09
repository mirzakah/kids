import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_models.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class EmotionsGameScreen extends StatefulWidget {
  final int level;

  const EmotionsGameScreen({super.key, required this.level});

  @override
  State<EmotionsGameScreen> createState() => _EmotionsGameScreenState();
}

class _EmotionsGameScreenState extends State<EmotionsGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _faceController;
  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _confettiController;
  late AnimationController _pulseController;
  late AnimationController _colorController;

  late Animation<double> _faceAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _colorAnimation;

  // Sve dostupne emocije
  final List<Emotion> _allEmotions = [
    const Emotion(
      id: 'happy',
      name: 'Srećan',
      imagePath: 'assets/images/emotions/happy.png',
      soundPath: 'srecan.mp3',
      description: 'Kada se osjećamo dobro i nasmiješimo se',
      color: Colors.yellow,
    ),
    const Emotion(
      id: 'sad',
      name: 'Tužan',
      imagePath: 'assets/images/emotions/sad.png',
      soundPath: 'tuzan.mp3',
      description: 'Kada se osjećamo loše ili želimo plakati',
      color: Colors.blue,
    ),
    const Emotion(
      id: 'angry',
      name: 'Ljut',
      imagePath: 'assets/images/emotions/angry.png',
      soundPath: 'ljut.mp3',
      description: 'Kada smo nezadovoljni i želimo vikati',
      color: Colors.red,
    ),
    const Emotion(
      id: 'scared',
      name: 'Uplašen',
      imagePath: 'assets/images/emotions/scared.png',
      soundPath: 'uplasen.mp3',
      description: 'Kada se bojimo nečega',
      color: Colors.purple,
    ),
    const Emotion(
      id: 'surprised',
      name: 'Iznenađen',
      imagePath: 'assets/images/emotions/surprised.png',
      soundPath: 'iznenadjen.mp3',
      description: 'Kada vidimo nešto neočekivano',
      color: Colors.orange,
    ),
    const Emotion(
      id: 'tired',
      name: 'Umoran',
      imagePath: 'assets/images/emotions/tired.png',
      soundPath: 'umoran.mp3',
      description: 'Kada trebamo spavati',
      color: Colors.grey,
    ),
    const Emotion(
      id: 'excited',
      name: 'Uzbuđen',
      imagePath: 'assets/images/emotions/excited.png',
      soundPath: 'uzbudjen.mp3',
      description: 'Kada se veselimo nečemu',
      color: Colors.pink,
    ),
    const Emotion(
      id: 'worried',
      name: 'Zabrinut',
      imagePath: 'assets/images/emotions/worried.png',
      soundPath: 'zabrinut.mp3',
      description: 'Kada razmišljamo o problemima',
      color: Colors.brown,
    ),
    const Emotion(
      id: 'bored',
      name: 'Dosadno',
      imagePath: 'assets/images/emotions/bored.png',
      soundPath: 'dosadno.mp3',
      description: 'Kada nemamo šta da radimo',
      color: Colors.blueGrey,
    ),
    const Emotion(
      id: 'love',
      name: 'Zaljubljen',
      imagePath: 'assets/images/emotions/love.png',
      soundPath: 'zaljubljen.mp3',
      description: 'Kada nekoga volimo',
      color: Colors.pink,
    ),
    const Emotion(
      id: 'proud',
      name: 'Ponosan',
      imagePath: 'assets/images/emotions/proud.png',
      soundPath: 'ponosan.mp3',
      description: 'Kada smo zadovoljni sobom',
      color: Colors.green,
    ),
    const Emotion(
      id: 'shocked',
      name: 'Šokiran',
      imagePath: 'assets/images/emotions/shocked.png',
      soundPath: 'sokiran.mp3',
      description: 'Kada smo veoma iznenađeni',
      color: Colors.lightBlue,
    ),
    const Emotion(
      id: 'disappointed',
      name: 'Razočaran',
      imagePath: 'assets/images/emotions/disappointed.png',
      soundPath: 'razocararan.mp3',
      description: 'Kada se nešto ne dogodi kako smo očekivali',
      color: Colors.indigo,
    ),
    const Emotion(
      id: 'confused',
      name: 'Smušen',
      imagePath: 'assets/images/emotions/confused.png',
      soundPath: 'smusen.mp3',
      description: 'Kada ne razumijemo nešto',
      color: Colors.amber,
    ),
    const Emotion(
      id: 'amazed',
      name: 'Oduševljen',
      imagePath: 'assets/images/emotions/amazed.png',
      soundPath: 'odusevljen.mp3',
      description: 'Kada vidimo nešto prekrasno',
      color: Colors.teal,
    ),
    const Emotion(
      id: 'nervous',
      name: 'Nervozan',
      imagePath: 'assets/images/emotions/nervous.png',
      soundPath: 'nervozan.mp3',
      description: 'Kada se osjećamo nelagodno',
      color: Colors.deepOrange,
    ),
  ];

  List<Emotion> _currentEmotions = [];
  EmotionQuestion? _currentQuestion;
  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  int _correctAnswers = 0;
  bool _isWaitingForAnswer = false;
  bool _showConfetti = false;
  bool _gameCompleted = false;
  EmotionQuestionType _currentQuestionType =
      EmotionQuestionType.sayNameChooseFace;

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
    _faceController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _colorController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _faceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _faceController,
      curve: Curves.elasticOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 15.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.blue.shade200,
      end: Colors.purple.shade200,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOut,
    ));
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic(
      'emotions_background.mp3',
      loop: true,
    );
    _audioHelper.setBackgroundMusicVolume(0.3);
    _audioHelper.setSoundEffectsVolume(0.8);
  }

  void _initializeGame() {
    int emotionCount;
    switch (widget.level) {
      case 1:
        emotionCount = 4; // Osnovne emocije
        _totalRounds = 6;
        break;
      case 2:
        emotionCount = 6; // + još 2
        _totalRounds = 8;
        break;
      case 3:
        emotionCount = 8; // + još 2
        _totalRounds = 10;
        break;
      default:
        emotionCount = 4;
        _totalRounds = 6;
    }

    _currentEmotions = _allEmotions.take(emotionCount).toList();
    _score = 0;
    _currentRound = 0;
    _correctAnswers = 0;
    _gameCompleted = false;
    _showConfetti = false;
    _isWaitingForAnswer = false;

    // Reset animacije
    _confettiController.reset();
    _faceController.reset();
    _bounceController.reset();
    _shakeController.reset();
    _colorController.reset();

    setState(() {});

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
      _currentRound++;
    });

    // Uvijek je tip pitanja: Kaži ime → odaberi lice
    _currentQuestionType = EmotionQuestionType.sayNameChooseFace;

    // Kreiraj novo pitanje
    final correctEmotion =
        _currentEmotions[Random().nextInt(_currentEmotions.length)];
    final optionsCount = min(4, _currentEmotions.length);

    List<Emotion> options = [correctEmotion];
    while (options.length < optionsCount) {
      final randomEmotion =
          _currentEmotions[Random().nextInt(_currentEmotions.length)];
      if (!options.any((e) => e.id == randomEmotion.id)) {
        options.add(randomEmotion);
      }
    }
    options.shuffle();

    _currentQuestion = EmotionQuestion(
      correctEmotion: correctEmotion,
      options: options,
      type: _currentQuestionType,
    );

    setState(() {});

    // Animiraj pozadinu
    _faceController.forward();
    _colorController.forward();

    // Pusti audio instrukciju
    await _audioHelper.playSoundSequence([
      'nadji_lice_emocije.mp3', // "Nađi lice koje pokazuje ovu emociju"
    ]);

    await Future.delayed(const Duration(milliseconds: 800));

    // Kaži ime emocije
    await _audioHelper.playSound(correctEmotion.soundPath);
  }

  void _checkAnswer(Emotion selectedEmotion) async {
    if (!_isWaitingForAnswer || _gameCompleted || _currentQuestion == null)
      return;

    setState(() {
      _isWaitingForAnswer = false;
      _currentQuestion!.isAnswered = true;
      _currentQuestion!.isCorrect =
          selectedEmotion.id == _currentQuestion!.correctEmotion.id;
    });

    if (_currentQuestion!.isCorrect) {
      // Tačan odgovor
      setState(() {
        _correctAnswers++;
        _score += (15 * widget.level);
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

      await _audioHelper.playSoundSequence([
        'correct_emotion.mp3',
        'tacno.mp3',
        selectedEmotion.soundPath,
        'bravo.mp3',
      ]);

      await Future.delayed(const Duration(milliseconds: 2000));
      _startNewRound();
    } else {
      // Netačan odgovor
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      await _audioHelper.playSoundSequence([
        'wrong_emotion.mp3',
        'probaj_ponovo.mp3',
        _currentQuestion!.correctEmotion.soundPath,
      ]);

      await Future.delayed(const Duration(milliseconds: 2000));

      // Nastavi sa istim pitanjem
      setState(() {
        _isWaitingForAnswer = true;
        _currentQuestion!.isAnswered = false;
      });
    }
  }

  void _replayInstruction() async {
    if (_currentQuestion == null || _gameCompleted) return;

    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });

    // Uvijek puštamo audio instrukciju + ime emocije
    await _audioHelper.playSoundSequence([
      'nadji_lice_emocije.mp3',
      _currentQuestion!.correctEmotion.soundPath,
    ]);
  }

  void _showWinDialog() async {
    setState(() {
      _showConfetti = true;
    });
    _confettiController.forward();

    // Spremi napredak
    await _progressTracker.saveModuleProgress('emotions', widget.level, 3);
    await _progressTracker.saveHighScore('emotions', _score);
    await _progressTracker.incrementAttempts('emotions');

    // Triumfalni zvukovi
    await _audioHelper.playSoundSequence([
      'game_complete.mp3',
      'sve_emocije_prepoznate.mp3',
      'odlicno.mp3',
    ]);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.purple.shade50,
        title: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.mood_rounded,
                    size: 60,
                    color: Colors.amber.shade600,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              _getWinTitle(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade200,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Osvojili ste $_score bodova!',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tačno odgovoreno: $_correctAnswers/$_totalRounds',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Odlično prepoznavate emocije!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.purple.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  _buildStarsRow(),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeGame();
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Nova igra', style: TextStyle(fontSize: 16)),
          ),
          if (widget.level < 3)
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/emotions?level=${widget.level + 1}');
              },
              icon: const Icon(Icons.arrow_forward_rounded),
              label:
                  const Text('Sljedeći level', style: TextStyle(fontSize: 16)),
            ),
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            icon: const Icon(Icons.home_rounded),
            label: const Text('Početna', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildStarsRow() {
    final maxScore = _totalRounds * 15 * widget.level;
    int stars = 1;
    if (_score >= maxScore * 0.8)
      stars = 3;
    else if (_score >= maxScore * 0.6) stars = 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + index * 100),
          child: Icon(
            index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: index < stars ? Colors.amber : Colors.grey.shade300,
            size: 35,
          ),
        );
      }),
    );
  }

  String _getWinTitle() {
    final accuracy = _correctAnswers / _totalRounds;
    if (accuracy >= 0.9) {
      return 'Savršeno! 🌟';
    } else if (accuracy >= 0.7) {
      return 'Odličo! 😊';
    } else {
      return 'Dobro! 👍';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prepoznaj emocije - Level ${widget.level}',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () async {
            await _audioHelper.stopBackgroundMusic();
            if (context.mounted) {
              context.go('/emotions-levels');
            }
          },
        ),
        actions: [
          IconButton(
            onPressed: _replayInstruction,
            icon: const Icon(Icons.volume_up, size: 30),
            tooltip: 'Ponovi instrukciju',
          ),
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
                  ? Icons.music_note
                  : Icons.music_off,
              size: 30,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _colorAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _colorAnimation.value ?? Colors.blue.shade200,
                      Colors.purple.shade100,
                      Colors.pink.shade50,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                // Score panel
                _buildScorePanel(),

                // Main question area
                Expanded(
                  child: _currentQuestion != null
                      ? _buildQuestionArea()
                      : _buildLoadingArea(),
                ),
              ],
            ),
          ),

          // Konfeti
          if (_showConfetti)
            AnimatedBuilder(
              animation: _confettiAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: ConfettiPainter(_confettiAnimation.value),
                  size: Size.infinite,
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildScorePanel() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildScoreItem(
              'Bodovi', _score.toString(), Icons.star, Colors.amber),
          _buildScoreItem('Pitanje', '$_currentRound/$_totalRounds', Icons.help,
              Colors.blue),
          _buildScoreItem(
              'Tačno', _correctAnswers.toString(), Icons.check, Colors.green),
          _buildScoreItem(
              'Level', widget.level.toString(), Icons.flag, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingArea() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.purple.shade400),
      ),
    );
  }

  Widget _buildQuestionArea() {
    if (_currentQuestion == null) return Container();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Instruction text
          _buildInstructionText(),

          const SizedBox(height: 20),

          // Emotion name (what we're looking for)
          _buildEmotionName(),

          const SizedBox(height: 30),

          // Face options to choose from
          _buildFaceOptions(),
        ],
      ),
    );
  }

  Widget _buildInstructionText() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.shade300,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hearing_rounded, color: Colors.purple.shade600, size: 24),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'Poslušaj emociju i nađi odgovarajuće lice',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.purple.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainFace() {
    return AnimatedBuilder(
      animation: _faceAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(sin(_shakeAnimation.value) * 3, 0),
              child: Transform.scale(
                scale: _faceAnimation.value,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _currentQuestion!.correctEmotion.color
                            .withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      _currentQuestion!.correctEmotion.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: _currentQuestion!.correctEmotion.color
                                .withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.mood,
                            size: 100,
                            color: _currentQuestion!.correctEmotion.color,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmotionName() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: _currentQuestion!.correctEmotion.color,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentQuestion!.correctEmotion.color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.hearing_rounded,
            size: 40,
            color: _currentQuestion!.correctEmotion.color,
          ),
          const SizedBox(height: 10),
          Text(
            _currentQuestion!.correctEmotion.name,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _currentQuestion!.correctEmotion.color,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _currentQuestion!.correctEmotion.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNameOptions() {
    return Wrap(
      spacing: 15,
      runSpacing: 15,
      children: _currentQuestion!.options.map((emotion) {
        return _buildNameOption(emotion);
      }).toList(),
    );
  }

  Widget _buildNameOption(Emotion emotion) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * 0.05 + 0.95,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              onTap: _isWaitingForAnswer ? () => _checkAnswer(emotion) : null,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 140,
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      emotion.color.withOpacity(0.8),
                      emotion.color.withOpacity(0.6),
                    ],
                  ),
                  border: Border.all(
                    color: emotion.color,
                    width: 2,
                  ),
                ),
                child: Text(
                  emotion.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFaceOptions() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 0.9,
      ),
      itemCount: _currentQuestion!.options.length,
      itemBuilder: (context, index) {
        final emotion = _currentQuestion!.options[index];
        return _buildFaceOption(emotion);
      },
    );
  }

  Widget _buildFaceOption(Emotion emotion) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value * 0.05 + 0.95,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(25),
            child: InkWell(
              onTap: _isWaitingForAnswer ? () => _checkAnswer(emotion) : null,
              borderRadius: BorderRadius.circular(25),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      emotion.color.withOpacity(0.2),
                      emotion.color.withOpacity(0.1),
                    ],
                  ),
                  border: Border.all(
                    color: emotion.color.withOpacity(0.5),
                    width: 3,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: emotion.color.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          emotion.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                color: emotion.color.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.mood,
                                size: 50,
                                color: emotion.color,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      emotion.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: emotion.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _faceController.dispose();
    _bounceController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    _colorController.dispose();
    _audioHelper.stopBackgroundMusic();
    super.dispose();
  }
}

// ConfettiPainter za konfeti animaciju
class ConfettiPainter extends CustomPainter {
  final double animationProgress;

  ConfettiPainter(this.animationProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final random = Random(42);

    // Emotikoni kao konfeti
    const emojis = ['😊', '😢', '😠', '😱', '😮', '😴', '🥳', '😰'];

    for (int i = 0; i < 60; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height * 1.5 * animationProgress) -
          size.height * 0.2;
      final color = [
        Colors.yellow,
        Colors.red,
        Colors.blue,
        Colors.green,
        Colors.purple,
        Colors.orange,
        Colors.pink,
      ][i % 7];

      paint.color = color;

      // Nasumični oblici
      if (i % 4 == 0) {
        canvas.drawCircle(Offset(x, y), 5, paint);
      } else if (i % 4 == 1) {
        // Srce oblik
        final path = Path();
        path.moveTo(x, y + 3);
        path.cubicTo(x - 5, y - 2, x - 5, y - 6, x, y - 4);
        path.cubicTo(x + 5, y - 6, x + 5, y - 2, x, y + 3);
        canvas.drawPath(path, paint);
      } else if (i % 4 == 2) {
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: 8, height: 6), paint);
      } else {
        // Zvjezdica
        final path = Path();
        for (int j = 0; j < 5; j++) {
          final angle = (j * 2 * pi / 5) - pi / 2;
          final px = x + 4 * cos(angle);
          final py = y + 4 * sin(angle);
          if (j == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
