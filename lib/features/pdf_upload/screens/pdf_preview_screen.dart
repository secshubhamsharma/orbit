import 'package:flutter/material.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String uploadId;
  const PdfPreviewScreen({super.key, required this.uploadId});
  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('PDF Preview: $uploadId')));
}
