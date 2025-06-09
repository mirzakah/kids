import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_models.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class ProfessionsGameScreen extends StatefulWidget {
  final int level;

  const ProfessionsGameScreen({super.key, required this.level});

  @override
  State<ProfessionsGameScreen> createState() => _ProfessionsGameScreenState();
}

class _ProfessionsGameScreenState extends State<ProfessionsGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _confettiController;
  late AnimationController _matchController;
  late AnimationController _pulseController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _matchAnimation;
  late Animation<double> _pulseAnimation;

  // Lista svih profesija i alata
  final List<Profession> _allProfessions = [
    const Profession(
      id: 'doctor',
      name: 'Doktor',
      imagePath: 'assets/images/professions/doctor.png',
      soundPath: 'doktor.mp3',
      toolId: 'stethoscope',
    ),
    const Profession(
      id: 'firefighter',
      name: 'Vatrogasac',
      imagePath: 'assets/images/professions/firefighter.png',
      soundPath: 'vatrogasac.mp3',
      toolId: 'hose',
    ),
    const Profession(
      id: 'chef',
      name: 'Kuvar',
      imagePath: 'assets/images/professions/chef.png',
      soundPath: 'kuvar.mp3',
      toolId: 'chef_hat',
    ),
    const Profession(
      id: 'teacher',
      name: 'Učitelj',
      imagePath: 'assets/images/professions/teacher.png',
      soundPath: 'ucitelj.mp3',
      toolId: 'book',
    ),
    const Profession(
      id: 'police',
      name: 'Policajac',
      imagePath: 'assets/images/professions/police.png',
      soundPath: 'policajac.mp3',
      toolId: 'badge',
    ),
  ];

  final List<ProfessionTool> _allTools = [
    const ProfessionTool(
      id: 'stethoscope',
      name: 'Stetoskop',
      imagePath: 'assets/images/tools/stethoscope.png',
      soundPath: 'stetoskop.mp3',
      professionId: 'doctor',
    ),
    const ProfessionTool(
      id: 'hose',
      name: 'Crijevo',
      imagePath: 'assets/images/tools/hose.png',
      soundPath: 'crijevo.mp3',
      professionId: 'firefighter',
    ),
    const ProfessionTool(
      id: 'chef_hat',
      name: 'Kuvarska kapa',
      imagePath: 'assets/images/tools/chef_hat.png',
      soundPath: 'kuvarska_kapa.mp3',
      professionId: 'chef',
    ),
    const ProfessionTool(
      id: 'book',
      name: 'Knjiga',
      imagePath: 'assets/images/tools/book.png',
      soundPath: 'knjiga.mp3',
      professionId: 'teacher',
    ),
    const ProfessionTool(
      id: 'badge',
      name: 'Značka',
      imagePath: 'assets/images/tools/badge.png',
      soundPath: 'znacka.mp3',
      professionId: 'police',
    ),
  ];

  List<ProfessionPair> _currentPairs = [];
  List<ProfessionTool> _availableTools = [];
  int _score = 0;
  int _matchedPairs = 0;
  int _totalPairs = 0;
  bool _gameCompleted = false;
  String? _draggedToolId;
  bool _showConfetti = false;

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
    _confettiController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _matchController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 12.0,
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

    _matchAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _matchController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic(
      'professions_background.mp3',
      loop: true,
    );
    _audioHelper.setBackgroundMusicVolume(0.3);
    _audioHelper.setSoundEffectsVolume(0.8);
  }

  void _initializeGame() {
    int pairCount;
    switch (widget.level) {
      case 1:
        pairCount = 3; // Doktor, Vatrogasac, Kuvar
        break;
      case 2:
        pairCount = 4; // + Učitelj
        break;
      case 3:
        pairCount = 5; // + Policajac
        break;
      default:
        pairCount = 3;
    }

    _totalPairs = pairCount;
    _score = 0;
    _matchedPairs = 0;
    _gameCompleted = false;
    _draggedToolId = null; // Reset drag state
    _showConfetti = false; // Reset confetti state

    // Kreiraj parove za trenutni level
    _currentPairs = [];
    for (int i = 0; i < pairCount; i++) {
      _currentPairs.add(ProfessionPair(
        profession: _allProfessions[i],
        tool: _allTools[i],
      ));
    }

    // Pomješaj alate
    _availableTools = _currentPairs.map((pair) => pair.tool).toList();
    _availableTools.shuffle();

    // Reset animacije
    _confettiController.reset();
    _matchController.reset();
    _bounceController.reset();
    _shakeController.reset();

    setState(() {});

    _playWelcomeSound();
  }

  void _playWelcomeSound() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioHelper.playSoundSequence([
      'povezi_profesije.mp3', // "Povuci alat na odgovarajuću profesiju"
      'zapocni_igru.mp3',
    ]);
  }

  void _onToolDragStarted(String toolId) {
    setState(() {
      _draggedToolId = toolId;
    });
    _audioHelper.playSound('pickup.mp3');
  }

  void _onToolDragEnd() {
    setState(() {
      _draggedToolId = null;
    });
  }

  void _onProfessionAcceptTool(String professionId, String toolId) async {
    final pair = _currentPairs.firstWhere(
      (p) => p.profession.id == professionId,
      orElse: () => _currentPairs.first,
    );

    if (pair.tool.id == toolId && !pair.isMatched) {
      // Tačan odgovor!
      setState(() {
        pair.isMatched = true;
        pair.isAnimating = true;
        _matchedPairs++;
        _score += (20 * widget.level);
      });

      // Ukloni alat iz dostupnih
      _availableTools.removeWhere((tool) => tool.id == toolId);

      // Animacije i zvukovi
      _matchController.forward().then((_) {
        _matchController.reset();
        setState(() {
          pair.isAnimating = false;
        });
      });

      await _audioHelper.playSoundSequence([
        'correct_match.mp3',
        pair.profession.soundPath,
        pair.tool.soundPath,
        'bravo.mp3',
      ]);

      // Provjeri da li je igra završena
      if (_matchedPairs >= _totalPairs) {
        await Future.delayed(const Duration(milliseconds: 800));
        _gameCompleted = true;
        _showWinDialog();
      }
    } else {
      // Netačan odgovor
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      await _audioHelper.playSoundSequence([
        'wrong_match.mp3',
        'pokusaj_ponovo.mp3',
      ]);
    }

    setState(() {
      _draggedToolId = null;
    });
  }

  void _showWinDialog() async {
    setState(() {
      _showConfetti = true;
    });
    _confettiController.forward();

    // Spremi napredak
    await _progressTracker.saveModuleProgress('professions', widget.level, 3);
    await _progressTracker.saveHighScore('professions', _score);
    await _progressTracker.incrementAttempts('professions');

    // Triumfalni zvukovi
    await _audioHelper.playSoundSequence([
      'game_complete.mp3',
      'sve_profesije_spojene.mp3',
      'odlicno.mp3',
    ]);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.blue.shade50,
        title: Column(
          children: [
            Icon(
              Icons.work_rounded,
              size: 60,
              color: Colors.amber.shade600,
            ),
            const SizedBox(height: 10),
            Text(
              _getWinTitle(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 10,
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
                    'Spojili ste sve profesije sa njihovim alatima!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade600,
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
                context.go('/professions?level=${widget.level + 1}');
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
    final maxScore = _totalPairs * 20 * widget.level;
    int stars = 1;
    if (_score >= maxScore * 0.8)
      stars = 3;
    else if (_score >= maxScore * 0.6) stars = 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
          color: index < stars ? Colors.amber : Colors.grey.shade300,
          size: 35,
        );
      }),
    );
  }

  String _getWinTitle() {
    final maxScore = _totalPairs * 20 * widget.level;
    if (_score >= maxScore * 0.8) {
      return 'Savršeno! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Odličo! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profesije - Level ${widget.level}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () async {
            await _audioHelper.stopBackgroundMusic();
            if (context.mounted) {
              context.go('/professions-levels');
            }
          },
        ),
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
          ),
        ],
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade100,
                  Colors.purple.shade50,
                  Colors.pink.shade50,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Score panel
                _buildScorePanel(),

                // Instruction text
                _buildInstructionText(),

                // Main game area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profesije (lijeva strana)
                            Flexible(
                              flex: 6,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.65,
                                ),
                                child: _buildProfessionsColumn(),
                              ),
                            ),

                            // Separator
                            Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight * 0.5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.blue.shade300,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Alati (desna strana)
                            Flexible(
                              flex: 4,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth: constraints.maxWidth * 0.30,
                                ),
                                child: _buildToolsColumn(),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
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
            color: Colors.blue.shade200.withOpacity(0.5),
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
          _buildScoreItem('Spojeno', '$_matchedPairs/$_totalPairs', Icons.link,
              Colors.green),
          _buildScoreItem(
              'Level', widget.level.toString(), Icons.flag, Colors.blue),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 5),
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
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.touch_app, color: Colors.blue.shade600, size: 24),
          const SizedBox(width: 10),
          Text(
            'Povuci alat na odgovarajuću profesiju!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionsColumn() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: _currentPairs.length,
      itemBuilder: (context, index) {
        final pair = _currentPairs[index];
        return _buildProfessionCard(pair);
      },
    );
  }

  Widget _buildProfessionCard(ProfessionPair pair) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            pair.isAnimating ? 0 : sin(_shakeAnimation.value) * 2,
            0,
          ),
          child: AnimatedBuilder(
            animation: _matchAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale:
                    pair.isAnimating ? _matchAnimation.value * 0.1 + 1.0 : 1.0,
                child: DragTarget<String>(
                  onAccept: (toolId) =>
                      _onProfessionAcceptTool(pair.profession.id, toolId),
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      height: 100,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: pair.isMatched
                                  ? Colors.green.shade200
                                  : isHovering
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade300,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: pair.isMatched
                                    ? [
                                        Colors.green.shade100,
                                        Colors.green.shade50
                                      ]
                                    : isHovering
                                        ? [
                                            Colors.blue.shade100,
                                            Colors.blue.shade50
                                          ]
                                        : [Colors.white, Colors.grey.shade50],
                              ),
                              border: Border.all(
                                color: pair.isMatched
                                    ? Colors.green.shade400
                                    : isHovering
                                        ? Colors.blue.shade400
                                        : Colors.grey.shade300,
                                width: 3,
                              ),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                // Slika profesije
                                Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade300,
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      pair.profession.imagePath,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Icon(
                                          Icons.person_rounded,
                                          size: 35,
                                          color: Colors.blue.shade400,
                                        );
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 12),

                                // Tekst i status - koristi Flexible umjesto Expanded
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        pair.profession.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: pair.isMatched
                                              ? Colors.green.shade700
                                              : Colors.blue.shade700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      if (pair.isMatched)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green.shade600,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Spojeno!',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.green.shade600,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      else if (isHovering)
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.touch_app,
                                              color: Colors.blue.shade600,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Pusti ovdje',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue.shade600,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        )
                                      else
                                        Text(
                                          'Čeka alat...',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                    ],
                                  ),
                                ),

                                // Alat ako je spojeno
                                if (pair.isMatched) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.shade200,
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        pair.tool.imagePath,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(
                                            Icons.build_rounded,
                                            size: 25,
                                            color: Colors.green.shade400,
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
      },
    );
  }

  Widget _buildToolsColumn() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.orange.shade300, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.build_rounded, color: Colors.orange.shade600),
              const SizedBox(width: 8),
              Text(
                'ALATI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 5),
            itemCount: _availableTools.length,
            itemBuilder: (context, index) {
              final tool = _availableTools[index];
              return _buildToolCard(tool);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildToolCard(ProfessionTool tool) {
    final isDragged = _draggedToolId == tool.id;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isDragged ? 0.9 : _pulseAnimation.value,
          child: Opacity(
            opacity: isDragged ? 0.5 : 1.0,
            child: Draggable<String>(
              data: tool.id,
              onDragStarted: () => _onToolDragStarted(tool.id),
              onDragEnd: (_) => _onToolDragEnd(),
              feedback: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.orange.shade400, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      tool.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.build_rounded,
                          size: 40,
                          color: Colors.orange.shade400,
                        );
                      },
                    ),
                  ),
                ),
              ),
              childWhenDragging: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                ),
                child: Center(
                  child: Icon(
                    Icons.touch_app,
                    color: Colors.grey.shade500,
                    size: 30,
                  ),
                ),
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.orange.shade100,
                          Colors.orange.shade50,
                        ],
                      ),
                      border: Border.all(
                        color: Colors.orange.shade300,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.shade200,
                                blurRadius: 5,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              tool.imagePath,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.build_rounded,
                                  size: 30,
                                  color: Colors.orange.shade400,
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tool.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
    _bounceController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    _matchController.dispose();
    _pulseController.dispose();
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

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final y = (random.nextDouble() * size.height * 1.5 * animationProgress) -
          size.height * 0.2;
      final color = [
        Colors.red,
        Colors.blue,
        Colors.yellow,
        Colors.green,
        Colors.purple,
        Colors.orange,
      ][i % 6];

      paint.color = color;

      // Različiti oblici konfeta
      if (i % 3 == 0) {
        canvas.drawCircle(Offset(x, y), 4, paint);
      } else if (i % 3 == 1) {
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: 8, height: 6), paint);
      } else {
        final path = Path();
        path.moveTo(x, y - 4);
        path.lineTo(x - 3, y + 2);
        path.lineTo(x + 3, y + 2);
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
