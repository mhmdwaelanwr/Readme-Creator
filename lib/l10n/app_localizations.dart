import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('ja'),
    Locale('pt'),
    Locale('ru'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Markdown Creator'**
  String get appTitle;

  /// No description provided for @saveToLibrary.
  ///
  /// In en, this message translates to:
  /// **'Save to Library'**
  String get saveToLibrary;

  /// No description provided for @localSnapshots.
  ///
  /// In en, this message translates to:
  /// **'Local Snapshots'**
  String get localSnapshots;

  /// No description provided for @clearWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Clear Workspace'**
  String get clearWorkspace;

  /// No description provided for @importMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Import Markdown'**
  String get importMarkdown;

  /// No description provided for @socialPreviewDesigner.
  ///
  /// In en, this message translates to:
  /// **'Social Preview Designer'**
  String get socialPreviewDesigner;

  /// No description provided for @githubActionsGenerator.
  ///
  /// In en, this message translates to:
  /// **'GitHub Actions Generator'**
  String get githubActionsGenerator;

  /// No description provided for @exportProjectJson.
  ///
  /// In en, this message translates to:
  /// **'Export Project (JSON)'**
  String get exportProjectJson;

  /// No description provided for @importProjectJson.
  ///
  /// In en, this message translates to:
  /// **'Import Project (JSON)'**
  String get importProjectJson;

  /// No description provided for @aiSettings.
  ///
  /// In en, this message translates to:
  /// **'AI Settings'**
  String get aiSettings;

  /// No description provided for @generateFromCodebase.
  ///
  /// In en, this message translates to:
  /// **'Generate from Codebase (AI)'**
  String get generateFromCodebase;

  /// No description provided for @showTour.
  ///
  /// In en, this message translates to:
  /// **'Show Tour'**
  String get showTour;

  /// No description provided for @keyboardShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Keyboard Shortcuts'**
  String get keyboardShortcuts;

  /// No description provided for @aboutDeveloper.
  ///
  /// In en, this message translates to:
  /// **'About Developer'**
  String get aboutDeveloper;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags (comma separated)'**
  String get tags;

  /// No description provided for @projectSaved.
  ///
  /// In en, this message translates to:
  /// **'Project saved to library'**
  String get projectSaved;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @confirmClearWorkspace.
  ///
  /// In en, this message translates to:
  /// **'Clear Workspace?'**
  String get confirmClearWorkspace;

  /// No description provided for @confirmClearWorkspaceContent.
  ///
  /// In en, this message translates to:
  /// **'This will remove all elements. This action cannot be undone (unless you have a snapshot).'**
  String get confirmClearWorkspaceContent;

  /// No description provided for @pickProjectFolder.
  ///
  /// In en, this message translates to:
  /// **'Pick Project Folder'**
  String get pickProjectFolder;

  /// No description provided for @repoUrl.
  ///
  /// In en, this message translates to:
  /// **'Repository URL'**
  String get repoUrl;

  /// No description provided for @scanAndGenerate.
  ///
  /// In en, this message translates to:
  /// **'Scan & Generate'**
  String get scanAndGenerate;

  /// No description provided for @geminiApiKey.
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key'**
  String get geminiApiKey;

  /// No description provided for @githubToken.
  ///
  /// In en, this message translates to:
  /// **'GitHub Token (Optional)'**
  String get githubToken;

  /// No description provided for @getApiKey.
  ///
  /// In en, this message translates to:
  /// **'Get your API key from Google AI Studio'**
  String get getApiKey;

  /// No description provided for @generateToken.
  ///
  /// In en, this message translates to:
  /// **'Generate a Personal Access Token'**
  String get generateToken;

  /// No description provided for @elements.
  ///
  /// In en, this message translates to:
  /// **'Elements'**
  String get elements;

  /// No description provided for @words.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get words;

  /// No description provided for @healthy.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// No description provided for @errors.
  ///
  /// In en, this message translates to:
  /// **'Errors'**
  String get errors;

  /// No description provided for @warnings.
  ///
  /// In en, this message translates to:
  /// **'Warnings'**
  String get warnings;

  /// No description provided for @focusMode.
  ///
  /// In en, this message translates to:
  /// **'FOCUS MODE'**
  String get focusMode;

  /// No description provided for @autoSaved.
  ///
  /// In en, this message translates to:
  /// **'Auto-saved'**
  String get autoSaved;

  /// No description provided for @projectSettings.
  ///
  /// In en, this message translates to:
  /// **'Project Settings'**
  String get projectSettings;

  /// No description provided for @variables.
  ///
  /// In en, this message translates to:
  /// **'Variables'**
  String get variables;

  /// No description provided for @license.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get license;

  /// No description provided for @contributing.
  ///
  /// In en, this message translates to:
  /// **'Contributing'**
  String get contributing;

  /// No description provided for @colors.
  ///
  /// In en, this message translates to:
  /// **'Colors'**
  String get colors;

  /// No description provided for @formatting.
  ///
  /// In en, this message translates to:
  /// **'Formatting'**
  String get formatting;

  /// No description provided for @primaryColor.
  ///
  /// In en, this message translates to:
  /// **'Primary Color'**
  String get primaryColor;

  /// No description provided for @secondaryColor.
  ///
  /// In en, this message translates to:
  /// **'Secondary Color'**
  String get secondaryColor;

  /// No description provided for @exportHtml.
  ///
  /// In en, this message translates to:
  /// **'Export HTML'**
  String get exportHtml;

  /// No description provided for @listBulletStyle.
  ///
  /// In en, this message translates to:
  /// **'List Bullet Style'**
  String get listBulletStyle;

  /// No description provided for @sectionSpacing.
  ///
  /// In en, this message translates to:
  /// **'Section Spacing (Newlines)'**
  String get sectionSpacing;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @load.
  ///
  /// In en, this message translates to:
  /// **'Load'**
  String get load;

  /// No description provided for @viewOnGithub.
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get viewOnGithub;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @rightsReserved.
  ///
  /// In en, this message translates to:
  /// **'All rights reserved.'**
  String get rightsReserved;

  /// No description provided for @systemDefault.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemDefault;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved!'**
  String get settingsSaved;

  /// No description provided for @commonShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Common Shortcuts'**
  String get commonShortcuts;

  /// No description provided for @elementShortcuts.
  ///
  /// In en, this message translates to:
  /// **'Element Shortcuts'**
  String get elementShortcuts;

  /// No description provided for @newProject.
  ///
  /// In en, this message translates to:
  /// **'New Project'**
  String get newProject;

  /// No description provided for @openProject.
  ///
  /// In en, this message translates to:
  /// **'Open Project'**
  String get openProject;

  /// No description provided for @saveProject.
  ///
  /// In en, this message translates to:
  /// **'Save Project'**
  String get saveProject;

  /// No description provided for @exportProject.
  ///
  /// In en, this message translates to:
  /// **'Export Project'**
  String get exportProject;

  /// No description provided for @print.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get print;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @showPreview.
  ///
  /// In en, this message translates to:
  /// **'Show Preview'**
  String get showPreview;

  /// No description provided for @toggleGrid.
  ///
  /// In en, this message translates to:
  /// **'Toggle Grid'**
  String get toggleGrid;

  /// No description provided for @toggleTheme.
  ///
  /// In en, this message translates to:
  /// **'Toggle Theme'**
  String get toggleTheme;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @addHeading.
  ///
  /// In en, this message translates to:
  /// **'Add Heading'**
  String get addHeading;

  /// No description provided for @addSubheading.
  ///
  /// In en, this message translates to:
  /// **'Add Subheading'**
  String get addSubheading;

  /// No description provided for @addParagraph.
  ///
  /// In en, this message translates to:
  /// **'Add Paragraph'**
  String get addParagraph;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No description provided for @addTable.
  ///
  /// In en, this message translates to:
  /// **'Add Table'**
  String get addTable;

  /// No description provided for @addList.
  ///
  /// In en, this message translates to:
  /// **'Add List'**
  String get addList;

  /// No description provided for @addQuote.
  ///
  /// In en, this message translates to:
  /// **'Add Quote'**
  String get addQuote;

  /// No description provided for @addLink.
  ///
  /// In en, this message translates to:
  /// **'Add Link'**
  String get addLink;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Markdown Creator is a powerful tool for generating professional Markdown documentation for your projects. All features work across desktop, mobile and web.'**
  String get aboutDescription;

  /// No description provided for @enterGeminiKey.
  ///
  /// In en, this message translates to:
  /// **'Enter your Gemini API Key to enable real AI features.'**
  String get enterGeminiKey;

  /// No description provided for @githubIntegration.
  ///
  /// In en, this message translates to:
  /// **'GitHub Integration'**
  String get githubIntegration;

  /// No description provided for @enterGithubToken.
  ///
  /// In en, this message translates to:
  /// **'Optional: Enter GitHub Token for higher rate limits when scanning repos.'**
  String get enterGithubToken;

  /// No description provided for @localFolder.
  ///
  /// In en, this message translates to:
  /// **'Local Folder'**
  String get localFolder;

  /// No description provided for @githubRepo.
  ///
  /// In en, this message translates to:
  /// **'GitHub Repo'**
  String get githubRepo;

  /// No description provided for @scanLocalFolder.
  ///
  /// In en, this message translates to:
  /// **'Scan a local project folder to generate a README.'**
  String get scanLocalFolder;

  /// No description provided for @scanGithubRepo.
  ///
  /// In en, this message translates to:
  /// **'Scan a public GitHub repository.'**
  String get scanGithubRepo;

  /// No description provided for @fetchingRepo.
  ///
  /// In en, this message translates to:
  /// **'Fetching repository data...'**
  String get fetchingRepo;

  /// No description provided for @analyzingAI.
  ///
  /// In en, this message translates to:
  /// **'Analyzing with AI...'**
  String get analyzingAI;

  /// No description provided for @readmeGenerated.
  ///
  /// In en, this message translates to:
  /// **'README generated successfully!'**
  String get readmeGenerated;

  /// No description provided for @projectImported.
  ///
  /// In en, this message translates to:
  /// **'Project imported successfully'**
  String get projectImported;

  /// No description provided for @contentFetched.
  ///
  /// In en, this message translates to:
  /// **'Content fetched! Switch to \"Text / File\" tab to review.'**
  String get contentFetched;

  /// No description provided for @fetchFailed.
  ///
  /// In en, this message translates to:
  /// **'Fetch Failed'**
  String get fetchFailed;

  /// No description provided for @generateExtraFiles.
  ///
  /// In en, this message translates to:
  /// **'Generate Extra Files'**
  String get generateExtraFiles;

  /// No description provided for @publishToGithub.
  ///
  /// In en, this message translates to:
  /// **'Publish to GitHub'**
  String get publishToGithub;

  /// No description provided for @contributionGuidelinesBuilder.
  ///
  /// In en, this message translates to:
  /// **'Contribution Guidelines Builder'**
  String get contributionGuidelinesBuilder;

  /// No description provided for @contributionGuidelinesDesc.
  ///
  /// In en, this message translates to:
  /// **'Generate standard community files for your project.'**
  String get contributionGuidelinesDesc;

  /// No description provided for @contributingMdDesc.
  ///
  /// In en, this message translates to:
  /// **'Guidelines for how to contribute to the project.'**
  String get contributingMdDesc;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @codeOfConductDesc.
  ///
  /// In en, this message translates to:
  /// **'Contributor Covenant Code of Conduct.'**
  String get codeOfConductDesc;

  /// No description provided for @githubTokenMissing.
  ///
  /// In en, this message translates to:
  /// **'GitHub Token is missing. Please set it in AI Settings.'**
  String get githubTokenMissing;

  /// No description provided for @owner.
  ///
  /// In en, this message translates to:
  /// **'Owner (Username/Org)'**
  String get owner;

  /// No description provided for @repoName.
  ///
  /// In en, this message translates to:
  /// **'Repository Name'**
  String get repoName;

  /// No description provided for @branchName.
  ///
  /// In en, this message translates to:
  /// **'New Branch Name'**
  String get branchName;

  /// No description provided for @commitMessage.
  ///
  /// In en, this message translates to:
  /// **'Commit Message'**
  String get commitMessage;

  /// No description provided for @publishDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'This will create a new branch and a Pull Request.'**
  String get publishDialogDesc;

  /// No description provided for @ownerRepoRequired.
  ///
  /// In en, this message translates to:
  /// **'Owner and Repo are required'**
  String get ownerRepoRequired;

  /// No description provided for @prCreated.
  ///
  /// In en, this message translates to:
  /// **'Pull Request created successfully.'**
  String get prCreated;

  /// No description provided for @viewPrs.
  ///
  /// In en, this message translates to:
  /// **'View PRs'**
  String get viewPrs;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'ja',
    'pt',
    'ru',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'ja':
      return AppLocalizationsJa();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
