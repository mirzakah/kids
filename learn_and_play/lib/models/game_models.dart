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
