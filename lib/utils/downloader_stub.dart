import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

Future<void> downloadFile(String content, String filename) async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsString(content);
      await Share.shareXFiles([XFile(file.path)], text: 'Here is your $filename');
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save $filename',
        fileName: filename,
      );
      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsString(content);
      }
    } else {
      debugPrint('Download not supported on this platform.');
    }
  } catch (e) {
    debugPrint('Error downloading file: $e');
  }
}

Future<void> downloadZip(List<int> bytes, String filename) async {
  try {
    if (Platform.isAndroid || Platform.isIOS) {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Here is your project archive');
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save $filename',
        fileName: filename,
      );
      if (outputFile != null) {
        final file = File(outputFile);
        await file.writeAsBytes(bytes);
      }
    } else {
      debugPrint('Download ZIP not supported on this platform.');
    }
  } catch (e) {
    debugPrint('Error downloading zip: $e');
  }
}

