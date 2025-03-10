import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JSON to Firestore Uploader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const JsonUploaderScreen(),
    );
  }
}

class JsonUploaderScreen extends StatefulWidget {
  const JsonUploaderScreen({Key? key}) : super(key: key);

  @override
  _JsonUploaderScreenState createState() => _JsonUploaderScreenState();
}

class _JsonUploaderScreenState extends State<JsonUploaderScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _collectionName = 'myCollection';
  bool _isUploading = false;
  String _statusMessage = '';
  int _totalDocuments = 0;
  int _uploadedDocuments = 0;

  Future<void> _selectAndUploadFile() async {
    try {
      // Pick file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null) {
        setState(() {
          _statusMessage = 'No file selected';
        });
        return;
      }

      setState(() {
        _isUploading = true;
        _statusMessage = 'Reading file...';
      });

      // Read file content
      File file = File(result.files.single.path!);
      String jsonContent = await file.readAsString();
      
      // Parse JSON
      dynamic jsonData = jsonDecode(jsonContent);
      
      // Upload to Firestore
      await _uploadJsonToFirestore(jsonData);
      
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  // For bundled assets
  Future<void> _uploadBundledJson() async {
    try {
      setState(() {
        _isUploading = true;
        _statusMessage = 'Reading bundled JSON...';
      });

      // Load the bundled JSON file
      String jsonContent = await rootBundle.loadString('lib/assets/place.json');
      
      // Parse JSON
      dynamic jsonData = jsonDecode(jsonContent);
      
      // Upload to Firestore
      await _uploadJsonToFirestore(jsonData);
      
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Error: ${e.toString()}';
      });
    }
  }

  Future<void> _uploadJsonToFirestore(dynamic jsonData) async {
    try {
      setState(() {
        _statusMessage = 'Preparing to upload...';
      });

      if (jsonData is List) {
        // Handle array of objects
        _totalDocuments = jsonData.length;
        _uploadedDocuments = 0;
        
        setState(() {
          _statusMessage = 'Uploading $_totalDocuments documents...';
        });

        // Use batched writes for better performance
        int batchSize = 500; // Firestore allows up to 500 operations per batch
        List<Future<void>> futures = [];

        for (int i = 0; i < jsonData.length; i += batchSize) {
          int end = (i + batchSize < jsonData.length) ? i + batchSize : jsonData.length;
          WriteBatch batch = _firestore.batch();
          
          for (int j = i; j < end; j++) {
            DocumentReference docRef = _firestore.collection(_collectionName).doc();
            batch.set(docRef, jsonData[j]);
          }
          
          futures.add(batch.commit().then((_) {
            setState(() {
              _uploadedDocuments += (end - i);
              _statusMessage = 'Uploaded $_uploadedDocuments/$_totalDocuments documents';
            });
          }));
        }
        
        await Future.wait(futures);
        
      } else if (jsonData is Map) {
        // Handle object with collections and documents
        _totalDocuments = 0;
        _uploadedDocuments = 0;
        
        // Count total documents first
        jsonData.forEach((collection, documents) {
          if (documents is Map) {
            _totalDocuments += documents.length;
          }
        });
        
        setState(() {
          _statusMessage = 'Uploading $_totalDocuments documents across collections...';
        });
        
        // Process each collection
        for (var collection in jsonData.keys) {
          var documents = jsonData[collection];
          
          if (documents is Map) {
            // Use batched writes for better performance
            int batchSize = 500;
            List<List<String>> batches = [];
            List<String> currentBatch = [];
            
            documents.keys.forEach((docId) {
              currentBatch.add(docId);
              if (currentBatch.length >= batchSize) {
                batches.add(currentBatch);
                currentBatch = [];
              }
            });
            
            if (currentBatch.isNotEmpty) {
              batches.add(currentBatch);
            }
            
            // Process each batch
            for (var docIdBatch in batches) {
              WriteBatch batch = _firestore.batch();
              
              for (var docId in docIdBatch) {
                batch.set(
                  _firestore.collection(collection).doc(docId),
                  documents[docId]
                );
              }
              
              await batch.commit();
              setState(() {
                _uploadedDocuments += docIdBatch.length;
                _statusMessage = 'Uploaded $_uploadedDocuments/$_totalDocuments documents';
              });
            }
          }
        }
      }

      setState(() {
        _isUploading = false;
        _statusMessage = 'Upload completed successfully!';
      });
      
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Error uploading: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSON to Firestore Uploader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Collection Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _collectionName = value;
                });
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isUploading ? null : _selectAndUploadFile,
              child: const Text('Select and Upload JSON File'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isUploading ? null : _uploadBundledJson,
              child: const Text('Upload Bundled JSON (from assets)'),
            ),
            const SizedBox(height: 16),
            if (_isUploading)
              const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              _statusMessage,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}