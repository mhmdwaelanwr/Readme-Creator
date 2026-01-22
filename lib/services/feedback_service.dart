import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> submitFeedback({
    required String type, // 'bug', 'feature', 'general'
    required String message,
    Uint8List? attachmentBytes,
    String? attachmentName,
    Map<String, dynamic>? additionalData,
  }) async {
    final packageInfo = await PackageInfo.fromPlatform();
    final user = _auth.currentUser;
    String? attachmentUrl;

    // 1. Upload attachment if exists
    if (attachmentBytes != null && attachmentName != null) {
      final fileName = '${const Uuid().v4()}_$attachmentName';
      final ref = _storage.ref().child('feedback_attachments/$fileName');
      
      final uploadTask = await ref.putData(
        attachmentBytes,
        SettableMetadata(contentType: _getContentType(attachmentName)),
      );
      attachmentUrl = await uploadTask.ref.getDownloadURL();
    }

    // 2. Save feedback to Firestore
    await _firestore.collection('feedback').add({
      'type': type,
      'message': message,
      'attachmentUrl': attachmentUrl,
      'userId': user?.uid ?? 'anonymous',
      'userEmail': user?.email ?? 'anonymous',
      'appVersion': packageInfo.version,
      'buildNumber': packageInfo.buildNumber,
      'platform': _getPlatform(),
      'timestamp': FieldValue.serverTimestamp(),
      if (additionalData != null) ...additionalData,
    });
  }

  String _getContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }

  String _getPlatform() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }
}
