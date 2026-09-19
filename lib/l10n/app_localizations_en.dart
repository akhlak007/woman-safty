// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'SafeLife';

  @override
  String get appTagline => 'Unified Smart Emergency Response Platform';

  @override
  String get emergency => 'Emergency';

  @override
  String get sos => 'SOS';

  @override
  String get cancel => 'Cancel';

  @override
  String get imSafe => 'I\'m Safe';

  @override
  String get countdownTitle => 'Emergency Alert Triggering';

  @override
  String countdownWarning(int seconds) {
    return 'Alerting emergency contacts in $seconds seconds';
  }

  @override
  String get holdToCancel => 'Tap to Cancel';

  @override
  String get womenSafety => 'Women Safety';

  @override
  String get cardiacEmergency => 'Heart Attack / Cardiac';

  @override
  String get strokeEmergency => 'Stroke (FAST)';

  @override
  String get medicalId => 'Medical ID';

  @override
  String get emergencyContacts => 'Emergency Contacts';

  @override
  String get incidentReport => 'Incident Report';

  @override
  String get nearbyHospitals => 'Nearby Hospitals';

  @override
  String get call999 => 'Call 999 (National Emergency)';

  @override
  String get call109 => 'Call 109 (Women & Children Helpline)';

  @override
  String get call333 => 'Call 333 (National Info Helpline)';

  @override
  String get bystanderMode => 'Bystander Mode (Assessing Someone Else)';

  @override
  String get lowRisk => 'Low Risk';

  @override
  String get mediumRisk => 'Medium Risk';

  @override
  String get highRisk => 'High Risk';

  @override
  String get criticalRisk => 'Critical Emergency';

  @override
  String get locationSharingActive => 'Live Location Sharing Active';

  @override
  String get stopSharing => 'Stop Sharing';

  @override
  String get disclaimer =>
      'SafeLife provides emergency response assistance and symptom-based triage. It is not a diagnostic tool or a substitute for professional medical care.';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get dontHaveAccount => 'Don\'t have an account? Register';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Create Account';

  @override
  String get signOut => 'Sign Out';

  @override
  String get logoutConfirmTitle => 'Sign Out';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to sign out of SafeLife?';

  @override
  String get onboardingWelcome => 'Welcome to SafeLife';

  @override
  String get onboardingSubtitle =>
      'One tap to safety threats and critical medical triage';

  @override
  String get onboardingStep1Title => 'Unified Smart Emergency Engine';

  @override
  String get onboardingStep1Desc =>
      'Instant emergency alerts for women\'s safety risks, acute cardiac events, and stroke emergencies.';

  @override
  String get onboardingStep2Title => 'Consent-Based Live Tracking';

  @override
  String get onboardingStep2Desc =>
      'Your verified contacts receive real-time location and SMS fallback when an emergency is active.';

  @override
  String get onboardingStep3Title => 'Ethical & Medical Notice';

  @override
  String get onboardingStep3Desc =>
      'SafeLife assists and triages based on clinical guidelines. Always contact national emergency services (999) for immediate acute care.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get acceptAndContinue => 'I Understand & Accept';

  @override
  String get myProfile => 'My Profile';

  @override
  String get medicalProfile => 'Medical Profile';

  @override
  String get bloodGroup => 'Blood Group';

  @override
  String get selectBloodGroup => 'Select Blood Group';

  @override
  String get chronicConditions => 'Chronic Medical Conditions';

  @override
  String get medications => 'Current Medications';

  @override
  String get allergies => 'Known Allergies';

  @override
  String get saveProfile => 'Save Profile';

  @override
  String get profileUpdated => 'Profile updated successfully';

  @override
  String get addMedication => 'Add Medication';

  @override
  String get addAllergy => 'Add Allergy';

  @override
  String get addCondition => 'Add Condition';

  @override
  String get myContacts => 'Emergency Contacts';

  @override
  String get addContact => 'Add Contact';

  @override
  String get editContact => 'Edit Contact';

  @override
  String get contactName => 'Contact Name';

  @override
  String get contactPhone => 'Phone Number';

  @override
  String get relation => 'Relationship';

  @override
  String get priority => 'Priority';

  @override
  String get verifiedConsent => 'Verified (Consent Granted)';

  @override
  String get pendingConsent => 'Pending Consent';

  @override
  String get requestConsent => 'Send Consent Request';

  @override
  String get consentRequested => 'Verification request sent to contact';

  @override
  String get minContactsNotice =>
      'We recommend adding at least 2 trusted emergency contacts.';

  @override
  String get deleteContact => 'Delete Contact';

  @override
  String get deleteContactConfirm =>
      'Are you sure you want to remove this emergency contact?';

  @override
  String get save => 'Save';

  @override
  String get close => 'Close';

  @override
  String get activeEmergencyTitle => 'ACTIVE EMERGENCY IN PROGRESS';

  @override
  String get activeEmergencyDesc =>
      'Alert dispatched! Continuous live location sharing is active with verified contacts.';

  @override
  String get imSafeResolve => 'I\'m Safe / Resolve';

  @override
  String get resolveDialogTitle => 'Resolve Emergency';

  @override
  String get resolveDialogMessage =>
      'Confirm if you are currently safe. This will immediately stop live location streaming and notify your contacts.';

  @override
  String get markAsFalseAlarm => 'False Alarm / Test';

  @override
  String get markAsResolved => 'I Am Safe (Resolved)';

  @override
  String get openInGoogleMaps => 'Open in Google Maps';

  @override
  String get liveLocation => 'Live GPS Location';

  @override
  String accuracy(int meters) {
    return 'Accuracy: ±${meters}m';
  }

  @override
  String get smsFallbackSent => 'SMS fallback prepared';

  @override
  String get sendSmsToContacts => 'Send Direct SMS Fallback';

  @override
  String get emergencyType => 'Emergency Type';

  @override
  String get alertedContacts => 'Alerted Emergency Contacts';

  @override
  String get callPolice999 => 'Call 999 (National Helpline)';

  @override
  String get cardiacTriageTitle => 'Cardiac Risk Assessment';

  @override
  String get cardiacTriageSubtitle =>
      'Symptom-based triage & pre-hospital clinical guidance';

  @override
  String get chestPainQuestion =>
      'Are you experiencing chest pain, tightness, or heavy pressure?';

  @override
  String get painRadiationQuestion =>
      'Does the pain radiate to your left arm, jaw, neck, or back?';

  @override
  String get shortnessOfBreathQuestion =>
      'Are you experiencing severe shortness of breath or difficulty breathing?';

  @override
  String get sweatingQuestion =>
      'Are you experiencing cold sweats (diaphoresis)?';

  @override
  String get nauseaQuestion =>
      'Are you feeling nauseous, lightheaded, or dizzy?';

  @override
  String get durationQuestion =>
      'Have symptoms persisted for longer than 10 minutes?';

  @override
  String get calculateRisk => 'Assess Risk';

  @override
  String get cardiacAssessmentResult => 'Cardiac Triage Assessment';

  @override
  String get firstAidGuidance => 'First-Aid Guidance';

  @override
  String get aspirinGuidance =>
      'If available, chew 300mg soluble aspirin immediately, unless you are allergic, have an active bleeding condition, or stroke is suspected.';

  @override
  String get restGuidance =>
      'Sit down immediately in a comfortable position, rest, and avoid all physical exertion.';

  @override
  String get dispatchCardiacSos => 'Dispatch Cardiac SOS Alert';

  @override
  String get rulesFired => 'Clinical Assessment Indicators';

  @override
  String get strokeTriageTitle => 'Stroke F.A.S.T. Assessment';

  @override
  String get strokeTriageSubtitle =>
      'Face, Arm, Speech, Time — Rapid triage protocol';

  @override
  String get selfMode => 'Self-Assessment Mode';

  @override
  String get faceTestTitle => 'F — Face Drooping';

  @override
  String get faceTestDesc =>
      'Ask the person to smile. Does one side of the face droop or look uneven?';

  @override
  String get armTestTitle => 'A — Arm Weakness';

  @override
  String get armTestDesc =>
      'Ask the person to raise both arms. Does one arm drift downward or feel numb?';

  @override
  String get speechTestTitle => 'S — Speech Difficulty';

  @override
  String get speechTestDesc =>
      'Ask the person to repeat a simple sentence. Is their speech slurred, strange, or unable to speak?';

  @override
  String get timeTestTitle => 'T — Time of Onset';

  @override
  String get timeTestDesc =>
      'Time is Brain! Note the exact time symptoms were first observed.';

  @override
  String get strokePositiveAlert => 'CRITICAL STROKE RISK IDENTIFIED';

  @override
  String get strokePositiveDesc =>
      'One or more positive signs of acute stroke detected. Every minute lost is brain tissue lost. Call emergency services immediately.';

  @override
  String get strokeNegativeNotice =>
      'No primary FAST signs reported. If sudden weakness, severe headache, or confusion develops, seek emergency care immediately.';

  @override
  String get dispatchStrokeSos => 'Dispatch Stroke SOS Alert';

  @override
  String get onsetTime => 'Symptom Onset Time';

  @override
  String get selectOnsetTime => 'Select Onset Time';

  @override
  String get incidentReportTitle => 'Report Safety Incident';

  @override
  String get incidentReportSubtitle =>
      'Confidential report for harassment, stalking, or safety threats';

  @override
  String get category => 'Incident Category';

  @override
  String get categoryHarassment => 'Harassment';

  @override
  String get categoryStalking => 'Stalking / Followed';

  @override
  String get categoryThreat => 'Physical Threat';

  @override
  String get categorySuspicious => 'Suspicious Activity';

  @override
  String get incidentDescription => 'Describe what happened';

  @override
  String get incidentDescriptionHint =>
      'Provide date, location details, context, or physical description...';

  @override
  String get attachLocation => 'Attach Current GPS Coordinates';

  @override
  String get submitReport => 'Submit Incident Report';

  @override
  String get reportSubmitted => 'Incident report submitted successfully';

  @override
  String get myReports => 'My Incident Reports';

  @override
  String get emergencyHistoryTitle => 'Emergency History';

  @override
  String get noHistory => 'No emergency cases recorded yet.';

  @override
  String get filterAll => 'All';

  @override
  String get filterSafety => 'Safety';

  @override
  String get filterCardiac => 'Cardiac';

  @override
  String get filterStroke => 'Stroke';

  @override
  String get viewDetails => 'View Details';

  @override
  String get caseDetails => 'Emergency Case Details';

  @override
  String get hospitalDirectoryTitle => 'Emergency Hospitals';

  @override
  String get hospitalDirectorySubtitle =>
      'Nearby emergency facilities with specialized cardiac & stroke care';

  @override
  String get searchHospitalsHint => 'Search by hospital name or area...';

  @override
  String get filter24x7 => '24/7 Emergency';

  @override
  String get filterCathLab => 'Cardiac (Cath Lab)';

  @override
  String get filterStrokeCenter => 'Stroke Care';

  @override
  String get filterICU => 'ICU Available';

  @override
  String get callHotline => 'Call Hotline';

  @override
  String get getDirections => 'Directions';

  @override
  String distanceKm(String dist) {
    return '$dist km away';
  }

  @override
  String get ambulanceRequestTitle => 'Request Emergency Ambulance';

  @override
  String get ambulanceRequestSubtitle =>
      'Emergency ambulance dispatch with live timeline tracking';

  @override
  String get ambulanceType => 'Ambulance Type';

  @override
  String get ambulanceBLS => 'Basic Life Support (BLS)';

  @override
  String get ambulanceALS => 'Advanced Cardiac Life Support (ALS)';

  @override
  String get ambulanceBLSDesc =>
      'Oxygen support, stretcher, emergency first-aid equipment';

  @override
  String get ambulanceALSDesc =>
      'Cardiac monitor, defibrillator, ventilator, paramedic onboard';

  @override
  String get pickupLocation => 'Pickup Location';

  @override
  String get destinationHospital => 'Destination Hospital (Optional)';

  @override
  String get requestAmbulanceNow => 'Request Ambulance Dispatch';

  @override
  String get statusRequested => 'Requested';

  @override
  String get statusDispatched => 'Dispatched';

  @override
  String get statusEnRoute => 'On The Way';

  @override
  String get statusArrived => 'Arrived On Scene';

  @override
  String get driverAssigned => 'Assigned Driver';

  @override
  String get callDriver => 'Call Driver';

  @override
  String get cancelBooking => 'Cancel Request';

  @override
  String get governmentAmbulance999 => 'Call 999 Ambulance';

  @override
  String get redCrescentAmbulance => 'Red Crescent (02-9330188)';

  @override
  String get safetyTimerTitle => 'Safety Timer (Walk With Me)';

  @override
  String get safetyTimerSubtitle =>
      'Set an arrival countdown. If unconfirmed, SOS triggers automatically.';

  @override
  String get timerPresets => 'Select Commute Window';

  @override
  String get timerMin5 => '5 min';

  @override
  String get timerMin15 => '15 min';

  @override
  String get timerMin30 => '30 min';

  @override
  String get timerMin60 => '60 min';

  @override
  String get arrivedSafely => 'I Arrived Safely';

  @override
  String get triggerSosNow => 'Emergency! Trigger SOS Now';

  @override
  String get timerRunning => 'Safety timer active';

  @override
  String get timerWarning =>
      'Time almost up! Confirm safety or SOS will alert contacts.';

  @override
  String get settingsTitle => 'Settings & Preferences';

  @override
  String get languageSetting => 'Language / ভাষা';

  @override
  String get appearanceSetting => 'Theme Appearance';

  @override
  String get countdownDuration => 'SOS Cancel Countdown';

  @override
  String secondsCount(int sec) {
    return '$sec seconds';
  }

  @override
  String get medicalIdShortcut => 'Quick Access Medical ID';

  @override
  String get aboutApp => 'About SafeLife & Ethics';

  @override
  String get adminPortalTitle => 'Admin Analytics Portal';

  @override
  String get responderPanelTitle => 'Responder & Hospital Command Panel';

  @override
  String get totalRegisteredUsers => 'Total Registered Users';

  @override
  String get activeEmergenciesCount => 'Active Emergencies';

  @override
  String get resolvedEmergenciesCount => 'Resolved Cases';

  @override
  String get avgResponseLatency => 'Avg Alert Latency';

  @override
  String get verifiedContactsCoverage => 'Verified Contacts Coverage';

  @override
  String get emergencyTypeBreakdown => 'Emergency Type Distribution';

  @override
  String get triageSeverityBreakdown => 'Triage Risk Breakdown';

  @override
  String get incidentHotspots => 'Geographic Incident Hotspots (Dhaka)';

  @override
  String get thesisEvaluationSummary => 'Thesis Evaluation Metrics';

  @override
  String get exportMetrics => 'Export Evaluation Data';

  @override
  String get incomingDispatches => 'Incoming Dispatches';

  @override
  String get noActiveEmergencies => 'No active emergencies in triage queue';

  @override
  String get acceptAndDispatch => 'Accept & Dispatch';

  @override
  String get markOnScene => 'Mark On-Scene';

  @override
  String get resolveCaseAction => 'Resolve Emergency Case';

  @override
  String get patientMedicalDetails => 'Patient Medical Details';

  @override
  String get triageIndicators => 'Triage Indicators';

  @override
  String get assignedResponder => 'Assigned Responder Unit';

  @override
  String get responderNotes => 'Clinical / Responder Notes';

  @override
  String get addNoteHint => 'Enter notes or hospital admission updates...';
}
