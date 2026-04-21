import 'package:flutter/material.dart';

class PdfResultScreen extends StatelessWidget {
  final String uploadId;
  const PdfResultScreen({super.key, required this.uploadId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('PDF Result: $uploadId')));
}
