import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
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
    Locale('bn'),
    Locale('en'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'SafeLife'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'Unified Smart Emergency Response Platform'**
  String get appTagline;

  /// No description provided for @emergency.
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// No description provided for @sos.
  ///
  /// In en, this message translates to:
  /// **'SOS'**
  String get sos;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @imSafe.
  ///
  /// In en, this message translates to:
  /// **'I\'m Safe'**
  String get imSafe;

  /// No description provided for @countdownTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Alert Triggering'**
  String get countdownTitle;

  /// No description provided for @countdownWarning.
  ///
  /// In en, this message translates to:
  /// **'Alerting emergency contacts in {seconds} seconds'**
  String countdownWarning(int seconds);

  /// No description provided for @holdToCancel.
  ///
  /// In en, this message translates to:
  /// **'Tap to Cancel'**
  String get holdToCancel;

  /// No description provided for @womenSafety.
  ///
  /// In en, this message translates to:
  /// **'Women Safety'**
  String get womenSafety;

  /// No description provided for @cardiacEmergency.
  ///
  /// In en, this message translates to:
  /// **'Heart Attack / Cardiac'**
  String get cardiacEmergency;

  /// No description provided for @strokeEmergency.
  ///
  /// In en, this message translates to:
  /// **'Stroke (FAST)'**
  String get strokeEmergency;

  /// No description provided for @medicalId.
  ///
  /// In en, this message translates to:
  /// **'Medical ID'**
  String get medicalId;

  /// No description provided for @emergencyContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get emergencyContacts;

  /// No description provided for @incidentReport.
  ///
  /// In en, this message translates to:
  /// **'Incident Report'**
  String get incidentReport;

  /// No description provided for @nearbyHospitals.
  ///
  /// In en, this message translates to:
  /// **'Nearby Hospitals'**
  String get nearbyHospitals;

  /// No description provided for @call999.
  ///
  /// In en, this message translates to:
  /// **'Call 999 (National Emergency)'**
  String get call999;

  /// No description provided for @call109.
  ///
  /// In en, this message translates to:
  /// **'Call 109 (Women & Children Helpline)'**
  String get call109;

  /// No description provided for @call333.
  ///
  /// In en, this message translates to:
  /// **'Call 333 (National Info Helpline)'**
  String get call333;

  /// No description provided for @bystanderMode.
  ///
  /// In en, this message translates to:
  /// **'Bystander Mode (Assessing Someone Else)'**
  String get bystanderMode;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// No description provided for @mediumRisk.
  ///
  /// In en, this message translates to:
  /// **'Medium Risk'**
  String get mediumRisk;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @criticalRisk.
  ///
  /// In en, this message translates to:
  /// **'Critical Emergency'**
  String get criticalRisk;

  /// No description provided for @locationSharingActive.
  ///
  /// In en, this message translates to:
  /// **'Live Location Sharing Active'**
  String get locationSharingActive;

  /// No description provided for @stopSharing.
  ///
  /// In en, this message translates to:
  /// **'Stop Sharing'**
  String get stopSharing;

  /// No description provided for @disclaimer.
  ///
  /// In en, this message translates to:
  /// **'SafeLife provides emergency response assistance and symptom-based triage. It is not a diagnostic tool or a substitute for professional medical care.'**
  String get disclaimer;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Register'**
  String get dontHaveAccount;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out of SafeLife?'**
  String get logoutConfirmMessage;

  /// No description provided for @onboardingWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to SafeLife'**
  String get onboardingWelcome;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'One tap to safety threats and critical medical triage'**
  String get onboardingSubtitle;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Unified Smart Emergency Engine'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'Instant emergency alerts for women\'s safety risks, acute cardiac events, and stroke emergencies.'**
  String get onboardingStep1Desc;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Consent-Based Live Tracking'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'Your verified contacts receive real-time location and SMS fallback when an emergency is active.'**
  String get onboardingStep2Desc;

  /// No description provided for @onboardingStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Ethical & Medical Notice'**
  String get onboardingStep3Title;

  /// No description provided for @onboardingStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'SafeLife assists and triages based on clinical guidelines. Always contact national emergency services (999) for immediate acute care.'**
  String get onboardingStep3Desc;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @acceptAndContinue.
  ///
  /// In en, this message translates to:
  /// **'I Understand & Accept'**
  String get acceptAndContinue;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @medicalProfile.
  ///
  /// In en, this message translates to:
  /// **'Medical Profile'**
  String get medicalProfile;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @selectBloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Select Blood Group'**
  String get selectBloodGroup;

  /// No description provided for @chronicConditions.
  ///
  /// In en, this message translates to:
  /// **'Chronic Medical Conditions'**
  String get chronicConditions;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Current Medications'**
  String get medications;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Known Allergies'**
  String get allergies;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdated;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'Add Medication'**
  String get addMedication;

  /// No description provided for @addAllergy.
  ///
  /// In en, this message translates to:
  /// **'Add Allergy'**
  String get addAllergy;

  /// No description provided for @addCondition.
  ///
  /// In en, this message translates to:
  /// **'Add Condition'**
  String get addCondition;

  /// No description provided for @myContacts.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contacts'**
  String get myContacts;

  /// No description provided for @addContact.
  ///
  /// In en, this message translates to:
  /// **'Add Contact'**
  String get addContact;

  /// No description provided for @editContact.
  ///
  /// In en, this message translates to:
  /// **'Edit Contact'**
  String get editContact;

  /// No description provided for @contactName.
  ///
  /// In en, this message translates to:
  /// **'Contact Name'**
  String get contactName;

  /// No description provided for @contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get contactPhone;

  /// No description provided for @relation.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relation;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @verifiedConsent.
  ///
  /// In en, this message translates to:
  /// **'Verified (Consent Granted)'**
  String get verifiedConsent;

  /// No description provided for @pendingConsent.
  ///
  /// In en, this message translates to:
  /// **'Pending Consent'**
  String get pendingConsent;

  /// No description provided for @requestConsent.
  ///
  /// In en, this message translates to:
  /// **'Send Consent Request'**
  String get requestConsent;

  /// No description provided for @consentRequested.
  ///
  /// In en, this message translates to:
  /// **'Verification request sent to contact'**
  String get consentRequested;

  /// No description provided for @minContactsNotice.
  ///
  /// In en, this message translates to:
  /// **'We recommend adding at least 2 trusted emergency contacts.'**
  String get minContactsNotice;

  /// No description provided for @deleteContact.
  ///
  /// In en, this message translates to:
  /// **'Delete Contact'**
  String get deleteContact;

  /// No description provided for @deleteContactConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this emergency contact?'**
  String get deleteContactConfirm;

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

  /// No description provided for @activeEmergencyTitle.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE EMERGENCY IN PROGRESS'**
  String get activeEmergencyTitle;

  /// No description provided for @activeEmergencyDesc.
  ///
  /// In en, this message translates to:
  /// **'Alert dispatched! Continuous live location sharing is active with verified contacts.'**
  String get activeEmergencyDesc;

  /// No description provided for @imSafeResolve.
  ///
  /// In en, this message translates to:
  /// **'I\'m Safe / Resolve'**
  String get imSafeResolve;

  /// No description provided for @resolveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Resolve Emergency'**
  String get resolveDialogTitle;

  /// No description provided for @resolveDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'Confirm if you are currently safe. This will immediately stop live location streaming and notify your contacts.'**
  String get resolveDialogMessage;

  /// No description provided for @markAsFalseAlarm.
  ///
  /// In en, this message translates to:
  /// **'False Alarm / Test'**
  String get markAsFalseAlarm;

  /// No description provided for @markAsResolved.
  ///
  /// In en, this message translates to:
  /// **'I Am Safe (Resolved)'**
  String get markAsResolved;

  /// No description provided for @openInGoogleMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Google Maps'**
  String get openInGoogleMaps;

  /// No description provided for @liveLocation.
  ///
  /// In en, this message translates to:
  /// **'Live GPS Location'**
  String get liveLocation;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy: ±{meters}m'**
  String accuracy(int meters);

  /// No description provided for @smsFallbackSent.
  ///
  /// In en, this message translates to:
  /// **'SMS fallback prepared'**
  String get smsFallbackSent;

  /// No description provided for @sendSmsToContacts.
  ///
  /// In en, this message translates to:
  /// **'Send Direct SMS Fallback'**
  String get sendSmsToContacts;

  /// No description provided for @emergencyType.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type'**
  String get emergencyType;

  /// No description provided for @alertedContacts.
  ///
  /// In en, this message translates to:
  /// **'Alerted Emergency Contacts'**
  String get alertedContacts;

  /// No description provided for @callPolice999.
  ///
  /// In en, this message translates to:
  /// **'Call 999 (National Helpline)'**
  String get callPolice999;

  /// No description provided for @cardiacTriageTitle.
  ///
  /// In en, this message translates to:
  /// **'Cardiac Risk Assessment'**
  String get cardiacTriageTitle;

  /// No description provided for @cardiacTriageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Symptom-based triage & pre-hospital clinical guidance'**
  String get cardiacTriageSubtitle;

  /// No description provided for @chestPainQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you experiencing chest pain, tightness, or heavy pressure?'**
  String get chestPainQuestion;

  /// No description provided for @painRadiationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Does the pain radiate to your left arm, jaw, neck, or back?'**
  String get painRadiationQuestion;

  /// No description provided for @shortnessOfBreathQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you experiencing severe shortness of breath or difficulty breathing?'**
  String get shortnessOfBreathQuestion;

  /// No description provided for @sweatingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you experiencing cold sweats (diaphoresis)?'**
  String get sweatingQuestion;

  /// No description provided for @nauseaQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you feeling nauseous, lightheaded, or dizzy?'**
  String get nauseaQuestion;

  /// No description provided for @durationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Have symptoms persisted for longer than 10 minutes?'**
  String get durationQuestion;

  /// No description provided for @calculateRisk.
  ///
  /// In en, this message translates to:
  /// **'Assess Risk'**
  String get calculateRisk;

  /// No description provided for @cardiacAssessmentResult.
  ///
  /// In en, this message translates to:
  /// **'Cardiac Triage Assessment'**
  String get cardiacAssessmentResult;

  /// No description provided for @firstAidGuidance.
  ///
  /// In en, this message translates to:
  /// **'First-Aid Guidance'**
  String get firstAidGuidance;

  /// No description provided for @aspirinGuidance.
  ///
  /// In en, this message translates to:
  /// **'If available, chew 300mg soluble aspirin immediately, unless you are allergic, have an active bleeding condition, or stroke is suspected.'**
  String get aspirinGuidance;

  /// No description provided for @restGuidance.
  ///
  /// In en, this message translates to:
  /// **'Sit down immediately in a comfortable position, rest, and avoid all physical exertion.'**
  String get restGuidance;

  /// No description provided for @dispatchCardiacSos.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Cardiac SOS Alert'**
  String get dispatchCardiacSos;

  /// No description provided for @rulesFired.
  ///
  /// In en, this message translates to:
  /// **'Clinical Assessment Indicators'**
  String get rulesFired;

  /// No description provided for @strokeTriageTitle.
  ///
  /// In en, this message translates to:
  /// **'Stroke F.A.S.T. Assessment'**
  String get strokeTriageTitle;

  /// No description provided for @strokeTriageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Face, Arm, Speech, Time — Rapid triage protocol'**
  String get strokeTriageSubtitle;

  /// No description provided for @selfMode.
  ///
  /// In en, this message translates to:
  /// **'Self-Assessment Mode'**
  String get selfMode;

  /// No description provided for @faceTestTitle.
  ///
  /// In en, this message translates to:
  /// **'F — Face Drooping'**
  String get faceTestTitle;

  /// No description provided for @faceTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask the person to smile. Does one side of the face droop or look uneven?'**
  String get faceTestDesc;

  /// No description provided for @armTestTitle.
  ///
  /// In en, this message translates to:
  /// **'A — Arm Weakness'**
  String get armTestTitle;

  /// No description provided for @armTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask the person to raise both arms. Does one arm drift downward or feel numb?'**
  String get armTestDesc;

  /// No description provided for @speechTestTitle.
  ///
  /// In en, this message translates to:
  /// **'S — Speech Difficulty'**
  String get speechTestTitle;

  /// No description provided for @speechTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Ask the person to repeat a simple sentence. Is their speech slurred, strange, or unable to speak?'**
  String get speechTestDesc;

  /// No description provided for @timeTestTitle.
  ///
  /// In en, this message translates to:
  /// **'T — Time of Onset'**
  String get timeTestTitle;

  /// No description provided for @timeTestDesc.
  ///
  /// In en, this message translates to:
  /// **'Time is Brain! Note the exact time symptoms were first observed.'**
  String get timeTestDesc;

  /// No description provided for @strokePositiveAlert.
  ///
  /// In en, this message translates to:
  /// **'CRITICAL STROKE RISK IDENTIFIED'**
  String get strokePositiveAlert;

  /// No description provided for @strokePositiveDesc.
  ///
  /// In en, this message translates to:
  /// **'One or more positive signs of acute stroke detected. Every minute lost is brain tissue lost. Call emergency services immediately.'**
  String get strokePositiveDesc;

  /// No description provided for @strokeNegativeNotice.
  ///
  /// In en, this message translates to:
  /// **'No primary FAST signs reported. If sudden weakness, severe headache, or confusion develops, seek emergency care immediately.'**
  String get strokeNegativeNotice;

  /// No description provided for @dispatchStrokeSos.
  ///
  /// In en, this message translates to:
  /// **'Dispatch Stroke SOS Alert'**
  String get dispatchStrokeSos;

  /// No description provided for @onsetTime.
  ///
  /// In en, this message translates to:
  /// **'Symptom Onset Time'**
  String get onsetTime;

  /// No description provided for @selectOnsetTime.
  ///
  /// In en, this message translates to:
  /// **'Select Onset Time'**
  String get selectOnsetTime;

  /// No description provided for @incidentReportTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Safety Incident'**
  String get incidentReportTitle;

  /// No description provided for @incidentReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Confidential report for harassment, stalking, or safety threats'**
  String get incidentReportSubtitle;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Incident Category'**
  String get category;

  /// No description provided for @categoryHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment'**
  String get categoryHarassment;

  /// No description provided for @categoryStalking.
  ///
  /// In en, this message translates to:
  /// **'Stalking / Followed'**
  String get categoryStalking;

  /// No description provided for @categoryThreat.
  ///
  /// In en, this message translates to:
  /// **'Physical Threat'**
  String get categoryThreat;

  /// No description provided for @categorySuspicious.
  ///
  /// In en, this message translates to:
  /// **'Suspicious Activity'**
  String get categorySuspicious;

  /// No description provided for @incidentDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened'**
  String get incidentDescription;

  /// No description provided for @incidentDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Provide date, location details, context, or physical description...'**
  String get incidentDescriptionHint;

  /// No description provided for @attachLocation.
  ///
  /// In en, this message translates to:
  /// **'Attach Current GPS Coordinates'**
  String get attachLocation;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Incident Report'**
  String get submitReport;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Incident report submitted successfully'**
  String get reportSubmitted;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Incident Reports'**
  String get myReports;

  /// No description provided for @emergencyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency History'**
  String get emergencyHistoryTitle;

  /// No description provided for @noHistory.
  ///
  /// In en, this message translates to:
  /// **'No emergency cases recorded yet.'**
  String get noHistory;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterSafety.
  ///
  /// In en, this message translates to:
  /// **'Safety'**
  String get filterSafety;

  /// No description provided for @filterCardiac.
  ///
  /// In en, this message translates to:
  /// **'Cardiac'**
  String get filterCardiac;

  /// No description provided for @filterStroke.
  ///
  /// In en, this message translates to:
  /// **'Stroke'**
  String get filterStroke;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @caseDetails.
  ///
  /// In en, this message translates to:
  /// **'Emergency Case Details'**
  String get caseDetails;

  /// No description provided for @hospitalDirectoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency Hospitals'**
  String get hospitalDirectoryTitle;

  /// No description provided for @hospitalDirectorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Nearby emergency facilities with specialized cardiac & stroke care'**
  String get hospitalDirectorySubtitle;

  /// No description provided for @searchHospitalsHint.
  ///
  /// In en, this message translates to:
  /// **'Search by hospital name or area...'**
  String get searchHospitalsHint;

  /// No description provided for @filter24x7.
  ///
  /// In en, this message translates to:
  /// **'24/7 Emergency'**
  String get filter24x7;

  /// No description provided for @filterCathLab.
  ///
  /// In en, this message translates to:
  /// **'Cardiac (Cath Lab)'**
  String get filterCathLab;

  /// No description provided for @filterStrokeCenter.
  ///
  /// In en, this message translates to:
  /// **'Stroke Care'**
  String get filterStrokeCenter;

  /// No description provided for @filterICU.
  ///
  /// In en, this message translates to:
  /// **'ICU Available'**
  String get filterICU;

  /// No description provided for @callHotline.
  ///
  /// In en, this message translates to:
  /// **'Call Hotline'**
  String get callHotline;

  /// No description provided for @getDirections.
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get getDirections;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{dist} km away'**
  String distanceKm(String dist);

  /// No description provided for @ambulanceRequestTitle.
  ///
  /// In en, this message translates to:
  /// **'Request Emergency Ambulance'**
  String get ambulanceRequestTitle;

  /// No description provided for @ambulanceRequestSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Emergency ambulance dispatch with live timeline tracking'**
  String get ambulanceRequestSubtitle;

  /// No description provided for @ambulanceType.
  ///
  /// In en, this message translates to:
  /// **'Ambulance Type'**
  String get ambulanceType;

  /// No description provided for @ambulanceBLS.
  ///
  /// In en, this message translates to:
  /// **'Basic Life Support (BLS)'**
  String get ambulanceBLS;

  /// No description provided for @ambulanceALS.
  ///
  /// In en, this message translates to:
  /// **'Advanced Cardiac Life Support (ALS)'**
  String get ambulanceALS;

  /// No description provided for @ambulanceBLSDesc.
  ///
  /// In en, this message translates to:
  /// **'Oxygen support, stretcher, emergency first-aid equipment'**
  String get ambulanceBLSDesc;

  /// No description provided for @ambulanceALSDesc.
  ///
  /// In en, this message translates to:
  /// **'Cardiac monitor, defibrillator, ventilator, paramedic onboard'**
  String get ambulanceALSDesc;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup Location'**
  String get pickupLocation;

  /// No description provided for @destinationHospital.
  ///
  /// In en, this message translates to:
  /// **'Destination Hospital (Optional)'**
  String get destinationHospital;

  /// No description provided for @requestAmbulanceNow.
  ///
  /// In en, this message translates to:
  /// **'Request Ambulance Dispatch'**
  String get requestAmbulanceNow;

  /// No description provided for @statusRequested.
  ///
  /// In en, this message translates to:
  /// **'Requested'**
  String get statusRequested;

  /// No description provided for @statusDispatched.
  ///
  /// In en, this message translates to:
  /// **'Dispatched'**
  String get statusDispatched;

  /// No description provided for @statusEnRoute.
  ///
  /// In en, this message translates to:
  /// **'On The Way'**
  String get statusEnRoute;

  /// No description provided for @statusArrived.
  ///
  /// In en, this message translates to:
  /// **'Arrived On Scene'**
  String get statusArrived;

  /// No description provided for @driverAssigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned Driver'**
  String get driverAssigned;

  /// No description provided for @callDriver.
  ///
  /// In en, this message translates to:
  /// **'Call Driver'**
  String get callDriver;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel Request'**
  String get cancelBooking;

  /// No description provided for @governmentAmbulance999.
  ///
  /// In en, this message translates to:
  /// **'Call 999 Ambulance'**
  String get governmentAmbulance999;

  /// No description provided for @redCrescentAmbulance.
  ///
  /// In en, this message translates to:
  /// **'Red Crescent (02-9330188)'**
  String get redCrescentAmbulance;

  /// No description provided for @safetyTimerTitle.
  ///
  /// In en, this message translates to:
  /// **'Safety Timer (Walk With Me)'**
  String get safetyTimerTitle;

  /// No description provided for @safetyTimerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set an arrival countdown. If unconfirmed, SOS triggers automatically.'**
  String get safetyTimerSubtitle;

  /// No description provided for @timerPresets.
  ///
  /// In en, this message translates to:
  /// **'Select Commute Window'**
  String get timerPresets;

  /// No description provided for @timerMin5.
  ///
  /// In en, this message translates to:
  /// **'5 min'**
  String get timerMin5;

  /// No description provided for @timerMin15.
  ///
  /// In en, this message translates to:
  /// **'15 min'**
  String get timerMin15;

  /// No description provided for @timerMin30.
  ///
  /// In en, this message translates to:
  /// **'30 min'**
  String get timerMin30;

  /// No description provided for @timerMin60.
  ///
  /// In en, this message translates to:
  /// **'60 min'**
  String get timerMin60;

  /// No description provided for @arrivedSafely.
  ///
  /// In en, this message translates to:
  /// **'I Arrived Safely'**
  String get arrivedSafely;

  /// No description provided for @triggerSosNow.
  ///
  /// In en, this message translates to:
  /// **'Emergency! Trigger SOS Now'**
  String get triggerSosNow;

  /// No description provided for @timerRunning.
  ///
  /// In en, this message translates to:
  /// **'Safety timer active'**
  String get timerRunning;

  /// No description provided for @timerWarning.
  ///
  /// In en, this message translates to:
  /// **'Time almost up! Confirm safety or SOS will alert contacts.'**
  String get timerWarning;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings & Preferences'**
  String get settingsTitle;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language / ভাষা'**
  String get languageSetting;

  /// No description provided for @appearanceSetting.
  ///
  /// In en, this message translates to:
  /// **'Theme Appearance'**
  String get appearanceSetting;

  /// No description provided for @countdownDuration.
  ///
  /// In en, this message translates to:
  /// **'SOS Cancel Countdown'**
  String get countdownDuration;

  /// No description provided for @secondsCount.
  ///
  /// In en, this message translates to:
  /// **'{sec} seconds'**
  String secondsCount(int sec);

  /// No description provided for @medicalIdShortcut.
  ///
  /// In en, this message translates to:
  /// **'Quick Access Medical ID'**
  String get medicalIdShortcut;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About SafeLife & Ethics'**
  String get aboutApp;

  /// No description provided for @adminPortalTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin Analytics Portal'**
  String get adminPortalTitle;

  /// No description provided for @responderPanelTitle.
  ///
  /// In en, this message translates to:
  /// **'Responder & Hospital Command Panel'**
  String get responderPanelTitle;

  /// No description provided for @totalRegisteredUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Registered Users'**
  String get totalRegisteredUsers;

  /// No description provided for @activeEmergenciesCount.
  ///
  /// In en, this message translates to:
  /// **'Active Emergencies'**
  String get activeEmergenciesCount;

  /// No description provided for @resolvedEmergenciesCount.
  ///
  /// In en, this message translates to:
  /// **'Resolved Cases'**
  String get resolvedEmergenciesCount;

  /// No description provided for @avgResponseLatency.
  ///
  /// In en, this message translates to:
  /// **'Avg Alert Latency'**
  String get avgResponseLatency;

  /// No description provided for @verifiedContactsCoverage.
  ///
  /// In en, this message translates to:
  /// **'Verified Contacts Coverage'**
  String get verifiedContactsCoverage;

  /// No description provided for @emergencyTypeBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Emergency Type Distribution'**
  String get emergencyTypeBreakdown;

  /// No description provided for @triageSeverityBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Triage Risk Breakdown'**
  String get triageSeverityBreakdown;

  /// No description provided for @incidentHotspots.
  ///
  /// In en, this message translates to:
  /// **'Geographic Incident Hotspots (Dhaka)'**
  String get incidentHotspots;

  /// No description provided for @thesisEvaluationSummary.
  ///
  /// In en, this message translates to:
  /// **'Thesis Evaluation Metrics'**
  String get thesisEvaluationSummary;

  /// No description provided for @exportMetrics.
  ///
  /// In en, this message translates to:
  /// **'Export Evaluation Data'**
  String get exportMetrics;

  /// No description provided for @incomingDispatches.
  ///
  /// In en, this message translates to:
  /// **'Incoming Dispatches'**
  String get incomingDispatches;

  /// No description provided for @noActiveEmergencies.
  ///
  /// In en, this message translates to:
  /// **'No active emergencies in triage queue'**
  String get noActiveEmergencies;

  /// No description provided for @acceptAndDispatch.
  ///
  /// In en, this message translates to:
  /// **'Accept & Dispatch'**
  String get acceptAndDispatch;

  /// No description provided for @markOnScene.
  ///
  /// In en, this message translates to:
  /// **'Mark On-Scene'**
  String get markOnScene;

  /// No description provided for @resolveCaseAction.
  ///
  /// In en, this message translates to:
  /// **'Resolve Emergency Case'**
  String get resolveCaseAction;

  /// No description provided for @patientMedicalDetails.
  ///
  /// In en, this message translates to:
  /// **'Patient Medical Details'**
  String get patientMedicalDetails;

  /// No description provided for @triageIndicators.
  ///
  /// In en, this message translates to:
  /// **'Triage Indicators'**
  String get triageIndicators;

  /// No description provided for @assignedResponder.
  ///
  /// In en, this message translates to:
  /// **'Assigned Responder Unit'**
  String get assignedResponder;

  /// No description provided for @responderNotes.
  ///
  /// In en, this message translates to:
  /// **'Clinical / Responder Notes'**
  String get responderNotes;

  /// No description provided for @addNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Enter notes or hospital admission updates...'**
  String get addNoteHint;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
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
