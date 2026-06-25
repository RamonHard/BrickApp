// pdf_pre_view.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:brickapp/utils/urls.dart';

class DocumentPreviewScreen extends StatefulWidget {
  final String? filePath;
  final Uint8List? fileBytes;
  final String fileName;
  final String title;
  final String? networkUrl;

  const DocumentPreviewScreen({
    Key? key,
    this.filePath,
    this.fileBytes,
    required this.fileName,
    required this.title,
    this.networkUrl,
  }) : super(key: key);

  @override
  State<DocumentPreviewScreen> createState() => _DocumentPreviewScreenState();
}

class _DocumentPreviewScreenState extends State<DocumentPreviewScreen> {
  PdfController? _pdfController;
  bool _isLoading = true;
  String? _error;
  bool _isPdf = true;
  Uint8List? _documentBytes;

  @override
  void initState() {
    super.initState();
    _loadDocument();
  }

  Future<void> _loadDocument() async {
    try {
      Uint8List? bytes;

      // 1. Check fileBytes first (for uploaded files)
      if (widget.fileBytes != null && widget.fileBytes!.isNotEmpty) {
        print('📄 Loading from bytes: ${widget.fileBytes!.length} bytes');
        bytes = widget.fileBytes;
      }
      // 2. Check networkUrl
      else if (widget.networkUrl != null && widget.networkUrl!.isNotEmpty) {
        print('📄 Loading from network: ${widget.networkUrl}');
        final response = await http.get(Uri.parse(widget.networkUrl!));
        if (response.statusCode == 200) {
          bytes = response.bodyBytes;
        } else {
          throw Exception('Failed to load: ${response.statusCode}');
        }
      }
      // 3. Check filePath
      else if (widget.filePath != null && widget.filePath!.isNotEmpty) {
        // Check if it's a network URL
        if (widget.filePath!.startsWith('http')) {
          print('📄 Loading from filePath (network): ${widget.filePath}');
          final response = await http.get(Uri.parse(widget.filePath!));
          if (response.statusCode == 200) {
            bytes = response.bodyBytes;
          } else {
            throw Exception('Failed to load: ${response.statusCode}');
          }
        } else {
          // Local file - try PDFX
          print('📄 Loading from local file: ${widget.filePath}');
          try {
            _pdfController = PdfController(
              document: PdfDocument.openFile(widget.filePath!),
            );
            setState(() {
              _isLoading = false;
              _isPdf = true;
            });
            return;
          } catch (e) {
            print('❌ Local PDF load failed: $e');
            throw Exception('Could not open PDF file');
          }
        }
      } else {
        throw Exception('No document source provided');
      }

      // Handle bytes if we have them
      if (bytes != null && bytes.isNotEmpty) {
        _documentBytes = bytes;
        print('📄 Document loaded: ${bytes.length} bytes');
        
        // Try to open as PDF
        try {
          _pdfController = PdfController(
            document: PdfDocument.openData(bytes),
          );
          setState(() {
            _isLoading = false;
            _isPdf = true;
          });
          return;
        } catch (e) {
          print('❌ PDF load failed: $e');
          // Try as text
          try {
            final text = utf8.decode(bytes, allowMalformed: true);
            if (text.isNotEmpty) {
              setState(() {
                _isLoading = false;
                _isPdf = false;
                _error = text;
              });
              return;
            }
          } catch (_) {}
          
          setState(() {
            _isLoading = false;
            _isPdf = false;
            _error = 'Unable to preview this document';
          });
        }
      } else {
        throw Exception('Document is empty');
      }
    } catch (e) {
      print('❌ Document loading error: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 16),
            Text('Loading document...'),
          ],
        ),
      );
    }

    if (_error != null) {
      if (_isPdf) {
        return _buildErrorView();
      } else {
        return _buildTextView();
      }
    }

    if (_pdfController != null) {
      return PdfView(
        controller: _pdfController!,
        scrollDirection: Axis.vertical,
      );
    }

    return _buildEmptyView();
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextView() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Document Preview (Text)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                _error!,
                style: const TextStyle(fontSize: 14, height: 1.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No document to preview',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }
}