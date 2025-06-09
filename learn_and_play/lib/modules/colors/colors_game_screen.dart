import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_models.dart';
import '../../utils/audio_helper.dart';

class ColorsGameScreen extends StatefulWidget {
  final int level;

  const ColorsGameScreen({super.key, required this.level});

  @override
  State<ColorsGameScreen> createState() => _ColorsGameScreenState();
}

class _ColorsGameScreenState extends State<ColorsGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  late AnimationController _animationController;
  late AnimationController _confettiController;
  late AnimationController _shakeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _shakeAnimation;

  // Proširene liste boja za različite levele
  final Map<int, List<GameColor>> _levelColors = {
    1: const [
      GameColor(
        name: 'red',
        bosnianName: 'crvenu',
        colorValue: 0xFFFFB3BA,
        soundPath: 'dodirni_crvenu_boju.mp3',
      ),
      GameColor(
        name: 'blue',
        bosnianName: 'plavu',
        colorValue: 0xFFBAE1FF,
        soundPath: 'dodirni_plavu_boju.mp3',
      ),
      GameColor(
        name: 'yellow',
        bosnianName: 'žutu',
        colorValue: 0xFFFFF3B3,
        soundPath: 'dodirni_zutu_boju.mp3',
      ),
      GameColor(
        name: 'green',
        bosnianName: 'zelenu',
        colorValue: 0xFFBAFFBA,
        soundPath: 'dodirni_zelenu_boju.mp3',
      ),
    ],
    2: const [
      GameColor(
        name: 'red',
        bosnianName: 'crvenu',
        colorValue: 0xFFFFB3BA,
        soundPath: 'dodirni_crvenu_boju.mp3',
      ),
      GameColor(
        name: 'blue',
        bosnianName: 'plavu',
        colorValue: 0xFFBAE1FF,
        soundPath: 'dodirni_plavu_boju.mp3',
      ),
      GameColor(
        name: 'yellow',
        bosnianName: 'žutu',
        colorValue: 0xFFFFF3B3,
        soundPath: 'dodirni_zutu_boju.mp3',
      ),
      GameColor(
        name: 'green',
        bosnianName: 'zelenu',
        colorValue: 0xFFBAFFBA,
        soundPath: 'dodirni_zelenu_boju.mp3',
      ),
      GameColor(
        name: 'purple',
        bosnianName: 'ljubičastu',
        colorValue: 0xFFE1BAFF,
        soundPath: 'dodirni_ljubicastu_boju.mp3',
      ),
      GameColor(
        name: 'orange',
        bosnianName: 'narandžastu',
        colorValue: 0xFFFFD4BA,
        soundPath: 'dodirni_narandzastu_boju.mp3',
      ),
    ],
    3: const [
      GameColor(
        name: 'red',
        bosnianName: 'crvenu',
        colorValue: 0xFFFFB3BA,
        soundPath: 'dodirni_crvenu_boju.mp3',
      ),
      GameColor(
        name: 'blue',
        bosnianName: 'plavu',
        colorValue: 0xFFBAE1FF,
        soundPath: 'dodirni_plavu_boju.mp3',
      ),
      GameColor(
        name: 'yellow',
        bosnianName: 'žutu',
        colorValue: 0xFFFFF3B3,
        soundPath: 'dodirni_zutu_boju.mp3',
      ),
      GameColor(
        name: 'green',
        bosnianName: 'zelenu',
        colorValue: 0xFFBAFFBA,
        soundPath: 'dodirni_zelenu_boju.mp3',
      ),
      GameColor(
        name: 'purple',
        bosnianName: 'ljubičastu',
        colorValue: 0xFFE1BAFF,
        soundPath: 'dodirni_ljubicastu_boju.mp3',
      ),
      GameColor(
        name: 'orange',
        bosnianName: 'narandžastu',
        colorValue: 0xFFFFD4BA,
        soundPath: 'dodirni_narandzastu_boju.mp3',
      ),
      GameColor(
        name: 'pink',
        bosnianName: 'ružičastu',
        colorValue: 0xFFFFBAE1,
        soundPath: 'dodirni_ruzicastu_boju.mp3',
      ),
      GameColor(
        name: 'brown',
        bosnianName: 'smeđu',
        colorValue: 0xFFD4C4BA,
        soundPath: 'dodirni_smedju_boju.mp3',
      ),
    ],
  };

  List<GameColor> _currentColors = [];
  GameColor? _currentTargetColor;
  int _score = 0;
  int _rounds = 0;
  int _maxRounds = 5;
  bool _isWaitingForAnswer = false;
  bool _showConfetti = false;
  bool _isAudioPlaying = false; // Dodano za kontrolu audio playback-a

  @override
  void initState() {
    super.initState();
    _currentColors = _levelColors[widget.level] ?? _levelColors[1]!;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _confettiController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _confettiAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _confettiController,
      curve: Curves.easeOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));

    // Počekaj malo prije početka
    Future.delayed(const Duration(milliseconds: 1000), () {
      _startNewRound();
    });
  }

  void _startNewRound() async {
    if (_rounds >= _maxRounds) {
      _showResultDialog();
      return;
    }

    // Resetuj stanje
    setState(() {
      _currentTargetColor = null;
      _isWaitingForAnswer = false;
      _isAudioPlaying = true;
    });

    // Kratka pauza prije novog kruga
    await Future.delayed(const Duration(milliseconds: 800));

    // Odaberi novu boju
    setState(() {
      _currentTargetColor =
          _currentColors[Random().nextInt(_currentColors.length)];
    });

    // Čekaj još malo prije reprodukcije audio-a
    await Future.delayed(const Duration(milliseconds: 500));

    // Reproduciraj audio instrukciju
    await _audioHelper.playSound(_currentTargetColor!.soundPath);

    // Audio je završen, sada može se odgovoriti
    setState(() {
      _isWaitingForAnswer = true;
      _isAudioPlaying = false;
    });
  }

  void _checkAnswer(GameColor selectedColor) async {
    if (!_isWaitingForAnswer || _isAudioPlaying) return;

    setState(() {
      _isWaitingForAnswer = false;
      _isAudioPlaying = true;
    });

    if (selectedColor.name == _currentTargetColor!.name) {
      // Tačan odgovor

      // Prvo animacija konfeta
      setState(() {
        _showConfetti = true;
      });
      _confettiController.forward();

      _animationController.forward().then((_) {
        _animationController.reverse();
      });

      // Reproduciraj bravo zvuk i čekaj da se završi
      await _audioHelper.playSound('bravo.mp3');

      // Čekaj da se završi animacija konfeta
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _showConfetti = false;
        _score += 10;
        _rounds++;
        _isAudioPlaying = false;
      });

      _confettiController.reset();

      // Nastavi sa sljedećim krugom
      _startNewRound();
    } else {
      // Netačan odgovor

      // Animacija tresenja
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      // Reproduciraj "pokušaj ponovo" i čekaj da se završi
      await _audioHelper.playSound('pokusaj_ponovo.mp3');

      // Kratka pauza
      await Future.delayed(const Duration(milliseconds: 1000));

      // Ponovi instrukciju i čekaj da se završi
      await _audioHelper.playSound(_currentTargetColor!.soundPath);

      setState(() {
        _isWaitingForAnswer = true;
        _isAudioPlaying = false;
      });
    }
  }

  void _showResultDialog() async {
    setState(() {
      _isAudioPlaying = true;
    });

    // Reproduciraj završni zvuk
    if (_score >= (_maxRounds * 10 * 0.8)) {
      await _audioHelper.playSound('odlicno.mp3');
    } else {
      await _audioHelper.playSound('dobro.mp3');
    }

    setState(() {
      _isAudioPlaying = false;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.orange.shade50,
        title: Text(
          _score >= (_maxRounds * 10 * 0.8) ? 'Odlično! 🌟' : 'Dobro! 👏',
          style: TextStyle(fontSize: 28, color: Colors.orange.shade700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _score >= (_maxRounds * 10 * 0.8) ? Icons.star : Icons.thumb_up,
              size: 80,
              color: _score >= (_maxRounds * 10 * 0.8)
                  ? Colors.amber
                  : Colors.blue,
            ),
            const SizedBox(height: 20),
            Text(
              'Osvojili ste $_score bodova!',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Level ${widget.level} - ${_getLevelName()}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.orange.shade600,
                fontWeight: FontWeight.w500,
              ),
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
              });
              _startNewRound();
            },
            child: const Text(
              'Nova igra',
              style: TextStyle(fontSize: 18),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/colors-levels');
            },
            child: const Text(
              'Nivoi',
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

  String _getLevelName() {
    switch (widget.level) {
      case 1:
        return 'Lako';
      case 2:
        return 'Srednje';
      case 3:
        return 'Teško';
      default:
        return 'Lako';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Prepoznaj boju - Level ${widget.level}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.orange.shade300,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () => context.go('/colors-levels'),
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
                  Colors.orange.shade100,
                  Colors.orange.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.shade200,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Text(
                            'Bodovi: $_score',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Runda: $_rounds / $_maxRounds',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.orange.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isAudioPlaying ? Icons.volume_off : Icons.volume_up,
                        size: 50,
                      ),
                      color: Colors.orange.shade600,
                      onPressed: _currentTargetColor != null && !_isAudioPlaying
                          ? () async {
                              setState(() {
                                _isAudioPlaying = true;
                              });
                              await _audioHelper
                                  .playSound(_currentTargetColor!.soundPath);
                              setState(() {
                                _isAudioPlaying = false;
                              });
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _shakeAnimation,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(sin(_shakeAnimation.value) * 2, 0),
                          child: _buildColorGrid(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Konfeti animacija
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

  Widget _buildColorGrid() {
    // Dinamički grid na osnovu broja boja
    int crossAxisCount = _currentColors.length <= 4
        ? 2
        : _currentColors.length <= 6
            ? 3
            : 4;

    return GridView.builder(
      padding: const EdgeInsets.all(30),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _currentColors.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return _buildColorButton(_currentColors[index]);
      },
    );
  }

  Widget _buildColorButton(GameColor color) {
    final isSelected = _currentTargetColor?.name == color.name;

    return ScaleTransition(
      scale: isSelected && !_isAudioPlaying
          ? _scaleAnimation
          : const AlwaysStoppedAnimation(1.0),
      child: Material(
        elevation: 8,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: () => _checkAnswer(color),
          customBorder: const CircleBorder(),
          child: Container(
            decoration: BoxDecoration(
              color: Color(color.colorValue),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
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
    _animationController.dispose();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }
}

// Konfeti painter za animaciju
class ConfettiPainter extends CustomPainter {
  final double progress;
  final Random random = Random();

  ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      const startY = -50.0;
      final endY = size.height + 50;
      final y = startY + (endY - startY) * progress;

      paint.color = [
        Colors.red,
        Colors.blue,
        Colors.yellow,
        Colors.green,
        Colors.purple,
        Colors.orange,
      ][random.nextInt(6)]
          .withOpacity(1 - progress);

      canvas.drawCircle(Offset(x, y), 5 + random.nextDouble() * 5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
