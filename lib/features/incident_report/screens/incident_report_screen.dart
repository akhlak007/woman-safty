import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safelife/core/services/location_service.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/incident_report/models/incident_report.dart';
import 'package:safelife/features/incident_report/repositories/incident_report_repository.dart';
import 'package:safelife/features/sos/models/emergency_case.dart';
import 'package:safelife/l10n/app_localizations.dart';

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

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  late final IncidentReportRepository _repo;
  late final LocationService _locationService;

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'harassment';
  bool _attachLocation = true;
  EmergencyLocation? _currentLocation;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? IncidentReportRepository();
    _locationService = widget.locationService ?? const LocationService();
    _fetchCurrentLocation();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
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
    final userName = auth.userProfile?.name ?? auth.user?.displayName ?? 'Anonymous User';
    final userPhone = auth.userProfile?.phone ?? auth.user?.phoneNumber ?? '';

    setState(() => _isSubmitting = true);

    try {
      EmergencyLocation? locationToSave;
      if (_attachLocation) {
        locationToSave = _currentLocation ?? await _locationService.getCurrentLocation();
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
                const Icon(Icons.check_circle_outline_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.reportSubmitted ?? 'Incident report submitted successfully',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'harassment':
        return Icons.record_voice_over_rounded;
      case 'stalking':
        return Icons.directions_walk_rounded;
      case 'threat':
        return Icons.warning_rounded;
      case 'suspicious':
        return Icons.visibility_outlined;
      default:
        return Icons.report_problem_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<SafeLifeAuthProvider>();
    final userId = auth.user?.uid ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n?.incidentReportTitle ?? 'Report Safety Incident'),
          bottom: TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.edit_note_rounded),
                text: l10n?.incidentReportTitle ?? 'New Report',
              ),
              Tab(
                icon: const Icon(Icons.history_rounded),
                text: l10n?.myReports ?? 'My Reports',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Form
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Confidentiality Notice
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withAlpha(80),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withAlpha(60),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n?.incidentReportSubtitle ??
                                      'Confidential report for harassment, stalking, or safety threats',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Reports are securely recorded. If you are in immediate physical danger, call 999 or tap SOS.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Category Selection
                    Text(
                      l10n?.category ?? 'Incident Category',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        'harassment',
                        'stalking',
                        'threat',
                        'suspicious',
                      ].map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return ChoiceChip(
                          avatar: Icon(
                            _getCategoryIcon(cat),
                            size: 18,
                            color: isSelected ? Colors.white : theme.colorScheme.primary,
                          ),
                          label: Text(_getCategoryLabel(cat, l10n)),
                          selected: isSelected,
                          selectedColor: theme.colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Description Input
                    Text(
                      l10n?.incidentDescription ?? 'Describe what happened',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: l10n?.incidentDescriptionHint ??
                            'Provide date, location details, context, or physical description...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignLabelWithHint: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().length < 10) {
                          return 'Please provide at least 10 characters of detail.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Attach GPS coordinates switch
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SwitchListTile(
                        value: _attachLocation,
                        title: Text(
                          l10n?.attachLocation ?? 'Attach Current GPS Coordinates',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        subtitle: _isLoadingLocation
                            ? const Text('Acquiring current GPS coordinates...')
                            : _currentLocation != null
                                ? Text(
                                    'Lat: ${_currentLocation!.latitude.toStringAsFixed(4)}, Lon: ${_currentLocation!.longitude.toStringAsFixed(4)}',
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )
                                : const Text('No location acquired yet.'),
                        secondary: Icon(
                          Icons.my_location_rounded,
                          color: _attachLocation
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outline,
                        ),
                        onChanged: (val) {
                          setState(() => _attachLocation = val);
                          if (val && _currentLocation == null) {
                            _fetchCurrentLocation();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
                      label: Text(
                        _isSubmitting
                            ? 'Submitting...'
                            : (l10n?.submitReport ?? 'Submit Incident Report'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

            // Tab 2: My Reports
            _MyReportsListView(repo: _repo, userId: userId),
          ],
        ),
      ),
    );
  }
}

class _MyReportsListView extends StatelessWidget {
  final IncidentReportRepository repo;
  final String userId;

  const _MyReportsListView({
    required this.repo,
    required this.userId,
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
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reports = snapshot.data ?? [];
        if (reports.isEmpty) {
          // Fallback to locally cached reports
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

    if (reports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.folder_open_rounded,
                size: 64,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'No incident reports submitted yet.',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Reports you submit will be listed here securely.',
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 850),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final r = reports[index];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${r.createdAt.year}-${r.createdAt.month.toString().padLeft(2, '0')}-${r.createdAt.day.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  r.description,
                  style: theme.textTheme.bodyMedium,
                ),
                if (r.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Location: ${r.location!.latitude.toStringAsFixed(4)}, ${r.location!.longitude.toStringAsFixed(4)}',
                        style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  ),
);
  }
}
