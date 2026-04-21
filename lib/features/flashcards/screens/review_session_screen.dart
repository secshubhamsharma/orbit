import 'package:flutter/material.dart';

class ReviewSessionScreen extends StatelessWidget {
  final String topicId;
  const ReviewSessionScreen({super.key, required this.topicId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Review: $topicId')));
}
