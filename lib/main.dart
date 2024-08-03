import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'data.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PDFToWordConverter(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PDFToWordConverter extends StatefulWidget {
  @override
  _PDFToWordConverterState createState() => _PDFToWordConverterState();
}

class _PDFToWordConverterState extends State<PDFToWordConverter> {
  File? _selectedFile;
  String? _convertedFilePath;
  String? _downloadedFilePath;
  bool _isLoading = false;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
      });
    }
  }

  Future<void> convertPdfToWord(File pdfFile) async {
    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'https://v2.convertapi.com/convert/pdf/to/docx?Secret=ACxMCejgOQievgqs';

    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      request.files.add(await http.MultipartFile.fromPath('file', pdfFile.path));

      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var responseString = String.fromCharCodes(responseData);
        var jsonResponse = jsonDecode(responseString);

        // Parse response to pdftoword object
        pdftoword conversionResult = pdftoword.fromJson(jsonResponse);

        if (conversionResult.files != null && conversionResult.files!.isNotEmpty) {
          String fileData = conversionResult.files!.first.fileData!;
          Uint8List bytes = base64Decode(fileData);

          // Save converted file to the device
          final directory = await getApplicationDocumentsDirectory();
          final filePath = '${directory.path}/${conversionResult.files!.first.fileName}';
          final file = File(filePath);
          await file.writeAsBytes(bytes);

          setState(() {
            _convertedFilePath = filePath;
            _isLoading = false;
          });
          print("successfully fetched");
        }
      } else {
        throw Exception('Failed to convert PDF. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> downloadFile() async {
    if (_convertedFilePath != null) {
      if (await Permission.storage.request().isGranted) {
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }
        final fileName = _convertedFilePath!.split('/').last;
        final filePath = '${directory.path}/$fileName';
        final file = File(_convertedFilePath!);
        await file.copy(filePath);

        setState(() {
          _downloadedFilePath = filePath;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('File downloaded to: $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Storage permission denied')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: Text('PDF to Word Converter',style: TextStyle(
        color: Colors.white
      ),)),
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedFile != null)
                Text('Selected file: ${_selectedFile!.path.split('/').last}'),
              SizedBox(height: 20),
              InkWell(
                onTap: pickFile,
                child: Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Select PDF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: _selectedFile == null || _isLoading ? null : () => convertPdfToWord(_selectedFile!),
                child: Container(
                  height: 50,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Center(
                        child: Text(
                                            'Convert to Word',
                                            style: TextStyle(color: Colors.white),
                                          ),
                      ),
                ),
              ),
              SizedBox(height: 20),
              if (_convertedFilePath != null)
                Column(
                  children: [
                    Text('File converted successfully! Saved at: $_convertedFilePath'),
                    SizedBox(height: 20),
                    InkWell(
                      onTap: downloadFile,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Download Converted File',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
