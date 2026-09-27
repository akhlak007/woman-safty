import 'package:flutter/material.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/hospitals/repositories/hospital_repository.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalDirectoryScreen extends StatefulWidget {
  final HospitalRepository? repository;
  final LocationService? locationService;

  const HospitalDirectoryScreen({
    super.key,
    this.repository,
    this.locationService,
  });

  @override
  State<HospitalDirectoryScreen> createState() => _HospitalDirectoryScreenState();
}

class _HospitalDirectoryScreenState extends State<HospitalDirectoryScreen> {
  late final HospitalRepository _repo;
  late final LocationService _locationService;

  final TextEditingController _searchController = TextEditingController();
  EmergencyLocation? _userLocation;

  String? _selectedFilter; // null = all, '24x7', 'cathLab', 'stroke', 'icu'

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? const HospitalRepository();
    _locationService = widget.locationService ?? const LocationService();
    _fetchLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      final loc = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _userLocation = loc;
        });
      }
    } catch (_) {}
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

  Future<void> _openDirections(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    final isDark = theme.brightness == Brightness.dark;

    final hospitals = _repo.getHospitals(
      userLat: _userLocation?.latitude,
      userLng: _userLocation?.longitude,
      searchQuery: _searchController.text,
      only24x7: _selectedFilter == '24x7' ? true : null,
      onlyCathLab: _selectedFilter == 'cathLab' ? true : null,
      onlyStroke: _selectedFilter == 'stroke' ? true : null,
      onlyICU: _selectedFilter == 'icu' ? true : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 960;
        final isTablet = screenWidth >= 600 && screenWidth < 960;
        final horizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n?.hospitalDirectoryTitle ?? 'Emergency Hospitals',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            elevation: 0,
            actions: [
              if (_userLocation != null)
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(25),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: const Color(0xFF10B981).withAlpha(70)),
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
                          Text(
                            isBangla ? 'জিপিএস সক্রিয়' : 'GPS Active',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: CustomScrollView(
                slivers: [
                  // Web Hero Banner Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isDesktop ? 24 : 12,
                        horizontalPadding,
                        16,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(isDesktop ? 32 : 20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isDark
                                ? [
                                    const Color(0xFF131D31),
                                    const Color(0xFF1A263D),
                                    const Color(0xFF0F172A),
                                  ]
                                : [
                                    const Color(0xFF0F2B48),
                                    const Color(0xFF1A456E),
                                    const Color(0xFF146C94),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 18,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(25),
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(color: Colors.white.withAlpha(50)),
                                    ),
                                    child: Text(
                                      isBangla ? '২৪/৭ ট্রমা ও জরুরি চিকিৎসা কেন্দ্র' : '24/7 TRAUMA & EMERGENCY CARE',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    isBangla
                                        ? 'নিকটস্থ জরুরি হাসপাতাল ও বিশেষায়িত কেন্দ্র'
                                        : 'Find Verified Emergency Hospitals Near You',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 32 : 22,
                                      fontWeight: FontWeight.w900,
                                      height: 1.18,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 680),
                                    child: Text(
                                      isBangla
                                          ? 'ক্যাথ ল্যাব (PCI), স্ট্রোক কেয়ার, আইসিইউ এবং ২৪/৭ জরুরি সুবিধা সম্বলিত হাসপাতালের তাৎক্ষণিক যোগাযোগ ও সরাসরি দিকনির্দেশনা।'
                                          : 'Locate 24/7 emergency departments, Cardiac Cath Labs, Stroke triage units, and ICU facilities with real-time distance and one-touch dispatch.',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(225),
                                        fontSize: isDesktop ? 14 : 13,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: 24),
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withAlpha(40), width: 2),
                                ),
                                child: const Icon(
                                  Icons.local_hospital_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Search and Filters Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 8,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant.withAlpha(70),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(isDark ? 25 : 8),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Search input field
                            TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: l10n?.searchHospitalsHint ?? 'Search by hospital name, area, or specialty...',
                                prefixIcon: const Icon(Icons.search_rounded),
                                suffixIcon: _searchController.text.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear_rounded),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant.withAlpha(100),
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 14),

                            // Filter Chips Row / Wrap
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _FilterChipButton(
                                  label: l10n?.filterAll ?? 'All Facilities',
                                  selected: _selectedFilter == null,
                                  onSelected: () => setState(() => _selectedFilter = null),
                                ),
                                _FilterChipButton(
                                  icon: Icons.access_time_filled_rounded,
                                  label: l10n?.filter24x7 ?? '24/7 Emergency',
                                  selected: _selectedFilter == '24x7',
                                  onSelected: () => setState(
                                    () => _selectedFilter = _selectedFilter == '24x7' ? null : '24x7',
                                  ),
                                ),
                                _FilterChipButton(
                                  icon: Icons.favorite_rounded,
                                  label: l10n?.filterCathLab ?? 'Cardiac (Cath Lab)',
                                  selected: _selectedFilter == 'cathLab',
                                  onSelected: () => setState(
                                    () => _selectedFilter = _selectedFilter == 'cathLab' ? null : 'cathLab',
                                  ),
                                ),
                                _FilterChipButton(
                                  icon: Icons.medical_services_rounded,
                                  label: l10n?.filterStrokeCenter ?? 'Stroke Care',
                                  selected: _selectedFilter == 'stroke',
                                  onSelected: () => setState(
                                    () => _selectedFilter = _selectedFilter == 'stroke' ? null : 'stroke',
                                  ),
                                ),
                                _FilterChipButton(
                                  icon: Icons.local_hospital_rounded,
                                  label: l10n?.filterICU ?? 'ICU Available',
                                  selected: _selectedFilter == 'icu',
                                  onSelected: () => setState(
                                    () => _selectedFilter = _selectedFilter == 'icu' ? null : 'icu',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Results count label
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isBangla
                                ? '${hospitals.length} টি জরুরি হাসপাতাল পাওয়া গেছে'
                                : 'Showing ${hospitals.length} emergency facilities',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (_userLocation != null)
                            Text(
                              isBangla ? 'দূরত্ব অনুসারে সাজানো' : 'Sorted by proximity',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Empty State or Responsive Grid
                  if (hospitals.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.local_hospital_outlined,
                                size: 68,
                                color: theme.colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isBangla
                                    ? 'কোনো হাসপাতাল খুঁজে পাওয়া যায়নি।'
                                    : 'No matching emergency facilities found.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isBangla
                                    ? 'অনুগ্রহ করে সার্চ বা ফিল্টারের ধরন পরিবর্তন করুন।'
                                    : 'Try clearing your search query or capability filter.',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        4,
                        horizontalPadding,
                        48,
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isDesktop ? 2 : 1,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          mainAxisExtent: 220,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final h = hospitals[index];
                            final distance = _userLocation != null
                                ? h.distanceTo(_userLocation!.latitude, _userLocation!.longitude)
                                : null;

                            return _WebHospitalCard(
                              hospital: h,
                              distance: distance,
                              isBangla: isBangla,
                              onCall: () => _makeCall(h.phone),
                              onDirections: () => _openDirections(h.latitude, h.longitude),
                            );
                          },
                          childCount: hospitals.length,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSIVE FILTER CHIP BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChipButton extends StatefulWidget {
  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _FilterChipButton({
    this.icon,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_FilterChipButton> createState() => _FilterChipButtonState();
}

class _FilterChipButtonState extends State<_FilterChipButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: widget.onSelected,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: widget.selected
                ? primary.withAlpha(28)
                : (_hovered ? theme.colorScheme.surfaceContainerHighest.withAlpha(120) : theme.colorScheme.surface),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.selected
                  ? primary
                  : (_hovered ? primary.withAlpha(120) : theme.colorScheme.outlineVariant.withAlpha(80)),
              width: widget.selected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: 15,
                  color: widget.selected ? primary : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.selected ? FontWeight.w900 : FontWeight.w600,
                  color: widget.selected ? primary : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSIVE WEB HOSPITAL CARD WITH HOVER LIFT
// ─────────────────────────────────────────────────────────────────────────────

class _WebHospitalCard extends StatefulWidget {
  final dynamic hospital;
  final double? distance;
  final bool isBangla;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _WebHospitalCard({
    required this.hospital,
    required this.distance,
    required this.isBangla,
    required this.onCall,
    required this.onDirections,
  });

  @override
  State<_WebHospitalCard> createState() => _WebHospitalCardState();
}

class _WebHospitalCardState extends State<_WebHospitalCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final h = widget.hospital;

    final hasCriticalCare = h.hasCathLab || h.hasStrokeThrombolysis;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.primary.withAlpha(160)
                : theme.colorScheme.outlineVariant.withAlpha(70),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 45 : 20),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 25 : 8),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: hasCriticalCare
                          ? theme.colorScheme.primary.withAlpha(25)
                          : theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: hasCriticalCare ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.isBangla && h.banglaName.isNotEmpty ? h.banglaName : h.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          h.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.distance != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondaryContainer.withAlpha(140),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.near_me_rounded, size: 12, color: theme.colorScheme.onSecondaryContainer),
                          const SizedBox(width: 4),
                          Text(
                            l10n?.distanceKm(widget.distance!.toStringAsFixed(1)) ??
                                '${widget.distance!.toStringAsFixed(1)} km',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),

              // Capabilities badges
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (h.is24x7) _badge('24/7 ER', const Color(0xFF10B981)),
                  if (h.hasCathLab) _badge('Cath Lab (PCI)', const Color(0xFFDC2626)),
                  if (h.hasStrokeThrombolysis) _badge('Stroke Care (tPA)', const Color(0xFF8B5CF6)),
                  if (h.hasICU) _badge('ICU', const Color(0xFF0284C7)),
                  _badge(h.type == 'government' ? 'Govt' : 'Private', theme.colorScheme.onSurfaceVariant),
                ],
              ),

              // Dual Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error.withAlpha(140)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: widget.onCall,
                      icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                      label: Text(
                        l10n?.callHotline ?? 'Call Hotline',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: widget.onDirections,
                      icon: const Icon(Icons.directions_rounded, size: 16),
                      label: Text(
                        l10n?.getDirections ?? 'Directions',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
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

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withAlpha(85)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
