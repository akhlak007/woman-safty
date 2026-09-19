import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safelife/app/theme/risk_level_theme.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/features/sos/repositories/emergency_repository.dart';
import 'package:safelife/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyHistoryScreen extends StatefulWidget {
  final EmergencyRepository? repository;

  const EmergencyHistoryScreen({
    super.key,
    this.repository,
  });

  @override
  State<EmergencyHistoryScreen> createState() => _EmergencyHistoryScreenState();
}

class _EmergencyHistoryScreenState extends State<EmergencyHistoryScreen> {
  late final EmergencyRepository _repo;
  late Future<List<EmergencyCase>> _cachedHistoryFuture;
  EmergencyType? _selectedFilter; // null = All

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? EmergencyRepository();
    _cachedHistoryFuture = _repo.getCachedHistory();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final riskTheme = theme.extension<RiskLevelTheme>() ?? RiskLevelTheme.light;
    final auth = context.watch<SafeLifeAuthProvider>();
    final userId = auth.user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.emergencyHistoryTitle ?? 'Emergency History'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 950),
          child: Column(
        children: [
          // Filter Chips Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: Text(l10n?.filterAll ?? 'All'),
                    selected: _selectedFilter == null,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilter = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n?.filterSafety ?? 'Safety'),
                    selected: _selectedFilter == EmergencyType.safety,
                    avatar: const Icon(Icons.security_rounded, size: 16),
                    onSelected: (selected) {
                      setState(() => _selectedFilter = selected ? EmergencyType.safety : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n?.filterCardiac ?? 'Cardiac'),
                    selected: _selectedFilter == EmergencyType.cardiac,
                    avatar: const Icon(Icons.favorite_rounded, size: 16),
                    onSelected: (selected) {
                      setState(() => _selectedFilter = selected ? EmergencyType.cardiac : null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: Text(l10n?.filterStroke ?? 'Stroke'),
                    selected: _selectedFilter == EmergencyType.stroke,
                    avatar: const Icon(Icons.medical_services_rounded, size: 16),
                    onSelected: (selected) {
                      setState(() => _selectedFilter = selected ? EmergencyType.stroke : null);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Stream / Future List of Cases
          Expanded(
            child: userId.isEmpty
                ? _buildCachedView(theme, riskTheme, l10n)
                : StreamBuilder<List<EmergencyCase>>(
                    stream: _repo.streamEmergencyHistory(userId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final cases = snapshot.data ?? [];
                      if (cases.isEmpty) {
                        return _buildCachedView(theme, riskTheme, l10n);
                      }

                      return _buildCaseList(context, cases, theme, riskTheme, l10n);
                    },
                  ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCachedView(
    ThemeData theme,
    RiskLevelTheme riskTheme,
    AppLocalizations? l10n,
  ) {
    return FutureBuilder<List<EmergencyCase>>(
      future: _cachedHistoryFuture,
      builder: (context, snapshot) {
        final cases = snapshot.data ?? [];
        return _buildCaseList(context, cases, theme, riskTheme, l10n);
      },
    );
  }

  Widget _buildCaseList(
    BuildContext context,
    List<EmergencyCase> allCases,
    ThemeData theme,
    RiskLevelTheme riskTheme,
    AppLocalizations? l10n,
  ) {
    final filteredCases = _selectedFilter == null
        ? allCases
        : allCases.where((c) => c.type == _selectedFilter).toList();

    if (filteredCases.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 64,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.noHistory ?? 'No emergency cases recorded yet.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filteredCases.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = filteredCases[index];
        final riskColor = riskTheme.getColor(item.riskLevel);

        return Card(
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _showDetailsDialog(context, item, riskColor, l10n),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: riskColor.withAlpha(25),
                        child: Icon(
                          _getIconForType(item.type),
                          color: riskColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTitleForType(item.type, l10n),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(item.createdAt),
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(item.status, theme),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: riskColor.withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: riskColor.withAlpha(80)),
                        ),
                        child: Text(
                          item.riskLevel.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: riskColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      if (item.lastKnownLocation != null) ...[
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${item.lastKnownLocation!.latitude.toStringAsFixed(3)}, ${item.lastKnownLocation!.longitude.toStringAsFixed(3)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                      const Spacer(),
                      Text(
                        l10n?.viewDetails ?? 'View Details',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(EmergencyStatus status, ThemeData theme) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case EmergencyStatus.active:
        bg = theme.colorScheme.error;
        fg = Colors.white;
        label = 'ACTIVE';
        break;
      case EmergencyStatus.resolved:
        bg = Colors.green.shade700;
        fg = Colors.white;
        label = 'RESOLVED';
        break;
      case EmergencyStatus.cancelled:
        bg = theme.colorScheme.surfaceContainerHighest;
        fg = theme.colorScheme.onSurfaceVariant;
        label = 'CANCELLED';
        break;
      case EmergencyStatus.falseAlarm:
        bg = Colors.amber.shade800;
        fg = Colors.white;
        label = 'FALSE ALARM';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  IconData _getIconForType(EmergencyType type) {
    switch (type) {
      case EmergencyType.safety:
        return Icons.security_rounded;
      case EmergencyType.cardiac:
        return Icons.favorite_rounded;
      case EmergencyType.stroke:
        return Icons.medical_services_rounded;
    }
  }

  String _getTitleForType(EmergencyType type, AppLocalizations? l10n) {
    switch (type) {
      case EmergencyType.safety:
        return l10n?.womenSafety ?? 'Women Safety Emergency';
      case EmergencyType.cardiac:
        return l10n?.cardiacEmergency ?? 'Heart Attack / Cardiac Triage';
      case EmergencyType.stroke:
        return l10n?.strokeEmergency ?? 'Stroke F.A.S.T. Emergency';
    }
  }

  String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hr = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hr:$min';
  }

  void _showDetailsDialog(
    BuildContext context,
    EmergencyCase item,
    Color riskColor,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(_getIconForType(item.type), color: riskColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n?.caseDetails ?? 'Emergency Case Details',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Case ID', item.id.substring(0, item.id.length > 8 ? 8 : item.id.length)),
              _detailRow('Type', item.type.code.toUpperCase()),
              _detailRow('Risk Level', item.riskLevel.label),
              _detailRow('Status', item.status.code.toUpperCase()),
              _detailRow('Created At', _formatDate(item.createdAt)),
              if (item.resolvedAt != null)
                _detailRow('Resolved At', _formatDate(item.resolvedAt!)),
              if (item.lastKnownLocation != null) ...[
                const Divider(),
                const Text(
                  'GPS Coordinates:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.lastKnownLocation!.latitude.toStringAsFixed(6)}, ${item.lastKnownLocation!.longitude.toStringAsFixed(6)}',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),
                FilledButton.tonalIcon(
                  onPressed: () {
                    final lat = item.lastKnownLocation!.latitude;
                    final lng = item.lastKnownLocation!.longitude;
                    final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                    launchUrl(url, mode: LaunchMode.externalApplication);
                  },
                  icon: const Icon(Icons.map_rounded, size: 18),
                  label: const Text('Open in Google Maps'),
                ),
              ],
              if (item.triageAnswers.isNotEmpty) ...[
                const Divider(),
                const Text(
                  'Triage Assessment Answers:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...item.triageAnswers.entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
