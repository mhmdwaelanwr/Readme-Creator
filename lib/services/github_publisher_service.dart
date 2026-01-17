import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class GitHubPublisherService {
  final String? accessToken;

  GitHubPublisherService(this.accessToken);

  Future<void> publishReadme({
    required String owner,
    required String repo,
    required String content,
    required String branchName,
    required String commitMessage,
  }) async {
    if (accessToken == null || accessToken!.isEmpty) {
      throw Exception("GitHub Access Token is required for publishing.");
    }

    final headers = {
      'Authorization': 'token $accessToken',
      'Accept': 'application/vnd.github.v3+json',
      'Content-Type': 'application/json',
    };

    // 1. Get the default branch (usually main or master)
    final repoUrl = Uri.parse('https://api.github.com/repos/$owner/$repo');
    final repoResponse = await http.get(repoUrl, headers: headers);
    if (repoResponse.statusCode != 200) {
      throw Exception("Failed to fetch repository info: ${repoResponse.body}");
    }
    final defaultBranch = jsonDecode(repoResponse.body)['default_branch'];

    // 2. Get the SHA of the default branch
    final refUrl = Uri.parse('https://api.github.com/repos/$owner/$repo/git/refs/heads/$defaultBranch');
    final refResponse = await http.get(refUrl, headers: headers);
    if (refResponse.statusCode != 200) {
      throw Exception("Failed to fetch branch ref: ${refResponse.body}");
    }
    final latestCommitSha = jsonDecode(refResponse.body)['object']['sha'];

    // 3. Create a new branch
    final createBranchUrl = Uri.parse('https://api.github.com/repos/$owner/$repo/git/refs');
    final createBranchResponse = await http.post(
      createBranchUrl,
      headers: headers,
      body: jsonEncode({
        'ref': 'refs/heads/$branchName',
        'sha': latestCommitSha,
      }),
    );
    // 201 Created, or 422 if branch already exists. Handle accordingly.

    // 4. Get the SHA of the existing README.md (if it exists)
    String? readmeSha;
    final readmeUrl = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/README.md?ref=$branchName');
    final readmeGetResponse = await http.get(readmeUrl, headers: headers);
    if (readmeGetResponse.statusCode == 200) {
      readmeSha = jsonDecode(readmeGetResponse.body)['sha'];
    }

    // 5. Update or Create README.md
    final updateUrl = Uri.parse('https://api.github.com/repos/$owner/$repo/contents/README.md');
    final updateResponse = await http.put(
      updateUrl,
      headers: headers,
      body: jsonEncode({
        'message': commitMessage,
        'content': base64Encode(utf8.encode(content)),
        'branch': branchName,
        if (readmeSha != null) 'sha': readmeSha,
      }),
    );

    if (updateResponse.statusCode != 200 && updateResponse.statusCode != 201) {
      throw Exception("Failed to update README: ${updateResponse.body}");
    }

    // 6. Create a Pull Request
    final prUrl = Uri.parse('https://api.github.com/repos/$owner/$repo/pulls');
    final prResponse = await http.post(
      prUrl,
      headers: headers,
      body: jsonEncode({
        'title': 'docs: update README.md',
        'head': branchName,
        'base': defaultBranch,
        'body': 'Automated README update via Readme Creator.',
      }),
    );

    if (prResponse.statusCode != 201) {
      debugPrint("Warning: PR creation failed (might already exist): ${prResponse.body}");
    }
  }
}
