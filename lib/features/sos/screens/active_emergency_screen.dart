import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../l10n/app_localizations.dart';

import '../../../core/constants/emergency_numbers.dart';
import '../../../core/services/sms_fallback_service.dart';
import '../../profile/providers/contacts_provider.dart';
import '../models/emergency_case.dart';
import '../providers/sos_provider.dart';

class ActiveEmergencyScreen extends StatefulWidget {
  const ActiveEmergencyScreen({super.key});

  @override
  State<ActiveEmergencyScreen> createState() => _ActiveEmergencyScreenState();
}

class _ActiveEmergencyScreenState extends State<ActiveEmergencyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps(EmergencyLocation? location) async {
    if (location == null) return;
    final uri = Uri.parse(location.googleMapsUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showResolveDialog(
    BuildContext context,
    SosProvider sosProvider,
    AppLocalizations? l10n,
  ) async {
    final theme = Theme.of(context);

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: theme.colorScheme.primary, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l10n?.resolveDialogTitle ?? 'Resolve Emergency',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Text(
          l10n?.resolveDialogMessage ??
              'Confirm if you are currently safe. This will immediately stop live location streaming and notify your contacts.',
          style: theme.textTheme.bodyMedium,
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await sosProvider.resolveEmergency(status: EmergencyStatus.falseAlarm);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n?.markAsFalseAlarm ?? 'False Alarm'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B873F), // Verified Safe Green
            ),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await sosProvider.resolveEmergency(status: EmergencyStatus.resolved);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(l10n?.markAsResolved ?? 'I Am Safe (Resolved)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final sosProvider = context.watch<SosProvider>();
    final contactsProvider = context.watch<ContactsProvider>();

    final emergency = sosProvider.activeEmergency;
    final location = sosProvider.currentLocation ?? emergency?.lastKnownLocation;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _showResolveDialog(context, sosProvider, l10n);
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: theme.colorScheme.error,
          foregroundColor: Colors.white,
          title: Text(
            l10n?.activeEmergencyTitle ?? 'ACTIVE EMERGENCY',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close_rounded),
              tooltip: l10n?.imSafeResolve ?? 'Resolve',
              onPressed: () => _showResolveDialog(context, sosProvider, l10n),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Pulsing Emergency Beacon
                Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.error.withAlpha(30),
                        border: Border.all(
                          color: theme.colorScheme.error,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.emergency_rounded,
                        size: 56,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    l10n?.activeEmergencyTitle ?? 'ACTIVE EMERGENCY IN PROGRESS',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    l10n?.activeEmergencyDesc ??
                        'Alert dispatched! Continuous live location sharing is active with verified contacts.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Emergency Details Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(90),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded,
                                size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.emergencyType ?? 'Emergency Type',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withAlpha(35),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                emergency?.type.displayName ?? 'Safety SOS',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Triggered: ${emergency != null ? DateFormat('hh:mm:ss a, dd MMM').format(emergency.createdAt) : 'Just now'}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Live Location Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(90),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded,
                                color: Color(0xFF1B873F), size: 22),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.liveLocation ?? 'Live GPS Location',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1B873F),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Streaming',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: const Color(0xFF1B873F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (location != null) ...[
                          Text(
                            'Lat: ${location.latitude.toStringAsFixed(5)}, Long: ${location.longitude.toStringAsFixed(5)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n?.accuracy(location.accuracy.toInt()) ??
                                'Accuracy: ±${location.accuracy.toInt()}m',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 14),
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(44),
                            ),
                            onPressed: () => _openGoogleMaps(location),
                            icon: const Icon(Icons.map_rounded, size: 18),
                            label: Text(l10n?.openInGoogleMaps ?? 'Open in Google Maps'),
                          ),
                        ] else ...[
                          Row(
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Acquiring GPS fix...',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Alerted Contacts Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: theme.colorScheme.outlineVariant.withAlpha(90),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.people_alt_rounded,
                                size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.alertedContacts ?? 'Alerted Emergency Contacts',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if ((emergency?.contactAlerts.isEmpty ?? true) &&
                            contactsProvider.contacts.isEmpty)
                          Text(
                            l10n?.minContactsNotice ??
                                'We recommend adding at least 2 trusted emergency contacts.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else if (emergency != null && emergency.contactAlerts.isNotEmpty)
                          ...emergency.contactAlerts.map((alert) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        theme.colorScheme.primary.withAlpha(40),
                                    child: Text(
                                      alert.contactName.isNotEmpty ? alert.contactName[0] : '?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          alert.contactName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          alert.contactPhone,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withAlpha(30),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      alert.channel == 'sms' ? 'SMS Sent' : alert.status.toUpperCase(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          })
                        else
                          ...contactsProvider.contacts.map((contact) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor:
                                        theme.colorScheme.primary.withAlpha(40),
                                    child: Text(
                                      contact.name.isNotEmpty ? contact.name[0] : '?',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          contact.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          contact.phone,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withAlpha(30),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'SMS Ready',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                          ),
                          onPressed: () {
                            if (emergency != null) {
                              final currentLang = Localizations.localeOf(context).languageCode;
                              const SmsFallbackService().sendDirectSms(
                                emergency: emergency,
                                contacts: contactsProvider.contacts,
                                language: currentLang,
                              );
                            }
                          },
                          icon: const Icon(Icons.sms_outlined, size: 18),
                          label: Text(
                            l10n?.sendSmsToContacts ?? 'Send Direct SMS Fallback',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Call 999 Direct Helpline
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => EmergencyNumbers.makeEmergencyCall(
                    EmergencyNumbers.nationalEmergency,
                  ),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 24),
                  label: Text(
                    l10n?.callPolice999 ?? 'Call 999 (National Helpline)',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 14),

                // "I Am Safe" Resolution Action
                FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _showResolveDialog(context, sosProvider, l10n),
                  icon: const Icon(Icons.check_circle_rounded, size: 22),
                  label: Text(
                    l10n?.imSafeResolve ?? "I'm Safe / Resolve Emergency",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
);
  }
}
