import 'package:flutter/material.dart';

class CardResultScreen extends StatelessWidget {
  final String topicId;
  const CardResultScreen({super.key, required this.topicId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Result: $topicId')));
}
