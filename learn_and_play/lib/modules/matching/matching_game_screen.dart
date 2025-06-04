import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class MatchingGameScreen extends StatefulWidget {
  final int level;

  const MatchingGameScreen({super.key, required this.level});

  @override
  State<MatchingGameScreen> createState() => _MatchingGameScreenState();
}

class _MatchingGameScreenState extends State<MatchingGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _correctController;
  late AnimationController _wrongController;
  late AnimationController _celebrationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  // Svi mogući parovi sa slikama
  final List<MatchingPair> _allPairs = [
    const MatchingPair(
      id: 'dog_bone',
      leftItem: MatchingItem(
          id: 'dog', imagePath: 'assets/images/matching/dog.png', label: 'Pas'),
      rightItem: MatchingItem(
          id: 'bone',
          imagePath: 'assets/images/matching/bone.png',
          label: 'Kost'),
      color: Colors.brown,
    ),
    const MatchingPair(
      id: 'sun_glasses',
      leftItem: MatchingItem(
          id: 'sun',
          imagePath: 'assets/images/matching/sun.png',
          label: 'Sunce'),
      rightItem: MatchingItem(
          id: 'glasses',
          imagePath: 'assets/images/matching/glasses.png',
          label: 'Naočale'),
      color: Colors.orange,
    ),
    const MatchingPair(
      id: 'rain_umbrella',
      leftItem: MatchingItem(
          id: 'rain',
          imagePath: 'assets/images/matching/rain.png',
          label: 'Kiša'),
      rightItem: MatchingItem(
          id: 'umbrella',
          imagePath: 'assets/images/matching/umbrella.png',
          label: 'Kišobran'),
      color: Colors.blue,
    ),
    const MatchingPair(
      id: 'night_stars',
      leftItem: MatchingItem(
          id: 'night',
          imagePath: 'assets/images/matching/night.png',
          label: 'Noć'),
      rightItem: MatchingItem(
          id: 'stars',
          imagePath: 'assets/images/matching/stars.png',
          label: 'Zvijezde'),
      color: Colors.indigo,
    ),
    const MatchingPair(
      id: 'flower_bee',
      leftItem: MatchingItem(
          id: 'flower',
          imagePath: 'assets/images/matching/flower.png',
          label: 'Cvijet'),
      rightItem: MatchingItem(
          id: 'bee',
          imagePath: 'assets/images/matching/bee.png',
          label: 'Pčela'),
      color: Colors.pink,
    ),
    const MatchingPair(
      id: 'fish_water',
      leftItem: MatchingItem(
          id: 'fish',
          imagePath: 'assets/images/matching/fish.png',
          label: 'Riba'),
      rightItem: MatchingItem(
          id: 'water',
          imagePath: 'assets/images/matching/water.png',
          label: 'Voda'),
      color: Colors.cyan,
    ),
    const MatchingPair(
      id: 'bird_nest',
      leftItem: MatchingItem(
          id: 'bird',
          imagePath: 'assets/images/matching/bird.png',
          label: 'Ptica'),
      rightItem: MatchingItem(
          id: 'nest',
          imagePath: 'assets/images/matching/nest.png',
          label: 'Gnijezdo'),
      color: Colors.green,
    ),
  ];

  List<MatchingPair> _currentPairs = [];
  List<MatchingItem> _leftItems = [];
  List<MatchingItem> _rightItems = [];
  MatchingItem? _selectedLeft;
  MatchingItem? _selectedRight;
  Set<String> _matchedPairs = {};
  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _progressTracker.init().then((_) {
      _determineGameSettings();
      _startNewRound();
    });
  }

  void _determineGameSettings() {
    // Broj rundi na osnovu levela
    switch (widget.level) {
      case 1:
        _totalRounds = 2; // 2 runde sa po 3 para
        break;
      case 2:
        _totalRounds = 3; // 3 runde sa po 4 para
        break;
      case 3:
        _totalRounds = 4; // 4 runde sa po 5 parova
        break;
      default:
        _totalRounds = 2;
    }
  }

  int get _pairsPerRound {
    switch (widget.level) {
      case 1:
        return 3;
      case 2:
        return 4;
      case 3:
        return 5;
      default:
        return 3;
    }
  }

  void _initializeAnimations() {
    _correctController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _wrongController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _celebrationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _correctController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _wrongController,
      curve: Curves.elasticInOut,
    ));
  }

  void _startNewRound() async {
    if (_currentRound >= _totalRounds) {
      _showResultDialog();
      return;
    }

    _currentRound++;

    setState(() {
      _matchedPairs.clear();
      _selectedLeft = null;
      _selectedRight = null;

      // Odaberi parove za ovu rundu
      _allPairs.shuffle();
      _currentPairs = _allPairs.take(_pairsPerRound).toList();

      // Pripremi lijeve i desne stavke
      _leftItems = _currentPairs.map((p) => p.leftItem).toList();
      _rightItems = _currentPairs.map((p) => p.rightItem).toList()..shuffle();
    });

    await Future.delayed(const Duration(milliseconds: 500));
    await _audioHelper.playSound('povezi_parove.mp3');
  }

  void _selectLeft(MatchingItem item) async {
    if (_isProcessing || _matchedPairs.contains(item.id)) return;

    setState(() {
      _selectedLeft = item;
    });

    await _audioHelper.playSound('klik.mp3');
    _checkForMatch();
  }

  void _selectRight(MatchingItem item) async {
    if (_isProcessing || _matchedPairs.any((id) => id.endsWith('_${item.id}')))
      return;

    setState(() {
      _selectedRight = item;
    });

    await _audioHelper.playSound('klik.mp3');
    _checkForMatch();
  }

  void _checkForMatch() async {
    if (_selectedLeft == null || _selectedRight == null) return;

    _isProcessing = true;

    // Pronađi par koji odgovara odabranim stavkama
    final matchingPair = _currentPairs.firstWhere(
      (pair) =>
          pair.leftItem.id == _selectedLeft!.id &&
          pair.rightItem.id == _selectedRight!.id,
      orElse: () => const MatchingPair(
        id: '',
        leftItem: MatchingItem(id: '', imagePath: '', label: ''),
        rightItem: MatchingItem(id: '', imagePath: '', label: ''),
        color: Colors.grey,
      ),
    );

    if (matchingPair.id.isNotEmpty) {
      // Tačno povezano!
      await _audioHelper.playSound('bravo.mp3');

      _correctController.forward().then((_) {
        _correctController.reset();
      });

      setState(() {
        _matchedPairs.add(_selectedLeft!.id);
        _matchedPairs.add('${_selectedLeft!.id}_${_selectedRight!.id}');
        _score += (10 * widget.level);
      });

      // Provjeri je li runda završena
      if (_matchedPairs.length >= _currentPairs.length * 2) {
        await Future.delayed(const Duration(seconds: 1));
        _startNewRound();
      }
    } else {
      // Pogrešno povezano
      await _audioHelper.playSound('pokusaj_ponovo.mp3');

      _wrongController.forward().then((_) {
        _wrongController.reset();
      });
    }

    setState(() {
      _selectedLeft = null;
      _selectedRight = null;
    });

    _isProcessing = false;
  }

  void _showResultDialog() async {
    // Spremi napredak
    await _progressTracker.saveModuleProgress('matching', widget.level, 3);
    await _progressTracker.saveHighScore('matching', _score);
    await _progressTracker.incrementAttempts('matching');

    await _audioHelper.playSound('bravo.mp3');

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.deepPurple.shade50,
        title: Text(
          _getWinTitle(),
          style: TextStyle(fontSize: 28, color: Colors.deepPurple.shade700),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getWinIcon(),
              size: 80,
              color: _getIconColor(),
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
                color: Colors.deepPurple.shade600,
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
                _score = 0;
                _currentRound = 0;
                _startNewRound();
              });
            },
            child: const Text('Nova igra', style: TextStyle(fontSize: 18)),
          ),
          if (widget.level < 3)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/matching?level=${widget.level + 1}');
              },
              child:
                  const Text('Sljedeći level', style: TextStyle(fontSize: 18)),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            child: const Text('Početni ekran', style: TextStyle(fontSize: 18)),
          ),
        ],
      ),
    );
  }

  String _getWinTitle() {
    double percentage =
        _score / (_totalRounds * _pairsPerRound * 10 * widget.level);
    if (percentage >= 0.9) return 'Savršeno! 🌟';
    if (percentage >= 0.7) return 'Odlično! 👏';
    if (percentage >= 0.5) return 'Dobro! 😊';
    return 'Pokušajte ponovo! 💪';
  }

  IconData _getWinIcon() {
    double percentage =
        _score / (_totalRounds * _pairsPerRound * 10 * widget.level);
    if (percentage >= 0.9) return Icons.star;
    if (percentage >= 0.7) return Icons.thumb_up;
    if (percentage >= 0.5) return Icons.emoji_emotions;
    return Icons.refresh;
  }

  Color _getIconColor() {
    double percentage =
        _score / (_totalRounds * _pairsPerRound * 10 * widget.level);
    if (percentage >= 0.9) return Colors.amber;
    if (percentage >= 0.7) return Colors.blue;
    if (percentage >= 0.5) return Colors.green;
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Poveži parove - Level ${widget.level}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade300,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () => context.go('/matching-levels'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade100,
              Colors.deepPurple.shade50,
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
                        'Bodovi', _score.toString(), Colors.deepPurple),
                    _buildInfoCard(
                        'Runda', '$_currentRound/$_totalRounds', Colors.pink),
                    _buildInfoCard(
                        'Level', widget.level.toString(), Colors.indigo),
                  ],
                ),
              ),
              // Oblast za povezivanje
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Lijeva kolona
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _leftItems.map((item) {
                            final isMatched = _matchedPairs.contains(item.id);
                            final isSelected = _selectedLeft?.id == item.id;
                            final pair = _currentPairs.firstWhere(
                              (p) => p.leftItem.id == item.id,
                            );

                            return AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset:
                                      isSelected && _wrongController.isAnimating
                                          ? Offset(
                                              sin(_shakeAnimation.value) * 2, 0)
                                          : Offset.zero,
                                  child: ScaleTransition(
                                    scale: isMatched
                                        ? _scaleAnimation
                                        : const AlwaysStoppedAnimation(1.0),
                                    child: _buildMatchingItem(
                                      item,
                                      isSelected,
                                      isMatched,
                                      pair.color,
                                      () => _selectLeft(item),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      // Centralna oblast (bez linija)
                      Container(
                        width: 60,
                        child: const Center(
                          child: Text(
                            '↔',
                            style: TextStyle(
                              fontSize: 40,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      // Desna kolona
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _rightItems.map((item) {
                            final matchId = _matchedPairs.firstWhere(
                              (id) => id.endsWith('_${item.id}'),
                              orElse: () => '',
                            );
                            final isMatched = matchId.isNotEmpty;
                            final isSelected = _selectedRight?.id == item.id;

                            Color itemColor = Colors.grey;
                            if (isMatched || isSelected) {
                              final pair = _currentPairs.firstWhere(
                                (p) => p.rightItem.id == item.id,
                                orElse: () => const MatchingPair(
                                  id: '',
                                  leftItem: MatchingItem(
                                      id: '', imagePath: '', label: ''),
                                  rightItem: MatchingItem(
                                      id: '', imagePath: '', label: ''),
                                  color: Colors.grey,
                                ),
                              );
                              itemColor = pair.color;
                            }

                            return AnimatedBuilder(
                              animation: _shakeAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset:
                                      isSelected && _wrongController.isAnimating
                                          ? Offset(
                                              sin(_shakeAnimation.value) * 2, 0)
                                          : Offset.zero,
                                  child: ScaleTransition(
                                    scale: isMatched
                                        ? _scaleAnimation
                                        : const AlwaysStoppedAnimation(1.0),
                                    child: _buildMatchingItem(
                                      item,
                                      isSelected,
                                      isMatched,
                                      itemColor,
                                      () => _selectRight(item),
                                    ),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ],
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

  Widget _buildMatchingItem(
    MatchingItem item,
    bool isSelected,
    bool isMatched,
    Color color,
    VoidCallback onTap,
  ) {
    return Material(
      elevation: isSelected ? 8 : 4,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: isMatched ? null : onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: isMatched
                ? color.withOpacity(0.3)
                : isSelected
                    ? color.withOpacity(0.2)
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected || isMatched ? color : Colors.grey.shade300,
              width: isSelected ? 3 : 2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Slika
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    item.imagePath,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        size: 40,
                        color: Colors.grey.shade400,
                      );
                    },
                  ),
                ),
              ),
              // Tekst
              Expanded(
                flex: 1,
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color:
                        isMatched || isSelected ? color : Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _correctController.dispose();
    _wrongController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }
}

// Modeli za igru povezivanja
class MatchingPair {
  final String id;
  final MatchingItem leftItem;
  final MatchingItem rightItem;
  final Color color;

  const MatchingPair({
    required this.id,
    required this.leftItem,
    required this.rightItem,
    required this.color,
  });
}

class MatchingItem {
  final String id;
  final String imagePath;
  final String label;

  const MatchingItem({
    required this.id,
    required this.imagePath,
    required this.label,
  });
}
