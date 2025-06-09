import 'package:flutter/material.dart';

class MemoryCard {
  final String id;
  final String imagePath;
  final String soundPath;
  final String name;
  bool isFlipped;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.imagePath,
    required this.soundPath,
    required this.name,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class GameColor {
  final String name;
  final String bosnianName;
  final int colorValue;
  final String soundPath;

  const GameColor({
    required this.name,
    required this.bosnianName,
    required this.colorValue,
    required this.soundPath,
  });
}

class AnimalSound {
  final String id;
  final String name;
  final String imagePath;
  final String soundPath;

  const AnimalSound({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.soundPath,
  });
}

class CountingObject {
  final String type;
  final String imagePath;
  final Color color;

  const CountingObject({
    required this.type,
    required this.imagePath,
    required this.color,
  });
}

class Profession {
  final String id;
  final String name;
  final String imagePath;
  final String soundPath;
  final String toolId;

  const Profession({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.soundPath,
    required this.toolId,
  });
}

class ProfessionTool {
  final String id;
  final String name;
  final String imagePath;
  final String soundPath;
  final String professionId;

  const ProfessionTool({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.soundPath,
    required this.professionId,
  });
}

class ProfessionPair {
  final Profession profession;
  final ProfessionTool tool;
  bool isMatched;
  bool isAnimating;

  ProfessionPair({
    required this.profession,
    required this.tool,
    this.isMatched = false,
    this.isAnimating = false,
  });
}

// Dodaj ove klase u postojeći game_models.dart fajl:

class Emotion {
  final String id;
  final String name;
  final String imagePath;
  final String soundPath;
  final String description;
  final Color color;

  const Emotion({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.soundPath,
    required this.description,
    required this.color,
  });
}

class EmotionQuestion {
  final Emotion correctEmotion;
  final List<Emotion> options;
  final EmotionQuestionType type;
  bool isAnswered;
  bool isCorrect;

  EmotionQuestion({
    required this.correctEmotion,
    required this.options,
    required this.type,
    this.isAnswered = false,
    this.isCorrect = false,
  });
}

enum EmotionQuestionType {
  sayNameChooseFace, // Kaži ime emocije, odaberi lice (jedini tip koji koristimo)
  // showFaceChooseName - rezervisano za stariju djecu koja znaju čitati
}

// Dodaj ove klase u postojeći game_models.dart fajl:

class Category {
  final String id;
  final String name;
  final String imagePath;
  final String soundPath;
  final Color color;
  final IconData icon;

  const Category({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.soundPath,
    required this.color,
    required this.icon,
  });
}

class CategoryItem {
  final String id;
  final String name;
  final String imagePath;
  final String soundPath;
  final String categoryId;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.soundPath,
    required this.categoryId,
  });
}

class CategoryBucket {
  final Category category;
  final List<CategoryItem> items;
  final List<CategoryItem> placedItems;

  CategoryBucket({
    required this.category,
    required this.items,
    List<CategoryItem>? placedItems,
  }) : placedItems = placedItems ?? [];

  bool get isComplete => placedItems.length == items.length;
}

class GameRound {
  final List<CategoryBucket> buckets;
  final List<CategoryItem> shuffledItems;
  int correctPlacements;
  bool isComplete;

  GameRound({
    required this.buckets,
    required this.shuffledItems,
    this.correctPlacements = 0,
    this.isComplete = false,
  });
}

// NOVI PRISTUP: Jednostavan tap-to-select umjesto drag & drop
// Djeca čuju "Nađi sve voće" i tapnu na sve predmete koji su voće