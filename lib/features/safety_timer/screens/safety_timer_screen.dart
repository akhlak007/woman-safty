import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/safety_timer_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/contacts_provider.dart';
import '../../sos/providers/sos_provider.dart';
import '../../../app/routes.dart';
import '../../../l10n/app_localizations.dart';

class SafetyTimerScreen extends StatefulWidget {
  const SafetyTimerScreen({super.key});

  @override
  State<SafetyTimerScreen> createState() => _SafetyTimerScreenState();
}

class _SafetyTimerScreenState extends State<SafetyTimerScreen> {
  int _selectedMinutes = 15;

  void _startTimer() {
    final auth = context.read<SafeLifeAuthProvider>();
    final contacts = context.read<ContactsProvider>().contacts;
    final sosProv = context.read<SosProvider>();
    final timerProv = context.read<SafetyTimerProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    final userId = auth.user?.uid ?? '';
    final userName = auth.userProfile?.name ?? auth.user?.displayName ?? 'SafeLife User';
    final userPhone = auth.userProfile?.phone ?? auth.user?.phoneNumber ?? '';

    timerProv.startTimer(
      minutes: _selectedMinutes,
      sosProvider: sosProv,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      contacts: contacts,
      language: lang,
    );
  }

  void _triggerInstantSos() {
    final auth = context.read<SafeLifeAuthProvider>();
    final contacts = context.read<ContactsProvider>().contacts;
    final sosProv = context.read<SosProvider>();
    final timerProv = context.read<SafetyTimerProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    timerProv.stopTimer();

    sosProv.dispatchEmergency(
      userId: auth.user?.uid ?? '',
      userName: auth.userProfile?.name ?? auth.user?.displayName ?? 'SafeLife User',
      userPhone: auth.userProfile?.phone ?? auth.user?.phoneNumber ?? '',
      contacts: contacts,
      language: lang,
    );

    Navigator.of(context).pushReplacementNamed(AppRoutes.sosActive);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final timerProv = context.watch<SafetyTimerProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.safetyTimerTitle ?? 'Safety Timer (Walk With Me)'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 700),
            child: timerProv.isRunning
                ? _buildActiveTimerView(context, timerProv, theme, l10n)
                : _buildConfigView(context, theme, l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildConfigView(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Informational Explainer Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(80),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.primary.withAlpha(60)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.safetyTimerTitle ?? 'Walk With Me Timer',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n?.safetyTimerSubtitle ??
                            'Set an arrival countdown. If you do not confirm safety before time expires, emergency SOS is automatically dispatched to your contacts.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(
            l10n?.timerPresets ?? 'Select Commute Window',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),

          // Duration Preset Grid
          Row(
            children: [5, 15, 30, 60].map((mins) {
              final isSelected = _selectedMinutes == mins;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => setState(() => _selectedMinutes = mins),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant.withAlpha(80),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$mins',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            'min',
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : theme.colorScheme.outline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 36),

          // Start Button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _startTimer,
            icon: const Icon(Icons.play_arrow_rounded, size: 24),
            label: Text(
              'Start $_selectedMinutes-Minute Safety Timer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Keep your phone accessible during transit. You can tap "I Arrived Safely" at any point.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTimerView(
    BuildContext context,
    SafetyTimerProvider timerProv,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final isWarning = timerProv.isWarning;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning Alert Banner
            if (isWarning) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n?.timerWarning ??
                            'Time almost up! Confirm safety or SOS will alert contacts.',
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Circular Countdown Clock
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: timerProv.progress,
                        strokeWidth: 12,
                        color: isWarning ? theme.colorScheme.error : theme.colorScheme.primary,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          timerProv.formattedTime,
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            color: isWarning ? theme.colorScheme.error : theme.colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          l10n?.timerRunning ?? 'Safety timer active',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 48),

            // Arrived Safely Confirmation Action
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                timerProv.stopTimer();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Safety timer cancelled. You arrived safely!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              icon: const Icon(Icons.check_circle_outline_rounded, size: 22),
              label: Text(
                l10n?.arrivedSafely ?? 'I Arrived Safely',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 14),

            // Emergency SOS Action
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _triggerInstantSos,
              icon: const Icon(Icons.warning_rounded, size: 20),
              label: Text(
                l10n?.triggerSosNow ?? 'Emergency! Trigger SOS Now',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
