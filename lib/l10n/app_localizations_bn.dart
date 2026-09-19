// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'সেফলাইফ';

  @override
  String get appTagline => 'সমন্বিত স্মার্ট জরুরি সহায়তা প্ল্যাটফর্ম';

  @override
  String get emergency => 'জরুরি অবস্থা';

  @override
  String get sos => 'জরুরি এসওএস';

  @override
  String get cancel => 'বাতিল';

  @override
  String get imSafe => 'আমি নিরাপদ';

  @override
  String get countdownTitle => 'জরুরি সতর্কতা পাঠানো হচ্ছে';

  @override
  String countdownWarning(int seconds) {
    return '$seconds সেকেন্ডের মধ্যে জরুরি পরিচিতিদের জানানো হবে';
  }

  @override
  String get holdToCancel => 'বাতিল করতে ট্যাপ করুন';

  @override
  String get womenSafety => 'নারী নিরাপত্তা';

  @override
  String get cardiacEmergency => 'হার্ট অ্যাটাক / কার্ডিয়াক';

  @override
  String get strokeEmergency => 'স্ট্রোক (FAST)';

  @override
  String get medicalId => 'মেডিকেল আইডি';

  @override
  String get emergencyContacts => 'জরুরি পরিচিতি';

  @override
  String get incidentReport => 'ঘটনার রিপোর্ট';

  @override
  String get nearbyHospitals => 'নিকটবর্তী হাসপাতাল';

  @override
  String get call999 => '৯৯৯ এ কল করুন (জাতীয় জরুরি সেবা)';

  @override
  String get call109 => '১০৯ এ কল করুন (নারী ও শিশু হেল্পলাইন)';

  @override
  String get call333 => '৩৩৩ এ কল করুন (জাতীয় তথ্য ও সেবা)';

  @override
  String get bystanderMode => 'প্রত্যক্ষদর্শী মোড (অন্য কাউকে পরীক্ষা করছেন)';

  @override
  String get lowRisk => 'স্বল্প ঝুঁকি';

  @override
  String get mediumRisk => 'মাঝারি ঝুঁকি';

  @override
  String get highRisk => 'উচ্চ ঝুঁকি';

  @override
  String get criticalRisk => 'সংকটাপন্ন জরুরি অবস্থা';

  @override
  String get locationSharingActive => 'লাইভ লোকেশন শেয়ারিং চালু আছে';

  @override
  String get stopSharing => 'শেয়ারিং বন্ধ করুন';

  @override
  String get disclaimer =>
      'সেফলাইফ একটি জরুরি সহায়তা ও প্রাথমিক ট্রায়াজ টুল, এটি কোনো রোগ নির্ণয়কারী বা পেশাদার চিকিৎসা সেবার বিকল্প নয়।';

  @override
  String get login => 'লগইন';

  @override
  String get register => 'নিবন্ধন করুন';

  @override
  String get email => 'ইমেইল ঠিকানা';

  @override
  String get password => 'পাসওয়ার্ড';

  @override
  String get confirmPassword => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get fullName => 'পূর্ণ নাম';

  @override
  String get phoneNumber => 'মোবাইল নম্বর';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get sendResetLink => 'রিসেট লিংক পাঠান';

  @override
  String get alreadyHaveAccount => 'ইতিমধ্যে একাউন্ট আছে? লগইন করুন';

  @override
  String get dontHaveAccount => 'একাউন্ট নেই? নিবন্ধন করুন';

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get signUp => 'একাউন্ট তৈরি করুন';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get logoutConfirmTitle => 'সাইন আউট';

  @override
  String get logoutConfirmMessage => 'আপনি কি সেফলাইফ থেকে সাইন আউট করতে চান?';

  @override
  String get onboardingWelcome => 'সেফলাইফে স্বাগতম';

  @override
  String get onboardingSubtitle =>
      'নিরাপত্তা হুমকি এবং জরুরি স্বাস্থ্য সহায়তায় এক ট্যাপেই সেবা';

  @override
  String get onboardingStep1Title => 'সমন্বিত জরুরি অ্যালার্ট ইঞ্জিন';

  @override
  String get onboardingStep1Desc =>
      'নারী নিরাপত্তা হুমকি, তীব্র হার্ট অ্যাটাক এবং স্ট্রোকের দ্রুততম জরুরি প্রতিক্রিয়া।';

  @override
  String get onboardingStep2Title => 'সম্মতিভিত্তিক লাইভ ট্র্যাকিং';

  @override
  String get onboardingStep2Desc =>
      'জরুরি অবস্থায় আপনার যাচাইকৃত পরিচিতিরা রিয়েল-টাইম লোকেশন ও এসএমএস অ্যালার্ট পাবেন।';

  @override
  String get onboardingStep3Title => 'নীতিমালা ও চিকিৎসা বিষয়ক তথ্য';

  @override
  String get onboardingStep3Desc =>
      'সেফলাইফ ক্লিনিক্যাল নির্দেশিকা ভিত্তিক সহায়তা প্রদান করে। তাত্ক্ষণিক সংকটে সর্বদা জাতীয় জরুরি সেবা ৯৯৯ এ যোগাযোগ করুন।';

  @override
  String get getStarted => 'শুরু করুন';

  @override
  String get acceptAndContinue => 'আমি পড়েছি ও সম্মত';

  @override
  String get myProfile => 'আমার প্রোফাইল';

  @override
  String get medicalProfile => 'মেডিকেল প্রোফাইল';

  @override
  String get bloodGroup => 'রক্তের গ্রুপ';

  @override
  String get selectBloodGroup => 'রক্তের গ্রুপ নির্বাচন করুন';

  @override
  String get chronicConditions => 'দীর্ঘস্থায়ী শারীরিক সমস্যা';

  @override
  String get medications => 'নিয়মিত ঔষধসমূহ';

  @override
  String get allergies => 'পরিচিত এলার্জি';

  @override
  String get saveProfile => 'প্রোফাইল সংরক্ষণ করুন';

  @override
  String get profileUpdated => 'প্রোফাইল সফলভাবে সংরক্ষিত হয়েছে';

  @override
  String get addMedication => 'ঔষধ যোগ করুন';

  @override
  String get addAllergy => 'এলার্জি যোগ করুন';

  @override
  String get addCondition => 'সমস্যা যোগ করুন';

  @override
  String get myContacts => 'জরুরি পরিচিতি তালিকা';

  @override
  String get addContact => 'পরিচিতি যোগ করুন';

  @override
  String get editContact => 'পরিচিতি সম্পাদনা';

  @override
  String get contactName => 'পরিচিতির নাম';

  @override
  String get contactPhone => 'ফোন নম্বর';

  @override
  String get relation => 'সম্পর্ক';

  @override
  String get priority => 'অগ্রাধিকার';

  @override
  String get verifiedConsent => 'যাচাইকৃত (সম্মতি প্রাপ্ত)';

  @override
  String get pendingConsent => 'সম্মতির অপেক্ষায়';

  @override
  String get requestConsent => 'সম্মতির অনুরোধ পাঠান';

  @override
  String get consentRequested => 'পরিচিতির কাছে সম্মতির অনুরোধ পাঠানো হয়েছে';

  @override
  String get minContactsNotice =>
      'আমরা অন্তত ২টি বিশ্বস্ত পরিচিতি যোগ করার সুপারিশ করছি।';

  @override
  String get deleteContact => 'পরিচিতি মুছুন';

  @override
  String get deleteContactConfirm =>
      'আপনি কি এই জরুরি পরিচিতিটি মুছে ফেলতে চান?';

  @override
  String get save => 'সংরক্ষণ';

  @override
  String get close => 'বন্ধ করুন';

  @override
  String get activeEmergencyTitle => 'জরুরি অবস্থা সক্রিয় রয়েছে';

  @override
  String get activeEmergencyDesc =>
      'সতর্কতা পাঠানো হয়েছে! যাচাইকৃত পরিচিতিদের সাথে রিয়েল-টাইম জিপিএস লোকেশন শেয়ার হচ্ছে।';

  @override
  String get imSafeResolve => 'আমি নিরাপদ / সমাপ্ত করুন';

  @override
  String get resolveDialogTitle => 'জরুরি অবস্থা সমাপ্ত করুন';

  @override
  String get resolveDialogMessage =>
      'আপনি এখন নিরাপদ কিনা নিশ্চিত করুন। এটি তাত্ক্ষণিকভাবে লাইভ ট্র্যাকিং বন্ধ করবে এবং পরিচিতিদের জানাবে।';

  @override
  String get markAsFalseAlarm => 'ভুলবশত চাপ পড়েছিল';

  @override
  String get markAsResolved => 'আমি নিরাপদ (সমাধান হয়েছে)';

  @override
  String get openInGoogleMaps => 'গুগল ম্যাপে দেখুন';

  @override
  String get liveLocation => 'লাইভ জিপিএস অবস্থান';

  @override
  String accuracy(int meters) {
    return 'নির্ভুলতা: ±$metersমি.';
  }

  @override
  String get smsFallbackSent => 'এসএমএস ফলব্যাক প্রস্তুত';

  @override
  String get sendSmsToContacts => 'সরাসরি এসএমএস ফলব্যাক পাঠান';

  @override
  String get emergencyType => 'জরুরি ধরন';

  @override
  String get alertedContacts => 'সতর্কতাপ্রাপ্ত পরিচিতিবৃন্দ';

  @override
  String get callPolice999 => '৯৯৯ এ কল করুন (জাতীয় জরুরি সেবা)';

  @override
  String get cardiacTriageTitle => 'হৃদরোগের ঝুঁকি মূল্যায়ন';

  @override
  String get cardiacTriageSubtitle =>
      'উপসর্গ-ভিত্তিক ট্রায়াজ ও প্রাথমিক চিকিৎসা নির্দেশিকা';

  @override
  String get chestPainQuestion =>
      'আপনার কি বুকে তীব্র ব্যথা, টান বা প্রচণ্ড চাপ অনুভূত হচ্ছে?';

  @override
  String get painRadiationQuestion =>
      'ব্যথা কি আপনার বাম বাহু, চোয়াল, ঘাড় বা পিঠের দিকে ছড়িয়ে পড়ছে?';

  @override
  String get shortnessOfBreathQuestion =>
      'আপনার কি প্রচণ্ড শ্বাসকষ্ট বা দম নিতে সমস্যা হচ্ছে?';

  @override
  String get sweatingQuestion => 'আপনার কি অস্বাভাবিক ঠান্ডা ঘাম হচ্ছে?';

  @override
  String get nauseaQuestion =>
      'আপনার কি বমি বমি ভাব বা মাথা ঘোরা অনুভূত হচ্ছে?';

  @override
  String get durationQuestion => 'উপসর্গগুলো কি ১০ মিনিটের বেশি সময় ধরে চলছে?';

  @override
  String get calculateRisk => 'ঝুঁকি যাচাই করুন';

  @override
  String get cardiacAssessmentResult => 'হৃদরোগের ট্রায়াজ মূল্যায়ন';

  @override
  String get firstAidGuidance => 'প্রাথমিক চিকিৎসা নির্দেশনা';

  @override
  String get aspirinGuidance =>
      'সম্ভব হলে দ্রুত ৩০০ মিগ্রা দ্রবণীয় অ্যাসপিরিন চিবিয়ে নিন (যদি এলার্জি না থাকে, রক্তক্ষরণের ঝুঁকি না থাকে এবং স্ট্রোকের লক্ষণ না থাকে)।';

  @override
  String get restGuidance =>
      'দ্রুত একটি আরামদায়ক অবস্থানে বসে বিশ্রাম নিন এবং শারীরিক পরিশ্রম থেকে সম্পূর্ণ বিরত থাকুন।';

  @override
  String get dispatchCardiacSos => 'হৃদরোগ এসওএস সতর্কতা পাঠান';

  @override
  String get rulesFired => 'ক্লিনিক্যাল মূল্যায়নের নির্দেশকসমূহ';

  @override
  String get strokeTriageTitle => 'স্ট্রোক ফাস্ট (F.A.S.T.) মূল্যায়ন';

  @override
  String get strokeTriageSubtitle =>
      'মুখ, হাত, কথা, সময় — দ্রুত স্ট্রোক শনাক্তকরণ';

  @override
  String get selfMode => 'স্বয়ং মূল্যায়ন মোড';

  @override
  String get faceTestTitle => 'F — মুখের অসাড়তা বা বিকৃতি';

  @override
  String get faceTestDesc =>
      'ব্যক্তিকে হাসতে বলুন। মুখের একপাশ কি বাঁকা হয়ে যাচ্ছে বা ঝুলে পড়েছে?';

  @override
  String get armTestTitle => 'A — বাহুর দুর্বলতা';

  @override
  String get armTestDesc =>
      'ব্যক্তিকে দুটি হাত উপরে তুলতে বলুন। একটি হাত কি নিচে নেমে যাচ্ছে বা অবশ লাগছে?';

  @override
  String get speechTestTitle => 'S — কথা বলার সমস্যা';

  @override
  String get speechTestDesc =>
      'ব্যক্তিকে একটি সাধারণ বাক্য বলতে বলুন। কথা কি জড়িয়ে যাচ্ছে বা স্পষ্ট বলতে পারছেন না?';

  @override
  String get timeTestTitle => 'T — উপসর্গ শুরুর সময়';

  @override
  String get timeTestDesc =>
      'সময়ই মস্তিষ্ক রক্ষা করে! উপসর্গ কখন প্রথম দেখা দিয়েছে তা সঠিকভাবে মনে রাখুন।';

  @override
  String get strokePositiveAlert => 'জরুরি স্ট্রোকের ঝুঁকি চিহ্নিত';

  @override
  String get strokePositiveDesc =>
      'স্ট্রোকের এক বা একাধিক স্পষ্ট লক্ষণ পরিলক্ষিত হয়েছে। বিলম্ব না করে অবিলম্বে জরুরি সেবায় যোগাযোগ করুন।';

  @override
  String get strokeNegativeNotice =>
      'প্রাথমিক ফাস্ট পরীক্ষায় স্পষ্ট লক্ষণ পাওয়া যায়নি। তবে হঠাৎ বিভ্রান্তি বা তীব্র মাথাব্যথা থাকলে চিকিৎসকের পরামর্শ নিন।';

  @override
  String get dispatchStrokeSos => 'স্ট্রোক জরুরি এসওএস পাঠান';

  @override
  String get onsetTime => 'লক্ষণ শুরুর সময়';

  @override
  String get selectOnsetTime => 'শুরুর সময় নির্ধারণ করুন';

  @override
  String get incidentReportTitle => 'নিরাপত্তা সংক্রান্ত রিপোর্ট';

  @override
  String get incidentReportSubtitle =>
      'হয়রানি বা নিরাপত্তা হুমকির গোপনীয় অভিযোগ দাখিল';

  @override
  String get category => 'ঘটনার ধরন';

  @override
  String get categoryHarassment => 'হয়রানি';

  @override
  String get categoryStalking => 'পিছু নেওয়া / স্টকিং';

  @override
  String get categoryThreat => 'শারীরিক হুমকি';

  @override
  String get categorySuspicious => 'সন্দেহজনক তৎপরতা';

  @override
  String get incidentDescription => 'কী ঘটেছে বিস্তারিত লিখুন';

  @override
  String get incidentDescriptionHint =>
      'তারিখ, এলাকা, ঘটনার বিবরণ বা ব্যক্তির বর্ণনা লিখুন...';

  @override
  String get attachLocation => 'বর্তমান জিপিএস অবস্থান যুক্ত করুন';

  @override
  String get submitReport => 'রিপোর্ট জমা দিন';

  @override
  String get reportSubmitted => 'রিপোর্ট সফলভাবে সংরক্ষিত হয়েছে';

  @override
  String get myReports => 'আমার রিপোর্টসমূহ';

  @override
  String get emergencyHistoryTitle => 'জরুরি সহায়তার ইতিহাস';

  @override
  String get noHistory => 'এখনও কোনো জরুরি ইতিহাস সংরক্ষিত নেই।';

  @override
  String get filterAll => 'সবগুলো';

  @override
  String get filterSafety => 'নিরাপত্তা';

  @override
  String get filterCardiac => 'হৃদরোগ';

  @override
  String get filterStroke => 'স্ট্রোক';

  @override
  String get viewDetails => 'বিস্তারিত দেখুন';

  @override
  String get caseDetails => 'জরুরি ঘটনার বিবরণ';

  @override
  String get hospitalDirectoryTitle => 'জরুরি হাসপাতালসমূহ';

  @override
  String get hospitalDirectorySubtitle =>
      'কাছাকাছি হৃদরোগ ও স্ট্রোক বিশেষায়িত জরুরি স্বাস্থ্যসেবা কেন্দ্র';

  @override
  String get searchHospitalsHint => 'হাসপাতাল বা এলাকার নাম দিয়ে খুঁজুন...';

  @override
  String get filter24x7 => '২৪/৭ জরুরি বিভাগ';

  @override
  String get filterCathLab => 'ক্যাথ ল্যাব (হৃদরোগ)';

  @override
  String get filterStrokeCenter => 'স্ট্রোক কেয়ার';

  @override
  String get filterICU => 'আইসিইউ সুবিধা';

  @override
  String get callHotline => 'হটলাইনে কল করুন';

  @override
  String get getDirections => 'ম্যাপে রাস্তা দেখুন';

  @override
  String distanceKm(String dist) {
    return '$dist কিমি দূরে';
  }

  @override
  String get ambulanceRequestTitle => 'জরুরি অ্যাম্বুলেন্স সেবা';

  @override
  String get ambulanceRequestSubtitle =>
      'লাইভ টাইমলাইন ট্র্যাকিংসহ দ্রুত জরুরি অ্যাম্বুলেন্স সহায়তা';

  @override
  String get ambulanceType => 'অ্যাম্বুলেন্সের ধরন';

  @override
  String get ambulanceBLS => 'বেসিক লাইফ সাপোর্ট (BLS)';

  @override
  String get ambulanceALS => 'অ্যাডভান্সড কার্ডিয়াক লাইফ সাপোর্ট (ALS)';

  @override
  String get ambulanceBLSDesc =>
      'অক্সিজেন সাপোর্ট, স্ট্রেচার ও প্রাথমিক জরুরি সরঞ্জাম';

  @override
  String get ambulanceALSDesc =>
      'কার্ডিয়াক মনিটর, ডিফিব্রিলেটর, ভেন্টিলেটর ও জরুরি প্যারামেডিক';

  @override
  String get pickupLocation => 'রোগীর অবস্থান';

  @override
  String get destinationHospital => 'গন্তব্য হাসপাতাল (ঐচ্ছিক)';

  @override
  String get requestAmbulanceNow => 'অ্যাম্বুলেন্সের জন্য অনুরোধ পাঠান';

  @override
  String get statusRequested => 'অনুরোধ গৃহীত';

  @override
  String get statusDispatched => 'অ্যাম্বুলেন্স রওনা হয়েছে';

  @override
  String get statusEnRoute => 'পথে আছে';

  @override
  String get statusArrived => 'ঘটনাস্থলে পৌঁছেছে';

  @override
  String get driverAssigned => 'নিযুক্ত চালক';

  @override
  String get callDriver => 'চালকের সাথে কথা বলুন';

  @override
  String get cancelBooking => 'অনুরোধ বাতিল করুন';

  @override
  String get governmentAmbulance999 => '৯৯৯ জাতীয় অ্যাম্বুলেন্স';

  @override
  String get redCrescentAmbulance => 'রেড ক্রিসেন্ট (০২-৯৩৩০১৮৮)';

  @override
  String get safetyTimerTitle => 'নিরাপত্তা টাইমার (ওয়াক উইথ মি)';

  @override
  String get safetyTimerSubtitle =>
      'গন্তব্যে পৌঁছানোর সময় নির্ধারণ করুন। নিশ্চিত না করলে স্বয়ংক্রিয় এসওএস চালু হবে।';

  @override
  String get timerPresets => 'যাত্রার আনুমানিক সময়';

  @override
  String get timerMin5 => '৫ মিনিট';

  @override
  String get timerMin15 => '১৫ মিনিট';

  @override
  String get timerMin30 => '৩০ মিনিট';

  @override
  String get timerMin60 => '৬০ মিনিট';

  @override
  String get arrivedSafely => 'নিরাপদে পৌঁছেছি';

  @override
  String get triggerSosNow => 'জরুরি বিপদ! এখনই এসওএস পাঠান';

  @override
  String get timerRunning => 'নিরাপত্তা টাইমার চলছে';

  @override
  String get timerWarning =>
      'সময় প্রায় শেষ! নিরাপত্তা নিশ্চিত করুন নয়তো এসওএস পাঠানো হবে।';

  @override
  String get settingsTitle => 'সেটিংস ও পছন্দসমূহ';

  @override
  String get languageSetting => 'ভাষা / Language';

  @override
  String get appearanceSetting => 'থিম ও ডিসপ্লে';

  @override
  String get countdownDuration => 'এসওএস বাতিল কাউন্টডাউন';

  @override
  String secondsCount(int sec) {
    return '$sec সেকেন্ড';
  }

  @override
  String get medicalIdShortcut => 'মেডিকেল আইডি দ্রুত প্রদর্শন';

  @override
  String get aboutApp => 'সেফলাইফ ও গবেষণা তথ্য';

  @override
  String get adminPortalTitle => 'অ্যাডমিন অ্যানালিটিক্স পোর্টাল';

  @override
  String get responderPanelTitle => 'রেসপন্ডার ও হাসপাতাল কমান্ড প্যানেল';

  @override
  String get totalRegisteredUsers => 'মোট নিবন্ধিত ব্যবহারকারী';

  @override
  String get activeEmergenciesCount => 'সক্রিয় জরুরি অ্যালার্ট';

  @override
  String get resolvedEmergenciesCount => 'সমাধানকৃত ইমার্জেন্সি';

  @override
  String get avgResponseLatency => 'গড় অ্যালার্ট লেটেন্সি';

  @override
  String get verifiedContactsCoverage => 'যাচাইকৃত কন্টাক্ট কাভারেজ';

  @override
  String get emergencyTypeBreakdown => 'জরুরি সেবার ধরন বিভাজন';

  @override
  String get triageSeverityBreakdown => 'ট্রায়াজ ঝুঁকির মাত্রা বিন্যাস';

  @override
  String get incidentHotspots => 'ভৌগোলিক জরুরি হটস্পট (ঢাকা)';

  @override
  String get thesisEvaluationSummary => 'থিসিস মূল্যায়ন মেট্রিক্স';

  @override
  String get exportMetrics => 'মূল্যায়ন তথ্য এক্সপোর্ট করুন';

  @override
  String get incomingDispatches => 'ইনকামিং ডিসপ্যাচ কল';

  @override
  String get noActiveEmergencies => 'এই মুহূর্তে কোনো সক্রিয় ইমার্জেন্সি নেই';

  @override
  String get acceptAndDispatch => 'গ্রহণ ও ডিসপ্যাচ করুন';

  @override
  String get markOnScene => 'ঘটনাস্থলে উপস্থিতি মার্ক করুন';

  @override
  String get resolveCaseAction => 'ইমার্জেন্সি কেস নিষ্পত্তি করুন';

  @override
  String get patientMedicalDetails => 'রোগীর মেডিকেল প্রোফাইল বিবরণ';

  @override
  String get triageIndicators => 'ট্রায়াজ লক্ষণ ও সূচক';

  @override
  String get assignedResponder => 'দায়িত্বপ্রাপ্ত রেসপন্ডার ইউনিট';

  @override
  String get responderNotes => 'ক্লিনিক্যাল ও রেসপন্ডার নোট';

  @override
  String get addNoteHint => 'নোট অথবা হাসপাতাল ভর্তির তথ্য লিখুন...';
}
