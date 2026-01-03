import 'downloader_stub.dart'
    if (dart.library.html) 'downloader_web.dart';

Future<void> downloadReadme(String content) => downloadFile(content, 'README.md');

Future<void> downloadZipFile(List<int> bytes, String filename) => downloadZip(bytes, filename);

Future<void> downloadJsonFile(String content, String filename) => downloadFile(content, filename);

