import 'package:flutter/material.dart';

class SubjectScreen extends StatelessWidget {
  final String domainId;
  final String subjectId;
  const SubjectScreen({super.key, required this.domainId, required this.subjectId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Subject: $subjectId')));
}
