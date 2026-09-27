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
  EmergencyCase? _selectedCase; // For desktop master-detail preview

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
    final isDark = theme.brightness == Brightness.dark;
    final riskTheme = theme.extension<RiskLevelTheme>() ?? RiskLevelTheme.light;
    final auth = context.watch<SafeLifeAuthProvider>();
    final userId = auth.user?.uid ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 1024 && screenWidth > constraints.maxHeight;
        final isTablet = screenWidth >= 680 && screenWidth < 1024;
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
                    Icons.history_toggle_off_rounded,
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n?.emergencyHistoryTitle ?? 'Emergency History',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            elevation: 0,
            actions: [
              IconButton(
                tooltip: 'Refresh History',
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () {
                  setState(() {
                    _cachedHistoryFuture = _repo.getCachedHistory();
                  });
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isDesktop ? 24 : 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Hero Banner
                      _buildHeroBanner(context, theme, isDark, isDesktop),
                      const SizedBox(height: 20),

                      // Filter Bar with Badges
                      _buildFilterBar(theme, isDark, l10n),
                      const SizedBox(height: 16),

                      // Main Stream / Future Content
                      Expanded(
                        child: userId.isEmpty
                            ? _buildCachedView(
                                theme, riskTheme, isDark, isDesktop, l10n)
                            : StreamBuilder<List<EmergencyCase>>(
                                stream: _repo.streamEmergencyHistory(userId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting &&
                                      !snapshot.hasData) {
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  }

                                  final cases = snapshot.data ?? [];
                                  if (cases.isEmpty) {
                                    return _buildCachedView(theme, riskTheme,
                                        isDark, isDesktop, l10n);
                                  }

                                  return _buildResponsiveCaseLayout(
                                    context,
                                    cases,
                                    theme,
                                    riskTheme,
                                    isDark,
                                    isDesktop,
                                    l10n,
                                  );
                                },
                              ),
                      ),
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
                  const Color(0xFF0F2027),
                  const Color(0xFF203A43),
                  const Color(0xFF2C5364),
                ]
              : [
                  const Color(0xFF1E3A8A),
                  const Color(0xFF0D9488),
                  const Color(0xFF0284C7),
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
                    Icon(Icons.verified_rounded,
                        color: Colors.white, size: 13),
                    SizedBox(width: 6),
                    Text(
                      'IMMUTABLE INCIDENT LOGS',
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
                child: const Row(
                  children: [
                    Icon(Icons.lock_clock_rounded,
                        color: Color(0xFF6EE7B7), size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Audited & GPS-Timestamped',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Emergency Response & Case History',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 24 : 19,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Chronological timeline of all triggered SOS alerts, cardiac symptom assessments, and stroke emergencies with clinician triage responses and GPS coordinates.',
            style: TextStyle(
              color: Colors.white.withAlpha(225),
              fontSize: isDesktop ? 13 : 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // FILTER BAR
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildFilterBar(
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F30) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Text(
              'Filter Classification:',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            _buildFilterChip(
              label: l10n?.filterAll ?? 'All',
              isSelected: _selectedFilter == null,
              icon: Icons.list_alt_rounded,
              color: theme.colorScheme.primary,
              onTap: () => setState(() => _selectedFilter = null),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: l10n?.filterSafety ?? 'Safety',
              isSelected: _selectedFilter == EmergencyType.safety,
              icon: Icons.security_rounded,
              color: const Color(0xFFE11D48),
              onTap: () => setState(() => _selectedFilter =
                  _selectedFilter == EmergencyType.safety
                      ? null
                      : EmergencyType.safety),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: l10n?.filterCardiac ?? 'Cardiac',
              isSelected: _selectedFilter == EmergencyType.cardiac,
              icon: Icons.favorite_rounded,
              color: const Color(0xFFEF4444),
              onTap: () => setState(() => _selectedFilter =
                  _selectedFilter == EmergencyType.cardiac
                      ? null
                      : EmergencyType.cardiac),
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: l10n?.filterStroke ?? 'Stroke',
              isSelected: _selectedFilter == EmergencyType.stroke,
              icon: Icons.medical_services_rounded,
              color: const Color(0xFF8B5CF6),
              onTap: () => setState(() => _selectedFilter =
                  _selectedFilter == EmergencyType.stroke
                      ? null
                      : EmergencyType.stroke),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withAlpha(22),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : color.withAlpha(70),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CACHED VIEW FALLBACK
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildCachedView(
    ThemeData theme,
    RiskLevelTheme riskTheme,
    bool isDark,
    bool isDesktop,
    AppLocalizations? l10n,
  ) {
    return FutureBuilder<List<EmergencyCase>>(
      future: _cachedHistoryFuture,
      builder: (context, snapshot) {
        final cases = snapshot.data ?? [];
        return _buildResponsiveCaseLayout(
          context,
          cases,
          theme,
          riskTheme,
          isDark,
          isDesktop,
          l10n,
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // RESPONSIVE CASE LAYOUT (Desktop Split Inspector vs Mobile List)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildResponsiveCaseLayout(
    BuildContext context,
    List<EmergencyCase> allCases,
    ThemeData theme,
    RiskLevelTheme riskTheme,
    bool isDark,
    bool isDesktop,
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
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.history_toggle_off_rounded,
                  size: 56,
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.noHistory ?? 'No emergency cases recorded yet.',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'When SOS is activated or symptom assessments are completed, records are archived here.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // On Desktop: Master-Detail dual pane
    if (isDesktop) {
      // Default to first case if nothing selected
      final activeCase = _selectedCase != null &&
              filteredCases.any((c) => c.id == _selectedCase!.id)
          ? _selectedCase!
          : filteredCases.first;

      final riskColor = riskTheme.getColor(activeCase.riskLevel);

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master Case List (52% width)
          Expanded(
            flex: 52,
            child: ListView.separated(
              itemCount: filteredCases.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = filteredCases[index];
                final itemRiskColor = riskTheme.getColor(item.riskLevel);
                final isSelected = activeCase.id == item.id;

                return _buildCaseCard(
                  context,
                  item,
                  itemRiskColor,
                  isSelected,
                  theme,
                  isDark,
                  l10n,
                  onTap: () {
                    setState(() => _selectedCase = item);
                    _showDetailsDialog(context, item, itemRiskColor, l10n);
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 24),

          // Detail Inspector Pane (48% width)
          Expanded(
            flex: 48,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF161F30) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF283548)
                      : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: _buildCaseInspector(
                    context, activeCase, riskColor, theme, isDark, l10n),
              ),
            ),
          ),
        ],
      );
    }

    // On Mobile & Tablet: Standard card list with popup details
    return ListView.separated(
      itemCount: filteredCases.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = filteredCases[index];
        final riskColor = riskTheme.getColor(item.riskLevel);

        return _buildCaseCard(
          context,
          item,
          riskColor,
          false,
          theme,
          isDark,
          l10n,
          onTap: () => _showDetailsDialog(context, item, riskColor, l10n),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // CASE CARD WIDGET
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildCaseCard(
    BuildContext context,
    EmergencyCase item,
    Color riskColor,
    bool isSelected,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n, {
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                    ? const Color(0xFF1E293B)
                    : const Color(0xFFF1F5F9))
                : (isDark
                    ? const Color(0xFF131C2E)
                    : Colors.white),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : (isDark
                      ? const Color(0xFF283548)
                      : const Color(0xFFE2E8F0)),
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: riskColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
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
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _formatDate(item.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: riskColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: riskColor.withAlpha(70)),
                    ),
                    child: Text(
                      item.riskLevel.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: riskColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (item.lastKnownLocation != null) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${item.lastKnownLocation!.latitude.toStringAsFixed(3)}, ${item.lastKnownLocation!.longitude.toStringAsFixed(3)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    l10n?.viewDetails ?? 'View Details',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 3),
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
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // DESKTOP CASE INSPECTOR PANEL
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildCaseInspector(
    BuildContext context,
    EmergencyCase item,
    Color riskColor,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: riskColor.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIconForType(item.type),
                  color: riskColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getTitleForType(item.type, l10n)} Record',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Case Reference #${item.id.substring(0, item.id.length > 10 ? 10 : item.id.length)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            _buildStatusBadge(item.status, theme),
          ],
        ),
        const SizedBox(height: 18),
        const Divider(height: 1),
        const SizedBox(height: 18),

        // Core Meta Info Grid
        _detailRow('Classification', item.type.code.toUpperCase()),
        _detailRow('Risk Rating', item.riskLevel.label),
        _detailRow('Lifecycle Status', item.status.code.toUpperCase()),
        _detailRow('Dispatch Time', _formatDate(item.createdAt)),
        if (item.resolvedAt != null)
          _detailRow('Resolution Time', _formatDate(item.resolvedAt!)),

        // Geotagged Coordinates
        if (item.lastKnownLocation != null) ...[
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          const Text(
            'Emergency GPS Coordinates',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.place_rounded,
                    color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lat: ${item.lastKnownLocation!.latitude.toStringAsFixed(6)}, Lon: ${item.lastKnownLocation!.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final lat = item.lastKnownLocation!.latitude;
                      final lng = item.lastKnownLocation!.longitude;
                      final url = Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                      launchUrl(url, mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: const Text('Open in Google Maps',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Triage Assessment Responses
        if (item.triageAnswers.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          const Text(
            'Clinical Triage Evaluation Responses',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: item.triageAnswers.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${e.key}: ${e.value}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // STATUS BADGE
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildStatusBadge(EmergencyStatus status, ThemeData theme) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case EmergencyStatus.active:
        bg = const Color(0xFFDC2626);
        fg = Colors.white;
        label = 'ACTIVE';
        break;
      case EmergencyStatus.resolved:
        bg = const Color(0xFF059669);
        fg = Colors.white;
        label = 'RESOLVED';
        break;
      case EmergencyStatus.cancelled:
        bg = theme.colorScheme.surfaceContainerHighest;
        fg = theme.colorScheme.onSurfaceVariant;
        label = 'CANCELLED';
        break;
      case EmergencyStatus.falseAlarm:
        bg = const Color(0xFFD97706);
        fg = Colors.white;
        label = 'FALSE ALARM';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
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
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: riskColor.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_getIconForType(item.type), color: riskColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n?.caseDetails ?? 'Emergency Case Details',
                style:
                    const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: _buildCaseInspector(
                context, item, riskColor, theme, isDark, l10n),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$title:',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
