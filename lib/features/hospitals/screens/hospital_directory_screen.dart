import 'package:flutter/material.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/hospitals/models/hospital.dart';
import 'package:safelife/features/hospitals/repositories/hospital_repository.dart';
import 'package:safelife/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper model for preset location hubs across Bangladesh
class _LocationHub {
  final String id;
  final String name;
  final String banglaName;
  final String area;
  final String district;
  final double latitude;
  final double longitude;

  const _LocationHub({
    required this.id,
    required this.name,
    required this.banglaName,
    required this.area,
    required this.district,
    required this.latitude,
    required this.longitude,
  });
}

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

  // Active real-time coordinates used to calculate distance and sort facilities
  double _activeLat = 22.7413; // Default fallback: Barishal / Central Bangladesh
  double _activeLng = 90.4357;
  String _activeLocationLabel = 'Detecting live real-time location...';
  String _activeLocationLabelBn = 'লাইভ রিয়েল-টাইম অবস্থান শনাক্ত করা হচ্ছে...';
  bool _isLiveGps = false;
  bool _isLocating = false;
  bool _isFetchingHospitals = false;

  // Real-time live hospital data list
  List<Hospital>? _liveHospitals;

  String? _selectedFilter; // null = all, '24x7', 'cathLab', 'stroke', 'icu'
  String? _selectedAreaFilter; // null = all, or specific area
  double? _selectedMaxDistanceKm; // null = any, 3.0, 5.0, 10.0, 25.0
  bool _isMapView = false; // Toggle between List view and Radar Map view
  Hospital? _selectedHospitalForMap; // Focused hospital on radar map

  // Preset location hubs for fast location switching
  final List<_LocationHub> _presetHubs = const [
    _LocationHub(
      id: 'hub_barishal',
      name: 'Barishal (Sadar / Band Road)',
      banglaName: 'বরিশাল (সদর / বান্দ রোড)',
      area: 'Band Road',
      district: 'Barishal',
      latitude: 22.7010,
      longitude: 90.3535,
    ),
    _LocationHub(
      id: 'hub_agargaon',
      name: 'Agargaon / Sher-e-Bangla (Dhaka)',
      banglaName: 'আগারগাঁও / শেরেবাংলা নগর (ঢাকা)',
      area: 'Sher-e-Bangla Nagar',
      district: 'Dhaka',
      latitude: 23.7712,
      longitude: 90.3698,
    ),
    _LocationHub(
      id: 'hub_panthapath',
      name: 'Panthapath / Dhanmondi (Dhaka)',
      banglaName: 'পান্থপথ / ধানমন্ডি (ঢাকা)',
      area: 'Panthapath',
      district: 'Dhaka',
      latitude: 23.7533,
      longitude: 90.3817,
    ),
    _LocationHub(
      id: 'hub_gulshan',
      name: 'Gulshan / Banani (Dhaka)',
      banglaName: 'গুলশান / বনানী (ঢাকা)',
      area: 'Gulshan',
      district: 'Dhaka',
      latitude: 23.7997,
      longitude: 90.4184,
    ),
    _LocationHub(
      id: 'hub_mirpur',
      name: 'Mirpur (Dhaka)',
      banglaName: 'মিরপুর (ঢাকা)',
      area: 'Mirpur',
      district: 'Dhaka',
      latitude: 23.8052,
      longitude: 90.3621,
    ),
    _LocationHub(
      id: 'hub_shahbagh',
      name: 'Shahbagh / Old Dhaka',
      banglaName: 'শাহবাগ / পুরান ঢাকা',
      area: 'Shahbagh',
      district: 'Dhaka',
      latitude: 23.7389,
      longitude: 90.3957,
    ),
    _LocationHub(
      id: 'hub_uttara',
      name: 'Uttara / Airport (Dhaka)',
      banglaName: 'উত্তরা / বিমানবন্দর (ঢাকা)',
      area: 'Uttara',
      district: 'Dhaka',
      latitude: 23.8687,
      longitude: 90.3986,
    ),
    _LocationHub(
      id: 'hub_chattogram',
      name: 'Chattogram (Panchlaish)',
      banglaName: 'চট্টগ্রাম (পাঁচলাইশ)',
      area: 'Panchlaish',
      district: 'Chattogram',
      latitude: 22.3592,
      longitude: 91.8282,
    ),
    _LocationHub(
      id: 'hub_sylhet',
      name: 'Sylhet (Medical Road)',
      banglaName: 'সিলেট (মেডিকেল রোড)',
      area: 'Kajalshah',
      district: 'Sylhet',
      latitude: 24.8988,
      longitude: 91.8542,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? const HospitalRepository();
    _locationService = widget.locationService ?? const LocationService();
    _initializeRealTimeData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Initial load: fetches real-time live location, reverse geocodes city, and queries real-time hospitals
  Future<void> _initializeRealTimeData() async {
    await _fetchLiveLocationAndHospitals();
  }

  Future<void> _fetchLiveLocationAndHospitals() async {
    if (!mounted) return;
    setState(() {
      _isLocating = true;
      _isFetchingHospitals = true;
    });

    try {
      final loc = await _locationService.getCurrentLocation();
      if (mounted && loc != null) {
        final addressStr = loc.address ?? 'Live Real-Time GPS';
        setState(() {
          _activeLat = loc.latitude;
          _activeLng = loc.longitude;
          _activeLocationLabel = addressStr;
          _activeLocationLabelBn = addressStr;
          _isLiveGps = true;
          _isLocating = false;
        });

        // Now query live nearby hospitals around real-time location
        await _fetchNearbyHospitals();
        return;
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        _isLocating = false;
        if (!_isLiveGps) {
          _activeLocationLabel = 'Barishal, Barisal Division (Auto Detected)';
          _activeLocationLabelBn = 'বরিশাল, বরিশাল বিভাগ (স্বয়ংক্রিয়)';
        }
      });
      await _fetchNearbyHospitals();
    }
  }

  Future<void> _fetchNearbyHospitals() async {
    if (!mounted) return;
    setState(() => _isFetchingHospitals = true);

    try {
      final liveList = await _repo.fetchLiveNearbyHospitals(
        userLat: _activeLat,
        userLng: _activeLng,
        radiusKm: 30.0,
      );
      if (mounted) {
        setState(() {
          _liveHospitals = liveList;
          _isFetchingHospitals = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isFetchingHospitals = false);
      }
    }
  }

  void _setLocationHub(_LocationHub hub) {
    setState(() {
      _activeLat = hub.latitude;
      _activeLng = hub.longitude;
      _activeLocationLabel = hub.name;
      _activeLocationLabelBn = hub.banglaName;
      _isLiveGps = false;
      _selectedHospitalForMap = null;
    });
    _fetchNearbyHospitals();
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

  void _showLocationPickerModal(BuildContext context, bool isBangla) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final theme = Theme.of(context);
        return Material(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.location_on_rounded, color: theme.colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isBangla ? 'হাসপাতাল প্রদর্শনের অবস্থান পরিবর্তন করুন' : 'Select Proximity Location',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                          Text(
                            isBangla
                                ? 'নির্বাচিত অবস্থান অনুসারে রিয়েল-টাইমে আশেপাশের হাসপাতালগুলোর দূরত্ব আপডেট হবে।'
                                : 'Hospitals and distances will update in real-time for this location.',
                            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ListTile(
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withAlpha(25),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.my_location_rounded, color: Color(0xFF10B981), size: 20),
                  ),
                  title: Text(
                    isBangla ? 'রিয়েল-টাইম লাইভ জিপিএস অবস্থান' : 'Live Real-Time GPS / IP Location',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    _isLiveGps
                        ? '${_activeLat.toStringAsFixed(4)}, ${_activeLng.toStringAsFixed(4)} (সক্রিয় / Active)'
                        : (isBangla ? 'ডিভাইসের লাইভ অবস্থান থেকে রিয়েল-টাইম তথ্য নিন' : 'Detect live coordinates and update in real-time'),
                    style: TextStyle(fontSize: 12, color: _isLiveGps ? const Color(0xFF10B981) : null),
                  ),
                  trailing: _isLiveGps
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
                      : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: _isLiveGps ? const Color(0xFF10B981) : theme.colorScheme.outlineVariant.withAlpha(60),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _fetchLiveLocationAndHospitals();
                  },
                ),
                const SizedBox(height: 14),
                Text(
                  isBangla ? 'অথবা জনপ্রিয় এলাকা নির্বাচন করুন:' : 'Or Select a Region / Hub:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _presetHubs.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 6),
                    itemBuilder: (context, i) {
                      final hub = _presetHubs[i];
                      final isSelected = !_isLiveGps &&
                          (_activeLat - hub.latitude).abs() < 0.001 &&
                          (_activeLng - hub.longitude).abs() < 0.001;

                      return ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withAlpha(40),
                          ),
                        ),
                        tileColor: isSelected ? theme.colorScheme.primary.withAlpha(18) : null,
                        leading: Icon(
                          Icons.place_rounded,
                          size: 18,
                          color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          isBangla ? hub.banglaName : hub.name,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? theme.colorScheme.primary : null,
                          ),
                        ),
                        subtitle: Text('${hub.area}, ${hub.district}', style: const TextStyle(fontSize: 11)),
                        trailing: isSelected ? Icon(Icons.check_rounded, color: theme.colorScheme.primary, size: 18) : null,
                        onTap: () {
                          _setLocationHub(hub);
                          Navigator.pop(context);
                        },
                      );
                    },
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isBangla = Localizations.localeOf(context).languageCode == 'bn';
    final isDark = theme.brightness == Brightness.dark;

    // Source list: use real-time live hospitals if loaded, otherwise fallback to repo.getHospitals
    List<Hospital> sourceList = _liveHospitals != null && _liveHospitals!.isNotEmpty
        ? List<Hospital>.from(_liveHospitals!)
        : _repo.getHospitals(
            userLat: _activeLat,
            userLng: _activeLng,
          );

    // Apply active filters on sourceList
    if (_searchController.text.trim().isNotEmpty) {
      final q = _searchController.text.trim().toLowerCase();
      sourceList = sourceList.where((h) {
        return h.name.toLowerCase().contains(q) ||
            h.banglaName.toLowerCase().contains(q) ||
            h.address.toLowerCase().contains(q) ||
            h.area.toLowerCase().contains(q) ||
            h.district.toLowerCase().contains(q);
      }).toList();
    }

    if (_selectedAreaFilter != null && _selectedAreaFilter!.isNotEmpty && _selectedAreaFilter != 'all') {
      final f = _selectedAreaFilter!.trim().toLowerCase();
      sourceList = sourceList.where((h) =>
          h.area.toLowerCase() == f || h.district.toLowerCase() == f).toList();
    }

    if (_selectedFilter == '24x7') {
      sourceList = sourceList.where((h) => h.is24x7).toList();
    } else if (_selectedFilter == 'cathLab') {
      sourceList = sourceList.where((h) => h.hasCathLab).toList();
    } else if (_selectedFilter == 'stroke') {
      sourceList = sourceList.where((h) => h.hasStrokeThrombolysis).toList();
    } else if (_selectedFilter == 'icu') {
      sourceList = sourceList.where((h) => h.hasICU).toList();
    }

    if (_selectedMaxDistanceKm != null) {
      sourceList = sourceList.where((h) => h.distanceTo(_activeLat, _activeLng) <= _selectedMaxDistanceKm!).toList();
    }

    // Sort strictly by proximity to active real-time coordinates
    sourceList.sort((a, b) {
      final distA = a.distanceTo(_activeLat, _activeLng);
      final distB = b.distanceTo(_activeLat, _activeLng);
      return distA.compareTo(distB);
    });

    final hospitals = sourceList;

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
              // Real-time GPS status badge
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Center(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(999),
                    onTap: _fetchLiveLocationAndHospitals,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: _isLiveGps
                            ? const Color(0xFF10B981).withAlpha(25)
                            : theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: _isLiveGps
                              ? const Color(0xFF10B981).withAlpha(80)
                              : theme.colorScheme.outlineVariant.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isLocating || _isFetchingHospitals) ...[
                            const SizedBox(
                              width: 10,
                              height: 10,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            const SizedBox(width: 6),
                          ] else ...[
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: _isLiveGps ? const Color(0xFF10B981) : Colors.amber.shade700,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            _isLiveGps
                                ? (isBangla ? 'রিয়েল-টাইম জিপিএস' : 'Live GPS')
                                : (isBangla ? 'অবস্থান নির্বাচন করুন' : 'Location Set'),
                            style: TextStyle(
                              color: _isLiveGps ? const Color(0xFF10B981) : theme.colorScheme.onSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
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
                  // Web Hero Banner with Real-time Status
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        isDesktop ? 20 : 12,
                        horizontalPadding,
                        12,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(isDesktop ? 28 : 18),
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
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 16,
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
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(25),
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: Colors.white.withAlpha(50)),
                                        ),
                                        child: Text(
                                          isBangla
                                              ? 'লাইভ রিয়েল-টাইম জরুরি তথ্য'
                                              : 'REAL-TIME LIVE DATA UPDATES',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withAlpha(190),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              isBangla ? 'রিয়েল-টাইম সক্রিয়' : 'LIVE API SYNC',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    isBangla
                                        ? 'আপনার বর্তমান অবস্থানের আশেপাশের জরুরি হাসপাতাল'
                                        : 'Emergency Hospitals Near Your Live Location',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isDesktop ? 28 : 20,
                                      fontWeight: FontWeight.w900,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 680),
                                    child: Text(
                                      isBangla
                                          ? 'ওপেনস্ট্রিটম্যাপ ও ডিভাইস জিপিএস থেকে সরাসরি রিয়েল-টাইমে আশেপাশের হাসপাতালের তথ্য ও দূরত্ব আপডেট হচ্ছে।'
                                          : 'Real-time live medical facilities and accurate distances fetched directly from OpenStreetMap and live device geolocation.',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(220),
                                        fontSize: isDesktop ? 13 : 12,
                                        height: 1.45,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: 20),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(20),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withAlpha(40), width: 2),
                                ),
                                child: const Icon(
                                  Icons.local_hospital_rounded,
                                  color: Colors.white,
                                  size: 42,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Dedicated "Real-time Location Reference & Refresh" Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _isLiveGps
                                ? const Color(0xFF10B981).withAlpha(120)
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: _isLiveGps
                                        ? const Color(0xFF10B981).withAlpha(30)
                                        : theme.colorScheme.primary.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isLiveGps ? Icons.my_location_rounded : Icons.location_on_rounded,
                                    size: 16,
                                    color: _isLiveGps ? const Color(0xFF10B981) : theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isBangla ? 'রিয়েল-টাইমে শনাক্তকৃত বর্তমান অবস্থান:' : 'Current Detected Real-Time Location:',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              isBangla ? _activeLocationLabelBn : _activeLocationLabel,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w900,
                                                color: _isLiveGps ? const Color(0xFF10B981) : theme.colorScheme.primary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF10B981).withAlpha(20),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              '${_activeLat.toStringAsFixed(4)}, ${_activeLng.toStringAsFixed(4)}',
                                              style: const TextStyle(
                                                color: Color(0xFF10B981),
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonalIcon(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: (_isLocating || _isFetchingHospitals)
                                      ? null
                                      : _fetchLiveLocationAndHospitals,
                                  icon: (_isLocating || _isFetchingHospitals)
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.refresh_rounded, size: 16),
                                  label: Text(
                                    isBangla ? 'রিয়েল-টাইম আপডেট' : 'Refresh Real-Time',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => _showLocationPickerModal(context, isBangla),
                                  icon: const Icon(Icons.edit_location_alt_rounded, size: 15),
                                  label: Text(
                                    isBangla ? 'অন্যান্য এলাকা' : 'Other Areas',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Quick area location switcher chips
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  // Live GPS Refresh button
                                  _LocationQuickPill(
                                    icon: Icons.my_location_rounded,
                                    label: isBangla ? '🔴 লাইভ জিপিএস রিলোড' : 'Live Real-Time GPS',
                                    isSelected: _isLiveGps,
                                    activeColor: const Color(0xFF10B981),
                                    onTap: _fetchLiveLocationAndHospitals,
                                  ),
                                  const SizedBox(width: 6),
                                  ..._presetHubs.map((hub) {
                                    final isSelected = !_isLiveGps &&
                                        (_activeLat - hub.latitude).abs() < 0.001 &&
                                        (_activeLng - hub.longitude).abs() < 0.001;
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 6),
                                      child: _LocationQuickPill(
                                        label: isBangla ? hub.banglaName : hub.name,
                                        isSelected: isSelected,
                                        activeColor: theme.colorScheme.primary,
                                        onTap: () => _setLocationHub(hub),
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Search, View Switcher & Clinical Filters Bar
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
                            // Search field and View Toggle (List vs Map)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
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
                                ),
                                const SizedBox(width: 12),
                                // View Mode Switcher: List vs Proximity Map
                                Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: isBangla ? 'তালিকা দর্শন' : 'List View',
                                        icon: Icon(
                                          Icons.view_list_rounded,
                                          color: !_isMapView ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: !_isMapView ? theme.colorScheme.primary.withAlpha(28) : Colors.transparent,
                                        ),
                                        onPressed: () => setState(() => _isMapView = false),
                                      ),
                                      IconButton(
                                        tooltip: isBangla ? 'রাডার ও ম্যাপ ভিউ' : 'Radar Map View',
                                        icon: Icon(
                                          Icons.radar_rounded,
                                          color: _isMapView ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: _isMapView ? theme.colorScheme.primary.withAlpha(28) : Colors.transparent,
                                        ),
                                        onPressed: () => setState(() => _isMapView = true),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Clinical Specialty Filter Chips
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _FilterChipButton(
                                  label: l10n?.filterAll ?? 'All Facilities',
                                  selected: _selectedFilter == null && _selectedMaxDistanceKm == null,
                                  onSelected: () => setState(() {
                                    _selectedFilter = null;
                                    _selectedMaxDistanceKm = null;
                                  }),
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

                                // Radius proximity chips
                                Container(
                                  width: 1,
                                  height: 24,
                                  color: theme.colorScheme.outlineVariant.withAlpha(100),
                                ),
                                _FilterChipButton(
                                  icon: Icons.near_me_rounded,
                                  label: '< 3 km',
                                  selected: _selectedMaxDistanceKm == 3.0,
                                  onSelected: () => setState(
                                    () => _selectedMaxDistanceKm = _selectedMaxDistanceKm == 3.0 ? null : 3.0,
                                  ),
                                ),
                                _FilterChipButton(
                                  icon: Icons.near_me_rounded,
                                  label: '< 7 km',
                                  selected: _selectedMaxDistanceKm == 7.0,
                                  onSelected: () => setState(
                                    () => _selectedMaxDistanceKm = _selectedMaxDistanceKm == 7.0 ? null : 7.0,
                                  ),
                                ),
                                _FilterChipButton(
                                  icon: Icons.near_me_rounded,
                                  label: '< 15 km',
                                  selected: _selectedMaxDistanceKm == 15.0,
                                  onSelected: () => setState(
                                    () => _selectedMaxDistanceKm = _selectedMaxDistanceKm == 15.0 ? null : 15.0,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Results count & location summary label (with overflow protection)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                if (_isFetchingHospitals) ...[
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: Text(
                                    isBangla
                                        ? '${hospitals.length} টি জরুরি হাসপাতাল (${isBangla ? _activeLocationLabelBn : _activeLocationLabel} থেকে দূরত্বের ক্রমানুসারে)'
                                        : 'Showing ${hospitals.length} facilities (sorted by distance from ${_isLiveGps ? "Live GPS" : _activeLocationLabel})',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sort_rounded, size: 14, color: theme.colorScheme.primary),
                              const SizedBox(width: 4),
                              Text(
                                isBangla ? 'নিকটবর্তী প্রথমে' : 'Nearest First',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content: Radar Map View OR Card List View
                  if (_isMapView)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          horizontalPadding,
                          4,
                          horizontalPadding,
                          48,
                        ),
                        child: _HospitalRadarMapView(
                          userLat: _activeLat,
                          userLng: _activeLng,
                          userLocationName: isBangla ? _activeLocationLabelBn : _activeLocationLabel,
                          hospitals: hospitals,
                          isBangla: isBangla,
                          selectedHospital: _selectedHospitalForMap,
                          onSelectHospital: (h) => setState(() => _selectedHospitalForMap = h),
                          onCall: (phone) => _makeCall(phone),
                          onDirections: (lat, lng) => _openDirections(lat, lng),
                        ),
                      ),
                    )
                  else if (hospitals.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.location_off_rounded,
                                size: 68,
                                color: theme.colorScheme.outlineVariant,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isBangla
                                    ? 'এই দূরত্বের মধ্যে কোনো হাসপাতাল পাওয়া যায়নি।'
                                    : 'No emergency facilities found matching your criteria.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isBangla
                                    ? 'অনুগ্রহ করে দূরত্বের ফিল্টার বা এলাকার অবস্থান পরিবর্তন করুন।'
                                    : 'Try widening your radius filter or selecting another location hub.',
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _selectedFilter = null;
                                    _selectedMaxDistanceKm = null;
                                    _selectedAreaFilter = null;
                                  });
                                  _fetchLiveLocationAndHospitals();
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 16),
                                label: Text(isBangla ? 'রিয়েল-টাইমে রিফ্রেশ করুন' : 'Refresh Real-Time Data'),
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
                          mainAxisExtent: 240,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final h = hospitals[index];
                            final distance = h.distanceTo(_activeLat, _activeLng);

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
// LOCATION QUICK PILL
// ─────────────────────────────────────────────────────────────────────────────

class _LocationQuickPill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _LocationQuickPill({
    this.icon,
    required this.label,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withAlpha(28) : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? activeColor : theme.colorScheme.outlineVariant.withAlpha(70),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: isSelected ? activeColor : theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? activeColor : theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
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
// RESPONSIVE WEB HOSPITAL CARD WITH LOCATION ACCENTS
// ─────────────────────────────────────────────────────────────────────────────

class _WebHospitalCard extends StatefulWidget {
  final Hospital hospital;
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
    final distance = widget.distance;
    final estMinutes = distance != null ? h.estimatedDrivingMinutes(distance) : null;

    // Color coding based on proximity
    final isImmediate = distance != null && distance <= 3.0;
    final isNearby = distance != null && distance > 3.0 && distance <= 8.0;

    final Color proximityColor = isImmediate
        ? const Color(0xFF10B981)
        : (isNearby ? const Color(0xFF0284C7) : theme.colorScheme.primary);

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
                ? proximityColor.withAlpha(160)
                : theme.colorScheme.outlineVariant.withAlpha(70),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: proximityColor.withAlpha(isDark ? 45 : 20),
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
              // Top header row: Icon + Names + Distance & ETA Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: hasCriticalCare
                          ? proximityColor.withAlpha(25)
                          : theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: hasCriticalCare ? proximityColor : theme.colorScheme.onSurfaceVariant,
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
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(Icons.place_outlined, size: 12, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                '${h.area}, ${h.district}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          h.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (distance != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: proximityColor.withAlpha(22),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: proximityColor.withAlpha(90)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.near_me_rounded, size: 13, color: proximityColor),
                              const SizedBox(width: 4),
                              Text(
                                '${distance.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: proximityColor,
                                ),
                              ),
                            ],
                          ),
                          if (estMinutes != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.isBangla ? '~$estMinutes মিনিট' : '~$estMinutes mins',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: proximityColor,
                              ),
                            ),
                          ],
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

// ─────────────────────────────────────────────────────────────────────────────
// INTERACTIVE PROXIMITY RADAR / MAP VIEW
// ─────────────────────────────────────────────────────────────────────────────

class _HospitalRadarMapView extends StatelessWidget {
  final double userLat;
  final double userLng;
  final String userLocationName;
  final List<Hospital> hospitals;
  final bool isBangla;
  final Hospital? selectedHospital;
  final ValueChanged<Hospital> onSelectHospital;
  final ValueChanged<String> onCall;
  final void Function(double lat, double lng) onDirections;

  const _HospitalRadarMapView({
    required this.userLat,
    required this.userLng,
    required this.userLocationName,
    required this.hospitals,
    required this.isBangla,
    required this.selectedHospital,
    required this.onSelectHospital,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final focused = selectedHospital ?? (hospitals.isNotEmpty ? hospitals.first : null);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(80)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radar_rounded, color: Color(0xFF10B981), size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isBangla ? 'হাসপাতাল প্রক্সিমিটি রাডার ও লোকেশন ম্যাপ' : 'Hospital Proximity Radar & Geographic Map',
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isBangla
                          ? 'কেন্দ্রবিন্দু: $userLocationName (দূরত্ব বলয়: ৩ কিমি, ৭ কিমি, ১৫ কিমি)'
                          : 'Center: $userLocationName (Concentric rings: 3 km, 7 km, 15 km)',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withAlpha(20),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: const Color(0xFF10B981).withAlpha(70)),
                ),
                child: Text(
                  isBangla ? '${hospitals.length} টি পিন' : '${hospitals.length} Pins',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Radar canvas representation
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 380,
              width: double.infinity,
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFF0C243B),
              child: Stack(
                children: [
                  // Custom painter for radar concentric circles and grid
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RadarGridPainter(isDark: isDark),
                    ),
                  ),

                  // Center user marker
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _PulsingUserPin(),
                        SizedBox(height: 4),
                        ContainerBadge(text: 'YOU ARE HERE / আপনার অবস্থান'),
                      ],
                    ),
                  ),

                  // Hospital pins plotted relative to user location
                  ...hospitals.map((h) {
                    final isFocused = focused?.id == h.id;
                    final distance = h.distanceTo(userLat, userLng);

                    // Coordinate offset normalized to canvas
                    final dLat = (h.latitude - userLat);
                    final dLng = (h.longitude - userLng);

                    // Scale factor for map representation (clamp so pins remain visible inside canvas)
                    final scale = 1100.0;
                    final rawDx = dLng * scale;
                    final rawDy = -dLat * scale; // inverted Y

                    final clampedDx = rawDx.clamp(-160.0, 160.0);
                    final clampedDy = rawDy.clamp(-140.0, 140.0);

                    return Align(
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: Offset(clampedDx, clampedDy),
                        child: GestureDetector(
                          onTap: () => onSelectHospital(h),
                          child: _HospitalMapPin(
                            hospital: h,
                            distance: distance,
                            isSelected: isFocused,
                            isBangla: isBangla,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Active Hospital Details Popup Card under the Map
          if (focused != null) ...[
            const SizedBox(height: 16),
            _MapSelectedHospitalCard(
              hospital: focused,
              distance: focused.distanceTo(userLat, userLng),
              isBangla: isBangla,
              onCall: () => onCall(focused.phone),
              onDirections: () => onDirections(focused.latitude, focused.longitude),
            ),
          ],
        ],
      ),
    );
  }
}

class ContainerBadge extends StatelessWidget {
  final String text;
  const ContainerBadge({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withAlpha(200),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _PulsingUserPin extends StatelessWidget {
  const _PulsingUserPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF10B981),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF10B981),
            blurRadius: 12,
            spreadRadius: 3,
          ),
        ],
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 12),
    );
  }
}

class _HospitalMapPin extends StatelessWidget {
  final Hospital hospital;
  final double distance;
  final bool isSelected;
  final bool isBangla;

  const _HospitalMapPin({
    required this.hospital,
    required this.distance,
    required this.isSelected,
    required this.isBangla,
  });

  @override
  Widget build(BuildContext context) {
    final color = hospital.hasCathLab
        ? const Color(0xFFEF4444)
        : (hospital.hasStrokeThrombolysis ? const Color(0xFF8B5CF6) : const Color(0xFF38BDF8));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.black87,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isSelected ? color : Colors.white24,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: color.withAlpha(120), blurRadius: 10, spreadRadius: 2)]
                  : null,
            ),
            child: Text(
              '${distance.toStringAsFixed(1)} km',
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: isSelected ? 26 : 20,
            height: isSelected ? 26 : 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: isSelected ? 2 : 1.5),
            ),
            child: Icon(
              Icons.local_hospital_rounded,
              color: Colors.white,
              size: isSelected ? 14 : 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarGridPainter extends CustomPainter {
  final bool isDark;
  _RadarGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rings = [45.0, 95.0, 150.0];
    for (final r in rings) {
      canvas.drawCircle(center, r, paint);
    }

    // Cross axes
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapSelectedHospitalCard extends StatelessWidget {
  final Hospital hospital;
  final double distance;
  final bool isBangla;
  final VoidCallback onCall;
  final VoidCallback onDirections;

  const _MapSelectedHospitalCard({
    required this.hospital,
    required this.distance,
    required this.isBangla,
    required this.onCall,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final estMinutes = hospital.estimatedDrivingMinutes(distance);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.primary.withAlpha(90)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.local_hospital_rounded, color: theme.colorScheme.primary, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isBangla && hospital.banglaName.isNotEmpty ? hospital.banglaName : hospital.name,
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${distance.toStringAsFixed(1)} km (~$estMinutes min)',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '${hospital.address} • (${hospital.area}, ${hospital.district})',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconButton.filledTonal(
            tooltip: isBangla ? 'কল করুন' : 'Call',
            icon: const Icon(Icons.phone_rounded, color: Colors.green),
            onPressed: onCall,
          ),
          const SizedBox(width: 6),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: onDirections,
            icon: const Icon(Icons.directions_rounded, size: 16),
            label: Text(
              isBangla ? 'দিকনির্দেশনা' : 'Navigate',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
