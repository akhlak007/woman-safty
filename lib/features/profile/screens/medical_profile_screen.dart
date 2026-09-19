import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/models/user_profile.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class MedicalProfileScreen extends StatefulWidget {
  const MedicalProfileScreen({super.key});

  @override
  State<MedicalProfileScreen> createState() => _MedicalProfileScreenState();
}

class _MedicalProfileScreenState extends State<MedicalProfileScreen> {
  String? _selectedBloodGroup;
  List<String> _selectedConditions = [];
  List<String> _medications = [];
  List<String> _allergies = [];
  bool _initialized = false;

  final _medicationInputController = TextEditingController();
  final _allergyInputController = TextEditingController();

  @override
  void dispose() {
    _medicationInputController.dispose();
    _allergyInputController.dispose();
    super.dispose();
  }

  void _populateExistingProfile(UserProfile? profile) {
    if (_initialized || profile == null) return;
    _selectedBloodGroup = profile.bloodGroup;
    _selectedConditions = List.from(profile.conditions);
    _medications = List.from(profile.medications);
    _allergies = List.from(profile.allergies);
    _initialized = true;
  }

  Future<void> _saveProfile() async {
    final auth = context.read<SafeLifeAuthProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final current = auth.userProfile;

    if (current == null) return;

    final updated = current.copyWith(
      bloodGroup: _selectedBloodGroup,
      conditions: _selectedConditions,
      medications: _medications,
      allergies: _allergies,
    );

    final success = await profileProvider.saveProfile(updated);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)?.profileUpdated ?? 'Profile updated successfully',
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  void _addMedication() {
    final text = _medicationInputController.text.trim();
    if (text.isNotEmpty && !_medications.contains(text)) {
      setState(() {
        _medications.add(text);
        _medicationInputController.clear();
      });
    }
  }

  void _addAllergy() {
    final text = _allergyInputController.text.trim();
    if (text.isNotEmpty && !_allergies.contains(text)) {
      setState(() {
        _allergies.add(text);
        _allergyInputController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<SafeLifeAuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    _populateExistingProfile(auth.userProfile);

    final profile = auth.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.medicalProfile ?? 'Medical Profile'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User Information Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primary.withAlpha(30),
                        child: Icon(
                          Icons.person,
                          size: 32,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile?.name ?? 'SafeLife User',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profile?.phone ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              profile?.email ?? '',
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
              ),

              const SizedBox(height: 24),

              // Blood Group Selection
              Text(
                l10n?.bloodGroup ?? 'Blood Group',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UserProfile.availableBloodGroups.map((group) {
                  final isSelected = _selectedBloodGroup == group;
                  return ChoiceChip(
                    label: Text(
                      group,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: theme.colorScheme.primary,
                    onSelected: (selected) {
                      setState(() {
                        _selectedBloodGroup = selected ? group : null;
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Chronic Conditions
              Text(
                l10n?.chronicConditions ?? 'Chronic Medical Conditions',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Select conditions to personalize acute heart and stroke risk assessment',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: UserProfile.commonConditions.map((condition) {
                  final isSelected = _selectedConditions.contains(condition);
                  return FilterChip(
                    label: Text(condition),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedConditions.add(condition);
                        } else {
                          _selectedConditions.remove(condition);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Current Medications
              Text(
                l10n?.medications ?? 'Current Medications',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _medicationInputController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Aspirin 75mg, Metformin',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (_) => _addMedication(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addMedication,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _medications.map((med) {
                  return Chip(
                    label: Text(med),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _medications.remove(med);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Known Allergies
              Text(
                l10n?.allergies ?? 'Known Allergies',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _allergyInputController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Penicillin, Peanuts, Latex',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                      onSubmitted: (_) => _addAllergy(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addAllergy,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _allergies.map((allergy) {
                  return Chip(
                    label: Text(allergy),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      setState(() {
                        _allergies.remove(allergy);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 36),

              // Save Button
              FilledButton(
                onPressed: profileProvider.isSaving ? null : _saveProfile,
                child: profileProvider.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n?.saveProfile ?? 'Save Profile'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  ),
);
  }
}
