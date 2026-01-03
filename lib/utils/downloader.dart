import 'downloader_stub.dart'
    if (dart.library.html) 'downloader_web.dart';

Future<void> downloadReadme(String content) => downloadFile(content, 'README.md');

Future<void> downloadZipFile(List<int> bytes, String filename) => downloadZip(bytes, filename);

Future<void> downloadImageFile(List<int> bytes, String filename) => downloadZip(bytes, filename); // Reusing binary downloader

Future<void> downloadJsonFile(String content, String filename) => downloadFile(content, filename);

