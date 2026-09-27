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
            AppLocalizations.of(context)?.profileUpdated ?? 'Medical profile updated successfully',
          ),
          backgroundColor: const Color(0xFF10B981),
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
    final isDark = theme.brightness == Brightness.dark;
    final auth = context.watch<SafeLifeAuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    _populateExistingProfile(auth.userProfile);

    final profile = auth.userProfile;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 960;
        final isTablet = screenWidth >= 640 && screenWidth < 960;
        final horizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n?.medicalProfile ?? 'Emergency Medical Profile',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: profileProvider.isSaving ? null : _saveProfile,
                    icon: profileProvider.isSaving
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      l10n?.save ?? 'Save Profile',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
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
                      // Top Hero Banner
                      _buildHeroBanner(theme, isDark, isDesktop),
                      const SizedBox(height: 24),

                      // Responsive 2-Column or Stacked Form
                      if (isDesktop)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left Column: User info, Blood group, Conditions
                            Expanded(
                              flex: 6,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildUserCard(profile, theme),
                                  const SizedBox(height: 20),
                                  _buildBloodGroupCard(theme, l10n),
                                  const SizedBox(height: 20),
                                  _buildConditionsCard(theme, l10n),
                                ],
                              ),
                            ),
                            const SizedBox(width: 24),
                            // Right Column: Medications, Allergies, Triage note, Save
                            Expanded(
                              flex: 5,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildMedicationsCard(theme, l10n),
                                  const SizedBox(height: 20),
                                  _buildAllergiesCard(theme, l10n),
                                  const SizedBox(height: 20),
                                  _buildTriageReadinessCard(theme),
                                  const SizedBox(height: 24),
                                  _buildSaveButton(profileProvider, l10n, theme),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildUserCard(profile, theme),
                            const SizedBox(height: 20),
                            _buildBloodGroupCard(theme, l10n),
                            const SizedBox(height: 20),
                            _buildConditionsCard(theme, l10n),
                            const SizedBox(height: 20),
                            _buildMedicationsCard(theme, l10n),
                            const SizedBox(height: 20),
                            _buildAllergiesCard(theme, l10n),
                            const SizedBox(height: 20),
                            _buildTriageReadinessCard(theme),
                            const SizedBox(height: 24),
                            _buildSaveButton(profileProvider, l10n, theme),
                          ],
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

  Widget _buildHeroBanner(ThemeData theme, bool isDark, bool isDesktop) {
    return Container(
      padding: EdgeInsets.all(isDesktop ? 28 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF142428), const Color(0xFF11222E), const Color(0xFF0F172A)]
              : [const Color(0xFF0E7490), const Color(0xFF0369A1), const Color(0xFF1D4ED8)],
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
              color: Colors.white.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_information_rounded,
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
                      'EMERGENCY CLINICAL BASELINE',
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
                  'Medical ID & Critical Health Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isDesktop ? 22 : 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This baseline data directly personalizes your acute Cardiac & Stroke triage risk scores and provides vital data to emergency responders.',
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

  Widget _buildUserCard(UserProfile? profile, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(70)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: theme.colorScheme.primary.withAlpha(25),
            child: Icon(
              Icons.person,
              size: 30,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile?.name ?? 'SafeLife User',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Verified ID',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (profile?.phone.isNotEmpty == true)
                  Text(
                    profile!.phone,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                if (profile?.email.isNotEmpty == true)
                  Text(
                    profile!.email,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBloodGroupCard(ThemeData theme, AppLocalizations? l10n) {
    return Container(
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
              const Icon(Icons.bloodtype_rounded, color: Color(0xFFDC2626), size: 22),
              const SizedBox(width: 10),
              Text(
                l10n?.bloodGroup ?? 'Blood Group',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
              const Spacer(),
              if (_selectedBloodGroup != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626).withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Selected: $_selectedBloodGroup',
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: UserProfile.availableBloodGroups.map((group) {
              final isSelected = _selectedBloodGroup == group;
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: ChoiceChip(
                  label: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    child: Text(
                      group,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: const Color(0xFFDC2626),
                  onSelected: (selected) {
                    setState(() {
                      _selectedBloodGroup = selected ? group : null;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConditionsCard(ThemeData theme, AppLocalizations? l10n) {
    return Container(
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
              const Icon(Icons.favorite_border_rounded, color: Color(0xFF7C3AED), size: 22),
              const SizedBox(width: 10),
              Text(
                l10n?.chronicConditions ?? 'Chronic Medical Conditions',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Select conditions to personalize clinical heart and stroke risk evaluations.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: UserProfile.commonConditions.map((condition) {
              final isSelected = _selectedConditions.contains(condition);
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: FilterChip(
                  label: Text(
                    condition,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
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
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsCard(ThemeData theme, AppLocalizations? l10n) {
    return Container(
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
              const Icon(Icons.medication_rounded, color: Color(0xFF0284C7), size: 22),
              const SizedBox(width: 10),
              Text(
                l10n?.medications ?? 'Current Medications',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _medicationInputController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Aspirin 75mg, Metformin, Clopidogrel',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _addMedication(),
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton.filled(
                  onPressed: _addMedication,
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          if (_medications.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _medications.map((med) {
                return Chip(
                  label: Text(med, style: const TextStyle(fontWeight: FontWeight.w600)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _medications.remove(med);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAllergiesCard(ThemeData theme, AppLocalizations? l10n) {
    return Container(
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
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B), size: 22),
              const SizedBox(width: 10),
              Text(
                l10n?.allergies ?? 'Known Drug & Food Allergies',
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _allergyInputController,
                  decoration: InputDecoration(
                    hintText: 'e.g., Penicillin, Peanuts, Latex, NSAIDs',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onSubmitted: (_) => _addAllergy(),
                ),
              ),
              const SizedBox(width: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton.filled(
                  onPressed: _addAllergy,
                  icon: const Icon(Icons.add),
                ),
              ),
            ],
          ),
          if (_allergies.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _allergies.map((allergy) {
                return Chip(
                  label: Text(allergy, style: const TextStyle(fontWeight: FontWeight.w600)),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () {
                    setState(() {
                      _allergies.remove(allergy);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTriageReadinessCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Your health records remain encrypted and stored locally under your control. Responders and triage algorithms access these only during an active emergency.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(
    ProfileProvider profileProvider,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4,
        ),
        onPressed: profileProvider.isSaving ? null : _saveProfile,
        icon: profileProvider.isSaving
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded, size: 20),
        label: Text(
          l10n?.saveProfile ?? 'Save Medical Profile',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
