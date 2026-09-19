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
          _pickupController.text = 'Current GPS: ${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}';
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
    final ambulanceProv = context.watch<AmbulanceProvider>();
    final booking = ambulanceProv.activeBooking;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.ambulanceRequestTitle ?? 'Request Emergency Ambulance'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 850),
          child: ambulanceProv.hasActiveBooking && booking != null
              ? _buildActiveTrackingView(context, booking, ambulanceProv, theme, l10n)
              : _buildBookingForm(context, theme, l10n),
        ),
      ),
    );
  }

  Widget _buildBookingForm(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // National Emergency Direct Calling Bar
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    side: BorderSide(color: theme.colorScheme.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => EmergencyNumbers.makeEmergencyCall(EmergencyNumbers.nationalEmergency),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                  label: Text(
                    l10n?.governmentAmbulance999 ?? 'Call 999 Ambulance',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => _makeCall('+88029330188'),
                  icon: const Icon(Icons.medical_services_outlined, size: 18),
                  label: Text(
                    l10n?.redCrescentAmbulance ?? 'Red Crescent',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Ambulance Type Selection
          Text(
            l10n?.ambulanceType ?? 'Ambulance Type',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          // BLS Card
          Card(
            elevation: _selectedType == AmbulanceType.bls ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: _selectedType == AmbulanceType.bls
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withAlpha(80),
                width: _selectedType == AmbulanceType.bls ? 2 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _selectedType = AmbulanceType.bls),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _selectedType == AmbulanceType.bls
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selectedType == AmbulanceType.bls
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 14),
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(Icons.airport_shuttle_rounded, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.ambulanceBLS ?? 'Basic Life Support (BLS)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n?.ambulanceBLSDesc ?? 'Oxygen support, stretcher, emergency first-aid equipment',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // ALS Card (Cardiac / Stroke Intensive)
          Card(
            elevation: _selectedType == AmbulanceType.als ? 2 : 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: _selectedType == AmbulanceType.als
                    ? theme.colorScheme.error
                    : theme.colorScheme.outlineVariant.withAlpha(80),
                width: _selectedType == AmbulanceType.als ? 2 : 1,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => setState(() => _selectedType = AmbulanceType.als),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _selectedType == AmbulanceType.als
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selectedType == AmbulanceType.als
                          ? theme.colorScheme.error
                          : theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 14),
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.errorContainer,
                      child: Icon(Icons.favorite_rounded, color: theme.colorScheme.error),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.ambulanceALS ?? 'Advanced Cardiac Life Support (ALS)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n?.ambulanceALSDesc ?? 'Cardiac monitor, defibrillator, ventilator, paramedic onboard',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Pickup Location Field
          Text(
            l10n?.pickupLocation ?? 'Pickup Location',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _pickupController,
            decoration: InputDecoration(
              hintText: 'Enter pickup address or area...',
              prefixIcon: const Icon(Icons.my_location_rounded),
              suffixIcon: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: _fetchLiveAddress,
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),

          // Destination Hospital Field
          Text(
            l10n?.destinationHospital ?? 'Destination Hospital (Optional)',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _destinationController,
            decoration: InputDecoration(
              hintText: 'e.g., NICVD, DMCH, United Hospital, or Nearest ER',
              prefixIcon: const Icon(Icons.local_hospital_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 32),

          // Request Button
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _selectedType == AmbulanceType.als
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: _handleRequest,
            icon: const Icon(Icons.send_rounded),
            label: Text(
              l10n?.requestAmbulanceNow ?? 'Request Ambulance Dispatch',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
  ) {
    final statusColor = _getStatusColor(booking.status, theme);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Urgency Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: statusColor, width: 2),
            ),
            child: Column(
              children: [
                Icon(Icons.airport_shuttle_rounded, size: 48, color: statusColor),
                const SizedBox(height: 8),
                Text(
                  _getStatusLabel(booking.status, l10n).toUpperCase(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  booking.status == AmbulanceStatus.arrived
                      ? 'Ambulance is at your specified pickup location!'
                      : 'Estimated Arrival: ~${booking.estimatedMinutes} minutes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Timeline Progress Stepper
          Text(
            'Dispatch Timeline',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _timelineStep('1', l10n?.statusRequested ?? 'Requested', true, theme),
          _timelineStep('2', l10n?.statusDispatched ?? 'Dispatched',
              booking.status != AmbulanceStatus.requested, theme),
          _timelineStep('3', l10n?.statusEnRoute ?? 'On The Way',
              booking.status == AmbulanceStatus.enRoute || booking.status == AmbulanceStatus.arrived, theme),
          _timelineStep('4', l10n?.statusArrived ?? 'Arrived On Scene',
              booking.status == AmbulanceStatus.arrived, theme, isLast: true),

          const SizedBox(height: 24),

          // Assigned Driver Card
          if (booking.driverName != null) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.driverAssigned ?? 'Assigned Driver',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: const Icon(Icons.person_rounded),
                        ),
                        const SizedBox(width: 12),
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
                                  booking.vehicleNumber!,
                                  style: theme.textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        if (booking.driverPhone != null)
                          FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.green.shade700,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => _makeCall(booking.driverPhone!),
                            icon: const Icon(Icons.phone, size: 16),
                            label: Text(l10n?.callDriver ?? 'Call'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Booking Details Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Ambulance Type', booking.ambulanceType.label),
                  _infoRow('Pickup Location', booking.pickupAddress),
                  _infoRow('Destination', booking.destinationHospital),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Cancel or Complete Action
          if (booking.status == AmbulanceStatus.arrived) ...[
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => provider.completeBooking(),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'Acknowledge Arrival / Complete',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ] else ...[
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => _confirmCancel(context, provider, l10n),
              icon: const Icon(Icons.cancel_outlined),
              label: Text(l10n?.cancelBooking ?? 'Cancel Request'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _timelineStep(String stepNumber, String title, bool isDone, ThemeData theme, {bool isLast = false}) {
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
                height: 28,
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
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
