import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class SortingGameScreen extends StatefulWidget {
  final int level;

  const SortingGameScreen({super.key, required this.level});

  @override
  State<SortingGameScreen> createState() => _SortingGameScreenState();
}

class _SortingGameScreenState extends State<SortingGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _celebrationController;
  late AnimationController _correctAnswerController;
  late AnimationController _glowController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _celebrationAnimation;
  late Animation<double> _glowAnimation;

  List<SortingObject> _allObjects = [];
  List<SortingObject> _currentObjects = [];
  List<SortingObject?> _sortedSlots = [];
  List<SortingObject> _availableObjects = [];

  int _score = 0;
  int _currentRound = 0;
  int _totalRounds = 0;
  bool _isProcessing = false;
  bool _showCelebration = false;
  bool _gameCompleted = false;
  bool _roundCompleted = false;

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

    _correctAnswerController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 8.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.elasticInOut,
    ));

    _celebrationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _celebrationController,
      curve: Curves.easeInOut,
    ));

    _glowAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _initializeObjects() {
    _allObjects = [
      // Lopte - 5 različitih veličina
      SortingObject(
          id: 'ball_tiny',
          type: 'ball',
          size: 1,
          imagePath: 'assets/images/sorting/ball_small.png',
          name: 'Lopta'),
      SortingObject(
          id: 'ball_small',
          type: 'ball',
          size: 2,
          imagePath: 'assets/images/sorting/ball_medium.png',
          name: 'Lopta'),
      SortingObject(
          id: 'ball_medium',
          type: 'ball',
          size: 3,
          imagePath: 'assets/images/sorting/ball_large.png',
          name: 'Lopta'),
      SortingObject(
          id: 'ball_large',
          type: 'ball',
          size: 4,
          imagePath: 'assets/images/sorting/ball_large.png',
          name: 'Lopta'),
      SortingObject(
          id: 'ball_huge',
          type: 'ball',
          size: 5,
          imagePath: 'assets/images/sorting/ball_large.png',
          name: 'Lopta'),

      // Jabuke - 5 različitih veličina
      SortingObject(
          id: 'apple_tiny',
          type: 'apple',
          size: 1,
          imagePath: 'assets/images/sorting/apple_small.png',
          name: 'Jabuka'),
      SortingObject(
          id: 'apple_small',
          type: 'apple',
          size: 2,
          imagePath: 'assets/images/sorting/apple_medium.png',
          name: 'Jabuka'),
      SortingObject(
          id: 'apple_medium',
          type: 'apple',
          size: 3,
          imagePath: 'assets/images/sorting/apple_large.png',
          name: 'Jabuka'),
      SortingObject(
          id: 'apple_large',
          type: 'apple',
          size: 4,
          imagePath: 'assets/images/sorting/apple_large.png',
          name: 'Jabuka'),
      SortingObject(
          id: 'apple_huge',
          type: 'apple',
          size: 5,
          imagePath: 'assets/images/sorting/apple_large.png',
          name: 'Jabuka'),

      // Kućice - 5 različitih veličina
      SortingObject(
          id: 'house_tiny',
          type: 'house',
          size: 1,
          imagePath: 'assets/images/sorting/house_small.png',
          name: 'Kuća'),
      SortingObject(
          id: 'house_small',
          type: 'house',
          size: 2,
          imagePath: 'assets/images/sorting/house_medium.png',
          name: 'Kuća'),
      SortingObject(
          id: 'house_medium',
          type: 'house',
          size: 3,
          imagePath: 'assets/images/sorting/house_large.png',
          name: 'Kuća'),
      SortingObject(
          id: 'house_large',
          type: 'house',
          size: 4,
          imagePath: 'assets/images/sorting/house_large.png',
          name: 'Kuća'),
      SortingObject(
          id: 'house_huge',
          type: 'house',
          size: 5,
          imagePath: 'assets/images/sorting/house_large.png',
          name: 'Kuća'),

      // Automobili - 5 različitih veličina
      SortingObject(
          id: 'car_tiny',
          type: 'car',
          size: 1,
          imagePath: 'assets/images/sorting/car_small.png',
          name: 'Auto'),
      SortingObject(
          id: 'car_small',
          type: 'car',
          size: 2,
          imagePath: 'assets/images/sorting/car_medium.png',
          name: 'Auto'),
      SortingObject(
          id: 'car_medium',
          type: 'car',
          size: 3,
          imagePath: 'assets/images/sorting/car_large.png',
          name: 'Auto'),
      SortingObject(
          id: 'car_large',
          type: 'car',
          size: 4,
          imagePath: 'assets/images/sorting/car_large.png',
          name: 'Auto'),
      SortingObject(
          id: 'car_huge',
          type: 'car',
          size: 5,
          imagePath: 'assets/images/sorting/car_large.png',
          name: 'Auto'),

      // Zvezde - 5 različitih veličina
      SortingObject(
          id: 'star_tiny',
          type: 'star',
          size: 1,
          imagePath: 'assets/images/sorting/star_small.png',
          name: 'Zvezda'),
      SortingObject(
          id: 'star_small',
          type: 'star',
          size: 2,
          imagePath: 'assets/images/sorting/star_medium.png',
          name: 'Zvezda'),
      SortingObject(
          id: 'star_medium',
          type: 'star',
          size: 3,
          imagePath: 'assets/images/sorting/star_large.png',
          name: 'Zvezda'),
      SortingObject(
          id: 'star_large',
          type: 'star',
          size: 4,
          imagePath: 'assets/images/sorting/star_large.png',
          name: 'Zvezda'),
      SortingObject(
          id: 'star_huge',
          type: 'star',
          size: 5,
          imagePath: 'assets/images/sorting/star_large.png',
          name: 'Zvezda'),
    ];
  }

  void _startBackgroundMusic() {
    _audioHelper.playBackgroundMusic(
      'sorting_background.mp3',
      loop: true,
    );

    _audioHelper.setBackgroundMusicVolume(0.24);
    _audioHelper.setSoundEffectsVolume(0.88);
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
      _currentRound++;
      _generateRoundObjects();
    });

    await _audioHelper.playSoundSequence([
      'sorting_instrukcija.mp3', // "Sortiraj objekte od najmanjeg do najvećeg"
    ]);

    await Future.delayed(const Duration(milliseconds: 800));
    await _audioHelper.playSound('poredaj_po_velicini.mp3');
  }

  void _generateRoundObjects() {
    List<int> sizes;

    switch (widget.level) {
      case 1:
        sizes = [1, 3, 5]; // 3 objekta - tiny, medium, huge (jasne razlike)
        break;
      case 2:
        sizes = [1, 2, 4, 5]; // 4 objekta - različite veličine
        break;
      case 3:
        sizes = [1, 2, 3, 4, 5]; // 5 objekata - sve veličine
        break;
      default:
        sizes = [1, 3, 5];
    }

    if (widget.level == 3) {
      // Level 3: Mix različitih tipova objekata
      _currentObjects = [];
      final types = ['ball', 'apple', 'house', 'car', 'star'];
      types.shuffle();

      for (int i = 0; i < sizes.length; i++) {
        final type = types[i % types.length];
        final size = sizes[i];
        final obj =
            _allObjects.firstWhere((o) => o.type == type && o.size == size);
        _currentObjects.add(obj);
      }
    } else {
      // Level 1 & 2: Isti tip objekata
      final types = ['ball', 'apple', 'house', 'car', 'star'];
      types.shuffle();
      final selectedType = types.first;

      _currentObjects = [];
      for (final size in sizes) {
        final obj = _allObjects
            .firstWhere((o) => o.type == selectedType && o.size == size);
        _currentObjects.add(obj);
      }
    }

    // Shuffle za random raspored
    _availableObjects = List.from(_currentObjects)..shuffle();

    // Initialize slots
    _sortedSlots = List.filled(_currentObjects.length, null);
  }

  void _onDragEnd(SortingObject object, int slotIndex) async {
    if (_isProcessing || _roundCompleted) return;

    setState(() {
      _isProcessing = true;
    });

    // If slot is already occupied, swap objects
    if (_sortedSlots[slotIndex] != null) {
      final existingObject = _sortedSlots[slotIndex]!;
      _availableObjects.add(existingObject);
    }

    // Remove object from available objects if it's there
    _availableObjects.removeWhere((obj) => obj.id == object.id);

    // Place object in slot
    _sortedSlots[slotIndex] = object;

    await _audioHelper.playSound('drop_sound.mp3');

    // Check if all slots are filled
    if (_sortedSlots.every((slot) => slot != null)) {
      await Future.delayed(const Duration(milliseconds: 500));
      _checkSorting();
    } else {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _checkSorting() async {
    // Check if sorted correctly (smallest to largest)
    bool isCorrect = true;
    for (int i = 0; i < _sortedSlots.length - 1; i++) {
      if (_sortedSlots[i]!.size > _sortedSlots[i + 1]!.size) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      // Correct sorting!
      await _audioHelper.playSoundSequence([
        'sorting_correct.mp3',
        'bravo.mp3',
      ]);

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
        _score += (10 * widget.level);
      });

      await Future.delayed(const Duration(milliseconds: 2000));
      _startNewRound();
    } else {
      // Incorrect sorting
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      await _audioHelper.playSoundSequence([
        'sorting_wrong.mp3',
        'pokusaj_ponovo.mp3',
      ]);

      await Future.delayed(const Duration(milliseconds: 1500));

      // Reset round - Put all objects back to available and clear slots
      setState(() {
        // Collect all objects from slots and put them back
        for (int i = 0; i < _sortedSlots.length; i++) {
          if (_sortedSlots[i] != null) {
            _availableObjects.add(_sortedSlots[i]!);
          }
        }
        // Shuffle available objects
        _availableObjects.shuffle();
        // Clear all slots
        _sortedSlots = List.filled(_currentObjects.length, null);
        _isProcessing = false;
        _roundCompleted = false;
      });
    }
  }

  void _resetRound() async {
    if (_isProcessing) return;

    await _audioHelper.playSound('reset_sound.mp3');

    setState(() {
      // Collect all objects from slots back to available
      _availableObjects.clear();
      for (int i = 0; i < _sortedSlots.length; i++) {
        if (_sortedSlots[i] != null) {
          _availableObjects.add(_sortedSlots[i]!);
        }
      }
      // Add any remaining objects from current objects that aren't in slots or available
      for (final obj in _currentObjects) {
        if (!_availableObjects.any((available) => available.id == obj.id)) {
          _availableObjects.add(obj);
        }
      }
      // Shuffle available objects
      _availableObjects.shuffle();
      // Clear all slots
      _sortedSlots = List.filled(_currentObjects.length, null);
      _isProcessing = false;
      _roundCompleted = false;
    });
  }

  // NEW: Function to remove object from slot back to available
  void _removeObjectFromSlot(int slotIndex) async {
    if (_isProcessing || _roundCompleted) return;
    if (_sortedSlots[slotIndex] == null) return;

    await _audioHelper.playSound('pickup_sound.mp3');

    setState(() {
      // Move object back to available
      _availableObjects.add(_sortedSlots[slotIndex]!);
      _sortedSlots[slotIndex] = null;
    });
  }

  void _showWinDialog() async {
    await _progressTracker.saveModuleProgress('sorting', widget.level, 3);
    await _progressTracker.saveHighScore('sorting', _score);
    await _progressTracker.incrementAttempts('sorting');

    await _audioHelper.playSoundSequence([
      'game_complete.mp3',
      'bravo.mp3',
    ]);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.cyan.shade50,
        title: Text(
          _getWinTitle(),
          style: const TextStyle(fontSize: 28, color: Colors.cyan),
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
                color: Colors.cyan.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () async {
                    await _audioHelper.pauseBackgroundMusic();
                  },
                  icon: const Icon(Icons.pause, size: 30),
                  tooltip: 'Pauziraj muziku',
                ),
                IconButton(
                  onPressed: () async {
                    await _audioHelper.resumeBackgroundMusic();
                  },
                  icon: const Icon(Icons.play_arrow, size: 30),
                  tooltip: 'Nastavi muziku',
                ),
              ],
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
            child: const Text('Nova igra', style: TextStyle(fontSize: 18)),
          ),
          if (widget.level < 3)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/sorting?level=${widget.level + 1}');
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
    final maxScore = _totalRounds * 10 * widget.level;
    if (_score >= maxScore * 0.8) {
      return 'Odlično! 🌟';
    } else if (_score >= maxScore * 0.6) {
      return 'Vrlo dobro! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  IconData _getWinIcon() {
    final maxScore = _totalRounds * 10 * widget.level;
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sortiraj po veličini - Level ${widget.level}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan.shade300,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () async {
            await _audioHelper.stopBackgroundMusic();
            if (context.mounted) {
              context.go('/sorting-levels');
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
              size: 28,
            ),
            tooltip: 'Uključi/isključi muziku',
          ),
          IconButton(
            onPressed: _resetRound,
            icon: const Icon(Icons.refresh_rounded, size: 28),
            tooltip: 'Počni ponovo',
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.cyan.shade100,
                  Colors.cyan.shade50,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Info panel
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Flexible(
                            child: _buildInfoCard(
                                'Bodovi', _score.toString(), Colors.cyan)),
                        Flexible(
                            child: _buildInfoCard(
                                'Runda',
                                '$_currentRound / $_totalRounds',
                                Colors.indigo)),
                        Flexible(
                            child: _buildInfoCard('Level',
                                widget.level.toString(), Colors.deepOrange)),
                      ],
                    ),
                  ),

                  // Available objects to drag - NO SCROLL, FIXED LAYOUT
                  Expanded(
                    flex: 3,
                    child: DragTarget<SortingObject>(
                      onAcceptWithDetails: (details) {
                        // Return object to available area
                        setState(() {
                          if (!_availableObjects
                              .any((obj) => obj.id == details.data.id)) {
                            _availableObjects.add(details.data);
                          }
                          // Remove from slots if it was there
                          for (int i = 0; i < _sortedSlots.length; i++) {
                            if (_sortedSlots[i]?.id == details.data.id) {
                              _sortedSlots[i] = null;
                              break;
                            }
                          }
                        });
                        _audioHelper.playSound('pickup_sound.mp3');
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: candidateData.isNotEmpty
                                ? Colors.cyan.shade100.withOpacity(0.9)
                                : Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(20),
                            border: candidateData.isNotEmpty
                                ? Border.all(
                                    color: Colors.cyan.shade400, width: 2)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyan.shade200,
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              if (candidateData.isNotEmpty)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.keyboard_return,
                                        color: Colors.cyan.shade600, size: 16),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Pustite da vratite objekat',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.cyan.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              if (candidateData.isNotEmpty)
                                const SizedBox(height: 10),
                              Expanded(
                                child: Center(
                                  child: _availableObjects.isEmpty &&
                                          candidateData.isEmpty
                                      ? Text(
                                          'Objekti su pomereni dole',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      : Wrap(
                                          spacing: 10,
                                          runSpacing: 10,
                                          alignment: WrapAlignment.center,
                                          children: _availableObjects
                                              .map((obj) =>
                                                  _buildDraggableObject(obj))
                                              .toList(),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Sorting slots - HORIZONTAL SCROLL FOR MANY ITEMS
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.shade200,
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_forward,
                                  color: Colors.cyan.shade600, size: 20),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Column(
                                  children: [
                                    Text(
                                      'Od najmanjeg do najvećeg',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.cyan.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'Dodirnite objekat da ga vratite',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.cyan.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward,
                                  color: Colors.cyan.shade600, size: 20),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Expanded(
                            child: Center(
                              child: _sortedSlots.length <= 3
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                          _sortedSlots.length,
                                          (index) => _buildDropSlot(index)),
                                    )
                                  : SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(
                                            _sortedSlots.length, (index) {
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            child: _buildDropSlot(index),
                                          );
                                        }),
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),
                ],
              ),
            ),
          ),

          // Celebration animation
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

  Widget _buildInfoCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableObject(SortingObject obj) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Draggable<SortingObject>(
          data: obj,
          feedback: _buildObjectWidget(obj, isDragging: true),
          childWhenDragging: _buildObjectWidget(obj, isPlaceholder: true),
          child: _buildObjectWidget(obj, glowIntensity: _glowAnimation.value),
        );
      },
    );
  }

  Widget _buildObjectWidget(SortingObject obj,
      {bool isDragging = false,
      bool isPlaceholder = false,
      double glowIntensity = 0.0}) {
    // Progressive sizing: size 1 = 50px, size 2 = 65px, size 3 = 80px, size 4 = 95px, size 5 = 110px
    final size = 35.0 + (obj.size * 15.0);

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
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isPlaceholder ? Colors.grey.shade300 : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color:
                    isPlaceholder ? Colors.grey.shade400 : Colors.cyan.shade300,
                width: 2,
              ),
              boxShadow: [
                if (!isPlaceholder)
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.3 + glowIntensity * 0.4),
                    blurRadius: 8 + glowIntensity * 10,
                    offset: const Offset(0, 4),
                    spreadRadius: glowIntensity * 3,
                  ),
              ],
            ),
            child: isPlaceholder
                ? null
                : Padding(
                    padding: const EdgeInsets.all(6),
                    child: Image.asset(
                      obj.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          _getIconForType(obj.type),
                          size: size * 0.6,
                          color: Colors.cyan.shade400,
                        );
                      },
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDropSlot(int index) {
    final isEmpty = _sortedSlots[index] == null;

    return DragTarget<SortingObject>(
      onAcceptWithDetails: (details) {
        // Only accept if slot is empty
        if (isEmpty) {
          _onDragEnd(details.data, index);
        }
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedBuilder(
          animation: _bounceAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: isEmpty ? 1.0 : _bounceAnimation.value,
              child: Container(
                width: 85,
                height: 85,
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isEmpty ? Colors.cyan.shade50 : Colors.green.shade100,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color:
                        isEmpty ? Colors.cyan.shade300 : Colors.green.shade400,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (isEmpty ? Colors.cyan : Colors.green)
                          .withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            size: 24,
                            color: Colors.cyan.shade400,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan.shade600,
                            ),
                          ),
                        ],
                      )
                    : Stack(
                        children: [
                          // Main draggable object in slot
                          Padding(
                            padding: const EdgeInsets.all(3),
                            child: Draggable<SortingObject>(
                              data: _sortedSlots[index]!,
                              feedback: _buildObjectWidget(_sortedSlots[index]!,
                                  isDragging: true),
                              childWhenDragging: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade400, width: 2),
                                ),
                              ),
                              onDragStarted: () {
                                // Remove from slot when drag starts
                                setState(() {
                                  _availableObjects.add(_sortedSlots[index]!);
                                  _sortedSlots[index] = null;
                                });
                              },
                              child: GestureDetector(
                                onTap: () => _removeObjectFromSlot(index),
                                child: _buildObjectWidget(_sortedSlots[index]!),
                              ),
                            ),
                          ),
                          // Small remove icon in top-right corner
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeObjectFromSlot(index),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.red.shade400,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'ball':
        return Icons.sports_soccer;
      case 'apple':
        return Icons.apple;
      case 'house':
        return Icons.home;
      case 'car':
        return Icons.directions_car;
      case 'star':
        return Icons.star;
      default:
        return Icons.circle;
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _shakeController.dispose();
    _celebrationController.dispose();
    _correctAnswerController.dispose();
    _glowController.dispose();

    _audioHelper.stopBackgroundMusic();

    super.dispose();
  }
}

// Model za sorting objekte
class SortingObject {
  final String id;
  final String type;
  final int size; // 1 = small, 2 = medium, 3 = large, 4 = extra large, 5 = huge
  final String imagePath;
  final String name;

  SortingObject({
    required this.id,
    required this.type,
    required this.size,
    required this.imagePath,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SortingObject &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Painter za celebration animation
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
        Colors.cyan.withOpacity(1 - progress),
        Colors.blue.withOpacity(1 - progress),
        Colors.purple.withOpacity(1 - progress),
        Colors.orange.withOpacity(1 - progress),
      ][i % 4];

      // Draw confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 8,
          height: 12,
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
