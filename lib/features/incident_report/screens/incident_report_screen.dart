import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safelife/core/constants/emergency_numbers.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/incident_report/models/incident_report.dart';
import 'package:safelife/features/incident_report/repositories/incident_report_repository.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class IncidentReportScreen extends StatefulWidget {
  final IncidentReportRepository? repository;
  final LocationService? locationService;

  const IncidentReportScreen({
    super.key,
    this.repository,
    this.locationService,
  });

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen>
    with SingleTickerProviderStateMixin {
  late final IncidentReportRepository _repo;
  late final LocationService _locationService;
  late final TabController _mobileTabController;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'harassment';
  bool _attachLocation = true;
  EmergencyLocation? _currentLocation;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  final List<String> _categories = const [
    'harassment',
    'stalking',
    'threat',
    'suspicious',
  ];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? IncidentReportRepository();
    _locationService = widget.locationService ?? const LocationService();
    _mobileTabController = TabController(length: 2, vsync: this);
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _mobileTabController.dispose();
    super.dispose();
  }

  Future<void> _fetchCurrentLocation() async {
    if (!_attachLocation || !mounted) return;
    setState(() => _isLoadingLocation = true);
    try {
      final loc = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentLocation = loc;
          _isLoadingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<SafeLifeAuthProvider>();
    final userId = auth.user?.uid ?? 'anonymous_user';
    final userName =
        auth.userProfile?.name ?? auth.user?.displayName ?? 'Anonymous User';
    final userPhone = auth.userProfile?.phone ?? auth.user?.phoneNumber ?? '';

    setState(() => _isSubmitting = true);

    try {
      EmergencyLocation? locationToSave;
      if (_attachLocation) {
        locationToSave =
            _currentLocation ?? await _locationService.getCurrentLocation();
      }

      final report = IncidentReport(
        id: '',
        userId: userId,
        userName: userName,
        userPhone: userPhone,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        location: locationToSave,
        createdAt: DateTime.now(),
      );

      await _repo.createReport(report);

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n?.reportSubmitted ??
                        'Incident report submitted successfully and encrypted.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _descriptionController.clear();
        setState(() {
          _selectedCategory = 'harassment';
          _isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit report: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _getCategoryLabel(String category, AppLocalizations? l10n) {
    switch (category) {
      case 'harassment':
        return l10n?.categoryHarassment ?? 'Harassment';
      case 'stalking':
        return l10n?.categoryStalking ?? 'Stalking';
      case 'threat':
        return l10n?.categoryThreat ?? 'Physical Threat';
      case 'suspicious':
        return l10n?.categorySuspicious ?? 'Suspicious Activity';
      default:
        return category;
    }
  }

  String _getCategoryDescription(String category) {
    switch (category) {
      case 'harassment':
        return 'Verbal abuse, inappropriate gestures, catcalling, or intimidation';
      case 'stalking':
        return 'Being followed, monitored, or repeated unwanted presence';
      case 'threat':
        return 'Direct violence, physical danger, weapon intimidation, or coercion';
      case 'suspicious':
        return 'Suspicious loitering, unsolicited recording, or alarming behavior';
      default:
        return 'General safety concern';
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'harassment':
        return Icons.record_voice_over_rounded;
      case 'stalking':
        return Icons.directions_walk_rounded;
      case 'threat':
        return Icons.warning_amber_rounded;
      case 'suspicious':
        return Icons.visibility_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'harassment':
        return const Color(0xFFE11D48); // Rose
      case 'stalking':
        return const Color(0xFFD97706); // Amber
      case 'threat':
        return const Color(0xFFDC2626); // Crimson
      case 'suspicious':
        return const Color(0xFF4F46E5); // Indigo
      default:
        return const Color(0xFF7C3AED);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<SafeLifeAuthProvider>();
    final userId = auth.user?.uid ?? '';

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 1024;
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
                    color: const Color(0xFFE11D48).withAlpha(28),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: Color(0xFFE11D48),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  l10n?.incidentReportTitle ?? 'Report Safety Incident',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            elevation: 0,
            actions: [
              // Fast 999 Help Call Action
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(
                          color: Color(0xFFDC2626), width: 1.5),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final url = Uri.parse(
                          'tel:${EmergencyNumbers.nationalEmergency}');
                      launchUrl(url);
                    },
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text(
                      'Emergency 999',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
            bottom: TabBar(
              controller: _mobileTabController,
              tabs: [
                Tab(
                  icon: const Icon(Icons.edit_note_rounded),
                  text: l10n?.incidentReportTitle ?? 'New Report',
                ),
                Tab(
                  icon: const Icon(Icons.history_rounded),
                  text: l10n?.myReports ?? 'My Incident Reports',
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: isDesktop
                    ? _buildDesktopView(
                        context, theme, isDark, horizontalPadding, userId, l10n)
                    : _buildMobileTabletView(context, theme, isDark,
                        horizontalPadding, userId, l10n),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // DESKTOP LAYOUT (Dual-pane side-by-side web experience)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildDesktopView(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    double horizontalPadding,
    String userId,
    AppLocalizations? l10n,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero Banner
          _buildHeroBanner(context, theme, isDark, true),
          const SizedBox(height: 28),

          // Dual-Column Content
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Form (approx 58%)
              Expanded(
                flex: 58,
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF161F30)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF283548)
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 50 : 12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _buildFormContent(context, theme, isDark, l10n),
                ),
              ),
              const SizedBox(width: 28),

              // Right Column: Incident History & Guidelines (approx 42%)
              Expanded(
                flex: 42,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Confidentiality & Legal Notice Card
                    _buildAdvisoryCard(context, theme, isDark),
                    const SizedBox(height: 20),

                    // Submitted Reports Stream Card
                    Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161F30)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF283548)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(isDark ? 50 : 12),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary
                                        .withAlpha(24),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.history_rounded,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Submitted Reports Feed',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        'Encrypted log of your past submissions',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color:
                                              theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          SizedBox(
                            height: 600,
                            child: _MyReportsListView(
                              repo: _repo,
                              userId: userId,
                              scrollable: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // MOBILE / TABLET LAYOUT (Tabbed view with responsive hero)
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildMobileTabletView(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    double horizontalPadding,
    String userId,
    AppLocalizations? l10n,
  ) {
    return Column(
      children: [
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _mobileTabController,
            children: [
              // Tab 1: Form
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeroBanner(context, theme, isDark, false),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161F30)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF283548)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: _buildFormContent(context, theme, isDark, l10n),
                    ),
                  ],
                ),
              ),

              // Tab 2: My Reports
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: 16),
                child: Column(
                  children: [
                    _buildAdvisoryCard(context, theme, isDark),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _MyReportsListView(
                        repo: _repo,
                        userId: userId,
                        scrollable: true,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
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
      padding: EdgeInsets.all(isDesktop ? 30 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  const Color(0xFF1E1B4B),
                  const Color(0xFF311042),
                  const Color(0xFF111827),
                ]
              : [
                  const Color(0xFF3730A3),
                  const Color(0xFF6B21A8),
                  const Color(0xFF9D174D),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 18,
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
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(60)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'CONFIDENTIAL & ENCRYPTED REPORTING',
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
              if (isDesktop)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user_rounded,
                          color: Color(0xFF34D399), size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Zero-Knowledge Local Storage Fallback',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Safety & Harassment Incident Center',
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 26 : 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Record harassment, stalking, threats, or suspicious activity with timestamped details and GPS geotagging. Your reports establish vital evidence for legal and protective actions.',
            style: TextStyle(
              color: Colors.white.withAlpha(220),
              fontSize: isDesktop ? 14 : 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _buildFeatureBadge(
                icon: Icons.shield_outlined,
                label: 'Anonymous / Encrypted ID',
              ),
              _buildFeatureBadge(
                icon: Icons.my_location_rounded,
                label: 'Geotagged Coordinates',
              ),
              _buildFeatureBadge(
                icon: Icons.gavel_rounded,
                label: 'GDPR / Local Law Compliant',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // ADVISORY CARD
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildAdvisoryCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E2235)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFF334155)
              : const Color(0xFFCBD5E1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: theme.colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Important Safety Guidance',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• Immediate Danger: If someone is chasing, threatening, or assaulting you, trigger the SOS button immediately or dial 999 directly.\n'
            '• Evidence Preservation: Take note of physical attire, license plate numbers, street markers, or vehicle models.\n'
            '• Privacy Guarantee: This report is securely stored and can be exported as legal evidence for law enforcement.',
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════════
  // FORM CONTENT
  // ═════════════════════════════════════════════════════════════════════════════
  Widget _buildFormContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section Title: Incident Classification
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n?.category ?? 'Select Incident Category',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Category Cards via responsive ChoiceChips
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _categories.map((cat) {
              final isSelected = _selectedCategory == cat;
              final catColor = _getCategoryColor(cat);
              return ChoiceChip(
                avatar: Icon(
                  _getCategoryIcon(cat),
                  size: 18,
                  color: isSelected ? Colors.white : catColor,
                ),
                label: Text(_getCategoryLabel(cat, l10n)),
                selected: isSelected,
                selectedColor: catColor,
                backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? catColor
                        : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                  ),
                ),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF1E293B)),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  fontSize: 13,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedCategory = cat);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _getCategoryDescription(_selectedCategory),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Section Title: Incident Details
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n?.incidentDescription ?? 'Incident Narrative & Context',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          TextFormField(
            controller: _descriptionController,
            maxLines: 6,
            minLines: 4,
            decoration: InputDecoration(
              hintText: l10n?.incidentDescriptionHint ??
                  'Describe what occurred in detail: approximate time, exact landmark or street name, suspect description (clothing, height, vehicle), and any bystander reactions...',
              hintStyle: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(160),
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              alignLabelWithHint: true,
            ),
            validator: (value) {
              if (value == null || value.trim().length < 10) {
                return 'Please provide at least 10 characters of descriptive detail.';
              }
              return null;
            },
          ),
          const SizedBox(height: 22),

          // Section Title: Location Geotagging
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n?.attachLocation ?? 'Geotagging & Location Attachment',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Location Container Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F172A)
                  : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _attachLocation
                        ? theme.colorScheme.primary.withAlpha(25)
                        : Colors.grey.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.my_location_rounded,
                    color: _attachLocation
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.attachLocation ?? 'Attach Current GPS Coordinates',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      _isLoadingLocation
                          ? const Row(
                              children: [
                                SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 1.5),
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Acquiring high-accuracy GPS fix...',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ],
                            )
                          : _currentLocation != null
                              ? Text(
                                  'Lat: ${_currentLocation!.latitude.toStringAsFixed(5)}, Lon: ${_currentLocation!.longitude.toStringAsFixed(5)}',
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                )
                              : Text(
                                  'No location coordinates acquired yet.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                    ],
                  ),
                ),
                if (_attachLocation)
                  IconButton(
                    tooltip: 'Refresh Location',
                    onPressed:
                        _isLoadingLocation ? null : _fetchCurrentLocation,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                  ),
                Switch(
                  value: _attachLocation,
                  onChanged: (val) {
                    setState(() => _attachLocation = val);
                    if (val && _currentLocation == null) {
                      _fetchCurrentLocation();
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Submit Action Button
          MouseRegion(
            cursor: _isSubmitting
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _isSubmitting ? null : _handleSubmit,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 20),
                label: Text(
                  _isSubmitting
                      ? 'Securing and Submitting Report...'
                      : (l10n?.submitReport ?? 'Submit Incident Report'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// MY REPORTS LIST VIEW
// ═════════════════════════════════════════════════════════════════════════════
class _MyReportsListView extends StatelessWidget {
  final IncidentReportRepository repo;
  final String userId;
  final bool scrollable;

  const _MyReportsListView({
    required this.repo,
    required this.userId,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    if (userId.isEmpty) {
      return FutureBuilder<List<IncidentReport>>(
        future: repo.getCachedReports(),
        builder: (context, snapshot) {
          final reports = snapshot.data ?? [];
          return _buildList(context, reports);
        },
      );
    }

    return StreamBuilder<List<IncidentReport>>(
      stream: repo.streamUserReports(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          return FutureBuilder<List<IncidentReport>>(
            future: repo.getCachedReports(),
            builder: (context, cacheSnap) {
              final cached = cacheSnap.data ?? [];
              return _buildList(context, cached);
            },
          );
        }

        return _buildList(context, reports);
      },
    );
  }

  Widget _buildList(BuildContext context, List<IncidentReport> reports) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 48,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No incident reports submitted yet.',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your submitted reports will be recorded here securely with timestamps and status.',
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

    return ListView.separated(
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      shrinkWrap: !scrollable,
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final r = reports[index];
        final catColor = _getCategoryColor(r.category);

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0F172A)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF283548)
                  : const Color(0xFFE2E8F0),
            ),
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
                      color: catColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: catColor.withAlpha(80)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(r.category),
                          size: 14,
                          color: catColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          r.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: catColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')} ${r.createdAt.hour.toString().padLeft(2, '0')}:${r.createdAt.minute.toString().padLeft(2, '0')}',
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                r.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  fontSize: 13,
                ),
              ),
              if (r.location != null) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 15,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GPS: ${r.location!.latitude.toStringAsFixed(4)}, ${r.location!.longitude.toStringAsFixed(4)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          final lat = r.location!.latitude;
                          final lng = r.location!.longitude;
                          final url = Uri.parse(
                              'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                          launchUrl(url, mode: LaunchMode.externalApplication);
                        },
                        icon: const Icon(Icons.open_in_new_rounded, size: 12),
                        label: const Text(
                          'View on Map',
                          style: TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'harassment':
        return const Color(0xFFE11D48);
      case 'stalking':
        return const Color(0xFFD97706);
      case 'threat':
        return const Color(0xFFDC2626);
      case 'suspicious':
        return const Color(0xFF4F46E5);
      default:
        return const Color(0xFF7C3AED);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'harassment':
        return Icons.record_voice_over_rounded;
      case 'stalking':
        return Icons.directions_walk_rounded;
      case 'threat':
        return Icons.warning_amber_rounded;
      case 'suspicious':
        return Icons.visibility_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }
}
