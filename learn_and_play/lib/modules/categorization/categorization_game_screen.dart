import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/game_models.dart';
import '../../utils/audio_helper.dart';
import '../../utils/progress_tracker.dart';

class CategorizationGameScreen extends StatefulWidget {
  final int level;

  const CategorizationGameScreen({super.key, required this.level});

  @override
  State<CategorizationGameScreen> createState() =>
      _CategorizationGameScreenState();
}

class _CategorizationGameScreenState extends State<CategorizationGameScreen>
    with TickerProviderStateMixin {
  final AudioHelper _audioHelper = AudioHelper();
  final ProgressTracker _progressTracker = ProgressTracker();

  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late AnimationController _confettiController;
  late AnimationController _successController;
  late AnimationController _pulseController;

  late Animation<double> _bounceAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _confettiAnimation;
  late Animation<double> _successAnimation;
  late Animation<double> _pulseAnimation;

  // Sve dostupne kategorije
  final List<Category> _allCategories = [
    const Category(
      id: 'fruits',
      name: 'Voće',
      imagePath: 'assets/images/categories/fruits.png',
      soundPath: 'voce.mp3',
      color: Colors.red,
      icon: Icons.apple,
    ),
    const Category(
      id: 'vegetables',
      name: 'Povrće',
      imagePath: 'assets/images/categories/vegetables.png',
      soundPath: 'povrce.mp3',
      color: Colors.green,
      icon: Icons.eco,
    ),
    const Category(
      id: 'animals',
      name: 'Životinje',
      imagePath: 'assets/images/categories/animals.png',
      soundPath: 'zivotinje.mp3',
      color: Colors.brown,
      icon: Icons.pets,
    ),
    const Category(
      id: 'vehicles',
      name: 'Vozila',
      imagePath: 'assets/images/categories/vehicles.png',
      soundPath: 'vozila.mp3',
      color: Colors.blue,
      icon: Icons.directions_car,
    ),
    const Category(
      id: 'food',
      name: 'Hrana',
      imagePath: 'assets/images/categories/food.png',
      soundPath: 'hrana.mp3',
      color: Colors.orange,
      icon: Icons.restaurant,
    ),
    const Category(
      id: 'toys',
      name: 'Igračke',
      imagePath: 'assets/images/categories/toys.png',
      soundPath: 'igracke.mp3',
      color: Colors.purple,
      icon: Icons.toys,
    ),
    const Category(
      id: 'clothes',
      name: 'Odjeća',
      imagePath: 'assets/images/categories/clothes.png',
      soundPath: 'odjeca.mp3',
      color: Colors.pink,
      icon: Icons.checkroom,
    ),
    const Category(
      id: 'household',
      name: 'Kućni predmeti',
      imagePath: 'assets/images/categories/household.png',
      soundPath: 'kucni_predmeti.mp3',
      color: Colors.indigo,
      icon: Icons.home,
    ),
  ];

  // Sve dostupne stavke po kategorijama
  final Map<String, List<CategoryItem>> _allItems = {
    'fruits': [
      const CategoryItem(
          id: 'apple',
          name: 'Jabuka',
          imagePath: 'assets/images/items/apple.png',
          soundPath: 'jabuka.mp3',
          categoryId: 'fruits'),
      const CategoryItem(
          id: 'banana',
          name: 'Banana',
          imagePath: 'assets/images/items/banana.png',
          soundPath: 'banana.mp3',
          categoryId: 'fruits'),
      const CategoryItem(
          id: 'orange',
          name: 'Narandža',
          imagePath: 'assets/images/items/orange.png',
          soundPath: 'narandza.mp3',
          categoryId: 'fruits'),
      const CategoryItem(
          id: 'strawberry',
          name: 'Jagoda',
          imagePath: 'assets/images/items/strawberry.png',
          soundPath: 'jagoda.mp3',
          categoryId: 'fruits'),
      const CategoryItem(
          id: 'grapes',
          name: 'Grožđe',
          imagePath: 'assets/images/items/grapes.png',
          soundPath: 'grozdje.mp3',
          categoryId: 'fruits'),
      const CategoryItem(
          id: 'cherry',
          name: 'Trešnja',
          imagePath: 'assets/images/items/cherry.png',
          soundPath: 'tresnja.mp3',
          categoryId: 'fruits'),
      const CategoryItem(
          id: 'pineapple',
          name: 'Ananas',
          imagePath: 'assets/images/items/pineapple.png',
          soundPath: 'ananas.mp3',
          categoryId: 'fruits'),
      const CategoryItem(
          id: 'watermelon',
          name: 'Lubenica',
          imagePath: 'assets/images/items/watermelon.png',
          soundPath: 'lubenica.mp3',
          categoryId: 'fruits'),
    ],
    'vegetables': [
      const CategoryItem(
          id: 'carrot',
          name: 'Mrkva',
          imagePath: 'assets/images/items/carrot.png',
          soundPath: 'mrkva.mp3',
          categoryId: 'vegetables'),
      const CategoryItem(
          id: 'tomato',
          name: 'Paradajz',
          imagePath: 'assets/images/items/tomato.png',
          soundPath: 'paradajz.mp3',
          categoryId: 'vegetables'),
      const CategoryItem(
          id: 'broccoli',
          name: 'Brokoli',
          imagePath: 'assets/images/items/broccoli.png',
          soundPath: 'brokoli.mp3',
          categoryId: 'vegetables'),
      const CategoryItem(
          id: 'corn',
          name: 'Kukuruz',
          imagePath: 'assets/images/items/corn.png',
          soundPath: 'kukuruz.mp3',
          categoryId: 'vegetables'),
      const CategoryItem(
          id: 'potato',
          name: 'Krompir',
          imagePath: 'assets/images/items/potato.png',
          soundPath: 'krompir.mp3',
          categoryId: 'vegetables'),
      const CategoryItem(
          id: 'onion',
          name: 'Luk',
          imagePath: 'assets/images/items/onion.png',
          soundPath: 'luk.mp3',
          categoryId: 'vegetables'),
      const CategoryItem(
          id: 'pepper',
          name: 'Paprika',
          imagePath: 'assets/images/items/pepper.png',
          soundPath: 'paprika.mp3',
          categoryId: 'vegetables'),
      const CategoryItem(
          id: 'cucumber',
          name: 'Krastavac',
          imagePath: 'assets/images/items/cucumber.png',
          soundPath: 'krastavac.mp3',
          categoryId: 'vegetables'),
    ],
    'animals': [
      const CategoryItem(
          id: 'dog',
          name: 'Pas',
          imagePath: 'assets/images/items/dog.png',
          soundPath: 'pas.mp3',
          categoryId: 'animals'),
      const CategoryItem(
          id: 'cat',
          name: 'Mačka',
          imagePath: 'assets/images/items/cat.png',
          soundPath: 'macka.mp3',
          categoryId: 'animals'),
      const CategoryItem(
          id: 'lion',
          name: 'Lav',
          imagePath: 'assets/images/items/lion.png',
          soundPath: 'lav.mp3',
          categoryId: 'animals'),
      const CategoryItem(
          id: 'elephant',
          name: 'Slon',
          imagePath: 'assets/images/items/elephant.png',
          soundPath: 'slon.mp3',
          categoryId: 'animals'),
      const CategoryItem(
          id: 'rabbit',
          name: 'Zec',
          imagePath: 'assets/images/items/rabbit.png',
          soundPath: 'zec.mp3',
          categoryId: 'animals'),
      const CategoryItem(
          id: 'bird',
          name: 'Ptica',
          imagePath: 'assets/images/items/bird.png',
          soundPath: 'ptica.mp3',
          categoryId: 'animals'),
      const CategoryItem(
          id: 'fish',
          name: 'Riba',
          imagePath: 'assets/images/items/fish.png',
          soundPath: 'riba.mp3',
          categoryId: 'animals'),
      const CategoryItem(
          id: 'bear',
          name: 'Medved',
          imagePath: 'assets/images/items/bear.png',
          soundPath: 'medved.mp3',
          categoryId: 'animals'),
    ],
    'vehicles': [
      const CategoryItem(
          id: 'car',
          name: 'Auto',
          imagePath: 'assets/images/items/car.png',
          soundPath: 'auto.mp3',
          categoryId: 'vehicles'),
      const CategoryItem(
          id: 'bus',
          name: 'Autobus',
          imagePath: 'assets/images/items/bus.png',
          soundPath: 'autobus.mp3',
          categoryId: 'vehicles'),
      const CategoryItem(
          id: 'plane',
          name: 'Avion',
          imagePath: 'assets/images/items/plane.png',
          soundPath: 'avion.mp3',
          categoryId: 'vehicles'),
      const CategoryItem(
          id: 'boat',
          name: 'Brod',
          imagePath: 'assets/images/items/boat.png',
          soundPath: 'brod.mp3',
          categoryId: 'vehicles'),
      const CategoryItem(
          id: 'bike',
          name: 'Bicikl',
          imagePath: 'assets/images/items/bike.png',
          soundPath: 'bicikl.mp3',
          categoryId: 'vehicles'),
      const CategoryItem(
          id: 'train',
          name: 'Voz',
          imagePath: 'assets/images/items/train.png',
          soundPath: 'voz.mp3',
          categoryId: 'vehicles'),
      const CategoryItem(
          id: 'truck',
          name: 'Kamion',
          imagePath: 'assets/images/items/truck.png',
          soundPath: 'kamion.mp3',
          categoryId: 'vehicles'),
      const CategoryItem(
          id: 'helicopter',
          name: 'Helikopter',
          imagePath: 'assets/images/items/helicopter.png',
          soundPath: 'helikopter.mp3',
          categoryId: 'vehicles'),
    ],
    'food': [
      const CategoryItem(
          id: 'bread',
          name: 'Hljeb',
          imagePath: 'assets/images/items/bread.png',
          soundPath: 'hljeb.mp3',
          categoryId: 'food'),
      const CategoryItem(
          id: 'milk',
          name: 'Mlijeko',
          imagePath: 'assets/images/items/milk.png',
          soundPath: 'mlijeko.mp3',
          categoryId: 'food'),
      const CategoryItem(
          id: 'cheese',
          name: 'Sir',
          imagePath: 'assets/images/items/cheese.png',
          soundPath: 'sir.mp3',
          categoryId: 'food'),
      const CategoryItem(
          id: 'egg',
          name: 'Jaje',
          imagePath: 'assets/images/items/egg.png',
          soundPath: 'jaje.mp3',
          categoryId: 'food'),
      const CategoryItem(
          id: 'pizza',
          name: 'Pizza',
          imagePath: 'assets/images/items/pizza.png',
          soundPath: 'pizza.mp3',
          categoryId: 'food'),
      const CategoryItem(
          id: 'cake',
          name: 'Torta',
          imagePath: 'assets/images/items/cake.png',
          soundPath: 'torta.mp3',
          categoryId: 'food'),
      const CategoryItem(
          id: 'sandwich',
          name: 'Sendvič',
          imagePath: 'assets/images/items/sandwich.png',
          soundPath: 'sendvic.mp3',
          categoryId: 'food'),
      const CategoryItem(
          id: 'soup',
          name: 'Supa',
          imagePath: 'assets/images/items/soup.png',
          soundPath: 'supa.mp3',
          categoryId: 'food'),
    ],
    'toys': [
      const CategoryItem(
          id: 'ball',
          name: 'Lopta',
          imagePath: 'assets/images/items/ball.png',
          soundPath: 'lopta.mp3',
          categoryId: 'toys'),
      const CategoryItem(
          id: 'doll',
          name: 'Lutka',
          imagePath: 'assets/images/items/doll.png',
          soundPath: 'lutka.mp3',
          categoryId: 'toys'),
      const CategoryItem(
          id: 'car_toy',
          name: 'Autić',
          imagePath: 'assets/images/items/car_toy.png',
          soundPath: 'autic.mp3',
          categoryId: 'toys'),
      const CategoryItem(
          id: 'teddy_bear',
          name: 'Meda',
          imagePath: 'assets/images/items/teddy_bear.png',
          soundPath: 'meda.mp3',
          categoryId: 'toys'),
      const CategoryItem(
          id: 'blocks',
          name: 'Kockice',
          imagePath: 'assets/images/items/blocks.png',
          soundPath: 'kockice.mp3',
          categoryId: 'toys'),
      const CategoryItem(
          id: 'puzzle',
          name: 'Slagalica',
          imagePath: 'assets/images/items/puzzle.png',
          soundPath: 'slagalica.mp3',
          categoryId: 'toys'),
      const CategoryItem(
          id: 'book',
          name: 'Knjiga',
          imagePath: 'assets/images/items/book.png',
          soundPath: 'knjiga.mp3',
          categoryId: 'toys'),
      const CategoryItem(
          id: 'crayons',
          name: 'Bojice',
          imagePath: 'assets/images/items/crayons.png',
          soundPath: 'bojice.mp3',
          categoryId: 'toys'),
    ],
    'clothes': [
      const CategoryItem(
          id: 'shirt',
          name: 'Majica',
          imagePath: 'assets/images/items/shirt.png',
          soundPath: 'majica.mp3',
          categoryId: 'clothes'),
      const CategoryItem(
          id: 'pants',
          name: 'Pantalone',
          imagePath: 'assets/images/items/pants.png',
          soundPath: 'pantalone.mp3',
          categoryId: 'clothes'),
      const CategoryItem(
          id: 'dress',
          name: 'Haljina',
          imagePath: 'assets/images/items/dress.png',
          soundPath: 'haljina.mp3',
          categoryId: 'clothes'),
      const CategoryItem(
          id: 'shoes',
          name: 'Cipele',
          imagePath: 'assets/images/items/shoes.png',
          soundPath: 'cipele.mp3',
          categoryId: 'clothes'),
      const CategoryItem(
          id: 'hat',
          name: 'Šešir',
          imagePath: 'assets/images/items/hat.png',
          soundPath: 'sesir.mp3',
          categoryId: 'clothes'),
      const CategoryItem(
          id: 'socks',
          name: 'Čarape',
          imagePath: 'assets/images/items/socks.png',
          soundPath: 'carape.mp3',
          categoryId: 'clothes'),
      const CategoryItem(
          id: 'jacket',
          name: 'Jakna',
          imagePath: 'assets/images/items/jacket.png',
          soundPath: 'jakna.mp3',
          categoryId: 'clothes'),
      const CategoryItem(
          id: 'gloves',
          name: 'Rukavice',
          imagePath: 'assets/images/items/gloves.png',
          soundPath: 'rukavice.mp3',
          categoryId: 'clothes'),
    ],
    'household': [
      const CategoryItem(
          id: 'chair',
          name: 'Stolica',
          imagePath: 'assets/images/items/chair.png',
          soundPath: 'stolica.mp3',
          categoryId: 'household'),
      const CategoryItem(
          id: 'table',
          name: 'Sto',
          imagePath: 'assets/images/items/table.png',
          soundPath: 'sto.mp3',
          categoryId: 'household'),
      const CategoryItem(
          id: 'bed',
          name: 'Krevet',
          imagePath: 'assets/images/items/bed.png',
          soundPath: 'krevet.mp3',
          categoryId: 'household'),
      const CategoryItem(
          id: 'lamp',
          name: 'Lampa',
          imagePath: 'assets/images/items/lamp.png',
          soundPath: 'lampa.mp3',
          categoryId: 'household'),
      const CategoryItem(
          id: 'tv',
          name: 'Televizor',
          imagePath: 'assets/images/items/tv.png',
          soundPath: 'televizor.mp3',
          categoryId: 'household'),
      const CategoryItem(
          id: 'phone',
          name: 'Telefon',
          imagePath: 'assets/images/items/phone.png',
          soundPath: 'telefon.mp3',
          categoryId: 'household'),
      const CategoryItem(
          id: 'cup',
          name: 'Šolja',
          imagePath: 'assets/images/items/cup.png',
          soundPath: 'solja.mp3',
          categoryId: 'household'),
      const CategoryItem(
          id: 'plate',
          name: 'Tanjir',
          imagePath: 'assets/images/items/plate.png',
          soundPath: 'tanjir.mp3',
          categoryId: 'household'),
    ],
  };

  GameRound? _currentRound;
  int _score = 0;
  int _roundNumber = 0;
  int _totalRounds = 0;
  int _correctPlacements = 0;
  bool _gameCompleted = false;
  bool _showConfetti = false;
  String? _draggedItemId;

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
    _successController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      end: 15.0,
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

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successController,
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
      'categorization_background.mp3',
      loop: true,
    );
    _audioHelper.setBackgroundMusicVolume(0.3);
    _audioHelper.setSoundEffectsVolume(0.8);
  }

  void _initializeGame() {
    // Konfiguracija po levelima
    switch (widget.level) {
      case 1:
        _totalRounds = 3; // 3 runde sa 2 kategorije
        break;
      case 2:
        _totalRounds = 3; // 3 runde sa 3 kategorije
        break;
      case 3:
        _totalRounds = 3; // 3 runde sa 4 kategorije
        break;
      default:
        _totalRounds = 3;
    }

    _score = 0;
    _roundNumber = 0;
    _correctPlacements = 0;
    _gameCompleted = false;
    _showConfetti = false;
    _draggedItemId = null;

    // Reset animacije
    _confettiController.reset();
    _successController.reset();
    _bounceController.reset();
    _shakeController.reset();

    setState(() {});

    _startNewRound();
  }

  void _startNewRound() async {
    if (_roundNumber >= _totalRounds) {
      _gameCompleted = true;
      await Future.delayed(const Duration(milliseconds: 500));
      _showWinDialog();
      return;
    }

    setState(() {
      _roundNumber++;
    });

    // Generiši novi round - NOVI PRISTUP
    _currentRound = _generateSimpleRound();

    setState(() {});

    // Audio instrukcija - JEDNOSTAVNA
    await _audioHelper.playSoundSequence([
      'nadji_sve.mp3', // "Nađi sve..."
      _currentRound!.buckets.first.category.soundPath, // naziv kategorije
    ]);
  }

  GameRound _generateSimpleRound() {
    // Odaberi jednu kategoriju po rundi
    final randomCategory =
        _allCategories[Random().nextInt(_allCategories.length)];
    final categoryItems = _allItems[randomCategory.id]!;

    // Odaberi 3-5 stavki iz te kategorije (tačni odgovori)
    final correctItems = List<CategoryItem>.from(categoryItems)..shuffle();
    final correctCount = 3 + widget.level; // Level 1: 3, Level 2: 4, Level 3: 5
    final selectedCorrectItems = correctItems.take(correctCount).toList();

    // Dodaj "pogrešne" stavke iz drugih kategorija
    final wrongItems = <CategoryItem>[];
    final otherCategories =
        _allCategories.where((cat) => cat.id != randomCategory.id).toList();

    for (int i = 0; i < correctCount; i++) {
      final randomOtherCategory =
          otherCategories[Random().nextInt(otherCategories.length)];
      final otherCategoryItems = _allItems[randomOtherCategory.id]!;
      final randomWrongItem =
          otherCategoryItems[Random().nextInt(otherCategoryItems.length)];

      // Provjeri da nije već dodana
      if (!wrongItems.any((item) => item.id == randomWrongItem.id)) {
        wrongItems.add(randomWrongItem);
      }
    }

    // Kombinuj sve stavke
    final allRoundItems = <CategoryItem>[];
    allRoundItems.addAll(selectedCorrectItems);
    allRoundItems.addAll(wrongItems);
    allRoundItems.shuffle();

    return GameRound(
      buckets: [
        CategoryBucket(
          category: randomCategory,
          items: selectedCorrectItems,
        )
      ],
      shuffledItems: allRoundItems,
    );
  }

  void _onItemDragStarted(String itemId) {
    // Više se ne koristi - sve je tap based
  }

  void _onItemDragEnd() {
    // Više se ne koristi - sve je tap based
  }

  void _onItemTapped(CategoryItem item) async {
    if (_currentRound == null) return;

    final targetCategory = _currentRound!.buckets.first.category;

    if (item.categoryId == targetCategory.id) {
      // Tačan odgovor!
      setState(() {
        _currentRound!.buckets.first.placedItems.add(item);
        _currentRound!.shuffledItems.removeWhere((i) => i.id == item.id);
        _currentRound!.correctPlacements++;
        _correctPlacements++;
        _score += (15 * widget.level);
      });

      // Animacije
      _successController.forward().then((_) {
        _successController.reset();
      });

      await _audioHelper.playSoundSequence([
        'correct_categorization.mp3',
        'tacno.mp3',
      ]);

      // Provjeri da li je round završen (svi tačni odgovori su odabrani)
      if (_currentRound!.buckets.first.placedItems.length >=
          _currentRound!.buckets.first.items.length) {
        await Future.delayed(const Duration(milliseconds: 1000));
        setState(() {
          _showConfetti = true;
        });
        _confettiController.forward().then((_) {
          _confettiController.reset();
          setState(() {
            _showConfetti = false;
          });
        });

        await _audioHelper.playSoundSequence([
          'round_complete.mp3',
          'svi_predmeti_nadjeni.mp3', // "Svi predmeti su nađeni!"
        ]);

        await Future.delayed(const Duration(milliseconds: 2000));
        _startNewRound();
      }
    } else {
      // Netačan odgovor
      _shakeController.forward().then((_) {
        _shakeController.reset();
      });

      await _audioHelper.playSoundSequence([
        'wrong_categorization.mp3',
        'pokusaj_ponovo_kategorija.mp3',
      ]);
    }
  }

  void _showWinDialog() async {
    setState(() {
      _showConfetti = true;
    });
    _confettiController.forward();

    // Spremi napredak
    await _progressTracker.saveModuleProgress(
        'categorization', widget.level, 3);
    await _progressTracker.saveHighScore('categorization', _score);
    await _progressTracker.incrementAttempts('categorization');

    // Triumfalni zvukovi
    await _audioHelper.playSoundSequence([
      'game_complete.mp3',
      'sve_kategorije_zavrsene.mp3',
      'odlicno.mp3',
    ]);

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        backgroundColor: Colors.green.shade50,
        title: Column(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Icon(
                    Icons.category_rounded,
                    size: 60,
                    color: Colors.amber.shade600,
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            Text(
              _getWinTitle(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade200,
                    blurRadius: 15,
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
                    'Tačno sortirano: $_correctPlacements stavki',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.green.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Odlično razlikujete kategorije!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.green.shade500,
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
                context.go('/categorization?level=${widget.level + 1}');
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
    final totalItems = _totalRounds * (widget.level + 1) * 3; // Aproksimacija
    int stars = 1;
    if (_correctPlacements >= totalItems * 0.8)
      stars = 3;
    else if (_correctPlacements >= totalItems * 0.6) stars = 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 200 + index * 100),
          child: Icon(
            index < stars ? Icons.star_rounded : Icons.star_outline_rounded,
            color: index < stars ? Colors.amber : Colors.grey.shade300,
            size: 35,
          ),
        );
      }),
    );
  }

  String _getWinTitle() {
    final totalItems = _totalRounds * (widget.level + 1) * 3;
    final accuracy = _correctPlacements / totalItems;
    if (accuracy >= 0.9) {
      return 'Savršeno! 🌟';
    } else if (accuracy >= 0.7) {
      return 'Odličo! 👏';
    } else {
      return 'Dobro! 😊';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grupiši po kategoriji - Level ${widget.level}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.green.shade400,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          onPressed: () async {
            await _audioHelper.stopBackgroundMusic();
            if (context.mounted) {
              context.go('/categorization-levels');
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
                  Colors.green.shade100,
                  Colors.blue.shade50,
                  Colors.purple.shade50,
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

                // Main game area
                Expanded(
                  child: _currentRound != null
                      ? _buildGameArea()
                      : _buildLoadingArea(),
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
            color: Colors.green.shade200.withOpacity(0.5),
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
          _buildScoreItem(
              'Runda', '$_roundNumber/$_totalRounds', Icons.flag, Colors.blue),
          _buildScoreItem('Sortirano', _correctPlacements.toString(),
              Icons.check, Colors.green),
          _buildScoreItem(
              'Level', widget.level.toString(), Icons.category, Colors.purple),
        ],
      ),
    );
  }

  Widget _buildScoreItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingArea() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.green.shade400),
      ),
    );
  }

  Widget _buildGameArea() {
    if (_currentRound == null) return Container();

    return Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          // Current category display
          _buildCurrentCategoryDisplay(),

          const SizedBox(height: 20),

          // Items grid
          Expanded(
            child: _buildItemsGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentCategoryDisplay() {
    final category = _currentRound!.buckets.first.category;
    final totalItems = _currentRound!.buckets.first.items.length;
    final foundItems = _currentRound!.buckets.first.placedItems.length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            category.color.withOpacity(0.8),
            category.color.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: category.color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                category.icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(width: 15),
              Flexible(
                child: Text(
                  'Nađi sve: ${category.name}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              'Našao: $foundItems / $totalItems',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: category.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.touch_app, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Tapni na predmete koji pripadaju kategoriji',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: _currentRound!.shuffledItems.length,
              itemBuilder: (context, index) {
                final item = _currentRound!.shuffledItems[index];
                return _buildTappableItem(item);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableItem(CategoryItem item) {
    final isFound =
        _currentRound!.buckets.first.placedItems.any((i) => i.id == item.id);
    final targetCategory = _currentRound!.buckets.first.category;
    final isCorrectCategory = item.categoryId == targetCategory.id;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isFound ? 1.0 : _pulseAnimation.value * 0.05 + 0.95,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: isFound ? Colors.green.shade300 : Colors.grey.shade300,
                  blurRadius: isFound ? 15 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent,
              child: InkWell(
                onTap: isFound ? null : () => _onItemTapped(item),
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isFound
                          ? Colors.green.shade400
                          : Colors.grey.shade400,
                      width: isFound ? 4 : 2,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isFound
                          ? [Colors.green.shade100, Colors.green.shade50]
                          : [Colors.white, Colors.grey.shade50],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Item image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          width: double.infinity,
                          height: double.infinity,
                          padding: const EdgeInsets.all(8),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.category,
                                  size: 40,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Found overlay
                      if (isFound)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              color: Colors.green.withOpacity(0.2),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_circle,
                                size: 40,
                                color: Colors.green,
                              ),
                            ),
                          ),
                        ),

                      // Item name at bottom
                      Positioned(
                        bottom: 4,
                        left: 4,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
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
    _successController.dispose();
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
        Colors.green,
        Colors.blue,
        Colors.orange,
        Colors.purple,
        Colors.pink,
        Colors.amber,
      ][i % 7];

      paint.color = color;

      // Različiti oblici
      if (i % 5 == 0) {
        canvas.drawCircle(Offset(x, y), 5, paint);
      } else if (i % 5 == 1) {
        canvas.drawRect(
            Rect.fromCenter(center: Offset(x, y), width: 8, height: 6), paint);
      } else if (i % 5 == 2) {
        // Trougao
        final path = Path();
        path.moveTo(x, y - 4);
        path.lineTo(x - 3, y + 2);
        path.lineTo(x + 3, y + 2);
        path.close();
        canvas.drawPath(path, paint);
      } else if (i % 5 == 3) {
        // Dijamant
        final path = Path();
        path.moveTo(x, y - 4);
        path.lineTo(x + 3, y);
        path.lineTo(x, y + 4);
        path.lineTo(x - 3, y);
        path.close();
        canvas.drawPath(path, paint);
      } else {
        // Zvjezdica
        final path = Path();
        for (int j = 0; j < 5; j++) {
          final angle = (j * 2 * pi / 5) - pi / 2;
          final px = x + 4 * cos(angle);
          final py = y + 4 * sin(angle);
          if (j == 0) {
            path.moveTo(px, py);
          } else {
            path.lineTo(px, py);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
