# README Creator — Flutter Documentation Workspace

<div align="center">
  <img src="web/icons/Icon-512.png" alt="README Creator logo" width="120" height="120">
  <br />
  <p>
    <b>Create, structure, preview, and improve GitHub README files from one cross-platform workspace.</b>
    <br />
    Built with Flutter, Firebase, and optional AI-assisted writing tools.
  </p>

  [![Version](https://img.shields.io/badge/version-1.0.0--stable-blue.svg?style=for-the-badge)](https://github.com/mhmdwaelanwr/Markdown-Creator-Dart/releases)
  [![License](https://img.shields.io/badge/license-MIT-green.svg?style=for-the-badge)](LICENSE)
  [![Flutter](https://img.shields.io/badge/Built%20with-Flutter-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Cloud-Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
</div>

---

## Features

### AI-assisted writing
Generate project descriptions and feature drafts with Google Gemini and use assisted editing to improve grammar and tone.

### Cloud sync
Firebase integration can synchronize projects and custom snippets across supported builds.

### Visual editor
Compose documentation from reusable sections and widgets, including Markdown content, diagrams, tables of contents, GitHub-oriented cards, badges, and developer-focused components.

### Repository-assisted documentation
The application can use a local folder or public GitHub repository as context when preparing README content.

### Cross-platform interface
The Flutter application targets web and supported desktop/mobile environments from one codebase.

---

## Getting started

### Web version

**[Open README Creator](https://www.readmecreator.studio/)**

The deployed web distribution is maintained separately in [Readme-Creator-Web](https://github.com/mhmdwaelanwr/Readme-Creator-Web).

### Source setup

```bash
git clone https://github.com/mhmdwaelanwr/Markdown-Creator-Dart.git
cd Markdown-Creator-Dart
flutter pub get
flutter run
```

### Tagged builds

See the repository's [Releases](https://github.com/mhmdwaelanwr/Markdown-Creator-Dart/releases) page for published artifacts when available.

### Android customization

To change the Android `applicationId`, set `appApplicationId` in `gradle.properties` or pass it at build time:

```properties
appApplicationId=com.example.readmecreator
```

```bash
./gradlew assembleRelease -PappApplicationId=com.example.readmecreator
```

---

## Technology stack

- **Framework:** Flutter / Dart
- **Cloud services:** Firebase
- **AI integration:** Google Gemini
- **State management:** Provider
- **Web distribution:** Flutter Web / PWA assets

---

## Repository relationship

- **This repository** contains the Flutter application source.
- **[Readme-Creator-Web](https://github.com/mhmdwaelanwr/Readme-Creator-Web)** contains the deployed web distribution and landing experience.
- **[readmecreator.studio](https://www.readmecreator.studio/)** is the public web entry point.

---

## Contributing

Contributions, bug fixes, and documentation improvements are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md) for the development workflow.

## Security and support

- [Security policy](SECURITY.md)
- [Support](SUPPORT.md)

## License

Released under the [MIT License](LICENSE).

---

<div align="center">
  Built by <a href="https://github.com/mhmdwaelanwr">Mohamed Anwar</a>
</div>