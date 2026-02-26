import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_filex/open_filex.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String filePath;
  final String? title;

  const DocumentPreviewScreen({super.key, required this.filePath, this.title});

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  bool _isPdf = false;
  bool _isLoading = true;
  int _pages = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _detectFileType();
  }

  void _detectFileType() {
    final ext = widget.filePath.toLowerCase();

    if (ext.endsWith('.pdf')) {
      _isPdf = true;
    } else {
      _isPdf = false;
      _openExternally();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openExternally() async {
    await OpenFilex.open(widget.filePath);
    if (mounted) Navigator.pop(context); // return after opening
  }

  @override
  Widget build(BuildContext context) {
    final fileName = widget.filePath.split('/').last;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? fileName),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => OpenFilex.open(widget.filePath),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _isPdf
              ? Stack(
                children: [
                  PDFView(
                    filePath: widget.filePath,
                    enableSwipe: true,
                    swipeHorizontal: false,
                    autoSpacing: true,
                    pageSnap: true,
                    onRender: (pages) {
                      setState(() => _pages = pages ?? 0);
                    },
                    onPageChanged: (page, total) {
                      setState(() => _currentPage = page ?? 0);
                    },
                    onError: (error) {
                      _showError(error.toString());
                    },
                  ),

                  // Page indicator
                  if (_pages > 0)
                    Positioned(
                      bottom: 16,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Page ${_currentPage + 1} / $_pages',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              )
              : const SizedBox(), // non-pdf handled externally
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
