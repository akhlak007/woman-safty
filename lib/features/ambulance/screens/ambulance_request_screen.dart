import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/ambulance_booking.dart';
import '../providers/ambulance_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../core/services/location_service.dart';
import '../../../core/constants/emergency_numbers.dart';
import '../../../l10n/app_localizations.dart';

class AmbulanceRequestScreen extends StatefulWidget {
  final LocationService? locationService;

  const AmbulanceRequestScreen({
    super.key,
    this.locationService,
  });

  @override
  State<AmbulanceRequestScreen> createState() => _AmbulanceRequestScreenState();
}

class _AmbulanceRequestScreenState extends State<AmbulanceRequestScreen> {
  late final LocationService _locationService;
  final _pickupController = TextEditingController();
  final _destinationController = TextEditingController();

  AmbulanceType _selectedType = AmbulanceType.bls;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _locationService = widget.locationService ?? const LocationService();
    _fetchLiveAddress();
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveAddress() async {
    setState(() => _isLoadingLocation = true);
    try {
      final loc = await _locationService.getCurrentLocation();
      if (mounted && loc != null) {
        setState(() {
          _pickupController.text =
              'Current GPS: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';
          _isLoadingLocation = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  Future<void> _handleRequest() async {
    if (_pickupController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide your pickup location.')),
      );
      return;
    }

    final auth = context.read<SafeLifeAuthProvider>();
    final ambulanceProv = context.read<AmbulanceProvider>();

    final userId = auth.user?.uid ?? 'anonymous_user';
    final userName = auth.userProfile?.name ?? auth.user?.displayName ?? 'SafeLife User';
    final userPhone = auth.userProfile?.phone ?? auth.user?.phoneNumber ?? '';

    final loc = await _locationService.getCurrentLocation();

    await ambulanceProv.requestAmbulance(
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      pickupAddress: _pickupController.text.trim(),
      pickupLocation: loc,
      destinationHospital: _destinationController.text.trim().isEmpty
          ? 'Nearest Emergency Hospital'
          : _destinationController.text.trim(),
      ambulanceType: _selectedType,
    );
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final ambulanceProv = context.watch<AmbulanceProvider>();
    final booking = ambulanceProv.activeBooking;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 960;
        final isTablet = screenWidth >= 640 && screenWidth < 960;
        final horizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n?.ambulanceRequestTitle ?? 'Request Emergency Ambulance',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => EmergencyNumbers.makeEmergencyCall(EmergencyNumbers.nationalEmergency),
                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                    label: const Text(
                      'Dial 999',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1320),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  isDesktop ? 24 : 16,
                  horizontalPadding,
                  48,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Dispatch Hero Banner
                    _buildTopBanner(theme, isDark, isDesktop),
                    const SizedBox(height: 24),

                    // Active tracking view OR booking form
                    ambulanceProv.hasActiveBooking && booking != null
                        ? _buildActiveTrackingView(
                            context,
                            booking,
                            ambulanceProv,
                            theme,
                            l10n,
                            isDesktop,
                          )
                        : _buildBookingForm(
                            context,
                            theme,
                            l10n,
                            isDesktop,
                            isTablet,
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBanner(ThemeData theme, bool isDark, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C1318), const Color(0xFF1E1424), const Color(0xFF0F172A)]
              : [const Color(0xFF991B1B), const Color(0xFF7F1D1D), const Color(0xFF450A0A)],
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(24),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.airport_shuttle_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'RAPID AMBULANCE DISPATCH NETWORK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Emergency Life Support & Hospital Transport',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 22 : 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Direct dispatch with GPS coordination, onboard clinical equipment, and hospital pre-notification.',
                  style: TextStyle(
                    color: Colors.white.withAlpha(220),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingForm(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
    bool isDesktop,
    bool isTablet,
  ) {
    // Form Inputs Column
    final formInputs = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emergency_rounded, color: Color(0xFFDC2626), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '1. Select Life Support Level',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // BLS and ALS Cards side-by-side or stacked
          _buildTypeOption(
            type: AmbulanceType.bls,
            title: l10n?.ambulanceBLS ?? 'Basic Life Support (BLS)',
            description: l10n?.ambulanceBLSDesc ?? 'Oxygen support, stretcher, emergency first-aid equipment',
            icon: Icons.airport_shuttle_rounded,
            color: theme.colorScheme.primary,
            theme: theme,
          ),
          const SizedBox(height: 12),
          _buildTypeOption(
            type: AmbulanceType.als,
            title: l10n?.ambulanceALS ?? 'Advanced Cardiac Life Support (ALS)',
            description: l10n?.ambulanceALSDesc ?? 'Cardiac monitor, defibrillator, ventilator, paramedic onboard',
            icon: Icons.favorite_rounded,
            color: const Color(0xFFDC2626),
            badgeText: 'CRITICAL CARE',
            theme: theme,
          ),

          const SizedBox(height: 28),
          Divider(color: theme.colorScheme.outlineVariant.withAlpha(60)),
          const SizedBox(height: 20),

          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '2. Pickup & Hospital Destination',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pickup Location Field
          Text(
            l10n?.pickupLocation ?? 'Pickup Location',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pickupController,
            decoration: InputDecoration(
              hintText: 'Enter current pickup address, house/road number, or area...',
              prefixIcon: const Icon(Icons.my_location_rounded),
              suffixIcon: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : IconButton(
                      tooltip: 'Auto-detect GPS Location',
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _fetchLiveAddress,
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 18),

          // Destination Hospital Field
          Text(
            l10n?.destinationHospital ?? 'Destination Hospital (Optional)',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(
              hintText: 'e.g., NICVD, DMCH, United Hospital, or Nearest ER',
              prefixIcon: const Icon(Icons.local_hospital_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Destination chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _destinationChip('Nearest Emergency Hospital'),
              _destinationChip('NICVD (Cardiac)'),
              _destinationChip('NINS (Neuro/Stroke)'),
              _destinationChip('DMCH'),
            ],
          ),

          const SizedBox(height: 28),

          // Request Button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _selectedType == AmbulanceType.als
                    ? const Color(0xFFDC2626)
                    : theme.colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 4,
              ),
              onPressed: _handleRequest,
              icon: const Icon(Icons.send_rounded, size: 20),
              label: Text(
                l10n?.requestAmbulanceNow ?? 'Request Ambulance Dispatch',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );

    // Sidebar: Emergency Direct Calling & Guidance
    final sideInfo = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Toll-free Direct Hotlines Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(70)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.phone_in_talk_rounded, color: Color(0xFFDC2626), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Direct Emergency Call',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'If patient is unconscious or unresponsive, call 999 immediately without delay.',
                style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => EmergencyNumbers.makeEmergencyCall(EmergencyNumbers.nationalEmergency),
                icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                label: Text(
                  l10n?.governmentAmbulance999 ?? 'Call 999 National Ambulance',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.primary,
                  side: BorderSide(color: theme.colorScheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => _makeCall('+88029330188'),
                icon: const Icon(Icons.medical_services_outlined, size: 18),
                label: Text(
                  l10n?.redCrescentAmbulance ?? 'Red Crescent Ambulance',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Clinical Standards Card
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dispatch Protocol & Guarantee',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 12),
              _protocolItem(Icons.gps_fixed_rounded, 'Real-time GPS Driver Tracking with Live ETA updates'),
              _protocolItem(Icons.healing_rounded, 'Onboard EMT & Paramedic triage before arrival'),
              _protocolItem(Icons.local_hospital_rounded, 'Hospital emergency room advance notification'),
            ],
          ),
        ),
      ],
    );

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: formInputs),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: sideInfo),
            ],
          )
        : Column(
            children: [
              formInputs,
              const SizedBox(height: 24),
              sideInfo,
            ],
          );
  }

  Widget _buildTypeOption({
    required AmbulanceType type,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    String? badgeText,
    required ThemeData theme,
  }) {
    final isSelected = _selectedType == type;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isSelected ? color.withAlpha(16) : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : theme.colorScheme.outlineVariant.withAlpha(70),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? color : theme.colorScheme.outline,
              ),
              const SizedBox(width: 14),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
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
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                          ),
                        ),
                        if (badgeText != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: color,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _destinationChip(String text) {
    return ActionChip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      onPressed: () {
        setState(() {
          _destinationController.text = text;
        });
      },
    );
  }

  Widget _protocolItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF10B981)),
          const SizedBox(width: 10),
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

  Widget _buildActiveTrackingView(
    BuildContext context,
    AmbulanceBooking booking,
    AmbulanceProvider provider,
    ThemeData theme,
    AppLocalizations? l10n,
    bool isDesktop,
  ) {
    final statusColor = _getStatusColor(booking.status, theme);

    final leftStatusColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Urgency Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: statusColor.withAlpha(20),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor, width: 2),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.airport_shuttle_rounded, size: 48, color: statusColor),
              ),
              const SizedBox(height: 14),
              Text(
                _getStatusLabel(booking.status, l10n).toUpperCase(),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                booking.status == AmbulanceStatus.arrived
                    ? 'Ambulance is at your specified pickup location!'
                    : 'Estimated Arrival: ~${booking.estimatedMinutes} minutes',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Timeline Progress Stepper
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(70)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dispatch Timeline',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 18),
              _timelineStep('1', l10n?.statusRequested ?? 'Requested', true, theme),
              _timelineStep(
                '2',
                l10n?.statusDispatched ?? 'Dispatched',
                booking.status != AmbulanceStatus.requested,
                theme,
              ),
              _timelineStep(
                '3',
                l10n?.statusEnRoute ?? 'On The Way',
                booking.status == AmbulanceStatus.enRoute || booking.status == AmbulanceStatus.arrived,
                theme,
              ),
              _timelineStep(
                '4',
                l10n?.statusArrived ?? 'Arrived On Scene',
                booking.status == AmbulanceStatus.arrived,
                theme,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );

    final rightDetailsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Assigned Driver Card
        if (booking.driverName != null) ...[
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(70)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.driverAssigned ?? 'Assigned Emergency Responder',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: const Icon(Icons.person_rounded, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.driverName!,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          if (booking.vehicleNumber != null)
                            Text(
                              'Vehicle: ${booking.vehicleNumber!}',
                              style: theme.textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    if (booking.driverPhone != null)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _makeCall(booking.driverPhone!),
                          icon: const Icon(Icons.phone, size: 16),
                          label: Text(l10n?.callDriver ?? 'Call Driver'),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Booking Details Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(70)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Dispatch Summary',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
              ),
              const SizedBox(height: 12),
              _infoRow('Ambulance Type', booking.ambulanceType.label),
              _infoRow('Pickup Location', booking.pickupAddress),
              _infoRow('Destination', booking.destinationHospital),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Cancel or Complete Action
        if (booking.status == AmbulanceStatus.arrived) ...[
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => provider.completeBooking(),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'Acknowledge Arrival / Complete',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ] else ...[
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _confirmCancel(context, provider, l10n),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(
                l10n?.cancelBooking ?? 'Cancel Request',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ],
    );

    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: leftStatusColumn),
              const SizedBox(width: 24),
              Expanded(flex: 5, child: rightDetailsColumn),
            ],
          )
        : Column(
            children: [
              leftStatusColumn,
              const SizedBox(height: 24),
              rightDetailsColumn,
            ],
          );
  }

  Widget _timelineStep(
    String stepNumber,
    String title,
    bool isDone,
    ThemeData theme, {
    bool isLast = false,
  }) {
    final activeColor = isDone ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: isDone ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(stepNumber, style: TextStyle(fontSize: 12, color: theme.colorScheme.outline)),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: activeColor,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(
              title,
              style: TextStyle(
                fontWeight: isDone ? FontWeight.bold : FontWeight.normal,
                color: isDone ? theme.colorScheme.onSurface : theme.colorScheme.outline,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(AmbulanceStatus status, ThemeData theme) {
    switch (status) {
      case AmbulanceStatus.requested:
        return Colors.amber.shade800;
      case AmbulanceStatus.dispatched:
        return Colors.blue.shade700;
      case AmbulanceStatus.enRoute:
        return theme.colorScheme.primary;
      case AmbulanceStatus.arrived:
        return Colors.green.shade700;
      case AmbulanceStatus.completed:
        return Colors.green.shade800;
      case AmbulanceStatus.cancelled:
        return theme.colorScheme.error;
    }
  }

  String _getStatusLabel(AmbulanceStatus status, AppLocalizations? l10n) {
    switch (status) {
      case AmbulanceStatus.requested:
        return l10n?.statusRequested ?? 'Requested';
      case AmbulanceStatus.dispatched:
        return l10n?.statusDispatched ?? 'Dispatched';
      case AmbulanceStatus.enRoute:
        return l10n?.statusEnRoute ?? 'On The Way';
      case AmbulanceStatus.arrived:
        return l10n?.statusArrived ?? 'Arrived On Scene';
      case AmbulanceStatus.completed:
        return 'Completed';
      case AmbulanceStatus.cancelled:
        return 'Cancelled';
    }
  }

  void _confirmCancel(BuildContext context, AmbulanceProvider provider, AppLocalizations? l10n) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Ambulance Request'),
        content: const Text('Are you sure you want to cancel your emergency ambulance dispatch?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Keep Request'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              provider.cancelBooking();
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
