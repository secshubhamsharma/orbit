import 'package:flutter/material.dart';

class DomainScreen extends StatelessWidget {
  final String domainId;
  const DomainScreen({super.key, required this.domainId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Domain: $domainId')));
}
