import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
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

  Future<void> _copyCoordinates(EmergencyLocation? location) async {
    if (location == null) return;
    final text = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Coordinates copied: $text')),
      );
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
            Icon(
              Icons.check_circle_outline_rounded,
              color: theme.colorScheme.primary,
              size: 28,
            ),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final isDesktop = screenWidth >= 960;
          final isTablet = screenWidth >= 640 && screenWidth < 960;
          final horizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

          return Scaffold(
            backgroundColor: theme.colorScheme.surface,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 2,
              title: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.activeEmergencyTitle ?? 'ACTIVE EMERGENCY OPERATIONS',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1B873F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text(
                        'Resolve',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                      onPressed: () => _showResolveDialog(context, sosProvider, l10n),
                    ),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      isDesktop ? 28 : 16,
                      horizontalPadding,
                      48,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Web Header Alert Banner
                        _buildHeroAlertBanner(emergency, theme, isDesktop),
                        const SizedBox(height: 24),

                        // Dual Column Operations Center on Web
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left: Location & Action Command
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildLiveLocationCard(location, theme, l10n),
                                    const SizedBox(height: 20),
                                    _buildActionButtons(context, sosProvider, theme, l10n),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              // Right: Guardians & Guidelines
                              Expanded(
                                flex: 5,
                                child: Column(
                                  children: [
                                    _buildAlertedContactsCard(
                                      context,
                                      emergency,
                                      contactsProvider,
                                      theme,
                                      l10n,
                                    ),
                                    const SizedBox(height: 20),
                                    _buildSafetyGuidelinesCard(theme),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              _buildLiveLocationCard(location, theme, l10n),
                              const SizedBox(height: 18),
                              _buildAlertedContactsCard(
                                context,
                                emergency,
                                contactsProvider,
                                theme,
                                l10n,
                              ),
                              const SizedBox(height: 20),
                              _buildActionButtons(context, sosProvider, theme, l10n),
                              const SizedBox(height: 18),
                              _buildSafetyGuidelinesCard(theme),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroAlertBanner(
    EmergencyCase? emergency,
    ThemeData theme,
    bool isDesktop,
  ) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF7F1D1D),
            Color(0xFF991B1B),
            Color(0xFFDC2626),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFDC2626).withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(35),
                border: Border.all(color: Colors.white, width: 2.5),
              ),
              child: const Icon(
                Icons.emergency_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withAlpha(70)),
                      ),
                      child: Text(
                        (emergency?.type.displayName ?? 'SAFETY SOS').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Triggered: ${emergency != null ? DateFormat('hh:mm:ss a, dd MMM').format(emergency.createdAt) : 'Just now'}',
                      style: TextStyle(
                        color: Colors.white.withAlpha(220),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Continuous Live Tracking & Emergency Broadcast Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 22 : 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Responders and verified emergency contacts have been notified with your real-time coordinates and emergency profile.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(225),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveLocationCard(
    EmergencyLocation? location,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(70)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 25 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on_rounded, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                l10n?.liveLocation ?? 'Live GPS Coordinates',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'STREAMING',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (location != null) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gps_fixed_rounded, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Lat: ${location.latitude.toStringAsFixed(6)}, Long: ${location.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    l10n?.accuracy(location.accuracy.toInt()) ??
                        '±${location.accuracy.toInt()}m',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _openGoogleMaps(location),
                      icon: const Icon(Icons.map_rounded, size: 18),
                      label: Text(
                        l10n?.openInGoogleMaps ?? 'Open in Google Maps',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _copyCoordinates(location),
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copy'),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: const [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2.2),
                ),
                SizedBox(width: 12),
                Text(
                  'Acquiring live high-precision satellite GPS fix...',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertedContactsCard(
    BuildContext context,
    EmergencyCase? emergency,
    ContactsProvider contactsProvider,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(70)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 25 : 8),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.people_alt_rounded, size: 22, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 12),
              Text(
                l10n?.alertedContacts ?? 'Alerted Guardians & Contacts',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if ((emergency?.contactAlerts.isEmpty ?? true) && contactsProvider.contacts.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                l10n?.minContactsNotice ??
                    'We recommend adding at least 2 trusted emergency contacts in your profile.',
                style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
              ),
            )
          else if (emergency != null && emergency.contactAlerts.isNotEmpty)
            ...emergency.contactAlerts.map((alert) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary.withAlpha(35),
                      child: Text(
                        alert.contactName.isNotEmpty ? alert.contactName[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.contactName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(alert.contactPhone, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        alert.channel == 'sms' ? 'SMS Sent' : alert.status.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
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
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: theme.colorScheme.primary.withAlpha(35),
                      child: Text(
                        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contact.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Text(contact.phone, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'SMS Ready',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          const SizedBox(height: 12),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
              label: Text(l10n?.sendSmsToContacts ?? 'Send Direct SMS Fallback'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SosProvider sosProvider,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Call 999 Direct Helpline
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 4,
            ),
            onPressed: () => EmergencyNumbers.makeEmergencyCall(
              EmergencyNumbers.nationalEmergency,
            ),
            icon: const Icon(Icons.phone_in_talk_rounded, size: 24),
            label: Text(
              l10n?.callPolice999 ?? 'Call 999 (National Helpline)',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // "I Am Safe" Resolution Action
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: FilledButton.tonalIcon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF1B873F).withAlpha(22),
              foregroundColor: const Color(0xFF1B873F),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _showResolveDialog(context, sosProvider, l10n),
            icon: const Icon(Icons.check_circle_rounded, size: 22),
            label: Text(
              l10n?.imSafeResolve ?? "I'm Safe / Resolve Emergency",
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSafetyGuidelinesCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 20),
              SizedBox(width: 8),
              Text(
                'Critical Safety Protocol',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _protocolBullet('Keep this web tab open to ensure continuous GPS telemetry.'),
          _protocolBullet('Emergency contacts receive direct SMS with your live coordinates.'),
          _protocolBullet('Tap "I\'m Safe" once you are in a secure location or responders arrive.'),
        ],
      ),
    );
  }

  Widget _protocolBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
