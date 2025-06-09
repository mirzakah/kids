import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class ColorShapeSortingGameScreen extends StatefulWidget {
  final int level;

  const ColorShapeSortingGameScreen({super.key, required this.level});

  @override
  State<ColorShapeSortingGameScreen> createState() =>
      _ColorShapeSortingGameScreenState();
}

class _ColorShapeSortingGameScreenState
    extends State<ColorShapeSortingGameScreen> with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late AnimationController _glowController;
  late AnimationController _progressController;
  late AnimationController _backgroundController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _backgroundAnimation;

  List<ColorShapeObject> _allObjects = [];
  List<ColorShapeObject> _currentObjects = [];
  List<SortingCategory> _categories = [];
  Map<String, List<ColorShapeObject>> _sortedObjects = {};
  List<ColorShapeObject> _availableObjects = [];

  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  bool _isProcessing = false;
  bool _showCelebration = false;
  bool _gameCompleted = false;
  bool _roundCompleted = false;

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
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut));

    _shakeAnimation = Tween<double>(begin: 0.0, end: 12.0).animate(
        CurvedAnimation(parent: _shakeController, curve: Curves.elasticInOut));

    _celebrationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _celebrationController, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: _progressController, curve: Curves.easeOutCubic));

    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _backgroundController, curve: Curves.linear));
  }

  void _initializeObjects() {
    _allObjects = [
      // Crveni objekti
      ColorShapeObject(
          id: 'red_circle',
          color: Colors.red,
          shape: 'circle',
          name: 'Crveni krug'),
      ColorShapeObject(
          id: 'red_square',
          color: Colors.red,
          shape: 'square',
          name: 'Crveni kvadrat'),
      ColorShapeObject(
          id: 'red_triangle',
          color: Colors.red,
          shape: 'triangle',
          name: 'Crveni trougao'),
      ColorShapeObject(
          id: 'red_star',
          color: Colors.red,
          shape: 'star',
          name: 'Crvena zvezda'),
      ColorShapeObject(
          id: 'red_heart',
          color: Colors.red,
          shape: 'heart',
          name: 'Crveno srce'),

      // Plavi objekti
      ColorShapeObject(
          id: 'blue_circle',
          color: Colors.blue,
          shape: 'circle',
          name: 'Plavi krug'),
      ColorShapeObject(
          id: 'blue_square',
          color: Colors.blue,
          shape: 'square',
          name: 'Plavi kvadrat'),
      ColorShapeObject(
          id: 'blue_triangle',
          color: Colors.blue,
          shape: 'triangle',
          name: 'Plavi trougao'),
      ColorShapeObject(
          id: 'blue_star',
          color: Colors.blue,
          shape: 'star',
          name: 'Plava zvezda'),
      ColorShapeObject(
          id: 'blue_heart',
          color: Colors.blue,
          shape: 'heart',
          name: 'Plavo srce'),

      // Žuti objekti
      ColorShapeObject(
          id: 'yellow_circle',
          color: Colors.yellow,
          shape: 'circle',
          name: 'Žuti krug'),
      ColorShapeObject(
          id: 'yellow_square',
          color: Colors.yellow,
          shape: 'square',
          name: 'Žuti kvadrat'),
      ColorShapeObject(
          id: 'yellow_triangle',
          color: Colors.yellow,
          shape: 'triangle',
          name: 'Žuti trougao'),
      ColorShapeObject(
          id: 'yellow_star',
          color: Colors.yellow,
          shape: 'star',
          name: 'Žuta zvezda'),
      ColorShapeObject(
          id: 'yellow_heart',
          color: Colors.yellow,
          shape: 'heart',
          name: 'Žuto srce'),

      // Zeleni objekti
      ColorShapeObject(
          id: 'green_circle',
          color: Colors.green,
          shape: 'circle',
          name: 'Zeleni krug'),
      ColorShapeObject(
          id: 'green_square',
          color: Colors.green,
          shape: 'square',
          name: 'Zeleni kvadrat'),
      ColorShapeObject(
          id: 'green_triangle',
          color: Colors.green,
          shape: 'triangle',
          name: 'Zeleni trougao'),
      ColorShapeObject(
          id: 'green_star',
          color: Colors.green,
          shape: 'star',
          name: 'Zelena zvezda'),
      ColorShapeObject(
          id: 'green_heart',
          color: Colors.green,
          shape: 'heart',
          name: 'Zeleno srce'),

      // Narandžasti objekti
      ColorShapeObject(
          id: 'orange_circle',
          color: Colors.orange,
          shape: 'circle',
          name: 'Narandžasti krug'),
      ColorShapeObject(
          id: 'orange_square',
          color: Colors.orange,
          shape: 'square',
          name: 'Narandžasti kvadrat'),
      ColorShapeObject(
          id: 'orange_triangle',
          color: Colors.orange,
          shape: 'triangle',
          name: 'Narandžasti trougao'),
      ColorShapeObject(
          id: 'orange_star',
          color: Colors.orange,
          shape: 'star',
          name: 'Narandžasta zvezda'),
      ColorShapeObject(
          id: 'orange_heart',
          color: Colors.orange,
          shape: 'heart',
          name: 'Narandžasto srce'),

      // Ljubičasti objekti
      ColorShapeObject(
          id: 'purple_circle',
          color: Colors.purple,
          shape: 'circle',
          name: 'Ljubičasti krug'),
      ColorShapeObject(
          id: 'purple_square',
          color: Colors.purple,
          shape: 'square',
          name: 'Ljubičasti kvadrat'),
      ColorShapeObject(
          id: 'purple_triangle',
          color: Colors.purple,
          shape: 'triangle',
          name: 'Ljubičasti trougao'),
      ColorShapeObject(
          id: 'purple_star',
          color: Colors.purple,
          shape: 'star',
          name: 'Ljubičasta zvezda'),
      ColorShapeObject(
          id: 'purple_heart',
          color: Colors.purple,
          shape: 'heart',
          name: 'Ljubičasto srce'),
    ];
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic('color_shape_background.mp3', loop: true);
    _audioHelper.setBackgroundMusicVolume(0.24);
    _audioHelper.setSoundEffectsVolume(0.88);
  }

  void _initializeGame() {
    switch (widget.level) {
      case 1:
        _totalRounds = 5;
        break;
      case 2:
        _totalRounds = 6;
        break;
      case 3:
        _totalRounds = 8;
        break;
      default:
        _totalRounds = 5;
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
      _currentRound++;
      _generateRoundObjects();
    });

    _progressController.reset();
    _progressController.forward();

    await _audioHelper.playSoundSequence([
      'color_shape_instrukcija.mp3',
    ]);

    await Future.delayed(const Duration(milliseconds: 800));
    await _audioHelper.playSound('sortiraj_objekte.mp3');
  }

  void _generateRoundObjects() {
    _currentObjects.clear();
    _categories.clear();
    _sortedObjects.clear();

    switch (widget.level) {
      case 1:
        _generateColorSortingRound();
        break;
      case 2:
        _generateShapeSortingRound();
        break;
      case 3:
        _generateMixedSortingRound();
        break;
    }

    for (final category in _categories) {
      _sortedObjects[category.id] = [];
    }

    _availableObjects = List.from(_currentObjects)..shuffle();
  }

  void _generateColorSortingRound() {
    final colors = [Colors.red, Colors.blue, Colors.yellow, Colors.green];
    colors.shuffle();
    final selectedColors = colors.take(2 + (_currentRound % 2)).toList();

    for (final color in selectedColors) {
      _categories.add(SortingCategory(
        id: _getColorName(color),
        type: 'color',
        targetColor: color,
        name: 'Sortiraj ${_getColorName(color)} boju',
      ));
    }

    final shapes = ['circle', 'square', 'triangle', 'star', 'heart'];
    for (final color in selectedColors) {
      shapes.shuffle();
      for (int i = 0; i < 2 + Random().nextInt(2); i++) {
        final shape = shapes[i % shapes.length];
        final obj =
            _allObjects.firstWhere((o) => o.color == color && o.shape == shape);
        _currentObjects.add(obj);
      }
    }

    _currentInstruction = "Sortiraj po bojama!";
  }

  void _generateShapeSortingRound() {
    final shapes = ['circle', 'square', 'triangle', 'star', 'heart'];
    shapes.shuffle();
    final selectedShapes = shapes.take(2 + (_currentRound % 2)).toList();

    for (final shape in selectedShapes) {
      _categories.add(SortingCategory(
        id: shape,
        type: 'shape',
        targetShape: shape,
        name: 'Sortiraj ${_getShapeName(shape)}',
      ));
    }

    final colors = [
      Colors.red,
      Colors.blue,
      Colors.yellow,
      Colors.green,
      Colors.orange
    ];
    for (final shape in selectedShapes) {
      colors.shuffle();
      for (int i = 0; i < 2 + Random().nextInt(2); i++) {
        final color = colors[i % colors.length];
        final obj =
            _allObjects.firstWhere((o) => o.shape == shape && o.color == color);
        _currentObjects.add(obj);
      }
    }

    _currentInstruction = "Sortiraj po oblicima!";
  }

  void _generateMixedSortingRound() {
    final shouldSortByColor = Random().nextBool();

    if (shouldSortByColor) {
      _generateColorSortingRound();

      for (final category in _categories) {
        if (category.type == 'color' && category.targetColor != null) {
          final availableShapes = [
            'circle',
            'square',
            'triangle',
            'star',
            'heart'
          ];
          availableShapes.shuffle();

          for (int i = 0; i < 1 + Random().nextInt(2); i++) {
            final shape = availableShapes[i % availableShapes.length];

            final existingObj = _currentObjects.any((obj) =>
                obj.color == category.targetColor && obj.shape == shape);

            if (!existingObj) {
              final obj = _allObjects.firstWhere(
                (o) => o.color == category.targetColor && o.shape == shape,
              );
              _currentObjects.add(obj);
            }
          }
        }
      }
    } else {
      _generateShapeSortingRound();

      for (final category in _categories) {
        if (category.type == 'shape' && category.targetShape != null) {
          final availableColors = [
            Colors.red,
            Colors.blue,
            Colors.yellow,
            Colors.green,
            Colors.orange
          ];
          availableColors.shuffle();

          for (int i = 0; i < 1 + Random().nextInt(2); i++) {
            final color = availableColors[i % availableColors.length];

            final existingObj = _currentObjects.any((obj) =>
                obj.shape == category.targetShape && obj.color == color);

            if (!existingObj) {
              final obj = _allObjects.firstWhere(
                (o) => o.shape == category.targetShape && o.color == color,
              );
              _currentObjects.add(obj);
            }
          }
        }
      }
    }

    _currentInstruction =
        shouldSortByColor ? "Sortiraj po bojama!" : "Sortiraj po oblicima!";
  }

  String _getColorName(Color color) {
    if (color == Colors.red) return 'crvena';
    if (color == Colors.blue) return 'plava';
    if (color == Colors.yellow) return 'žuta';
    if (color == Colors.green) return 'zelena';
    if (color == Colors.orange) return 'narandžasta';
    if (color == Colors.purple) return 'ljubičasta';
    return 'boja';
  }

  String _getShapeName(String shape) {
    switch (shape) {
      case 'circle':
        return 'krugovi';
      case 'square':
        return 'kvadrati';
      case 'triangle':
        return 'trouglovi';
      case 'star':
        return 'zvezde';
      case 'heart':
        return 'srca';
      default:
        return 'oblici';
    }
  }

  void _onDragEnd(ColorShapeObject object, String categoryId) async {
    if (_isProcessing || _roundCompleted) return;

    setState(() {
      _isProcessing = true;
    });

    _availableObjects.removeWhere((obj) => obj.id == object.id);

    for (final category in _categories) {
      _sortedObjects[category.id]?.removeWhere((obj) => obj.id == object.id);
    }

    _sortedObjects[categoryId]?.add(object);

    await _audioHelper.playSound('drop_sound.mp3');

    await Future.delayed(const Duration(milliseconds: 300));
    _checkSorting();
  }

  void _checkSorting() async {
    bool allCorrect = true;
    bool hasIncorrectObjects = false;

    for (final category in _categories) {
      final objectsInCategory = _sortedObjects[category.id] ?? [];

      for (final obj in objectsInCategory) {
        bool isCorrect = false;

        if (category.type == 'color') {
          isCorrect = obj.color == category.targetColor;
        } else if (category.type == 'shape') {
          isCorrect = obj.shape == category.targetShape;
        }

        if (!isCorrect) {
          hasIncorrectObjects = true;
          allCorrect = false;
          break;
        }
      }

      if (!allCorrect) break;
    }

    final hasAvailableObjects = _availableObjects.isNotEmpty;

    if (!hasAvailableObjects && allCorrect && !hasIncorrectObjects) {
      await _audioHelper
          .playSoundSequence(['color_shape_correct.mp3', 'bravo.mp3']);

      setState(() {
        _roundCompleted = true;
        _showCelebration = true;
      });

      _celebrationController.forward().then((_) {
        _celebrationController.reset();
        setState(() {
          _showCelebration = false;
        });
      });

      _bounceController.forward().then((_) {
        _bounceController.reverse();
      });

      setState(() {
        _score += (15 * widget.level);
      });

      await Future.delayed(const Duration(milliseconds: 2000));
      _startNewRound();
    } else if (hasIncorrectObjects) {
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      await _audioHelper
          .playSoundSequence(['color_shape_wrong.mp3', 'pokusaj_ponovo.mp3']);
      await Future.delayed(const Duration(milliseconds: 1000));
    }

    setState(() {
      _isProcessing = false;
    });
  }

  void _removeObjectFromCategory(
      ColorShapeObject object, String categoryId) async {
    if (_isProcessing || _roundCompleted) return;

    await _audioHelper.playSound('pickup_sound.mp3');

    setState(() {
      _sortedObjects[categoryId]?.removeWhere((obj) => obj.id == object.id);
      if (!_availableObjects.any((obj) => obj.id == object.id)) {
        _availableObjects.add(object);
      }
    });
  }

  void _resetRound() async {
    if (_isProcessing) return;

    await _audioHelper.playSound('reset_sound.mp3');

    setState(() {
      _availableObjects.clear();
      _availableObjects.addAll(_currentObjects);
      _availableObjects.shuffle();

      for (final category in _categories) {
        _sortedObjects[category.id] = [];
      }

      _isProcessing = false;
      _roundCompleted = false;
    });
  }

  void _showWinDialog() async {
    await _progressTracker.saveModuleProgress('color_shape', widget.level, 3);
    await _progressTracker.saveHighScore('color_shape', _score);
    await _progressTracker.incrementAttempts('color_shape');

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
              Colors.pink.shade100,
              Colors.purple.shade50,
              Colors.orange.shade50,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.3),
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
                color: Colors.pink,
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
                color: Colors.pink.shade600,
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
                    context.go('/color_shape?level=${widget.level + 1}');
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
    final maxScore = _totalRounds * 15 * widget.level;
    if (_score >= maxScore * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    final maxScore = _totalRounds * 15 * widget.level;
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink.shade50,
              Colors.purple.shade50,
              Colors.orange.shade50,
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
              Expanded(child: _buildMainGameArea()),
            ],
          ),
        ),
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
            color: Colors.pink.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTopBarButton(
            icon: Icons.arrow_back_rounded,
            color: Colors.pink,
            onTap: () async {
              await _audioHelper.stopBackgroundMusic();
              if (context.mounted) {
                context.go('/color_shape-levels');
              }
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sortiraj po boji/obliku',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink.shade700,
                  ),
                ),
                Text(
                  'Level ${widget.level}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.pink.shade500,
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
                  'Bodovi', _score.toString(), Colors.pink, Icons.star)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Runda', '$_currentRound/$_totalRounds',
                  Colors.blue, Icons.flag)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildStatCard('Level', widget.level.toString(),
                  Colors.orange, Icons.trending_up)),
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
                colors: [Colors.pink.shade400, Colors.purple.shade400],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
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
                  child: const Icon(Icons.lightbulb,
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

  Widget _buildMainGameArea() {
    return Column(
      children: [
        Expanded(flex: 2, child: _buildAvailableObjectsArea()),
        const SizedBox(height: 16),
        Expanded(flex: 3, child: _buildSortingCategoriesArea()),
      ],
    );
  }

  Widget _buildAvailableObjectsArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: DragTarget<ColorShapeObject>(
        onAcceptWithDetails: (details) {
          setState(() {
            if (!_availableObjects.any((obj) => obj.id == details.data.id)) {
              _availableObjects.add(details.data);
            }
            for (final category in _categories) {
              _sortedObjects[category.id]
                  ?.removeWhere((obj) => obj.id == details.data.id);
            }
          });
          _audioHelper.playSound('pickup_sound.mp3');
        },
        builder: (context, candidateData, rejectedData) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: candidateData.isNotEmpty
                  ? Colors.green.shade50
                  : Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              border: candidateData.isNotEmpty
                  ? Border.all(color: Colors.green.shade300, width: 3)
                  : Border.all(color: Colors.grey.shade200, width: 2),
              boxShadow: [
                BoxShadow(
                  color: candidateData.isNotEmpty
                      ? Colors.green.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                if (candidateData.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.keyboard_return,
                            color: Colors.green.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Pustite da vratite objekat',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (candidateData.isNotEmpty) const SizedBox(height: 16),
                Expanded(
                  child: _availableObjects.isEmpty && candidateData.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_downward,
                                  color: Colors.grey.shade400, size: 32),
                              const SizedBox(height: 8),
                              Text(
                                'Objekti su pomereni dole',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount =
                                constraints.maxWidth > 400 ? 4 : 3;
                            return GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1,
                              ),
                              itemCount: _availableObjects.length,
                              itemBuilder: (context, index) {
                                return _buildDraggableObject(
                                    _availableObjects[index]);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSortingCategoriesArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = _categories.length <= 2 ? 2 : 3;
          return GridView.builder(
            physics: const BouncingScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.8,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return _buildCategoryCard(_categories[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildDraggableObject(ColorShapeObject obj) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Draggable<ColorShapeObject>(
          data: obj,
          feedback: Transform.scale(
            scale: 1.2,
            child: _buildObjectWidget(obj, isFloating: true),
          ),
          childWhenDragging: _buildObjectWidget(obj, isPlaceholder: true),
          child: _buildObjectWidget(obj, glowIntensity: _glowAnimation.value),
        );
      },
    );
  }

  Widget _buildObjectWidget(
    ColorShapeObject obj, {
    bool isFloating = false,
    bool isPlaceholder = false,
    double glowIntensity = 0.0,
  }) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _isProcessing && !_roundCompleted
                ? sin(_shakeAnimation.value) * 2
                : 0,
            0,
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: isPlaceholder
                  ? LinearGradient(
                      colors: [Colors.grey.shade200, Colors.grey.shade300])
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        obj.color.withOpacity(0.9),
                        obj.color,
                        obj.color.withOpacity(0.7),
                      ],
                    ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                if (!isPlaceholder)
                  BoxShadow(
                    color: obj.color.withOpacity(0.3 + glowIntensity * 0.4),
                    blurRadius: 10 + glowIntensity * 15,
                    offset: const Offset(0, 5),
                    spreadRadius: glowIntensity * 2,
                  ),
              ],
            ),
            child: isPlaceholder
                ? null
                : Center(
                    child: Icon(
                      _getIconForShape(obj.shape),
                      size: isFloating ? 40 : 32,
                      color: Colors.white,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(SortingCategory category) {
    final objectsInCategory = _sortedObjects[category.id] ?? [];

    return DragTarget<ColorShapeObject>(
      onAcceptWithDetails: (details) {
        _onDragEnd(details.data, category.id);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? Colors.purple.shade400
                  : (category.type == 'color'
                      ? category.targetColor!.withOpacity(0.5)
                      : Colors.grey.shade300),
              width: candidateData.isNotEmpty ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: candidateData.isNotEmpty
                    ? Colors.purple.withOpacity(0.3)
                    : (category.type == 'color'
                        ? category.targetColor!.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1)),
                blurRadius: candidateData.isNotEmpty ? 20 : 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: category.type == 'color'
                      ? LinearGradient(
                          colors: [
                            category.targetColor!.withOpacity(0.8),
                            category.targetColor!,
                          ],
                        )
                      : LinearGradient(
                          colors: [Colors.grey.shade300, Colors.grey.shade400],
                        ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(23),
                    topRight: Radius.circular(23),
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      category.type == 'color'
                          ? Icons.circle
                          : _getIconForShape(category.targetShape!),
                      size: 32,
                      color: category.type == 'color'
                          ? category.targetColor
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: objectsInCategory.isEmpty
                      ? Center(
                          child: Text(
                            category.type == 'color'
                                ? _getColorName(category.targetColor!)
                                : _getShapeName(category.targetShape!),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: objectsInCategory.length,
                          itemBuilder: (context, index) {
                            final obj = objectsInCategory[index];
                            return GestureDetector(
                              onTap: () =>
                                  _removeObjectFromCategory(obj, category.id),
                              child: Draggable<ColorShapeObject>(
                                data: obj,
                                feedback: Transform.scale(
                                  scale: 1.2,
                                  child: _buildSmallObjectWidget(obj),
                                ),
                                childWhenDragging: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onDragStarted: () {
                                  _removeObjectFromCategory(obj, category.id);
                                },
                                child: _buildSmallObjectWidget(obj),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSmallObjectWidget(ColorShapeObject obj) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [obj.color.withOpacity(0.9), obj.color],
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: obj.color.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getIconForShape(obj.shape),
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  IconData _getIconForShape(String shape) {
    switch (shape) {
      case 'circle':
        return Icons.circle;
      case 'square':
        return Icons.square;
      case 'triangle':
        return Icons.change_history;
      case 'star':
        return Icons.star;
      case 'heart':
        return Icons.favorite;
      default:
        return Icons.circle;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _backgroundController.dispose();
    _audioHelper.stopBackgroundMusic();
    super.dispose();
  }
}

// Model classes
class ColorShapeObject {
  final String id;
  final Color color;
  final String shape;
  final String name;

  ColorShapeObject({
    required this.id,
    required this.color,
    required this.shape,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorShapeObject &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class SortingCategory {
  final String id;
  final String type;
  final Color? targetColor;
  final String? targetShape;
  final String name;

  SortingCategory({
    required this.id,
    required this.type,
    this.targetColor,
    this.targetShape,
    required this.name,
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
        Colors.pink.withOpacity(1 - progress),
        Colors.purple.withOpacity(1 - progress),
        Colors.orange.withOpacity(1 - progress),
        Colors.blue.withOpacity(1 - progress),
      ][i % 4];

      if (i % 3 == 0) {
        canvas.drawCircle(Offset(x, y), 6, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 10, height: 10),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
