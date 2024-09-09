import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class Viewer extends StatefulWidget {
  final String pdfPath; // Make it final
  const Viewer({super.key, required this.pdfPath});

  @override
  State<Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<Viewer> {
  late String _pdfPath; // 
  @override
  void initState() {
    super.initState();
    // Initialize _pdfPath here safely
    _pdfPath = widget.pdfPath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfPath),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Navigate back when pressed
          },
        ),
      ),
      body: Center(
        child: PDFView(
          filePath: _pdfPath,
          pageSnap: true,
          defaultPage: 0,
        ),
      ),
    );
  }
}
