import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/routes.dart';
import '../../../app/theme/risk_level_theme.dart';
import '../../../core/constants/alert_constants.dart';
import '../../../core/constants/emergency_numbers.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/contacts_provider.dart';
import '../../sos/providers/sos_provider.dart';
import '../models/cardiac_triage_model.dart';

class CardiacTriageScreen extends StatefulWidget {
  const CardiacTriageScreen({super.key});

  @override
  State<CardiacTriageScreen> createState() => _CardiacTriageScreenState();
}

class _CardiacTriageScreenState extends State<CardiacTriageScreen> {
  bool _chestPain = false;
  double _severity = 7;
  bool _painRadiates = false;
  bool _shortnessOfBreath = false;
  bool _diaphoresis = false;
  bool _nauseaOrDizziness = false;
  bool _durationOver10Min = false;

  bool _hasHypertension = false;
  bool _hasDiabetes = false;
  bool _priorCardiacHistory = false;
  bool _ageOver55 = false;

  CardiacTriageResult? _result;

  @override
  void initState() {
    super.initState();
    // Pre-populate comorbidities from existing profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<SafeLifeAuthProvider>().userProfile;
      if (profile != null && mounted) {
        setState(() {
          final cond = profile.conditions.map((c) => c.toLowerCase()).toList();
          _hasHypertension = cond.any((c) => c.contains('hypertension') || c.contains('pressure'));
          _hasDiabetes = cond.any((c) => c.contains('diabetes') || c.contains('sugar'));
          _priorCardiacHistory = cond.any((c) => c.contains('heart') || c.contains('cardiac'));
        });
      }
    });
  }

  void _calculateTriage() {
    final input = CardiacSymptomInput(
      chestPain: _chestPain,
      chestPainSeverity: _severity.round(),
      painRadiates: _painRadiates,
      shortnessOfBreath: _shortnessOfBreath,
      diaphoresis: _diaphoresis,
      nauseaOrDizziness: _nauseaOrDizziness,
      durationOver10Min: _durationOver10Min,
      ageOver55: _ageOver55,
      hasHypertension: _hasHypertension,
      hasDiabetes: _hasDiabetes,
      priorCardiacHistory: _priorCardiacHistory,
    );

    setState(() {
      _result = const CardiacTriageScorer().assess(input);
    });
  }

  Future<void> _dispatchCardiacEmergency() async {
    if (_result == null) return;
    final auth = context.read<SafeLifeAuthProvider>();
    final contacts = context.read<ContactsProvider>().contacts;
    final sosProvider = context.read<SosProvider>();
    final lang = Localizations.localeOf(context).languageCode;

    await sosProvider.dispatchEmergency(
      userId: auth.user?.uid ?? '',
      userName: auth.userProfile?.name ?? auth.user?.displayName ?? 'SafeLife User',
      userPhone: auth.userProfile?.phone ?? auth.user?.phoneNumber ?? '',
      contacts: contacts,
      language: lang,
      type: EmergencyType.cardiac,
      riskLevel: _result!.riskLevel,
      alertLevel: _result!.alertLevel,
      triggerSource: 'cardiac_triage',
      triageAnswers: _result!.toMap(),
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.sosActive);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final riskTheme = theme.extension<RiskLevelTheme>() ?? RiskLevelTheme.light;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.cardiacTriageTitle ?? 'Cardiac Risk Assessment',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Medical disclaimer banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n?.disclaimer ??
                            'SafeLife is an emergency assistance and symptom triage tool, not a diagnostic device.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              if (_result == null) ...[
                // Questionnaire Form
                Text(
                  'Acute Symptoms (Check all that apply)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // Chest Pain Switch
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        title: Text(
                          l10n?.chestPainQuestion ??
                              'Are you experiencing chest pain, tightness, or heavy pressure?',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        value: _chestPain,
                        onChanged: (val) => setState(() => _chestPain = val),
                      ),
                      if (_chestPain) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Pain Severity: ${_severity.round()} / 10',
                                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Slider(
                                value: _severity,
                                min: 1,
                                max: 10,
                                divisions: 9,
                                activeColor: theme.colorScheme.error,
                                label: _severity.round().toString(),
                                onChanged: (val) => setState(() => _severity = val),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Radiating Pain
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      l10n?.painRadiationQuestion ??
                          'Does the pain radiate to your left arm, jaw, neck, or back?',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    value: _painRadiates,
                    onChanged: (val) => setState(() => _painRadiates = val),
                  ),
                ),

                const SizedBox(height: 8),

                // Shortness of Breath
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      l10n?.shortnessOfBreathQuestion ??
                          'Are you experiencing severe shortness of breath or difficulty breathing?',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    value: _shortnessOfBreath,
                    onChanged: (val) => setState(() => _shortnessOfBreath = val),
                  ),
                ),

                const SizedBox(height: 8),

                // Diaphoresis / Cold Sweats
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      l10n?.sweatingQuestion ??
                          'Are you experiencing cold sweats (diaphoresis)?',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    value: _diaphoresis,
                    onChanged: (val) => setState(() => _diaphoresis = val),
                  ),
                ),

                const SizedBox(height: 8),

                // Nausea / Dizziness
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      l10n?.nauseaQuestion ??
                          'Are you feeling nauseous, lightheaded, or dizzy?',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    value: _nauseaOrDizziness,
                    onChanged: (val) => setState(() => _nauseaOrDizziness = val),
                  ),
                ),

                const SizedBox(height: 8),

                // Duration Over 10 Min
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: SwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(
                      l10n?.durationQuestion ??
                          'Have symptoms persisted for longer than 10 minutes?',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    value: _durationOver10Min,
                    onChanged: (val) => setState(() => _durationOver10Min = val),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'Risk Factors & Comorbidities',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Age > 55'),
                      selected: _ageOver55,
                      onSelected: (val) => setState(() => _ageOver55 = val),
                    ),
                    FilterChip(
                      label: const Text('Hypertension (High BP)'),
                      selected: _hasHypertension,
                      onSelected: (val) => setState(() => _hasHypertension = val),
                    ),
                    FilterChip(
                      label: const Text('Diabetes'),
                      selected: _hasDiabetes,
                      onSelected: (val) => setState(() => _hasDiabetes = val),
                    ),
                    FilterChip(
                      label: const Text('Prior Heart Attack / Stent'),
                      selected: _priorCardiacHistory,
                      onSelected: (val) => setState(() => _priorCardiacHistory = val),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _calculateTriage,
                  icon: const Icon(Icons.analytics_outlined),
                  label: Text(
                    l10n?.calculateRisk ?? 'Assess Risk',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                // Assessment Result Presentation
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: riskTheme.getColor(_result!.riskLevel).withAlpha(25),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: riskTheme.getColor(_result!.riskLevel),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        riskTheme.getIcon(_result!.riskLevel),
                        size: 50,
                        color: riskTheme.getColor(_result!.riskLevel),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _result!.riskLevel.name.toUpperCase(),
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: riskTheme.getColor(_result!.riskLevel),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Triage Score: ${_result!.score} pts',
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // First Aid Guidance
                Text(
                  l10n?.firstAidGuidance ?? 'First-Aid Guidance',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._result!.firstAidGuidance.map((guideline) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline_rounded,
                            color: Color(0xFF1B873F), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            guideline,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Explainability: Rules Fired
                if (_result!.rulesFired.isNotEmpty) ...[
                  Text(
                    l10n?.rulesFired ?? 'Clinical Assessment Indicators',
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: _result!.rulesFired.map((rule) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3.0),
                          child: Row(
                            children: [
                              Icon(Icons.arrow_right_rounded,
                                  size: 20, color: theme.colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Primary Emergency Actions
                if (_result!.shouldEscalateEmergency) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _dispatchCardiacEmergency,
                    icon: const Icon(Icons.emergency_rounded, size: 24),
                    label: Text(
                      l10n?.dispatchCardiacSos ?? 'Dispatch Cardiac SOS Alert',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(color: theme.colorScheme.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => EmergencyNumbers.makeEmergencyCall(
                      EmergencyNumbers.nationalEmergency,
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded),
                    label: Text(
                      l10n?.callPolice999 ?? 'Call 999 (National Helpline)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                TextButton(
                  onPressed: () {
                    setState(() {
                      _result = null;
                    });
                  },
                  child: const Text('Retake Assessment'),
                ),
              ],

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
