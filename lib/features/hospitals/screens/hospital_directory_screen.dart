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

    final hospitals = _repo.getHospitals(
      userLat: _userLocation?.latitude,
      userLng: _userLocation?.longitude,
      searchQuery: _searchController.text,
      only24x7: _selectedFilter == '24x7' ? true : null,
      onlyCathLab: _selectedFilter == 'cathLab' ? true : null,
      onlyStroke: _selectedFilter == 'stroke' ? true : null,
      onlyICU: _selectedFilter == 'icu' ? true : null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.hospitalDirectoryTitle ?? 'Emergency Hospitals'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
          // Search & Filter Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n?.searchHospitalsHint ?? 'Search by hospital name or area...',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Capability Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                  avatar: const Icon(Icons.access_time_filled_rounded, size: 16),
                  label: Text(l10n?.filter24x7 ?? '24/7 Emergency'),
                  selected: _selectedFilter == '24x7',
                  onSelected: (selected) {
                    setState(() => _selectedFilter = selected ? '24x7' : null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.favorite_rounded, size: 16),
                  label: Text(l10n?.filterCathLab ?? 'Cardiac (Cath Lab)'),
                  selected: _selectedFilter == 'cathLab',
                  onSelected: (selected) {
                    setState(() => _selectedFilter = selected ? 'cathLab' : null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.medical_services_rounded, size: 16),
                  label: Text(l10n?.filterStrokeCenter ?? 'Stroke Care'),
                  selected: _selectedFilter == 'stroke',
                  onSelected: (selected) {
                    setState(() => _selectedFilter = selected ? 'stroke' : null);
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  avatar: const Icon(Icons.local_hospital_rounded, size: 16),
                  label: Text(l10n?.filterICU ?? 'ICU Available'),
                  selected: _selectedFilter == 'icu',
                  onSelected: (selected) {
                    setState(() => _selectedFilter = selected ? 'icu' : null);
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 16),

          // Hospital List
          Expanded(
            child: hospitals.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_hospital_outlined,
                              size: 64, color: theme.colorScheme.outlineVariant),
                          const SizedBox(height: 16),
                          Text(
                            'No matching emergency facilities found.',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: hospitals.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final h = hospitals[index];
                      final distance = _userLocation != null
                          ? h.distanceTo(_userLocation!.latitude, _userLocation!.longitude)
                          : null;

                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: h.hasCathLab || h.hasStrokeThrombolysis
                                        ? theme.colorScheme.primaryContainer
                                        : theme.colorScheme.surfaceContainerHighest,
                                    child: Icon(
                                      Icons.local_hospital_rounded,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isBangla && h.banglaName.isNotEmpty
                                              ? h.banglaName
                                              : h.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          h.address,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (distance != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer.withAlpha(120),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        l10n?.distanceKm(distance.toStringAsFixed(1)) ??
                                            '${distance.toStringAsFixed(1)} km',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Capability badges
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  if (h.is24x7)
                                    _capabilityBadge('24/7 ER', Colors.green.shade800, theme),
                                  if (h.hasCathLab)
                                    _capabilityBadge('Cath Lab (PCI)', Colors.red.shade800, theme),
                                  if (h.hasStrokeThrombolysis)
                                    _capabilityBadge('Stroke Care (tPA)', Colors.purple.shade800, theme),
                                  if (h.hasICU)
                                    _capabilityBadge('ICU', Colors.blue.shade800, theme),
                                  _capabilityBadge(
                                    h.type == 'government' ? 'Govt' : 'Private',
                                    theme.colorScheme.onSurfaceVariant,
                                    theme,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Action buttons
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: theme.colorScheme.error,
                                        side: BorderSide(color: theme.colorScheme.error),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      onPressed: () => _makeCall(h.phone),
                                      icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                                      label: Text(l10n?.callHotline ?? 'Call Hotline'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: FilledButton.tonalIcon(
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                      ),
                                      onPressed: () => _openDirections(h.latitude, h.longitude),
                                      icon: const Icon(Icons.directions_rounded, size: 18),
                                      label: Text(l10n?.getDirections ?? 'Directions'),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _capabilityBadge(String label, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
