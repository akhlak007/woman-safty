import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import '../features/auth/providers/auth_provider.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/profile/providers/contacts_provider.dart';
import '../features/profile/providers/profile_provider.dart';
import '../features/profile/screens/emergency_contacts_screen.dart';
import '../features/profile/screens/medical_profile_screen.dart';
import '../features/sos/providers/sos_provider.dart';
import '../features/sos/screens/active_emergency_screen.dart';
import '../features/heart_triage/screens/cardiac_triage_screen.dart';
import '../features/history/screens/emergency_history_screen.dart';
import '../features/incident_report/screens/incident_report_screen.dart';
import '../features/stroke_triage/screens/stroke_triage_screen.dart';
import '../features/hospitals/screens/hospital_directory_screen.dart';
import '../features/ambulance/providers/ambulance_provider.dart';
import '../features/ambulance/screens/ambulance_request_screen.dart';
import '../features/safety_timer/providers/safety_timer_provider.dart';
import '../features/safety_timer/screens/safety_timer_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../features/admin/screens/admin_dashboard_screen.dart';
import '../features/responder/providers/responder_provider.dart';
import '../features/responder/screens/responder_panel_screen.dart';
import '../l10n/app_localizations.dart';
import 'auth_wrapper.dart';
import 'routes.dart';
import 'theme/app_theme.dart';

class SafeLifeApp extends StatefulWidget {
  final SafeLifeAuthProvider? authProvider;
  final ProfileProvider? profileProvider;
  final ContactsProvider? contactsProvider;
  final SosProvider? sosProvider;
  final AmbulanceProvider? ambulanceProvider;
  final SafetyTimerProvider? safetyTimerProvider;
  final ResponderProvider? responderProvider;
  final Widget? home;
  final Locale? initialLocale;

  const SafeLifeApp({
    super.key,
    this.authProvider,
    this.profileProvider,
    this.contactsProvider,
    this.sosProvider,
    this.ambulanceProvider,
    this.safetyTimerProvider,
    this.responderProvider,
    this.home,
    this.initialLocale,
  });

  @override
  State<SafeLifeApp> createState() => _SafeLifeAppState();
}

class _SafeLifeAppState extends State<SafeLifeApp> {
  ThemeMode _themeMode = ThemeMode.system;
  late Locale _locale;

  late final SafeLifeAuthProvider _authProvider;
  late final ProfileProvider _profileProvider;
  late final ContactsProvider _contactsProvider;
  late final SosProvider _sosProvider;
  late final AmbulanceProvider _ambulanceProvider;
  late final SafetyTimerProvider _safetyTimerProvider;
  late final ResponderProvider _responderProvider;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale ?? const Locale('bn'); // Bangla-first by default
    _authProvider = widget.authProvider ?? SafeLifeAuthProvider();
    _profileProvider = widget.profileProvider ?? ProfileProvider();
    _contactsProvider = widget.contactsProvider ?? ContactsProvider();
    _sosProvider = widget.sosProvider ?? SosProvider();
    _ambulanceProvider = widget.ambulanceProvider ?? AmbulanceProvider();
    _safetyTimerProvider = widget.safetyTimerProvider ?? SafetyTimerProvider();
    _responderProvider = widget.responderProvider ?? ResponderProvider();
  }

  @override
  void didUpdateWidget(covariant SafeLifeApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialLocale != null &&
        widget.initialLocale != oldWidget.initialLocale) {
      setState(() {
        _locale = widget.initialLocale!;
      });
    }
  }

  @override
  void dispose() {
    if (widget.authProvider == null) _authProvider.dispose();
    if (widget.profileProvider == null) _profileProvider.dispose();
    if (widget.contactsProvider == null) _contactsProvider.dispose();
    if (widget.sosProvider == null) _sosProvider.dispose();
    if (widget.ambulanceProvider == null) _ambulanceProvider.dispose();
    if (widget.safetyTimerProvider == null) _safetyTimerProvider.dispose();
    if (widget.responderProvider == null) _responderProvider.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  void _toggleLocale() {
    setState(() {
      _locale = _locale.languageCode == 'bn'
          ? const Locale('en')
          : const Locale('bn');
    });
  }

  @override
  Widget build(BuildContext context) {
    final materialApp = MaterialApp(
      title: 'SafeLife',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: widget.home ??
          AuthWrapper(
            onToggleTheme: _toggleTheme,
            onToggleLocale: _toggleLocale,
            currentLocale: _locale,
            currentThemeMode: _themeMode,
          ),
      routes: {
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),
        AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
        AppRoutes.profile: (context) => const MedicalProfileScreen(),
        AppRoutes.contacts: (context) => const EmergencyContactsScreen(),
        AppRoutes.sosActive: (context) => const ActiveEmergencyScreen(),
        AppRoutes.dashboard: (context) => DashboardScreen(
              onToggleTheme: _toggleTheme,
              onToggleLocale: _toggleLocale,
              currentLocale: _locale,
              currentThemeMode: _themeMode,
            ),
        AppRoutes.heartTriage: (context) => const CardiacTriageScreen(),
        AppRoutes.strokeTriage: (context) => const StrokeTriageScreen(),
        AppRoutes.incidentReport: (context) => const IncidentReportScreen(),
        AppRoutes.history: (context) => const EmergencyHistoryScreen(),
        AppRoutes.hospitals: (context) => const HospitalDirectoryScreen(),
        AppRoutes.ambulance: (context) => const AmbulanceRequestScreen(),
        AppRoutes.safetyTimer: (context) => const SafetyTimerScreen(),
        AppRoutes.settings: (context) => SettingsScreen(
              onToggleTheme: _toggleTheme,
              onToggleLocale: _toggleLocale,
              currentLocale: _locale,
              currentThemeMode: _themeMode,
            ),
        AppRoutes.admin: (context) => const AdminDashboardScreen(),
        AppRoutes.responder: (context) => const ResponderPanelScreen(),
      },
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SafeLifeAuthProvider>.value(value: _authProvider),
        ChangeNotifierProvider<ProfileProvider>.value(value: _profileProvider),
        ChangeNotifierProvider<ContactsProvider>.value(value: _contactsProvider),
        ChangeNotifierProvider<SosProvider>.value(value: _sosProvider),
        ChangeNotifierProvider<AmbulanceProvider>.value(value: _ambulanceProvider),
        ChangeNotifierProvider<SafetyTimerProvider>.value(value: _safetyTimerProvider),
        ChangeNotifierProvider<ResponderProvider>.value(value: _responderProvider),
      ],
      child: materialApp,
    );
  }
}
