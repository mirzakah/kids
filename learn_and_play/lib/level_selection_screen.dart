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
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.8,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _playLevelSelectionSound();
  }

  void _playLevelSelectionSound() async {
    await _audioHelper.playSound('odaberi_nivo.mp3');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.moduleTitle,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: widget.moduleColor.withOpacity(0.8),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              widget.moduleColor.withOpacity(0.3),
              widget.moduleColor.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                // Naslov
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: widget.moduleColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Odaberi nivo težine',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 60),
                // Level dugmad
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLevelButton(
                        level: 1,
                        title: 'Lako',
                        subtitle: _getLevelSubtitle(1),
                        stars: 1,
                        color: Colors.green,
                      ),
                      _buildLevelButton(
                        level: 2,
                        title: 'Srednje',
                        subtitle: _getLevelSubtitle(2),
                        stars: 2,
                        color: Colors.orange,
                      ),
                      _buildLevelButton(
                        level: 3,
                        title: 'Teško',
                        subtitle: _getLevelSubtitle(3),
                        stars: 3,
                        color: Colors.red,
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
  }

  String _getLevelSubtitle(int level) {
    switch (widget.moduleId) {
      case 'memory':
        return level == 1
            ? '3 para'
            : level == 2
                ? '5 parova'
                : '8 parova';
      case 'colors':
        return level == 1
            ? '4 boje'
            : level == 2
                ? '6 boja'
                : '8 boja';
      case 'sounds':
        return level == 1
            ? '3 životinje'
            : level == 2
                ? '5 životinja'
                : '7 životinja';
      case 'counting':
        return level == 1
            ? '1-3'
            : level == 2
                ? '1-5'
                : '1-7';
      case 'matching':
        return level == 1
            ? '3 para'
            : level == 2
                ? '5 parova'
                : '7 parova';
      case 'missing':
        return level == 1
            ? 'Jednostavno'
            : level == 2
                ? 'Srednje'
                : 'Složeno';
      default:
        return '';
    }
  }

  Widget _buildLevelButton({
    required int level,
    required String title,
    required String subtitle,
    required int stars,
    required Color color,
  }) {
    return ScaleTransition(
      scale: _bounceAnimation,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(25),
        child: InkWell(
          onTap: () async {
            // Animate button press
            _bounceController.forward().then((_) {
              _bounceController.reverse();
            });

            await _audioHelper.playSound('klik.mp3');
            await Future.delayed(const Duration(milliseconds: 300));

            if (context.mounted) {
              context.go('/${widget.moduleId}?level=$level');
            }
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            height: 120,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  // Stars
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Icon(
                        index < stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(width: 30),
                  // Text info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Arrow
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _audioHelper.dispose();
    super.dispose();
  }
}
