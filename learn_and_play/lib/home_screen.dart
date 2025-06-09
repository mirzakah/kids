import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math' as math;
import 'utils/audio_helper.dart';
import 'utils/progress_tracker.dart';

enum HomeScreenState { ageSelection, babyModules, toddlerModules }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _floatController;
  late AnimationController _shimmerController;
  late AnimationController _particleController;
  late AnimationController _pulseController;
  late AnimationController _transitionController;

  late Animation<double> _floatAnimation;
  late Animation<double> _shimmerAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _slideAnimation;

  Map<String, bool> _completedModules = {};
  Map<String, double> _moduleProgress = {};
  bool _isLoaded = false;
  HomeScreenState _currentState = HomeScreenState.ageSelection;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProgress();
    _playWelcomeSound();
  }

  void _initializeAnimations() {
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatAnimation = Tween<double>(
      begin: -15,
      end: 15,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _shimmerAnimation = Tween<double>(
      begin: -2.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.linear,
    ));

    _particleAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadProgress() async {
    await _progressTracker.init();
    setState(() {
      _completedModules = {
        'memory': _progressTracker.isModuleCompleted('memory'),
        'sounds': _progressTracker.isModuleCompleted('sounds'),
        'counting': _progressTracker.isModuleCompleted('counting'),
        'missing': _progressTracker.isModuleCompleted('missing'),
        'colors': _progressTracker.isModuleCompleted('colors'),
        'matching': _progressTracker.isModuleCompleted('matching'),
        'sorting': _progressTracker.isModuleCompleted('sorting'),
        'color_shape': _progressTracker.isModuleCompleted('color_shape'),
        'odd_one_out': _progressTracker.isModuleCompleted('odd_one_out'),
        'simple_math': _progressTracker.isModuleCompleted('simple_math'),
        'counting_tap': _progressTracker.isModuleCompleted('counting_tap'),
        'letter_learning':
            _progressTracker.isModuleCompleted('letter_learning'),
        'shadow_matching':
            _progressTracker.isModuleCompleted('shadow_matching'),
        'professions': _progressTracker.isModuleCompleted('professions'),
        'emotions': _progressTracker.isModuleCompleted('emotions'),
        'categorization': _progressTracker.isModuleCompleted('categorization'),
      };

      _moduleProgress = {
        'memory': _progressTracker.getModuleProgress('memory'),
        'sounds': _progressTracker.getModuleProgress('sounds'),
        'counting': _progressTracker.getModuleProgress('counting'),
        'missing': _progressTracker.getModuleProgress('missing'),
        'colors': _progressTracker.getModuleProgress('colors'),
        'matching': _progressTracker.getModuleProgress('matching'),
        'sorting': _progressTracker.getModuleProgress('sorting'),
        'color_shape': _progressTracker.getModuleProgress('color_shape'),
        'odd_one_out': _progressTracker.getModuleProgress('odd_one_out'),
        'simple_math': _progressTracker.getModuleProgress('simple_math'),
        'counting_tap': _progressTracker.getModuleProgress('counting_tap'),
        'letter_learning':
            _progressTracker.getModuleProgress('letter_learning'),
        'shadow_matching':
            _progressTracker.getModuleProgress('shadow_matching'),
        'professions': _progressTracker.getModuleProgress('professions'),
        'emotions': _progressTracker.getModuleProgress('emotions'),
        'categorization': _progressTracker.getModuleProgress('categorization'),
      };

      _isLoaded = true;
    });
  }

  void _playWelcomeSound() async {
    await Future.delayed(const Duration(milliseconds: 800));
    await _audioHelper.playSoundSequence([
      'dobrodosli.mp3',
      'odaberi_uzrast.mp3', // "Odaberi uzrast"
    ]);
  }

  void _navigateToAge(String ageGroup) async {
    await _audioHelper.playSoundSequence([
      'klik.mp3',
      ageGroup == 'baby' ? 'beba_odabrana.mp3' : 'toddler_odabran.mp3',
    ]);

    _transitionController.forward();
    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      _currentState = ageGroup == 'baby'
          ? HomeScreenState.babyModules
          : HomeScreenState.toddlerModules;
    });
  }

  void _goBackToAgeSelection() async {
    await _audioHelper.playSound('klik.mp3');

    _transitionController.reverse();
    await Future.delayed(const Duration(milliseconds: 400));

    setState(() {
      _currentState = HomeScreenState.ageSelection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          _buildAnimatedBackground(),

          // Floating particles
          _buildFloatingParticles(),

          // Main content
          SafeArea(
            child: AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset:
                      Offset(0, 0), // No slide for now, can add later if needed
                  child: _buildCurrentView(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentState) {
      case HomeScreenState.ageSelection:
        return _buildAgeSelectionView();
      case HomeScreenState.babyModules:
        return _buildModulesView('baby');
      case HomeScreenState.toddlerModules:
        return _buildModulesView('toddler');
    }
  }

  Widget _buildAnimatedBackground() {
    Color primaryColor;
    Color secondaryColor;

    switch (_currentState) {
      case HomeScreenState.ageSelection:
        primaryColor = Colors.purple.shade100;
        secondaryColor = Colors.pink.shade50;
        break;
      case HomeScreenState.babyModules:
        primaryColor = Colors.pink.shade100;
        secondaryColor = Colors.purple.shade50;
        break;
      case HomeScreenState.toddlerModules:
        primaryColor = Colors.blue.shade100;
        secondaryColor = Colors.green.shade50;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            secondaryColor,
            primaryColor.withOpacity(0.3),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildFloatingParticles() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlesPainter(_particleAnimation.value, _currentState),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAgeSelectionView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Welcome header
            _buildWelcomeHeader(),

            const SizedBox(height: 60),

            // Age selection cards
            _buildAgeCard(
              ageGroup: 'baby',
              title: 'Beba',
              subtitle: '6-18 meseci',
              description: 'Osnovne aktivnosti za najmlađe',
              icon: Icons.child_care,
              colors: [Colors.pink.shade300, Colors.purple.shade200],
              completedCount: _getBabyCompletedCount(),
              totalCount: _getBabyTotalCount(),
            ),

            const SizedBox(height: 30),

            _buildAgeCard(
              ageGroup: 'toddler',
              title: 'Toddler',
              subtitle: '18+ meseci',
              description: 'Naprednije igre i učenje',
              icon: Icons.child_friendly,
              colors: [Colors.blue.shade300, Colors.green.shade200],
              completedCount: _getToddlerCompletedCount(),
              totalCount: _getToddlerTotalCount(),
            ),

            const SizedBox(height: 40),

            // Overall stats
            if (_isLoaded) _buildOverallStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildModulesView(String ageGroup) {
    final modules = _getModulesForAge(ageGroup);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Back button and title
            _buildModulesHeader(ageGroup),

            const SizedBox(height: 30),

            // Modules grid
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.8,
              ),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: modules.length,
              itemBuilder: (context, index) {
                final module = modules[index];
                return _buildModuleCard(
                  moduleId: module['id'] as String,
                  title: module['title'] as String,
                  subtitle: module['subtitle'] as String,
                  icon: module['icon'] as IconData,
                  color: module['color'] as Color,
                  route: module['route'] as String,
                  soundFile: module['soundFile'] as String,
                  ageGroup: ageGroup,
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.5),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.shade200.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Icon(
                            Icons.favorite,
                            size: 40,
                            color: Colors.pink.shade400,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                    // Shimmer text effect
                    AnimatedBuilder(
                      animation: _shimmerAnimation,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment(_shimmerAnimation.value - 1, 0),
                              end: Alignment(_shimmerAnimation.value + 1, 0),
                              colors: [
                                Colors.purple.withOpacity(0.5),
                                Colors.purple,
                                Colors.pink,
                                Colors.purple,
                                Colors.purple.withOpacity(0.5),
                              ],
                              stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                            ).createShader(bounds);
                          },
                          child: const Text(
                            'Učimo zajedno!',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 15),
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Icon(
                            Icons.favorite,
                            size: 40,
                            color: Colors.pink.shade400,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Odaberite uzrast vašeg deteta',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.purple.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAgeCard({
    required String ageGroup,
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required List<Color> colors,
    required int completedCount,
    required int totalCount,
  }) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value * 0.3),
          child: Material(
            borderRadius: BorderRadius.circular(25),
            elevation: 0,
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _navigateToAge(ageGroup),
              borderRadius: BorderRadius.circular(25),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colors[0].withOpacity(0.9),
                      colors[1].withOpacity(0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors[0].withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: CustomPaint(
                        painter: AgeCardPatternPainter(colors[0]),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Row(
                        children: [
                          // Icon section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.5),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              size: 40,
                              color: colors[0],
                            ),
                          ),

                          const SizedBox(width: 25),

                          // Text section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Progress indicator
                                Row(
                                  children: [
                                    Text(
                                      '$completedCount/$totalCount',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: totalCount > 0
                                            ? completedCount / totalCount
                                            : 0,
                                        backgroundColor:
                                            Colors.white.withOpacity(0.3),
                                        valueColor:
                                            const AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Arrow
                          const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
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

  Widget _buildModulesHeader(String ageGroup) {
    final isBAby = ageGroup == 'baby';
    final title = isBAby ? 'Igre za bebe' : 'Igre za toddlere';
    final color = isBAby ? Colors.pink : Colors.blue;

    return Row(
      children: [
        IconButton(
          onPressed: _goBackToAgeSelection,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: color.shade700,
            size: 30,
          ),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String moduleId,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
    required String soundFile,
    required String ageGroup,
  }) {
    final isCompleted = _completedModules[moduleId] ?? false;
    final progress = _moduleProgress[moduleId] ?? 0.0;

    return Material(
      borderRadius: BorderRadius.circular(25),
      elevation: 0,
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await _audioHelper.playSoundSequence([
            'klik.mp3',
            soundFile,
          ]);

          await Future.delayed(const Duration(milliseconds: 800));

          if (context.mounted) {
            context.go(route);
          }
        },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
                color.withOpacity(0.5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: ModuleCardPatternPainter(color),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with glow effect
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 35,
                        color: color,
                      ),
                    ),

                    const Spacer(),

                    // Title and subtitle
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 15),

                    // Progress bar
                    _buildProgressBar(progress, isCompleted),
                  ],
                ),
              ),

              // Completion badge
              if (isCompleted)
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: Colors.green.shade600,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, bool isCompleted) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Napredak',
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOverallStats() {
    const totalModules = 12; // Sada imamo 12 ukupno modula
    final completedCount =
        _completedModules.values.where((completed) => completed).length;
    final totalProgress =
        _moduleProgress.values.fold(0.0, (sum, progress) => sum + progress) /
            _moduleProgress.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.8),
            Colors.white.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events_rounded,
              title: 'Završeno',
              value: '$completedCount/$totalModules',
              color: Colors.amber,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: Colors.grey.shade300,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.trending_up_rounded,
              title: 'Napredak',
              value: '${(totalProgress * 100).toInt()}%',
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getModulesForAge(String ageGroup) {
    if (ageGroup == 'baby') {
      return [
        {
          'id': 'memory',
          'title': 'Pamti me',
          'subtitle': 'Memorijska igra',
          'icon': Icons.psychology_rounded,
          'color': Colors.purple,
          'route': '/memory-levels',
          'soundFile': 'pamti_me.mp3',
        },
        {
          'id': 'sounds',
          'title': 'Ko to govori?',
          'subtitle': 'Prepoznavanje zvukova',
          'icon': Icons.volume_up_rounded,
          'color': Colors.green,
          'route': '/sounds-levels',
          'soundFile': 'ko_to_govori.mp3',
        },
        {
          'id': 'counting',
          'title': 'Koliko ima?',
          'subtitle': 'Učimo brojanje',
          'icon': Icons.calculate_rounded,
          'color': Colors.teal,
          'route': '/counting-levels',
          'soundFile': 'koliko_ima.mp3',
        },
        {
          'id': 'colors',
          'title': 'Prepoznaj boju',
          'subtitle': 'Učimo boje',
          'icon': Icons.palette_rounded,
          'color': Colors.orange,
          'route': '/colors-levels',
          'soundFile': 'prepoznaj_boju.mp3',
        },
        {
          'id': 'professions',
          'title': 'Profesije',
          'subtitle': 'Ko koristi šta?',
          'icon': Icons.work_rounded,
          'color': Colors.blue,
          'route': '/professions-levels',
          'soundFile': 'profesije.mp3',
        },
        {
          'id': 'emotions',
          'title': 'Prepoznaj emocije',
          'subtitle': 'Kako se osjećamo?',
          'icon': Icons.mood_rounded,
          'color': Colors.purple,
          'route': '/emotions-levels',
          'soundFile': 'prepoznaj_emocije.mp3',
        },
        // NOVO: Categorization modul za bebe
        {
          'id': 'categorization',
          'title': 'Grupiši po kategoriji',
          'subtitle': 'Sortiraj predmete',
          'icon': Icons.category_rounded,
          'color': Colors.green,
          'route': '/categorization-levels',
          'soundFile': 'grupisi_po_kategoriji.mp3',
        },
        {
          'id': 'counting_tap',
          'title': 'Brojanje sa kretanjem',
          'subtitle': 'Tapni i broji',
          'icon': Icons.touch_app,
          'color': Colors.green,
          'route': '/counting_tap-levels',
          'soundFile': 'brojanje_sa_kretanjem.mp3',
        },
      ];
    } else {
      // toddler - također dodaj categorization
      return [
        {
          'id': 'memory',
          'title': 'Pamti me',
          'subtitle': 'Memorijska igra',
          'icon': Icons.psychology_rounded,
          'color': Colors.purple,
          'route': '/memory-levels',
          'soundFile': 'pamti_me.mp3',
        },
        {
          'id': 'missing',
          'title': 'Šta nedostaje?',
          'subtitle': 'Logičko razmišljanje',
          'icon': Icons.extension_rounded,
          'color': Colors.amber,
          'route': '/missing-levels',
          'soundFile': 'sta_nedostaje.mp3',
        },
        {
          'id': 'matching',
          'title': 'Poveži parove',
          'subtitle': 'Povezivanje',
          'icon': Icons.link_rounded,
          'color': Colors.deepPurple,
          'route': '/matching-levels',
          'soundFile': 'povezi_parove.mp3',
        },
        {
          'id': 'sorting',
          'title': 'Sortiraj po veličini',
          'subtitle': 'Logičko sortiranje',
          'icon': Icons.sort_rounded,
          'color': Colors.cyan,
          'route': '/sorting-levels',
          'soundFile': 'sortiraj_po_velicini.mp3',
        },
        {
          'id': 'color_shape',
          'title': 'Sortiraj po boji/obliku',
          'subtitle': 'Prepoznavanje i sortiranje',
          'icon': Icons.category_rounded,
          'color': Colors.pink,
          'route': '/color_shape-levels',
          'soundFile': 'sortiraj_po_boji_obliku.mp3',
        },
        {
          'id': 'professions',
          'title': 'Profesije',
          'subtitle': 'Ko koristi šta?',
          'icon': Icons.work_rounded,
          'color': Colors.blue,
          'route': '/professions-levels',
          'soundFile': 'profesije.mp3',
        },
        {
          'id': 'emotions',
          'title': 'Prepoznaj emocije',
          'subtitle': 'Kako se osjećamo?',
          'icon': Icons.mood_rounded,
          'color': Colors.purple,
          'route': '/emotions-levels',
          'soundFile': 'prepoznaj_emocije.mp3',
        },
        // NOVO: Categorization modul za toddlere
        {
          'id': 'categorization',
          'title': 'Grupiši po kategoriji',
          'subtitle': 'Sortiraj predmete',
          'icon': Icons.category_rounded,
          'color': Colors.green,
          'route': '/categorization-levels',
          'soundFile': 'grupisi_po_kategoriji.mp3',
        },
        {
          'id': 'odd_one_out',
          'title': 'Koji ne pripada?',
          'subtitle': 'Logičko razmišljanje',
          'icon': Icons.help_outline_rounded,
          'color': Colors.amber,
          'route': '/odd_one_out-levels',
          'soundFile': 'koji_ne_pripada.mp3',
        },
        {
          'id': 'simple_math',
          'title': 'Jednostavna matematika',
          'subtitle': 'Računanje i brojevi',
          'icon': Icons.calculate,
          'color': Colors.blue,
          'route': '/simple_math-levels',
          'soundFile': 'jednostavna_matematika.mp3',
        },
        {
          'id': 'letter_learning',
          'title': 'Učimo slova',
          'subtitle': 'Velika i mala slova',
          'icon': Icons.abc,
          'color': Colors.purple,
          'route': '/letter_learning-levels',
          'soundFile': 'ucimo_slova.mp3',
        },
      ];
    }
  }

  int _getBabyCompletedCount() {
    final babyModules = [
      'memory',
      'sounds',
      'counting',
      'colors',
      'professions',
      'emotions',
      'categorization',
      'counting_tap'
    ];
    return babyModules
        .where((module) => _completedModules[module] ?? false)
        .length;
  }

  int _getBabyTotalCount() {
    return 8; // Sada imamo 8 modula za bebe
  }

  int _getToddlerCompletedCount() {
    final toddlerModules = [
      'memory',
      'missing',
      'matching',
      'sorting',
      'color_shape',
      'professions',
      'emotions',
      'categorization', // DODANO
      'odd_one_out',
      'simple_math',
      'letter_learning'
    ];
    return toddlerModules
        .where((module) => _completedModules[module] ?? false)
        .length;
  }

  int _getToddlerTotalCount() {
    return 11; // Sada imamo 11 modula za toddlere
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    _particleController.dispose();
    _pulseController.dispose();
    _transitionController.dispose();

    super.dispose();
  }
}

// Custom painter za floating particles
class ParticlesPainter extends CustomPainter {
  final double animationValue;
  final HomeScreenState state;

  ParticlesPainter(this.animationValue, this.state);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    List<Color> colors;
    switch (state) {
      case HomeScreenState.ageSelection:
        colors = [Colors.purple, Colors.pink, Colors.blue, Colors.orange];
        break;
      case HomeScreenState.babyModules:
        colors = [Colors.pink, Colors.purple, Colors.orange, Colors.red];
        break;
      case HomeScreenState.toddlerModules:
        colors = [Colors.blue, Colors.green, Colors.cyan, Colors.teal];
        break;
    }

    for (int i = 0; i < 15; i++) {
      final progress = (animationValue + i * 0.1) % 1.0;
      final x =
          (i % 5) * (size.width / 4) + math.sin(progress * 2 * math.pi) * 30;
      final y = size.height * progress;
      final opacity = (1 - progress) * 0.3;

      paint.color = colors[i % colors.length].withOpacity(opacity);

      canvas.drawCircle(
        Offset(x, y),
        3 + math.sin(progress * 4 * math.pi) * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter za age card pattern
class AgeCardPatternPainter extends CustomPainter {
  final Color color;

  AgeCardPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw hearts for baby theme
    for (int i = 0; i < 8; i++) {
      final x = (i % 4) * (size.width / 3);
      final y = (i ~/ 4) * (size.height / 3);

      canvas.drawCircle(
        Offset(x, y),
        12,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter za module card pattern
class ModuleCardPatternPainter extends CustomPainter {
  final Color color;

  ModuleCardPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw subtle geometric pattern
    for (int i = 0; i < 8; i++) {
      final x = (i % 4) * (size.width / 3);
      final y = (i ~/ 4) * (size.height / 3);

      canvas.drawCircle(
        Offset(x, y),
        15,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
