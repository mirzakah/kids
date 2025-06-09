import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/audio_helper.dart';

class LevelSelectionScreen extends StatefulWidget {
  final String moduleId;
  final String moduleTitle;
  final Color moduleColor;

  const LevelSelectionScreen({
    super.key,
    required this.moduleId,
    required this.moduleTitle,
    required this.moduleColor,
  });

  @override
  State<LevelSelectionScreen> createState() => _LevelSelectionScreenState();
}

class _LevelSelectionScreenState extends State<LevelSelectionScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  late PageController _pageController;
  late AnimationController _bounceController;
  late AnimationController _shimmerController;
  late AnimationController _floatController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _floatAnimation;

  int _currentLevel = 1;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85, // Card overlap effect
    );

    _initializeAnimations();
    _playWelcomeSound();
  }

  void _initializeAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    _floatAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _bounceController.forward();
  }

  void _playWelcomeSound() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _audioHelper.playSoundSequence([
      'odaberi_nivo.mp3',
      'level_1.mp3', // "Level jedan"
    ]);
  }

  void _onPageChanged(int index) async {
    if (_isAnimating) return;

    _isAnimating = true;
    setState(() {
      _currentLevel = index + 1;
    });

    // Bounce effect on card change
    _bounceController.reset();
    _bounceController.forward();

    // Play level sound
    await _audioHelper.playSound('level_${_currentLevel}.mp3');

    await Future.delayed(const Duration(milliseconds: 300));
    _isAnimating = false;
  }

  void _onLevelSelected(int level) async {
    if (_isAnimating) return;

    // Play selection sound
    await _audioHelper.playSoundSequence([
      'klik.mp3',
      'level_${level}_selected.mp3', // "Level X odabran"
    ]);

    await Future.delayed(const Duration(milliseconds: 300));

    if (context.mounted) {
      context.go('/${widget.moduleId}?level=$level');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              widget.moduleColor.withOpacity(0.1),
              widget.moduleColor.withOpacity(0.3),
              widget.moduleColor.withOpacity(0.1),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar sa floating effect
              _buildCustomAppBar(),

              // Title Section sa shimmer effect
              _buildTitleSection(),

              // Level indicator dots
              _buildLevelIndicator(),

              // Main Cards Section
              Expanded(
                child: _buildLevelCards(screenHeight, screenWidth),
              ),

              // Navigation hints
              _buildNavigationHints(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.3),
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: widget.moduleColor.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    await _audioHelper.playSound('klik.mp3');
                    if (context.mounted) {
                      context.go('/');
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: widget.moduleColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: widget.moduleColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    widget.moduleTitle,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: widget.moduleColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.moduleColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getModuleIcon(),
                    color: widget.moduleColor,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Stack(
            children: [
              // Background text
              Text(
                'Odaberi nivo težine',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  foreground: Paint()
                    ..color = widget.moduleColor.withOpacity(0.1),
                ),
                textAlign: TextAlign.center,
              ),
              // Shimmer overlay
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    begin: Alignment(_shimmerAnimation.value - 1, 0),
                    end: Alignment(_shimmerAnimation.value + 1, 0),
                    colors: [
                      widget.moduleColor.withOpacity(0.3),
                      widget.moduleColor,
                      widget.moduleColor.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ).createShader(bounds);
                },
                child: Text(
                  'Odaberi nivo težine',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isActive = index + 1 == _currentLevel;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 40 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive
                  ? widget.moduleColor
                  : widget.moduleColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(6),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: widget.moduleColor.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLevelCards(double screenHeight, double screenWidth) {
    return Container(
      height: screenHeight * 0.5,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: 3,
        itemBuilder: (context, index) {
          final level = index + 1;
          return AnimatedBuilder(
            animation: _bounceAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _currentLevel == level ? _bounceAnimation.value : 0.95,
                child: _buildLevelCard(level, screenWidth),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLevelCard(int level, double screenWidth) {
    final levelData = _getLevelData(level);
    final isActive = level == _currentLevel;

    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, isActive ? _floatAnimation.value * 0.5 : 0),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: levelData['color'].withOpacity(0.3),
                  blurRadius: isActive ? 25 : 15,
                  offset: Offset(0, isActive ? 15 : 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      levelData['color'].withOpacity(0.9),
                      levelData['color'],
                      levelData['color'].withOpacity(0.8),
                    ],
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onLevelSelected(level),
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: [
                        // Background pattern
                        _buildBackgroundPattern(),

                        // Content
                        Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Level number with glow effect
                              _buildLevelNumber(level),

                              const SizedBox(height: 20),

                              // Title
                              Text(
                                levelData['title'],
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 10),

                              // Subtitle
                              Text(
                                _getLevelSubtitle(level),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 25),

                              // Stars row
                              _buildStarsRow(level),

                              const SizedBox(height: 25),

                              // Play button
                              _buildPlayButton(level),
                            ],
                          ),
                        ),

                        // Top corner badge
                        _buildCornerBadge(levelData['badge']),
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

  Widget _buildBackgroundPattern() {
    return Positioned.fill(
      child: CustomPaint(
        painter: PatternPainter(widget.moduleColor),
      ),
    );
  }

  Widget _buildLevelNumber(int level) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          level.toString(),
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildStarsRow(int level) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final isActive = index < level;
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + index * 100),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          child: Icon(
            isActive ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isActive ? Colors.amber : Colors.white.withOpacity(0.5),
            size: 32,
          ),
        );
      }),
    );
  }

  Widget _buildPlayButton(int level) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.play_arrow_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            'IGRAJ',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBadge(String badge) {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          badge,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationHints() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHintArrow(Icons.chevron_left_rounded, 'Prethodni'),
          Text(
            '${_currentLevel} / 3',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.moduleColor,
            ),
          ),
          _buildHintArrow(Icons.chevron_right_rounded, 'Sljedeći'),
        ],
      ),
    );
  }

  Widget _buildHintArrow(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          color: widget.moduleColor.withOpacity(0.6),
          size: 32,
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: widget.moduleColor.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getLevelData(int level) {
    switch (level) {
      case 1:
        return {
          'title': 'Lako',
          'color': Colors.green,
          'badge': 'POČETNIK',
        };
      case 2:
        return {
          'title': 'Srednje',
          'color': Colors.orange,
          'badge': 'NAPREDNI',
        };
      case 3:
        return {
          'title': 'Teško',
          'color': Colors.red,
          'badge': 'EKSPERT',
        };
      default:
        return {
          'title': 'Lako',
          'color': Colors.green,
          'badge': 'POČETNIK',
        };
    }
  }

  String _getLevelSubtitle(int level) {
    switch (widget.moduleId) {
      case 'memory':
        return level == 1
            ? '3 para kartica'
            : level == 2
                ? '5 parova kartica'
                : '8 parova kartica';
      case 'sounds':
        return level == 1
            ? '3 životinje'
            : level == 2
                ? '5 životinja'
                : '7 životinja';
      case 'counting':
        return level == 1
            ? 'Broji do 3'
            : level == 2
                ? 'Broji do 5'
                : 'Broji do 7';
      case 'missing':
        return level == 1
            ? 'Jednostavni zadaci'
            : level == 2
                ? 'Srednji zadaci'
                : 'Složeni zadaci';
      case 'matching':
        return level == 1
            ? '3 para objekata'
            : level == 2
                ? '5 parova objekata'
                : '8 parova objekata';
      case 'sorting':
        return level == 1
            ? '3 objekta'
            : level == 2
                ? '4 objekta'
                : '5 objekata';
      case 'colors':
        return level == 1
            ? '3 boje'
            : level == 2
                ? '5 boja'
                : '7 boja';
      case 'color_shape':
        return level == 1
            ? 'Sortiraj po boji'
            : level == 2
                ? 'Sortiraj po obliku'
                : 'Kombinovano sortiranje';
      case 'odd_one_out':
        return level == 1
            ? 'Jasne razlike'
            : level == 2
                ? 'Srednje razlike'
                : 'Suptilne razlike';
      case 'simple_math':
        return level == 1
            ? 'Sabiranje i oduzimanje'
            : level == 2
                ? 'Množenje i dijeljenje'
                : 'Kombinovani zadaci';
      case 'counting_tap':
        return level == 1
            ? 'Tapni 3 objekta'
            : level == 2
                ? 'Tapni 3-5 objekata'
                : 'Tapni 4-7 objekata';
      case 'letter_learning':
        return level == 1
            ? 'Velika slova A-Z'
            : level == 2
                ? 'Mala slova a-z'
                : 'Kombinovano slova';
      case 'categorization':
        return level == 1
            ? 'Nađi 3 predmeta (Voće, Povrće, Životinje...)'
            : level == 2
                ? 'Nađi 4 predmeta (+ Vozila, Hrana...)'
                : 'Nađi 5 predmeta (+ Igračke, Odjeća...)';
      default:
        return 'Zabavno učenje';
    }
  }

  IconData _getModuleIcon() {
    switch (widget.moduleId) {
      case 'memory':
        return Icons.psychology_rounded;
      case 'sounds':
        return Icons.volume_up_rounded;
      case 'counting':
        return Icons.calculate_rounded;
      case 'missing':
        return Icons.extension_rounded;
      case 'matching':
        return Icons.link_rounded;
      case 'sorting':
        return Icons.sort_rounded;
      case 'colors':
        return Icons.palette_rounded;
      case 'color_shape':
        return Icons.category_rounded;
      case 'odd_one_out':
        return Icons.help_outline_rounded;
      case 'simple_math':
        return Icons.calculate;
      case 'counting_tap':
        return Icons.touch_app;
      case 'letter_learning':
        return Icons.abc;
      case 'categorization':
        return Icons.category_rounded;
      default:
        return Icons.games_rounded;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bounceController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }
}

// Custom painter za background pattern
class PatternPainter extends CustomPainter {
  final Color color;

  PatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw circles pattern
    for (int i = 0; i < 20; i++) {
      final x = (i % 5) * (size.width / 4) - size.width * 0.1;
      final y = (i ~/ 5) * (size.height / 4) - size.height * 0.1;
      canvas.drawCircle(Offset(x, y), 20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
