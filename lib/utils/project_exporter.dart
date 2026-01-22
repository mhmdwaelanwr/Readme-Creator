import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:markdown/markdown.dart' as md;
import '../models/readme_element.dart';
import '../generator/markdown_generator.dart';
import '../generator/license_generator.dart';
import '../generator/documentation_generator.dart';
import '../utils/templates.dart';
import '../utils/downloader.dart';

class ProjectExporter {
  static void export({
    required List<ReadmeElement> elements,
    required Map<String, String> variables,
    required String licenseType,
    required bool includeContributing,
    bool includeSecurity = false,
    bool includeSupport = false,
    bool includeCodeOfConduct = false,
    bool includeIssueTemplates = false,
    String listBullet = '*',
    int sectionSpacing = 1,
    bool exportHtml = false,
    String targetLanguage = 'en',
  }) {
    final markdownGenerator = MarkdownGenerator();
    final readmeContent = markdownGenerator.generate(
      elements,
      variables: variables,
      listBullet: listBullet,
      sectionSpacing: sectionSpacing,
      targetLanguage: targetLanguage,
    );

    final files = <String, dynamic>{
      'README.md': readmeContent,
    };

    if (exportHtml) {
      final htmlContent = md.markdownToHtml(
        readmeContent,
        extensionSet: md.ExtensionSet.gitHubWeb,
      );
      // Wrap in a basic HTML template
      final fullHtml = '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>README</title>
<style>
body {
  font-family: -apple-system,BlinkMacSystemFont,"Segoe UI",Helvetica,Arial,sans-serif,"Apple Color Emoji","Segoe UI Emoji";
  line-height: 1.5;
  max-width: 850px;
  margin: 0 auto;
  padding: 20px;
  color: #24292f;
}
h1, h2, h3, h4, h5, h6 { margin-top: 24px; margin-bottom: 16px; font-weight: 600; line-height: 1.25; }
h1 { font-size: 2em; border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
h2 { font-size: 1.5em; border-bottom: 1px solid #eaecef; padding-bottom: .3em; }
code { background-color: #afb8c133; padding: .2em .4em; border-radius: 6px; font-family: ui-monospace,SFMono-Regular,SF Mono,Menlo,Consolas,Liberation Mono,monospace; }
pre { background-color: #f6f8fa; padding: 16px; border-radius: 6px; overflow: auto; }
pre code { background-color: transparent; padding: 0; }
blockquote { border-left: .25em solid #d0d7de; color: #656d76; padding: 0 1em; margin: 0; }
table { border-spacing: 0; border-collapse: collapse; width: 100%; }
table th, table td { padding: 6px 13px; border: 1px solid #d0d7de; }
table tr:nth-child(2n) { background-color: #f6f8fa; }
img { max-width: 100%; }
</style>
</head>
<body>
$htmlContent
</body>
</html>
''';
      files['README.html'] = fullHtml;
    }

    if (licenseType != 'None') {
      final year = variables['CURRENT_YEAR'] ?? DateTime.now().year.toString();
      final author = variables['GITHUB_USERNAME'] ?? 'Author';
      files['LICENSE'] = LicenseGenerator.generate(licenseType, year, author);
    }

    if (includeContributing) {
      // Find Contributing Template
      final template = Templates.all.firstWhere((t) => t.name == 'Contributing Guide', orElse: () => Templates.all.first);
      final contributingContent = markdownGenerator.generate(
        template.elements,
        variables: variables,
        listBullet: listBullet,
        sectionSpacing: sectionSpacing,
      );
      files['CONTRIBUTING.md'] = contributingContent;
    }

    final email = variables['EMAIL'] ?? 'email@example.com';
    final discord = variables['DISCORD_LINK'] ?? '';

    if (includeSecurity) {
      files['SECURITY.md'] = DocumentationGenerator.generateSecurityPolicy(email);
    }

    if (includeSupport) {
      files['SUPPORT.md'] = DocumentationGenerator.generateSupport(email, discord);
    }

    if (includeCodeOfConduct) {
      files['CODE_OF_CONDUCT.md'] = DocumentationGenerator.generateCodeOfConduct(email);
    }

    if (includeIssueTemplates) {
      files['.github/ISSUE_TEMPLATE/bug_report.md'] = DocumentationGenerator.generateBugReportTemplate();
      files['.github/ISSUE_TEMPLATE/feature_request.md'] = DocumentationGenerator.generateFeatureRequestTemplate();
      files['.github/PULL_REQUEST_TEMPLATE.md'] = DocumentationGenerator.generatePullRequestTemplate();
    }

    // Check for local images
    bool hasLocalImages = false;
    for (final element in elements) {
      if (element is ImageElement && element.localData != null) {
        hasLocalImages = true;
        // Use the filename from the URL (which we set to ./filename)
        // Remove ./ prefix if present
        String filename = element.url;
        if (filename.startsWith('./')) {
          filename = filename.substring(2);
        }
        files[filename] = element.localData;
      }
    }

    if (files.length == 1 && !hasLocalImages) {
      downloadReadme(files['README.md'] as String);
    } else {
      final archive = Archive();
      files.forEach((filename, content) {
        if (content is String) {
          final bytes = utf8.encode(content);
          archive.addFile(ArchiveFile(filename, bytes.length, bytes));
        } else if (content is List<int>) {
          archive.addFile(ArchiveFile(filename, content.length, content));
        }
      });
      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(archive);
      if (zipBytes != null) {
        downloadZipFile(zipBytes, 'project_files.zip');
      }
    }
  }
}
