import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/theme/risk_level_theme.dart';
import '../../../core/constants/alert_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../models/responder_case.dart';
import '../providers/responder_provider.dart';

class ResponderPanelScreen extends StatefulWidget {
  const ResponderPanelScreen({super.key});

  @override
  State<ResponderPanelScreen> createState() => _ResponderPanelScreenState();
}

class _ResponderPanelScreenState extends State<ResponderPanelScreen> {
  final _noteController = TextEditingController();
  final _unitController = TextEditingController(text: 'Dhaka Emergency Unit 1');

  @override
  void dispose() {
    _noteController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String phone) async {
    final clean = phone.replaceAll(' ', '').replaceAll('-', '');
    final uri = Uri(scheme: 'tel', path: clean);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  Future<void> _openLocation(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final provider = context.watch<ResponderProvider>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.responderPanelTitle ?? 'Responder Command Panel'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: provider.criticalCount > 0 ? Colors.red.shade700 : Colors.green.shade700,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emergency_rounded, size: 16, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  '${provider.criticalCount} CRITICAL',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: isDesktop
            ? _buildDesktopLayout(context, provider, theme, l10n)
            : _buildMobileLayout(context, provider, theme, l10n),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    ResponderProvider provider,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 380,
          child: _buildQueueList(context, provider, theme, l10n),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: provider.selectedCase != null
              ? _buildCaseDetails(context, provider.selectedCase!, provider, theme, l10n)
              : Center(
                  child: Text(
                    l10n?.noActiveEmergencies ?? 'No active emergencies selected',
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    ResponderProvider provider,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return _buildQueueList(context, provider, theme, l10n, onSelectMobile: (rCase) {
      provider.selectCase(rCase);
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) => DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, scrollController) => _buildCaseDetails(
            context,
            rCase,
            provider,
            theme,
            l10n,
            scrollController: scrollController,
          ),
        ),
      );
    });
  }

  Widget _buildQueueList(
    BuildContext context,
    ResponderProvider provider,
    ThemeData theme,
    AppLocalizations? l10n, {
    void Function(ResponderCase)? onSelectMobile,
  }) {
    final cases = provider.filteredCases;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Filter Chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: ResponderFilter.values.map((f) {
              final isSelected = provider.activeFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: FilterChip(
                  label: Text(f.label),
                  selected: isSelected,
                  onSelected: (_) => provider.setFilter(f),
                ),
              );
            }).toList(),
          ),
        ),
        const Divider(height: 1),

        // Cases List
        Expanded(
          child: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : cases.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: Colors.green.shade600),
                          const SizedBox(height: 12),
                          Text(
                            l10n?.noActiveEmergencies ?? 'No active emergencies in triage queue',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: cases.length,
                      itemBuilder: (context, index) {
                        final rCase = cases[index];
                        final isSelected = provider.selectedCase?.caseId == rCase.caseId;
                        return _buildCaseTile(context, rCase, isSelected, theme, () {
                          if (onSelectMobile != null) {
                            onSelectMobile(rCase);
                          } else {
                            provider.selectCase(rCase);
                          }
                        });
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildCaseTile(
    BuildContext context,
    ResponderCase rCase,
    bool isSelected,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    final eCase = rCase.emergencyCase;
    final riskColor = theme.extension<RiskLevelTheme>()?.getColor(eCase.riskLevel) ?? Colors.red;
    final isCritical = eCase.riskLevel == RiskLevel.critical;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isSelected ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isCritical
              ? Colors.red
              : isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withAlpha(60),
          width: isCritical ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: riskColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      eCase.riskLevel.name.toUpperCase(),
                      style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        rCase.status.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateTime.now().difference(eCase.createdAt).inMinutes}m ago',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                eCase.userName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(_getTypeIcon(eCase.type), size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _getTypeLabel(eCase.type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: theme.colorScheme.primary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              if (eCase.lastKnownLocation?.address != null) ...[
                const SizedBox(height: 4),
                Text(
                  eCase.lastKnownLocation!.address!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseDetails(
    BuildContext context,
    ResponderCase rCase,
    ResponderProvider provider,
    ThemeData theme,
    AppLocalizations? l10n, {
    ScrollController? scrollController,
  }) {
    final eCase = rCase.emergencyCase;
    final riskColor = theme.extension<RiskLevelTheme>()?.getColor(eCase.riskLevel) ?? Colors.red;

    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Urgency Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: riskColor.withAlpha(20),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: riskColor, width: 2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: riskColor,
                  child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getTypeLabel(eCase.type).toUpperCase(),
                        style: TextStyle(color: riskColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        eCase.userName,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Case ID: ${eCase.id}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () => _makeCall(eCase.userPhone),
                  icon: const Icon(Icons.phone_in_talk_rounded),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Bar: Accept / Status Transitions
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Operational Dispatch Actions',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (rCase.status == ResponderStatus.pending) ...[
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.indigo.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => _showAcceptDialog(context, provider, rCase.caseId),
                      icon: const Icon(Icons.assignment_turned_in_rounded),
                      label: Text(l10n?.acceptAndDispatch ?? 'Accept & Dispatch Unit'),
                    ),
                  ] else if (rCase.status == ResponderStatus.accepted || rCase.status == ResponderStatus.dispatched) ...[
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.amber.shade800,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => provider.updateStatus(rCase.caseId, ResponderStatus.onScene),
                      icon: const Icon(Icons.location_on_rounded),
                      label: Text(l10n?.markOnScene ?? 'Mark On-Scene'),
                    ),
                  ] else if (rCase.status == ResponderStatus.onScene) ...[
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => provider.updateStatus(rCase.caseId, ResponderStatus.resolved),
                      icon: const Icon(Icons.check_circle_rounded),
                      label: Text(l10n?.resolveCaseAction ?? 'Resolve Emergency Case'),
                    ),
                  ] else ...[
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('Emergency Resolved', style: theme.textTheme.titleSmall?.copyWith(color: Colors.green)),
                      ],
                    ),
                  ],
                  if (rCase.assignedUnit != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Assigned: ${rCase.assignedUnit}',
                      style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Triage Indicators & Symptoms
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.triageIndicators ?? 'Triage Indicators',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (eCase.triageAnswers.isNotEmpty) ...[
                    ...eCase.triageAnswers.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            const Icon(Icons.chevron_right_rounded, size: 18),
                            const SizedBox(width: 6),
                            Expanded(child: Text('${entry.key}: ${entry.value}')),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    const Text('Direct User SOS Alert Triggered (No questionnaire answers)'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // GPS Location Card
          if (eCase.lastKnownLocation != null) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Live Incident Coordinates',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${eCase.lastKnownLocation!.latitude.toStringAsFixed(5)}, ${eCase.lastKnownLocation!.longitude.toStringAsFixed(5)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (eCase.lastKnownLocation!.address != null) ...[
                      const SizedBox(height: 4),
                      Text(eCase.lastKnownLocation!.address!),
                    ],
                    const SizedBox(height: 14),
                    OutlinedButton.icon(
                      onPressed: () => _openLocation(
                        eCase.lastKnownLocation!.latitude,
                        eCase.lastKnownLocation!.longitude,
                      ),
                      icon: const Icon(Icons.directions_rounded),
                      label: const Text('Open Route in Google Maps'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Clinical & Responder Notes
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n?.responderNotes ?? 'Clinical / Responder Notes',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (rCase.notes.isNotEmpty) ...[
                    ...rCase.notes.map(
                      (n) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(n, style: const TextStyle(fontSize: 13)),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _noteController,
                          decoration: InputDecoration(
                            hintText: l10n?.addNoteHint ?? 'Enter notes or updates...',
                            isDense: true,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          final text = _noteController.text.trim();
                          if (text.isNotEmpty) {
                            provider.addNote(rCase.caseId, text);
                            _noteController.clear();
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 18),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAcceptDialog(BuildContext context, ResponderProvider provider, String caseId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accept & Dispatch Unit'),
        content: TextField(
          controller: _unitController,
          decoration: const InputDecoration(
            labelText: 'Response Unit Name / Call Sign',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.acceptCase(caseId, _unitController.text.trim());
            },
            child: const Text('Confirm Dispatch'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(EmergencyType type) {
    switch (type) {
      case EmergencyType.safety:
        return Icons.security_rounded;
      case EmergencyType.cardiac:
        return Icons.favorite_rounded;
      case EmergencyType.stroke:
        return Icons.psychology_rounded;
    }
  }

  String _getTypeLabel(EmergencyType type) {
    switch (type) {
      case EmergencyType.safety:
        return "Women's Safety SOS";
      case EmergencyType.cardiac:
        return 'Acute Cardiac Triage';
      case EmergencyType.stroke:
        return 'Stroke F.A.S.T. Assessment';
    }
  }
}
