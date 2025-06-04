import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'utils/audio_helper.dart';
import 'utils/progress_tracker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  Map<String, bool> _completedModules = {};

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    ));

    _loadProgress();
    _playWelcomeSound();
  }

  Future<void> _loadProgress() async {
    await _progressTracker.init();
    setState(() {
      _completedModules = {
        'memory': _progressTracker.isModuleCompleted('memory'),
        'colors': _progressTracker.isModuleCompleted('colors'),
        'sounds': _progressTracker.isModuleCompleted('sounds'),
        'counting': _progressTracker.isModuleCompleted('counting'),
        'matching': _progressTracker.isModuleCompleted('matching'),
        'missing': _progressTracker.isModuleCompleted('missing'),
      };
    });
  }

  void _playWelcomeSound() async {
    await _audioHelper.playSound('dobrodosli.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade200,
              Colors.blue.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Naslov sa animacijom
                  AnimatedBuilder(
                    animation: _floatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _floatAnimation.value),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.shade200,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                size: 40,
                                color: Colors.amber.shade600,
                              ),
                              const SizedBox(width: 15),
                              const Text(
                                'Učimo zajedno!',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Icon(
                                Icons.star,
                                size: 40,
                                color: Colors.amber.shade600,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 50),
                  // Grid sa modulima
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildModuleCard(
                        context,
                        moduleId: 'memory',
                        title: 'Pamti me',
                        icon: Icons.grid_view_rounded,
                        color: Colors.purple,
                        route: '/memory',
                        soundFile: 'pamti_me.mp3',
                      ),
                      _buildModuleCard(
                        context,
                        moduleId: 'colors',
                        title: 'Prepoznaj boju',
                        icon: Icons.palette_rounded,
                        color: Colors.orange,
                        route: '/colors',
                        soundFile: 'prepoznaj_boju.mp3',
                      ),
                      _buildModuleCard(
                        context,
                        moduleId: 'sounds',
                        title: 'Ko to govori?',
                        icon: Icons.hearing_rounded,
                        color: Colors.green,
                        route: '/sounds',
                        soundFile: 'ko_to_govori.mp3',
                      ),
                      _buildModuleCard(
                        context,
                        moduleId: 'counting',
                        title: 'Koliko ima?',
                        icon: Icons.numbers_rounded,
                        color: Colors.teal,
                        route: '/counting',
                        soundFile: 'koliko_ima.mp3',
                      ),
                      _buildModuleCard(
                        context,
                        moduleId: 'matching',
                        title: 'Poveži parove',
                        icon: Icons.link_rounded,
                        color: Colors.deepPurple,
                        route: '/matching',
                        soundFile: 'povezi_parove.mp3',
                      ),
                      _buildModuleCard(
                        context,
                        moduleId: 'missing',
                        title: 'Šta nedostaje?',
                        icon: Icons.help_outline_rounded,
                        color: Colors.amber,
                        route: '/missing',
                        soundFile: 'sta_nedostaje.mp3',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required String moduleId,
    required String title,
    required IconData icon,
    required Color color,
    required String route,
    required String soundFile,
  }) {
    final isCompleted = _completedModules[moduleId] ?? false;
    final progress = _progressTracker.getModuleProgress(moduleId);

    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: () async {
          await _audioHelper.playSound('klik.mp3');
          await Future.delayed(const Duration(milliseconds: 200));
          await _audioHelper.playSound(soundFile);
          await Future.delayed(const Duration(milliseconds: 1000));
          if (context.mounted) {
            context.go('$route-levels');
          }
        },
        borderRadius: BorderRadius.circular(25),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color.withOpacity(0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Stack(
            children: [
              // Ikonica modula
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 60,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    Container(
                      width: 100,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Oznaka završenog modula
              if (isCompleted)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 30,
                    ),
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
    _floatController.dispose();
    _audioHelper.dispose();
    super.dispose();
  }
}
