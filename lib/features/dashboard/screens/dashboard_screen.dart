import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safelife/app/routes.dart';
import 'package:safelife/app/theme/risk_level_theme.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/core/constants/emergency_numbers.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/profile/models/emergency_contact.dart';
import 'package:safelife/features/profile/providers/contacts_provider.dart';
import 'package:safelife/features/profile/screens/emergency_contacts_screen.dart';
import 'package:safelife/features/profile/screens/medical_profile_screen.dart';
import 'package:safelife/features/sos/providers/sos_provider.dart';
import 'package:safelife/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLocale;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.onToggleLocale,
    required this.currentLocale,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final riskTheme = theme.extension<RiskLevelTheme>() ?? RiskLevelTheme.light;
    final authProvider = context.watch<SafeLifeAuthProvider>();
    final contactsProvider = context.watch<ContactsProvider>();
    final sosProvider = context.watch<SosProvider>();
    final userProfile = authProvider.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.appName ?? 'SafeLife',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Language / ভাষা',
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                currentLocale.languageCode == 'bn' ? 'EN' : 'বাং',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            onPressed: onToggleLocale,
          ),
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              currentThemeMode == ThemeMode.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
              ),
              accountName: Text(
                userProfile?.name.isNotEmpty == true
                    ? userProfile!.name
                    : (authProvider.user?.email ?? 'SafeLife User'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
              accountEmail: Text(
                userProfile?.phone.isNotEmpty == true
                    ? '${userProfile!.phone} • ${userProfile.bloodGroup ?? 'Blood Group Not Set'}'
                    : (authProvider.user?.email ?? ''),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userProfile?.name.isNotEmpty == true
                      ? userProfile!.name[0].toUpperCase()
                      : 'S',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.badge_outlined),
              title: Text(l10n?.medicalProfile ?? 'Medical Profile'),
              subtitle: Text(userProfile?.bloodGroup ?? 'Configure conditions & meds'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MedicalProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people_alt_outlined),
              title: Text(l10n?.emergencyContacts ?? 'Emergency Contacts'),
              subtitle: Text(
                '${contactsProvider.verifiedContacts.length} verified • ${contactsProvider.contacts.length} total',
              ),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report_problem_outlined),
              title: Text(l10n?.incidentReportTitle ?? 'Report Safety Incident'),
              subtitle: const Text('Confidential harassment/threat report'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.incidentReport);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded),
              title: Text(l10n?.emergencyHistoryTitle ?? 'Emergency History'),
              subtitle: const Text('View past alerts and triage records'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.history);
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_hospital_outlined),
              title: Text(l10n?.hospitalDirectoryTitle ?? 'Emergency Hospitals'),
              subtitle: const Text('Find nearby specialized emergency facilities'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.hospitals);
              },
            ),
            ListTile(
              leading: const Icon(Icons.airport_shuttle_outlined),
              title: Text(l10n?.ambulanceRequestTitle ?? 'Request Ambulance'),
              subtitle: const Text('Emergency dispatch & timeline tracking'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.ambulance);
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_outlined),
              title: Text(l10n?.safetyTimerTitle ?? 'Safety Timer'),
              subtitle: const Text('Timed check-in with automatic SOS'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.safetyTimer);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n?.settingsTitle ?? 'Settings & Preferences'),
              subtitle: const Text('Language, appearance, SOS countdown delay'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.settings);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.analytics_outlined),
              title: Text(l10n?.adminPortalTitle ?? 'Admin Analytics Portal'),
              subtitle: const Text('User metrics, hotspots, thesis evaluation'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.admin);
              },
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_customize_outlined),
              title: Text(l10n?.responderPanelTitle ?? 'Responder Command Panel'),
              subtitle: const Text('Live emergency queue & hospital triage dispatch'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed(AppRoutes.responder);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: const Text('Language / ভাষা'),
              trailing: Text(
                currentLocale.languageCode == 'bn' ? 'বাংলা' : 'English',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: onToggleLocale,
            ),
            ListTile(
              leading: Icon(
                currentThemeMode == ThemeMode.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
              title: const Text('Appearance'),
              trailing: Text(
                currentThemeMode == ThemeMode.dark ? 'Dark' : 'Light',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onTap: onToggleTheme,
            ),
            const Spacer(),
            if (authProvider.isAuthenticated) ...[
              const Divider(),
              ListTile(
                leading: Icon(Icons.logout_rounded, color: theme.colorScheme.error),
                title: Text(
                  l10n?.signOut ?? 'Sign Out',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmLogout(context, authProvider);
                },
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;

            if (isDesktop) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (sosProvider.hasActiveEmergency) ...[
                          _buildActiveEmergencyBanner(context, theme, l10n),
                          const SizedBox(height: 20),
                        ],
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: Interactive SOS Beacon, Profile & Helplines
                            SizedBox(
                              width: 380,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildQuickProfileBar(context, theme, l10n, userProfile, contactsProvider),
                                  const SizedBox(height: 16),
                                  _buildDisclaimer(theme, l10n),
                                  const SizedBox(height: 24),
                                  _buildSosBeacon(context, theme, l10n, sosProvider),
                                  const SizedBox(height: 24),
                                  _buildHelplines(theme),
                                ],
                              ),
                            ),
                            const SizedBox(width: 32),
                            // Right Column: Comprehensive Emergency Services & Triage Grid
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Emergency Services & Clinical Triage',
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rapid dispatch, guideline-directed triage, specialized hospitals, and command panels',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 18),
                                  GridView.count(
                                    crossAxisCount: constraints.maxWidth >= 1200 ? 2 : 2,
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: 2.5,
                                    children: _buildAllServiceTiles(context, theme, riskTheme, l10n, sosProvider),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Mobile / Tablet Compact Layout
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (sosProvider.hasActiveEmergency) ...[
                        _buildActiveEmergencyBanner(context, theme, l10n),
                        const SizedBox(height: 16),
                      ],
                      _buildQuickProfileBar(context, theme, l10n, userProfile, contactsProvider),
                      const SizedBox(height: 16),
                      _buildDisclaimer(theme, l10n),
                      const SizedBox(height: 28),
                      _buildSosBeacon(context, theme, l10n, sosProvider),
                      const SizedBox(height: 28),
                      _buildHelplines(theme),
                      const SizedBox(height: 28),
                      Text(
                        'Emergency Services & Triage',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      ..._buildAllServiceTiles(context, theme, riskTheme, l10n, sosProvider).map(
                        (tile) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: tile,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActiveEmergencyBanner(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.sosActive),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.colorScheme.error,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.error.withAlpha(90),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.activeEmergencyTitle ?? 'ACTIVE EMERGENCY IN PROGRESS',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view live coordinates and responder tracking',
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickProfileBar(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
    dynamic userProfile,
    ContactsProvider contactsProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MedicalProfileScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_information_outlined,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.medicalId ?? 'Medical ID',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          userProfile?.bloodGroup ?? 'Set Blood Group',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const EmergencyContactsScreen(),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.contacts_outlined,
                    size: 20,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.emergencyContacts ?? 'Contacts',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          '${contactsProvider.verifiedContacts.length} Active',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisclaimer(ThemeData theme, AppLocalizations? l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_outlined,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n?.disclaimer ??
                  'SafeLife is an emergency assistance and symptom triage tool, not a diagnostic device.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosBeacon(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
    SosProvider sosProvider,
  ) {
    return Center(
      child: Column(
        children: [
          Semantics(
            button: true,
            label: l10n?.sos ?? 'SOS',
            child: Material(
              color: theme.colorScheme.error,
              elevation: 6,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  if (sosProvider.hasActiveEmergency) {
                    Navigator.of(context).pushNamed(AppRoutes.sosActive);
                  } else {
                    _showSosCountdownDialog(context);
                  }
                },
                child: Container(
                  width: 170,
                  height: 170,
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.emergency_rounded,
                        size: 52,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n?.sos ?? 'SOS',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Tap to trigger emergency alert',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelplines(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => EmergencyNumbers.makeEmergencyCall(
              EmergencyNumbers.nationalEmergency,
            ),
            icon: const Icon(Icons.phone_in_talk_rounded),
            label: const Text(
              '999 (National)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
              side: BorderSide(color: theme.colorScheme.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () => EmergencyNumbers.makeEmergencyCall(
              EmergencyNumbers.womenAndChildrenHelpline,
            ),
            icon: const Icon(Icons.support_agent_rounded),
            label: const Text(
              '109 (Helpline)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildAllServiceTiles(
    BuildContext context,
    ThemeData theme,
    RiskLevelTheme riskTheme,
    AppLocalizations? l10n,
    SosProvider sosProvider,
  ) {
    return [
      _ServiceTile(
        title: l10n?.womenSafety ?? 'Women Safety',
        subtitle: 'Discreet alert, live tracking, trusted contacts',
        icon: Icons.security_rounded,
        iconColor: theme.colorScheme.primary,
        onTap: () {
          if (sosProvider.hasActiveEmergency) {
            Navigator.of(context).pushNamed(AppRoutes.sosActive);
          } else {
            _showSosCountdownDialog(context);
          }
        },
      ),
      _ServiceTile(
        title: l10n?.cardiacEmergency ?? 'Heart Attack / Cardiac',
        subtitle: 'Acute symptom check & rule-based triage score',
        icon: Icons.favorite_rounded,
        iconColor: riskTheme.getColor(RiskLevel.high),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.heartTriage),
      ),
      _ServiceTile(
        title: l10n?.strokeEmergency ?? 'Stroke (FAST)',
        subtitle: 'Face, Arm, Speech, Time + Bystander mode',
        icon: Icons.medical_services_rounded,
        iconColor: riskTheme.getColor(RiskLevel.critical),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.strokeTriage),
      ),
      _ServiceTile(
        title: l10n?.hospitalDirectoryTitle ?? 'Emergency Hospitals',
        subtitle: 'Nearby hospitals with Cath Lab, Stroke tPA, & 24/7 ER',
        icon: Icons.local_hospital_rounded,
        iconColor: theme.colorScheme.primary,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.hospitals),
      ),
      _ServiceTile(
        title: l10n?.ambulanceRequestTitle ?? 'Request Ambulance',
        subtitle: 'Verified emergency ambulance dispatch with live tracking',
        icon: Icons.airport_shuttle_rounded,
        iconColor: theme.colorScheme.error,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.ambulance),
      ),
      _ServiceTile(
        title: l10n?.safetyTimerTitle ?? 'Safety Timer (Walk With Me)',
        subtitle: 'Arrival countdown with automatic SOS escalation',
        icon: Icons.timer_rounded,
        iconColor: Colors.amber.shade800,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.safetyTimer),
      ),
      _ServiceTile(
        title: l10n?.incidentReportTitle ?? 'Report Safety Incident',
        subtitle: 'Confidential harassment and stalking telemetry report',
        icon: Icons.report_problem_outlined,
        iconColor: Colors.deepOrange.shade700,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.incidentReport),
      ),
      _ServiceTile(
        title: l10n?.emergencyHistoryTitle ?? 'Emergency History',
        subtitle: 'View historical alerts, triage scores, and logs',
        icon: Icons.history_rounded,
        iconColor: Colors.blueGrey.shade700,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.history),
      ),
      _ServiceTile(
        title: l10n?.adminPortalTitle ?? 'Admin Analytics Portal',
        subtitle: 'Platform user KPIs, incident hotspots, and thesis evaluation',
        icon: Icons.analytics_outlined,
        iconColor: Colors.indigo.shade700,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.admin),
      ),
      _ServiceTile(
        title: l10n?.responderPanelTitle ?? 'Responder Command Panel',
        subtitle: 'Live emergency dispatch queue and hospital triage routing',
        icon: Icons.dashboard_customize_outlined,
        iconColor: Colors.teal.shade700,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.responder),
      ),
    ];
  }

  void _confirmLogout(BuildContext context, SafeLifeAuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of SafeLife?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              auth.signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showSosCountdownDialog(BuildContext context) {
    final auth = context.read<SafeLifeAuthProvider>();
    final contacts = context.read<ContactsProvider>().contacts;
    final sos = context.read<SosProvider>();

    final userId = auth.user?.uid ?? '';
    final userName = auth.userProfile?.name ?? auth.user?.displayName ?? 'SafeLife User';
    final userPhone = auth.userProfile?.phone ?? auth.user?.phoneNumber ?? '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return _CountdownDialog(
          userId: userId,
          userName: userName,
          userPhone: userPhone,
          contacts: contacts,
          language: currentLocale.languageCode,
          sosProvider: sos,
          onDispatched: () {
            Navigator.of(dialogCtx).pop();
            Navigator.of(context).pushNamed(AppRoutes.sosActive);
          },
        );
      },
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(50),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: iconColor.withAlpha(25),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountdownDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhone;
  final List<EmergencyContact> contacts;
  final String language;
  final SosProvider sosProvider;
  final VoidCallback onDispatched;

  const _CountdownDialog({
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.contacts,
    required this.language,
    required this.sosProvider,
    required this.onDispatched,
  });

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _remaining = AlertConstants.defaultCountdownSeconds;
  Timer? _timer;
  bool _cancelled = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cancelled || !mounted) {
        timer.cancel();
        return;
      }
      if (_remaining > 1) {
        setState(() {
          _remaining--;
        });
      } else {
        timer.cancel();
        _dispatchNow();
      }
    });
  }

  void _dispatchNow() {
    if (_cancelled) return;
    _timer?.cancel();
    widget.sosProvider.dispatchEmergency(
      userId: widget.userId,
      userName: widget.userName,
      userPhone: widget.userPhone,
      contacts: widget.contacts,
      language: widget.language,
      type: EmergencyType.safety,
    );
    widget.onDispatched();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n?.countdownTitle ?? 'Emergency Alert Triggering',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.countdownWarning(_remaining) ??
                'Alerting emergency contacts in $_remaining seconds',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: _remaining / AlertConstants.defaultCountdownSeconds,
                  strokeWidth: 8,
                  color: theme.colorScheme.error,
                  backgroundColor: theme.colorScheme.error.withAlpha(40),
                ),
              ),
              Text(
                '$_remaining',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        FilledButton.tonal(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
          onPressed: () {
            _cancelled = true;
            _timer?.cancel();
            Navigator.of(context).pop();
          },
          child: Text(l10n?.cancel ?? 'Cancel / I\'m Safe'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
          ),
          onPressed: () {
            _dispatchNow();
          },
          child: const Text('Dispatch Now'),
        ),
      ],
    );
  }
}
