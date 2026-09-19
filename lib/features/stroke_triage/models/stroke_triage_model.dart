import '../../../core/constants/alert_constants.dart';

/// Input observations for Stroke F.A.S.T. rapid clinical triage
class StrokeAssessmentInput {
  final bool isBystanderMode;
  final bool faceDroop;
  final bool armWeakness;
  final bool speechDifficulty;
  final DateTime? onsetTime;

  const StrokeAssessmentInput({
    this.isBystanderMode = false,
    this.faceDroop = false,
    this.armWeakness = false,
    this.speechDifficulty = false,
    this.onsetTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'isBystanderMode': isBystanderMode,
      'faceDroop': faceDroop,
      'armWeakness': armWeakness,
      'speechDifficulty': speechDifficulty,
      'onsetTime': onsetTime?.toIso8601String(),
    };
  }

  factory StrokeAssessmentInput.fromMap(Map<String, dynamic> map) {
    return StrokeAssessmentInput(
      isBystanderMode: map['isBystanderMode'] as bool? ?? false,
      faceDroop: map['faceDroop'] as bool? ?? false,
      armWeakness: map['armWeakness'] as bool? ?? false,
      speechDifficulty: map['speechDifficulty'] as bool? ?? false,
      onsetTime: map['onsetTime'] != null
          ? DateTime.tryParse(map['onsetTime'] as String)
          : null,
    );
  }
}

/// Clinical result for Stroke F.A.S.T. assessment
class StrokeTriageResult {
  final bool hasPositiveSign;
  final RiskLevel riskLevel;
  final AlertLevel alertLevel;
  final List<String> positiveSigns;
  final DateTime? onsetTime;
  final List<String> clinicalGuidance;

  const StrokeTriageResult({
    required this.hasPositiveSign,
    required this.riskLevel,
    required this.alertLevel,
    required this.positiveSigns,
    this.onsetTime,
    required this.clinicalGuidance,
  });

  Map<String, dynamic> toMap() {
    return {
      'hasPositiveSign': hasPositiveSign,
      'riskLevel': riskLevel.name,
      'alertLevel': alertLevel.value,
      'positiveSigns': positiveSigns,
      'onsetTime': onsetTime?.toIso8601String(),
      'clinicalGuidance': clinicalGuidance,
    };
  }
  factory StrokeTriageResult.fromMap(Map<String, dynamic> map) {
    return StrokeTriageResult(
      hasPositiveSign: map['hasPositiveSign'] as bool? ?? false,
      riskLevel: RiskLevel.values.firstWhere(
        (r) => r.name == map['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      alertLevel: AlertLevel.values.firstWhere(
        (a) => a.value == map['alertLevel'],
        orElse: () => AlertLevel.informational,
      ),
      positiveSigns: List<String>.from(map['positiveSigns'] as List? ?? []),
      onsetTime: map['onsetTime'] != null
          ? DateTime.tryParse(map['onsetTime'] as String)
          : null,
      clinicalGuidance: List<String>.from(map['clinicalGuidance'] as List? ?? []),
    );
  }
}

/// Rapid clinical triage engine for Acute Ischemic / Hemorrhagic Stroke (F.A.S.T. Protocol)
class StrokeTriageScorer {
  const StrokeTriageScorer();

  static StrokeTriageResult evaluate(StrokeAssessmentInput input) =>
      const StrokeTriageScorer().assess(input);

  StrokeTriageResult assess(StrokeAssessmentInput input) {
    final List<String> positiveSigns = [];
    final List<String> guidance = [];

    if (input.faceDroop) {
      positiveSigns.add('F — Face Drooping / Asymmetric Smile');
    }
    if (input.armWeakness) {
      positiveSigns.add('A — Arm Weakness / Downward Drift');
    }
    if (input.speechDifficulty) {
      positiveSigns.add('S — Speech Difficulty / Slurred Language');
    }

    final hasPositive = positiveSigns.isNotEmpty;

    if (hasPositive) {
      // Acute Stroke Emergency (Time is Brain)
      guidance.add(
        'TIME IS BRAIN: Millions of neurons are lost every minute. Call 999 immediately.',
      );
      guidance.add(
        'Position the patient lying down with the head and shoulders slightly elevated (about 30 degrees).',
      );
      guidance.add(
        'DO NOT give any food, water, or medicine (DO NOT administer aspirin, as it can worsen bleeding in hemorrhagic stroke).',
      );
      guidance.add(
        'Note symptom onset time accurately for hospital thrombolysis / thrombectomy eligibility (therapeutic window: 3 to 4.5 hours).',
      );

      return StrokeTriageResult(
        hasPositiveSign: true,
        riskLevel: RiskLevel.critical,
        alertLevel: AlertLevel.critical,
        positiveSigns: positiveSigns,
        onsetTime: input.onsetTime ?? DateTime.now(),
        clinicalGuidance: guidance,
      );
    } else {
      // Non-primary screening
      guidance.add(
        'No classic F.A.S.T. signs reported at this time.',
      );
      guidance.add(
        'Be vigilant: if sudden vision loss, severe balance difficulty, or sudden confusion occurs, seek emergency care immediately.',
      );

      return StrokeTriageResult(
        hasPositiveSign: false,
        riskLevel: RiskLevel.low,
        alertLevel: AlertLevel.informational,
        positiveSigns: [],
        onsetTime: input.onsetTime,
        clinicalGuidance: guidance,
      );
    }
  }
}
