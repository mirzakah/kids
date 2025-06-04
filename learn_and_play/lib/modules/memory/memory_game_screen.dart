import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_models.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class MemoryGameScreen extends StatefulWidget {
  final int level;

  const MemoryGameScreen({super.key, required this.level});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  List<MemoryCard> _cards = [];
  MemoryCard? _firstCard;
  MemoryCard? _secondCard;
  bool _isProcessing = false;
  int _score = 0;
  int _totalPairs = 0;
  int _foundPairs = 0;

  late AnimationController _flipController;
  late AnimationController _matchController;
  late AnimationController _correctAnswerController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _matchController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _correctAnswerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _correctAnswerController,
      curve: Curves.elasticInOut,
    ));

    _progressTracker.init().then((_) {
      _initializeGame();
    });
  }

  void _initializeGame() {
    // Određujemo broj parova na osnovu levela
    int pairsCount;
    switch (widget.level) {
      case 1:
        pairsCount = 3; // 6 kartica
        break;
      case 2:
        pairsCount = 5; // 10 kartica
        break;
      case 3:
        pairsCount = 8; // 16 kartica
        break;
      default:
        pairsCount = 3;
    }

    _totalPairs = pairsCount;

    // Lista životinja za igru
    final allAnimals = [
      MemoryCard(
        id: 'dog',
        imagePath: 'assets/images/animals/dog.png',
        soundPath: 'ovo_je_pas.mp3',
        name: 'Pas',
      ),
      MemoryCard(
        id: 'cat',
        imagePath: 'assets/images/animals/cat.png',
        soundPath: 'ovo_je_macka.mp3',
        name: 'Mačka',
      ),
      MemoryCard(
        id: 'bird',
        imagePath: 'assets/images/animals/bird.png',
        soundPath: 'ovo_je_ptica.mp3',
        name: 'Ptica',
      ),
      MemoryCard(
        id: 'cow',
        imagePath: 'assets/images/animals/cow.png',
        soundPath: 'ovo_je_krava.mp3',
        name: 'Krava',
      ),
      MemoryCard(
        id: 'sheep',
        imagePath: 'assets/images/animals/sheep.png',
        soundPath: 'ovo_je_ovca.mp3',
        name: 'Ovca',
      ),
      MemoryCard(
        id: 'horse',
        imagePath: 'assets/images/animals/horse.png',
        soundPath: 'ovo_je_konj.mp3',
        name: 'Konj',
      ),
      MemoryCard(
        id: 'pig',
        imagePath: 'assets/images/animals/pig.png',
        soundPath: 'ovo_je_svinja.mp3',
        name: 'Svinja',
      ),
      MemoryCard(
        id: 'duck',
        imagePath: 'assets/images/animals/duck.png',
        soundPath: 'ovo_je_patka.mp3',
        name: 'Patka',
      ),
    ];

    // Uzimamo potreban broj životinja
    final selectedAnimals = allAnimals.take(pairsCount).toList();

    // Dupliraj karte za parove
    _cards = [];
    for (var animal in selectedAnimals) {
      _cards.add(MemoryCard(
        id: '${animal.id}_1',
        imagePath: animal.imagePath,
        soundPath: animal.soundPath,
        name: animal.name,
      ));
      _cards.add(MemoryCard(
        id: '${animal.id}_2',
        imagePath: animal.imagePath,
        soundPath: animal.soundPath,
        name: animal.name,
      ));
    }

    // Promiješaj karte
    _cards.shuffle(Random());
    _score = 0;
    _foundPairs = 0;
  }

  int get _crossAxisCount {
    switch (widget.level) {
      case 1:
        return 3; // 2x3 grid
      case 2:
        return 5; // 2x5 grid ili 5x2
      case 3:
        return 4; // 4x4 grid
      default:
        return 3;
    }
  }

  void _flipCard(MemoryCard card) async {
    if (_isProcessing || card.isFlipped || card.isMatched) return;

    setState(() {
      card.isFlipped = true;
    });

    await _audioHelper.playSound('flip.mp3');

    if (_firstCard == null) {
      _firstCard = card;
    } else if (_secondCard == null) {
      _secondCard = card;
      _checkMatch();
    }
  }

  void _checkMatch() async {
    _isProcessing = true;

    await Future.delayed(const Duration(milliseconds: 1000));

    if (_firstCard!.name == _secondCard!.name) {
      // Pronađen par!
      await _audioHelper.playSound(_firstCard!.soundPath);

      // Animacija za tačan odgovor
      _correctAnswerController.forward().then((_) {
        _correctAnswerController.reset();
      });

      setState(() {
        _firstCard!.isMatched = true;
        _secondCard!.isMatched = true;
        _foundPairs++;
        _score += (10 * widget.level); // Više bodova za teži level
      });

      // Provjeri je li igra završena
      if (_foundPairs >= _totalPairs) {
        await Future.delayed(const Duration(milliseconds: 1000));
        _showWinDialog();
      }
    } else {
      // Nije par
      await _audioHelper.playSound('pokusaj_ponovo.mp3');

      // Animacija tresenja za netačan odgovor
      _correctAnswerController.forward().then((_) {
        _correctAnswerController.reset();
      });

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _firstCard!.isFlipped = false;
        _secondCard!.isFlipped = false;
      });
    }

    _firstCard = null;
    _secondCard = null;
    _isProcessing = false;
  }

  void _showWinDialog() async {
    // Spremamo napredak
    await _progressTracker.saveModuleProgress('memory', widget.level, 3);
    await _progressTracker.saveHighScore('memory', _score);
    await _progressTracker.incrementAttempts('memory');

    await _audioHelper.playSound('bravo.mp3');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.purple.shade50,
        title: Text(
          _getWinTitle(),
          style: const TextStyle(fontSize: 28, color: Colors.purple),
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
                color: Colors.purple.shade600,
                fontWeight: FontWeight.bold,
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
                context.go('/memory?level=${widget.level + 1}');
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
    if (_score >= _totalPairs * 10 * widget.level * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= _totalPairs * 10 * widget.level * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    if (_score >= _totalPairs * 10 * widget.level * 0.8) {
      return Icons.star;
    } else if (_score >= _totalPairs * 10 * widget.level * 0.6) {
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
          'Pamti me - Level ${widget.level}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () => context.go('/memory-levels'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade100,
              Colors.purple.shade50,
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
                    _buildInfoCard('Bodovi', _score.toString(), Colors.purple),
                    _buildInfoCard(
                        'Parovi', '$_foundPairs/$_totalPairs', Colors.pink),
                    _buildInfoCard(
                        'Level', widget.level.toString(), Colors.indigo),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _crossAxisCount,
                      childAspectRatio: 1,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _cards.length,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final card = _cards[index];
                      return _buildMemoryCard(card);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildMemoryCard(MemoryCard card) {
    return GestureDetector(
      onTap: () => _flipCard(card),
      child: AnimatedBuilder(
        animation: _shakeAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(
              _firstCard == card || _secondCard == card
                  ? sin(_shakeAnimation.value) * 2
                  : 0,
              0,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(
                begin: 0,
                end: card.isFlipped ? 1 : 0,
              ),
              duration: const Duration(milliseconds: 600),
              builder: (context, value, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(value * pi),
                  child: Container(
                    decoration: BoxDecoration(
                      color: value < 0.5
                          ? Colors.purple.shade400
                          : card.isMatched
                              ? Colors.green.shade200
                              : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: card.isMatched
                          ? Border.all(color: Colors.green, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: value < 0.5
                        ? const Center(
                            child: Icon(
                              Icons.question_mark,
                              size: 40,
                              color: Colors.white,
                            ),
                          )
                        : Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()..rotateY(pi),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Image.asset(
                                  card.imagePath,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.pets,
                                            size: 30,
                                            color: Colors.purple.shade300,
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            card.name,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.purple.shade700,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
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
  }

  @override
  void dispose() {
    _flipController.dispose();
    _matchController.dispose();
    _correctAnswerController.dispose();
    _audioHelper.dispose();
    super.dispose();
  }
}
