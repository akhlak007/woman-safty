import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/emergency_numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../../profile/screens/emergency_contacts_screen.dart';
import '../../profile/screens/medical_profile_screen.dart';

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
    final isDark = widget.currentThemeMode == ThemeMode.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 960;
        final isTablet = screenWidth >= 640 && screenWidth < 960;
        final horizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

        return Scaffold(
          appBar: AppBar(
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.settings_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n?.settingsTitle ?? 'Settings & Preferences',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            elevation: 0,
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isDesktop ? 24 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Hero Banner
                      _buildHeroBanner(context, theme, isDark, isDesktop),
                      const SizedBox(height: 24),

                      // Settings Sections
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column (50%): System Preferences & SOS Countdown
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildLanguageAndDisplaySection(
                                      context, theme, isDark, l10n),
                                  const SizedBox(height: 24),
                                  _buildEmergencyPreferencesSection(
                                      context, theme, isDark, l10n),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),

                            // Right Column (50%): Profiles & Ethics/Helplines
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildProfilesSection(
                                      context, theme, isDark, l10n),
                                  const SizedBox(height: 24),
                                  _buildAboutAndHelplinesSection(
                                      context, theme, isDark, l10n),
                                ],
                              ),
                            ),
                          ],
                        )
                      else ...[
                        // Mobile & Tablet: Stacked layout
                        _buildLanguageAndDisplaySection(
                            context, theme, isDark, l10n),
                        const SizedBox(height: 20),
                        _buildEmergencyPreferencesSection(
                            context, theme, isDark, l10n),
                        const SizedBox(height: 20),
                        _buildProfilesSection(
                            context, theme, isDark, l10n),
                        const SizedBox(height: 20),
                        _buildAboutAndHelplinesSection(
                            context, theme, isDark, l10n),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // HERO BANNER
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildHeroBanner(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 26 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1E2F),
                  const Color(0xFF2D2B55),
                  const Color(0xFF1A1A2E),
                ]
              : [
                  const Color(0xFF4F46E5),
                  const Color(0xFF6366F1),
                  const Color(0xFF818CF8),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(60)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.tune_rounded, color: Colors.white, size: 13),
                    SizedBox(width: 6),
                    Text(
                      'SYSTEM CONFIGURATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'SafeLife v1.0.0',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Application Settings & Safety Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 22 : 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Personalize language preferences, visual theme appearance, emergency cancel delay triggers, and quick access to clinical profiles.',
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: isDesktop ? 13 : 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 1. LANGUAGE & DISPLAY SECTION
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildLanguageAndDisplaySection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Material(
      color: isDark ? const Color(0xFF161F30) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette_outlined,
                    color: Color(0xFF3B82F6),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Language & Display',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Language Setting Tile
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.language_rounded,
                  color: theme.colorScheme.primary, size: 20),
            ),
            title: Text(
              l10n?.languageSetting ?? 'Language / ভাষা',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
              widget.currentLocale.languageCode == 'bn'
                  ? 'বাংলা (Bangla) — Active'
                  : 'English (US) — Active',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                onPressed: widget.onToggleLocale,
                child: Text(
                  widget.currentLocale.languageCode == 'bn'
                      ? 'Switch to EN'
                      : 'বাংলায় দেখুন',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 2. EMERGENCY & SOS PREFERENCES SECTION
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildEmergencyPreferencesSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F30) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFDC2626).withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.timer_rounded,
                  color: Color(0xFFDC2626),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Emergency & SOS Preferences',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            l10n?.countdownDuration ?? 'SOS Cancel Countdown Window',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            'Allows you a grace period to cancel accidental SOS activations before real-time emergency alerts are dispatched to trusted contacts and responders.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [3, 5, 10].map((sec) {
              final isSelected = _countdownSeconds == sec;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => setState(() => _countdownSeconds = sec),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : (isDark
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : (isDark
                                    ? const Color(0xFF334155)
                                    : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              l10n?.secondsCount(sec) ?? '$sec seconds',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                                color: isSelected
                                    ? Colors.white
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              sec == 3
                                  ? 'Fast'
                                  : (sec == 5 ? 'Recommended' : 'Safe'),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white70
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 3. PROFILES & HEALTH MANAGEMENT SECTION
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildProfilesSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Material(
      color: isDark ? const Color(0xFF161F30) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withAlpha(25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Profile & Security',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Medical Profile Tile
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.badge_outlined,
                  color: Color(0xFFEF4444), size: 20),
            ),
            title: Text(
              l10n?.medicalProfile ?? 'Medical ID & Clinical Conditions',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
              'Blood type, known allergies, chronic conditions, and medications',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MedicalProfileScreen()),
              );
            },
          ),
          const Divider(height: 1),

          // Emergency Contacts Tile
          ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded,
                  color: Color(0xFF6366F1), size: 20),
            ),
            title: Text(
              l10n?.emergencyContacts ?? 'Emergency Guardians & Contacts',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
              'Manage verified trusted family and friend guardians',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const EmergencyContactsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // 4. ABOUT SAFELIFE, ETHICS & NATIONAL HELPLINES
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildAboutAndHelplinesSection(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F30) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                l10n?.aboutApp ?? 'About SafeLife & Ethics',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'SafeLife: Unified Smart Emergency Response Platform',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(
            'SafeLife coordinates immediate emergency assistance, hospital resource queries, and pre-hospital clinical triage for personal safety threats, cardiac emergencies, and stroke crises.',
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Clinical Notice Callout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(50),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: theme.colorScheme.primary.withAlpha(60)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.health_and_safety_rounded,
                    color: theme.colorScheme.primary, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'CLINICAL NOTICE: SafeLife provides algorithmic symptom triage. It does NOT substitute professional medical diagnosis or government emergency dispatch.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Bangladesh National Helplines Quick Call Buttons
          const Text(
            'National Helplines (Bangladesh):',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildHelplineButton(
                number: EmergencyNumbers.nationalEmergency,
                label: '999 National Emergency',
                color: const Color(0xFFDC2626),
              ),
              _buildHelplineButton(
                number: EmergencyNumbers.womenAndChildrenHelpline,
                label: '109 Women & Child',
                color: const Color(0xFF9333EA),
              ),
              _buildHelplineButton(
                number: EmergencyNumbers.nationalHelpDesk,
                label: '333 Govt Info',
                color: const Color(0xFF0284C7),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 6,
            children: [
              Text(
                'Version: 1.0.0 • Thesis Evaluation Release',
                style: TextStyle(
                  fontSize: 11,
                  color: theme.colorScheme.outline,
                ),
              ),
              const Text(
                'Designed for Web & Mobile',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHelplineButton({
    required String number,
    required String label,
    required Color color,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color.withAlpha(120)),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          final url = Uri.parse('tel:$number');
          launchUrl(url);
        },
        icon: const Icon(Icons.call_rounded, size: 14),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
        ),
      ),
    );
  }
}
