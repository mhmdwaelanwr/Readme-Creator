class DocumentationGenerator {
  static String generateSecurityPolicy(String email) {
    return '''
# Security Policy

## Supported Versions

Use this section to tell people about which versions of your project are currently being supported with security updates.

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Reporting a Vulnerability

We take the security of this project seriously. If you discover a security vulnerability, please report it to us immediately.

### How to Report

Please **DO NOT** open a public issue on GitHub for security vulnerabilities. Instead, please report it via email to:

**$email**

Please include the following details in your report:
*   A description of the vulnerability.
*   Steps to reproduce the issue.
*   Any relevant code snippets or configuration files.

### Response Timeline

*   We will acknowledge your report within 48 hours.
*   We will provide a timeline for fixing the vulnerability within 1 week.
*   We will notify you once the vulnerability has been fixed.

### Disclosure Policy

We ask that you do not disclose the vulnerability to the public until we have had a chance to fix it. We will credit you for your discovery in our release notes (unless you prefer to remain anonymous).
''';
  }

  static String generateSupport(String email, String discordLink) {
    return '''
# Support

Thank you for using our project! We are here to help you get the most out of it.

## 📚 Documentation

Before asking for help, please check the following resources:
*   [README.md](README.md) - General usage and installation instructions.
*   [CONTRIBUTING.md](CONTRIBUTING.md) - Guide for contributors.

## 💬 Community Support

If you have questions, need help, or want to discuss the project, you can join our community:

${discordLink.isNotEmpty ? '*   **Discord**: [Join our Server]($discordLink)' : ''}
*   **GitHub Discussions**: [Ask a Question](../../discussions)

## 🐛 Reporting Bugs

If you encounter a bug, please open an issue on GitHub using our [Bug Report Template](../../issues/new?template=bug_report.md).

## 💡 Feature Requests

Have an idea for a new feature? We'd love to hear it! Please submit a feature request using our [Feature Request Template](../../issues/new?template=feature_request.md).

## 📧 Contact

For non-technical inquiries or private matters, you can contact the maintainer at: **$email**
''';
  }

  static String generateCodeOfConduct(String email) {
    return '''
# Contributor Covenant Code of Conduct

## Our Pledge

We as members, contributors, and leaders pledge to make participation in our community a harassment-free experience for everyone, regardless of age, body size, visible or invisible disability, ethnicity, sex characteristics, gender identity and expression, level of experience, education, socio-economic status, nationality, personal appearance, race, religion, or sexual identity and orientation.

We pledge to act and interact in ways that contribute to an open, welcoming, diverse, inclusive, and healthy community.

## Our Standards

Examples of behavior that contributes to a positive environment for our community include:

* Demonstrating empathy and kindness toward other people
* Being respectful of differing opinions, viewpoints, and experiences
* Giving and gracefully accepting constructive feedback
* Accepting responsibility and apologizing to those affected by our mistakes, and learning from the experience
* Focusing on what is best not just for us as individuals, but for the overall community

Examples of unacceptable behavior include:

* The use of sexualized language or imagery, and sexual attention or advances of any kind
* Trolling, insulting or derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information, such as a physical or email address, without their explicit permission
* Other conduct which could reasonably be considered inappropriate in a professional setting

## Enforcement Responsibilities

Community leaders are responsible for clarifying and enforcing our standards of acceptable behavior and will take appropriate and fair corrective action in response to any behavior that they deem inappropriate, threatening, offensive, or harmful.

## Scope

This Code of Conduct applies within all community spaces, and also applies when an individual is officially representing the community in public spaces. Examples of representing our community include using an official e-mail address, posting via an official social media account, or acting as an appointed representative at an online or offline event.

## Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported to the community leaders responsible for enforcement at [$email]. All complaints will be reviewed and investigated promptly and fairly.

All community leaders are obligated to respect the privacy and security of the reporter of any incident.

## Attribution

This Code of Conduct is adapted from the [Contributor Covenant][homepage], version 2.0, available at https://www.contributor-covenant.org/version/2/0/code_of_conduct.html.

[homepage]: https://www.contributor-covenant.org
''';
  }

  static String generateBugReportTemplate() {
    return '''
---
name: Bug report
about: Create a report to help us improve
title: "[BUG] "
labels: bug
assignees: ''

---

**Describe the bug**
A clear and concise description of what the bug is.

**To Reproduce**
Steps to reproduce the behavior:
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected behavior**
A clear and concise description of what you expected to happen.

**Screenshots**
If applicable, add screenshots to help explain your problem.

**Desktop (please complete the following information):**
 - OS: [e.g. Windows, macOS, Linux]
 - Version [e.g. 10, 11, Ubuntu 20.04]

**Smartphone (please complete the following information):**
 - Device: [e.g. iPhone 12]
 - OS: [e.g. iOS 14]
 - Version [e.g. 22]

**Additional context**
Add any other context about the problem here.
''';
  }

  static String generateFeatureRequestTemplate() {
    return '''
---
name: Feature request
about: Suggest an idea for this project
title: "[FEAT] "
labels: enhancement
assignees: ''

---

**Is your feature request related to a problem? Please describe.**
A clear and concise description of what the problem is. Ex. I'm always frustrated when [...]

**Describe the solution you'd like**
A clear and concise description of what you want to happen.

**Describe alternatives you've considered**
A clear and concise description of any alternative solutions or features you've considered.

**Additional context**
Add any other context or screenshots about the feature request here.
''';
  }

  static String generatePullRequestTemplate() {
    return '''
## Description

Please include a summary of the change and which issue is fixed. Please also include relevant motivation and context. List any dependencies that are required for this change.

Fixes # (issue)

## Type of change

Please delete options that are not relevant.

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## How Has This Been Tested?

Please describe the tests that you ran to verify your changes. Provide instructions so we can reproduce. Please also list any relevant details for your test configuration

- [ ] Test A
- [ ] Test B

## Checklist:

- [ ] My code follows the style guidelines of this project
- [ ] I have performed a self-review of my own code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
- [ ] Any dependent changes have been merged and published in downstream modules
''';
  }
}

