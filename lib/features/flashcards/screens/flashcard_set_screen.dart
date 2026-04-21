import 'package:flutter/material.dart';

class FlashcardSetScreen extends StatelessWidget {
  final String topicId;
  const FlashcardSetScreen({super.key, required this.topicId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Flashcards: $topicId')));
}
