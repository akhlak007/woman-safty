import 'package:flutter/material.dart';
import '../../profile/screens/emergency_contacts_screen.dart';
import '../../profile/screens/medical_profile_screen.dart';
import '../../../core/constants/emergency_numbers.dart';
import '../../../l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLocale;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;

  const SettingsScreen({
    super.key,
    required this.onToggleTheme,
    required this.onToggleLocale,
    required this.currentLocale,
    required this.currentThemeMode,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _countdownSeconds = 5;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTitle ?? 'Settings & Preferences'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
          // Section: Language & Display
          Text(
            'Language & Display',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l10n?.languageSetting ?? 'Language / ভাষা'),
                  subtitle: Text(
                    widget.currentLocale.languageCode == 'bn' ? 'বাংলা (Bangla)' : 'English',
                  ),
                  trailing: FilledButton.tonal(
                    onPressed: widget.onToggleLocale,
                    child: Text(
                      widget.currentLocale.languageCode == 'bn' ? 'Switch to EN' : 'বাংলায় দেখুন',
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Icon(
                    widget.currentThemeMode == ThemeMode.dark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                  ),
                  title: Text(l10n?.appearanceSetting ?? 'Theme Appearance'),
                  subtitle: Text(
                    widget.currentThemeMode == ThemeMode.dark ? 'Dark Mode' : 'Light Mode',
                  ),
                  trailing: Switch(
                    value: widget.currentThemeMode == ThemeMode.dark,
                    onChanged: (_) => widget.onToggleTheme(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: Emergency Triggers
          Text(
            'Emergency & SOS Preferences',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timer_rounded, color: theme.colorScheme.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.countdownDuration ?? 'SOS Cancel Countdown',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Time to cancel accidental triggers before alerts dispatch',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [3, 5, 10].map((sec) {
                      final isSelected = _countdownSeconds == sec;
                      return ChoiceChip(
                        label: Text(l10n?.secondsCount(sec) ?? '$sec seconds'),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _countdownSeconds = sec);
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section: Health & Contacts Quick Links
          Text(
            'Profile & Security',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined),
                  title: Text(l10n?.medicalProfile ?? 'Medical ID & Conditions'),
                  subtitle: const Text('Blood group, allergies, chronic conditions'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MedicalProfileScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.people_outline_rounded),
                  title: Text(l10n?.emergencyContacts ?? 'Emergency Contacts'),
                  subtitle: const Text('Manage verified trusted contacts'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const EmergencyContactsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section: About & Ethics
          Text(
            l10n?.aboutApp ?? 'About SafeLife & Ethics',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SafeLife: Unified Smart Emergency Response Platform',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SafeLife is an emergency response coordination and clinical symptom triage platform designed for women\'s safety threats and acute cardiovascular / stroke emergencies.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'CLINICAL NOTICE: SafeLife provides pre-hospital guideline-based symptom triage and does NOT substitute professional medical diagnosis or government emergency dispatch.',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Emergency Helplines: ${EmergencyNumbers.nationalEmergency} (National), ${EmergencyNumbers.womenAndChildrenHelpline} (Women & Child), ${EmergencyNumbers.nationalHelpDesk} (Govt Services)',
                    style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Version: 1.0.0 • Thesis Evaluation Release',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
            ),
          ),
        ],
            ),
          ),
        ),
      ),
    );
  }
}
