import 'package:flutter/material.dart';
import 'game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World1!'),
        ),
      ),
    );
  }
}


class Title extends StatelessWidget {
  const Title(this.letter, this.hitType, {super.key});
  
  final String letter;
  final HitType hitType;

  
}