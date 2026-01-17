import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class GitHubScannerService {
  final AuthService _authService = AuthService();

  Future<String> scanRepo(String repoUrl) async {
    // 1. Parse URL to get owner and repo name
    final uri = Uri.tryParse(repoUrl);
    if (uri == null || uri.pathSegments.length < 2) {
      throw Exception("Invalid GitHub URL. Expected format: https://github.com/owner/repo");
    }

    final owner = uri.pathSegments[0];
    final repo = uri.pathSegments[1];

    final headers = <String, String>{
      'Accept': 'application/vnd.github.v3+json',
    };

    // REAL INTEGRATION: Use Token if user is logged in via GitHub
    if (_authService.githubToken != null) {
      headers['Authorization'] = 'token ${_authService.githubToken}';
    }

    // 2. Fetch the file tree recursively
    // We'll fetch the default branch first to get the tree SHA
    final repoApiUrl = Uri.parse('https://api.github.com/repos/$owner/$repo');
    final repoResponse = await http.get(repoApiUrl, headers: headers);
    
    if (repoResponse.statusCode != 200) {
      throw Exception("Failed to access repository: ${repoResponse.body}");
    }

    final repoData = jsonDecode(repoResponse.body);
    final defaultBranch = repoData['default_branch'];

    final treeUrl = Uri.parse('https://api.github.com/repos/$owner/$repo/git/trees/$defaultBranch?recursive=1');
    final treeResponse = await http.get(treeUrl, headers: headers);

    if (treeResponse.statusCode != 200) {
      throw Exception("Failed to fetch project tree: ${treeResponse.body}");
    }

    final treeData = jsonDecode(treeResponse.body);
    final List<dynamic> tree = treeData['tree'];

    // 3. Filter and build a text representation of the structure
    final buffer = StringBuffer();
    buffer.writeln('GitHub Repository Structure for $owner/$repo:');
    buffer.writeln('===========================================\n');

    for (var item in tree) {
      final type = item['type']; // 'blob' (file) or 'tree' (dir)
      final path = item['path'];
      
      // Skip common binary/heavy folders
      if (path.contains('.git/') || path.contains('node_modules/') || path.contains('build/')) continue;

      if (type == 'tree') {
        buffer.writeln('[DIR]  $path');
      } else {
        buffer.writeln('[FILE] $path');
      }
    }

    return buffer.toString();
  }
}
