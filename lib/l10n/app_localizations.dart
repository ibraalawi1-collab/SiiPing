import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Nixen'**
  String get appTitle;

  /// No description provided for @navPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get navPulse;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navChannels.
  ///
  /// In en, this message translates to:
  /// **'Channels'**
  String get navChannels;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @signUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUpTitle;

  /// No description provided for @enterPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN'**
  String get enterPinLabel;

  /// No description provided for @enterPinHint.
  ///
  /// In en, this message translates to:
  /// **'Create a unique alphanumeric PIN'**
  String get enterPinHint;

  /// No description provided for @agreeToTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms of Service and Privacy Policy.'**
  String get agreeToTerms;

  /// No description provided for @confirmAge.
  ///
  /// In en, this message translates to:
  /// **'I confirm I am 17+ years old.'**
  String get confirmAge;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @registrationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Registration logic coming in Phase 2'**
  String get registrationComingSoon;

  /// No description provided for @channelsTitle.
  ///
  /// In en, this message translates to:
  /// **'CHANNELS'**
  String get channelsTitle;

  /// No description provided for @channelsPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Channels Placeholder'**
  String get channelsPlaceholder;

  /// No description provided for @createChannelComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Create Channel logic coming soon'**
  String get createChannelComingSoon;

  /// No description provided for @premiumFeatureTitle.
  ///
  /// In en, this message translates to:
  /// **'Premium Feature'**
  String get premiumFeatureTitle;

  /// No description provided for @premiumChannelMessage.
  ///
  /// In en, this message translates to:
  /// **'Creating a Secure Channel is reserved for Elite members.'**
  String get premiumChannelMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @subscriptionComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Subscription flow coming soon'**
  String get subscriptionComingSoon;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'PROFILE'**
  String get profileTitle;

  /// No description provided for @userProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'User Profile'**
  String get userProfileTitle;

  /// No description provided for @reportUser.
  ///
  /// In en, this message translates to:
  /// **'Report User'**
  String get reportUser;

  /// No description provided for @reportComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Report User functionality coming soon'**
  String get reportComingSoon;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @blockComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Block User functionality coming soon'**
  String get blockComingSoon;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms & Privacy'**
  String get termsAndPrivacy;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete My Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account?'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountMessage.
  ///
  /// In en, this message translates to:
  /// **'This action is irreversible. All your data will be permanently removed.'**
  String get deleteAccountMessage;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteRequested.
  ///
  /// In en, this message translates to:
  /// **'Account deletion requested'**
  String get deleteRequested;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'PULSE'**
  String get feedTitle;

  /// No description provided for @feedPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Feed Placeholder'**
  String get feedPlaceholder;

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'CHATS'**
  String get chatTitle;

  /// No description provided for @chatPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Chat List Placeholder'**
  String get chatPlaceholder;

  /// No description provided for @adminDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboardTitle;

  /// No description provided for @adminBroadcastTitle.
  ///
  /// In en, this message translates to:
  /// **'System Broadcast'**
  String get adminBroadcastTitle;

  /// No description provided for @broadcastTitleLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get broadcastTitleLabel;

  /// No description provided for @broadcastBodyLabel.
  ///
  /// In en, this message translates to:
  /// **'Message Body'**
  String get broadcastBodyLabel;

  /// No description provided for @broadcastSendButton.
  ///
  /// In en, this message translates to:
  /// **'SEND BROADCAST'**
  String get broadcastSendButton;

  /// No description provided for @userManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagementTitle;

  /// No description provided for @searchUserHint.
  ///
  /// In en, this message translates to:
  /// **'Search Users...'**
  String get searchUserHint;

  /// No description provided for @banUserButton.
  ///
  /// In en, this message translates to:
  /// **'Ban'**
  String get banUserButton;

  /// No description provided for @upgradeUserButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeUserButton;

  /// No description provided for @adminAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminAccessButton;

  /// No description provided for @googleSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignInButton;

  /// No description provided for @createUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'New Update'**
  String get createUpdateTitle;

  /// No description provided for @updateContentHint.
  ///
  /// In en, this message translates to:
  /// **'What\'s on your mind?'**
  String get updateContentHint;

  /// No description provided for @cancelButton.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButton;

  /// No description provided for @postButton.
  ///
  /// In en, this message translates to:
  /// **'Post'**
  String get postButton;

  /// No description provided for @noUpdates.
  ///
  /// In en, this message translates to:
  /// **'No updates yet.'**
  String get noUpdates;

  /// No description provided for @createChannelTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Channel'**
  String get createChannelTitle;

  /// No description provided for @channelNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Channel Name'**
  String get channelNameLabel;

  /// No description provided for @channelDescLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get channelDescLabel;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @createChannelTooltip.
  ///
  /// In en, this message translates to:
  /// **'Create Channel'**
  String get createChannelTooltip;

  /// No description provided for @noChannels.
  ///
  /// In en, this message translates to:
  /// **'No channels found.'**
  String get noChannels;

  /// No description provided for @premiumFeatureLocked.
  ///
  /// In en, this message translates to:
  /// **'This feature is locked for your tier.'**
  String get premiumFeatureLocked;

  /// No description provided for @upgradeButton.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgradeButton;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found.'**
  String get noUsersFound;

  /// No description provided for @noMessages.
  ///
  /// In en, this message translates to:
  /// **'No messages yet.'**
  String get noMessages;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get messageHint;

  /// No description provided for @subscriptionTitle.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscriptionTitle;

  /// No description provided for @freeTier.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get freeTier;

  /// No description provided for @freePrice.
  ///
  /// In en, this message translates to:
  /// **'\$0/mo'**
  String get freePrice;

  /// No description provided for @eliteTier.
  ///
  /// In en, this message translates to:
  /// **'Elite'**
  String get eliteTier;

  /// No description provided for @elitePrice.
  ///
  /// In en, this message translates to:
  /// **'\$9.99/mo'**
  String get elitePrice;

  /// No description provided for @featureReadFeed.
  ///
  /// In en, this message translates to:
  /// **'Read Pulse Feed'**
  String get featureReadFeed;

  /// No description provided for @featureJoinChannels.
  ///
  /// In en, this message translates to:
  /// **'Join Public Channels'**
  String get featureJoinChannels;

  /// No description provided for @featureBasicChat.
  ///
  /// In en, this message translates to:
  /// **'Basic Chat'**
  String get featureBasicChat;

  /// No description provided for @featureCreateChannels.
  ///
  /// In en, this message translates to:
  /// **'Create Secure Channels'**
  String get featureCreateChannels;

  /// No description provided for @featureGhostMode.
  ///
  /// In en, this message translates to:
  /// **'Ghost Mode'**
  String get featureGhostMode;

  /// No description provided for @featurePrioritySupport.
  ///
  /// In en, this message translates to:
  /// **'Priority Support'**
  String get featurePrioritySupport;

  /// No description provided for @featureVerifiedBadge.
  ///
  /// In en, this message translates to:
  /// **'Verified Badge'**
  String get featureVerifiedBadge;

  /// No description provided for @upgradeSuccess.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Elite!'**
  String get upgradeSuccess;

  /// No description provided for @currentPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan'**
  String get currentPlan;

  /// No description provided for @connectIdentity.
  ///
  /// In en, this message translates to:
  /// **'Connect Identity'**
  String get connectIdentity;

  /// No description provided for @authError.
  ///
  /// In en, this message translates to:
  /// **'Authentication Failed'**
  String get authError;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
