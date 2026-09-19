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
import '../models/stroke_triage_model.dart';

class StrokeTriageScreen extends StatefulWidget {
  const StrokeTriageScreen({super.key});

  @override
  State<StrokeTriageScreen> createState() => _StrokeTriageScreenState();
}

class _StrokeTriageScreenState extends State<StrokeTriageScreen> {
  bool _isBystanderMode = true; // Default to bystander mode as recommended for stroke
  bool _faceDroop = false;
  bool _armWeakness = false;
  bool _speechDifficulty = false;
  TimeOfDay _onsetTime = TimeOfDay.now();

  StrokeTriageResult? _result;

  void _calculateTriage() {
    final now = DateTime.now();
    final onsetDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _onsetTime.hour,
      _onsetTime.minute,
    );

    final input = StrokeAssessmentInput(
      isBystanderMode: _isBystanderMode,
      faceDroop: _faceDroop,
      armWeakness: _armWeakness,
      speechDifficulty: _speechDifficulty,
      onsetTime: onsetDateTime,
    );

    setState(() {
      _result = const StrokeTriageScorer().assess(input);
    });
  }

  Future<void> _dispatchStrokeEmergency() async {
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
      type: EmergencyType.stroke,
      riskLevel: _result!.riskLevel,
      alertLevel: _result!.alertLevel,
      triggerSource: _isBystanderMode ? 'stroke_bystander' : 'stroke_self',
      triageAnswers: _result!.toMap(),
    );

    if (mounted) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.sosActive);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _onsetTime,
    );
    if (picked != null) {
      setState(() {
        _onsetTime = picked;
      });
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
          l10n?.strokeTriageTitle ?? 'Stroke F.A.S.T. Assessment',
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
              // Mode Selector: Bystander vs Self
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment<bool>(
                    value: true,
                    icon: const Icon(Icons.people_alt_outlined),
                    label: Text(
                      l10n?.bystanderMode ?? 'Bystander Mode',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    icon: const Icon(Icons.person_outline),
                    label: Text(
                      l10n?.selfMode ?? 'Self Mode',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                selected: {_isBystanderMode},
                onSelectionChanged: (newVal) {
                  setState(() {
                    _isBystanderMode = newVal.first;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Medical Disclaimer Banner
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
                // F — Face Drooping Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'F',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n?.faceTestTitle ?? 'F — Face Drooping',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Switch(
                              value: _faceDroop,
                              activeThumbColor: theme.colorScheme.error,
                              onChanged: (val) => setState(() => _faceDroop = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isBystanderMode
                              ? (l10n?.faceTestDesc ?? 'Ask the person to smile. Does one side of the face droop or look uneven?')
                              : 'Look in a mirror or touch both sides of your face. Does one side of your mouth droop when you smile?',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // A — Arm Weakness Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'A',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n?.armTestTitle ?? 'A — Arm Weakness',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Switch(
                              value: _armWeakness,
                              activeThumbColor: theme.colorScheme.error,
                              onChanged: (val) => setState(() => _armWeakness = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isBystanderMode
                              ? (l10n?.armTestDesc ?? 'Ask the person to raise both arms horizontally. Does one arm drift downward or feel limp?')
                              : 'Raise both arms horizontally in front of you. Does one arm drift downward or feel numb and weak?',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // S — Speech Difficulty Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'S',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n?.speechTestTitle ?? 'S — Speech Difficulty',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            Switch(
                              value: _speechDifficulty,
                              activeThumbColor: theme.colorScheme.error,
                              onChanged: (val) => setState(() => _speechDifficulty = val),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isBystanderMode
                              ? (l10n?.speechTestDesc ?? 'Ask the person to repeat a simple phrase. Is their speech slurred, strange, or are they unable to speak?')
                              : 'Say aloud: "The sky is blue in Dhaka." Is your speech slurred, hard to pronounce, or are words coming out jumbled?',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // T — Time of Onset Card
                Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(25),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                'T',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l10n?.timeTestTitle ?? 'T — Time of Onset',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n?.timeTestDesc ?? 'Time is Brain! Note the exact time symptoms were first observed.',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time_rounded, size: 18),
                          label: Text('Onset Time: ${_onsetTime.format(context)}'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _calculateTriage,
                  icon: const Icon(Icons.speed_rounded),
                  label: Text(
                    l10n?.calculateRisk ?? 'Assess Risk',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ] else ...[
                // Assessment Result Screen
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
                        size: 56,
                        color: riskTheme.getColor(_result!.riskLevel),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _result!.hasPositiveSign
                            ? (l10n?.strokePositiveAlert ?? 'CRITICAL STROKE RISK IDENTIFIED')
                            : 'LOW PRIMARY RISK',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: riskTheme.getColor(_result!.riskLevel),
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!.hasPositiveSign
                            ? (l10n?.strokePositiveDesc ?? 'One or more positive signs of acute stroke detected. Every minute lost is brain tissue lost. Call emergency services immediately.')
                            : (l10n?.strokeNegativeNotice ?? 'No primary FAST signs reported. If sudden weakness, severe headache, or confusion develops, seek emergency care immediately.'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Positive Signs Identified
                if (_result!.positiveSigns.isNotEmpty) ...[
                  Text(
                    'Positive FAST Indicators',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: _result!.positiveSigns.map((sign) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Icon(Icons.warning_amber_rounded,
                                  size: 20, color: theme.colorScheme.error),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sign,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Clinical Guidance
                Text(
                  l10n?.firstAidGuidance ?? 'First-Aid Guidance',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ..._result!.clinicalGuidance.map((guideline) {
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

                const SizedBox(height: 24),

                if (_result!.hasPositiveSign) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _dispatchStrokeEmergency,
                    icon: const Icon(Icons.emergency_rounded, size: 24),
                    label: Text(
                      l10n?.dispatchStrokeSos ?? 'Dispatch Stroke SOS Alert',
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
                      _faceDroop = false;
                      _armWeakness = false;
                      _speechDifficulty = false;
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
