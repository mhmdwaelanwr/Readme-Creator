import '../models/readme_element.dart';

enum IssueSeverity { error, warning, info }

class HealthIssue {
  final String message;
  final IssueSeverity severity;
  final String? elementId;

  HealthIssue({
    required this.message,
    required this.severity,
    this.elementId,
  });
}

class HealthCheckService {
  static List<HealthIssue> analyze(List<ReadmeElement> elements) {
    final List<HealthIssue> issues = [];

    // 1. Check for empty project
    if (elements.isEmpty) {
      issues.add(HealthIssue(
        message: 'Project is empty. Add some elements to get started.',
        severity: IssueSeverity.info,
      ));
      return issues;
    }

    // 2. Check Heading Hierarchy
    int lastLevel = 0;
    for (final element in elements) {
      if (element is HeadingElement) {
        if (element.text.trim().isEmpty) {
          issues.add(HealthIssue(
            message: 'Heading is empty.',
            severity: IssueSeverity.error,
            elementId: element.id,
          ));
        }

        if (lastLevel != 0 && element.level > lastLevel + 1) {
          issues.add(HealthIssue(
            message: 'Skipped heading level: H$lastLevel to H${element.level}.',
            severity: IssueSeverity.warning,
            elementId: element.id,
          ));
        }
        lastLevel = element.level;
      }
    }

    // 3. Check Images for Alt Text
    for (final element in elements) {
      if (element is ImageElement) {
        if (element.url.isEmpty && element.localData == null) {
          issues.add(HealthIssue(
            message: 'Image has no URL or uploaded file.',
            severity: IssueSeverity.error,
            elementId: element.id,
          ));
        } else if (element.altText.trim().isEmpty) {
          issues.add(HealthIssue(
            message: 'Image missing Alt Text (important for accessibility).',
            severity: IssueSeverity.warning,
            elementId: element.id,
          ));
        }
      }
    }

    // 4. Check Links
    for (final element in elements) {
      if (element is LinkButtonElement) {
        if (element.text.trim().isEmpty) {
          issues.add(HealthIssue(
            message: 'Link button has no text.',
            severity: IssueSeverity.error,
            elementId: element.id,
          ));
        }
        if (element.url.trim().isEmpty) {
          issues.add(HealthIssue(
            message: 'Link button has no URL.',
            severity: IssueSeverity.error,
            elementId: element.id,
          ));
        }
      }
      if (element is BadgeElement) {
        if (element.imageUrl.trim().isEmpty) {
           issues.add(HealthIssue(
            message: 'Badge image URL is empty.',
            severity: IssueSeverity.error,
            elementId: element.id,
          ));
        }
      }
    }

    // 5. Check GitHub Stats
    for (final element in elements) {
      if (element is GitHubStatsElement) {
        if (element.repoName.trim().isEmpty || !element.repoName.contains('/')) {
          issues.add(HealthIssue(
            message: 'Invalid GitHub repository format (use user/repo).',
            severity: IssueSeverity.error,
            elementId: element.id,
          ));
        }
      }
    }

    return issues;
  }
}

