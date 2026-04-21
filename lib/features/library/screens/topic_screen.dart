import 'package:flutter/material.dart';

class TopicScreen extends StatelessWidget {
  final String domainId;
  final String subjectId;
  final String topicId;
  const TopicScreen({super.key, required this.domainId, required this.subjectId, required this.topicId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Topic: $topicId')));
}
