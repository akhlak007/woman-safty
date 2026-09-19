import '../../../core/constants/alert_constants.dart';

/// User symptom responses and medical risk inputs for cardiac assessment
class CardiacSymptomInput {
  final bool chestPain;
  final int chestPainSeverity; // 1-10
  final bool painRadiates; // Radiating to left arm, shoulder, jaw, neck, or back
  final bool shortnessOfBreath;
  final bool diaphoresis; // Cold sweats
  final bool nauseaOrDizziness;
  final bool durationOver10Min;
  final bool ageOver55;
  final bool hasHypertension;
  final bool hasDiabetes;
  final bool priorCardiacHistory;

  const CardiacSymptomInput({
    this.chestPain = false,
    this.chestPainSeverity = 1,
    this.painRadiates = false,
    this.shortnessOfBreath = false,
    this.diaphoresis = false,
    this.nauseaOrDizziness = false,
    this.durationOver10Min = false,
    this.ageOver55 = false,
    this.hasHypertension = false,
    this.hasDiabetes = false,
    this.priorCardiacHistory = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'chestPain': chestPain,
      'chestPainSeverity': chestPainSeverity,
      'painRadiates': painRadiates,
      'shortnessOfBreath': shortnessOfBreath,
      'diaphoresis': diaphoresis,
      'nauseaOrDizziness': nauseaOrDizziness,
      'durationOver10Min': durationOver10Min,
      'ageOver55': ageOver55,
      'hasHypertension': hasHypertension,
      'hasDiabetes': hasDiabetes,
      'priorCardiacHistory': priorCardiacHistory,
    };
  }

  factory CardiacSymptomInput.fromMap(Map<String, dynamic> map) {
    return CardiacSymptomInput(
      chestPain: map['chestPain'] as bool? ?? false,
      chestPainSeverity: map['chestPainSeverity'] as int? ?? 1,
      painRadiates: map['painRadiates'] as bool? ?? false,
      shortnessOfBreath: map['shortnessOfBreath'] as bool? ?? false,
      diaphoresis: map['diaphoresis'] as bool? ?? false,
      nauseaOrDizziness: map['nauseaOrDizziness'] as bool? ?? false,
      durationOver10Min: map['durationOver10Min'] as bool? ?? false,
      ageOver55: map['ageOver55'] as bool? ?? false,
      hasHypertension: map['hasHypertension'] as bool? ?? false,
      hasDiabetes: map['hasDiabetes'] as bool? ?? false,
      priorCardiacHistory: map['priorCardiacHistory'] as bool? ?? false,
    );
  }
}

/// Result of clinical symptom-based cardiac triage assessment
class CardiacTriageResult {
  final int score;
  final RiskLevel riskLevel;
  final AlertLevel alertLevel;
  final List<String> rulesFired;
  final List<String> firstAidGuidance;
  final bool shouldEscalateEmergency;

  const CardiacTriageResult({
    required this.score,
    required this.riskLevel,
    required this.alertLevel,
    required this.rulesFired,
    required this.firstAidGuidance,
    required this.shouldEscalateEmergency,
  });

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'riskLevel': riskLevel.name,
      'alertLevel': alertLevel.value,
      'rulesFired': rulesFired,
      'firstAidGuidance': firstAidGuidance,
      'shouldEscalateEmergency': shouldEscalateEmergency,
    };
  }
  factory CardiacTriageResult.fromMap(Map<String, dynamic> map) {
    return CardiacTriageResult(
      score: map['score'] as int? ?? 0,
      riskLevel: RiskLevel.values.firstWhere(
        (r) => r.name == map['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      alertLevel: AlertLevel.values.firstWhere(
        (a) => a.value == map['alertLevel'],
        orElse: () => AlertLevel.informational,
      ),
      rulesFired: List<String>.from(map['rulesFired'] as List? ?? []),
      firstAidGuidance: List<String>.from(map['firstAidGuidance'] as List? ?? []),
      shouldEscalateEmergency: map['shouldEscalateEmergency'] as bool? ?? false,
    );
  }
}

/// Clinical guideline aligned rule-based triage scoring engine
/// (Follows American Heart Association / European Society of Cardiology pre-hospital triage guidelines)
class CardiacTriageScorer {
  const CardiacTriageScorer();

  static CardiacTriageResult evaluate(CardiacSymptomInput input) =>
      const CardiacTriageScorer().assess(input);

  CardiacTriageResult assess(CardiacSymptomInput input) {
    int score = 0;
    final List<String> rulesFired = [];
    final List<String> guidance = [];

    // Acute Symptom Scoring
    if (input.chestPain) {
      score += (input.chestPainSeverity >= 7) ? 3 : 2;
      rulesFired.add(
        'Severe acute chest tightness / pressure (Severity: ${input.chestPainSeverity}/10)',
      );
    }

    if (input.painRadiates) {
      score += 2;
      rulesFired.add('Radiation of discomfort to arm, shoulder, neck, or jaw');
    }

    if (input.shortnessOfBreath) {
      score += 2;
      rulesFired.add('Acute dyspnea / shortness of breath');
    }

    if (input.diaphoresis) {
      score += 2;
      rulesFired.add('Profuse diaphoresis / unexplained cold sweats');
    }

    if (input.durationOver10Min) {
      score += 2;
      rulesFired.add('Symptoms persisting > 10 minutes continuously');
    }

    if (input.nauseaOrDizziness) {
      score += 1;
      rulesFired.add('Associated lightheadedness, nausea, or dizziness');
    }

    // Profile Risk Factor Scoring
    if (input.priorCardiacHistory) {
      score += 2;
      rulesFired.add('Established prior history of cardiovascular disease / MI');
    }

    if (input.ageOver55) {
      score += 1;
      rulesFired.add('Age demographic factor (> 55 years)');
    }

    if (input.hasHypertension || input.hasDiabetes) {
      score += 1;
      rulesFired.add('Pre-existing cardiovascular comorbidity (Hypertension/Diabetes)');
    }

    // Over-triage rule: classic radiating chest pain lasting > 10 mins is immediately critical
    final isClassicPresentation = input.chestPain &&
        input.painRadiates &&
        (input.durationOver10Min || input.diaphoresis || input.shortnessOfBreath);

    final RiskLevel risk;
    final AlertLevel alert;

    if (isClassicPresentation || score >= 7) {
      risk = RiskLevel.critical;
      alert = AlertLevel.critical;
    } else if (score >= 5) {
      risk = RiskLevel.high;
      alert = AlertLevel.highPriority;
    } else if (score >= 3) {
      risk = RiskLevel.medium;
      alert = AlertLevel.emergencyContactAlert;
    } else {
      risk = RiskLevel.low;
      alert = AlertLevel.informational;
    }

    // Pre-hospital first aid guidance based on risk level
    if (risk == RiskLevel.critical || risk == RiskLevel.high) {
      guidance.add(
        'Sit down immediately in a semi-reclined, comfortable position. Avoid all physical exertion or walking.',
      );
      guidance.add(
        'Chew 300mg soluble aspirin immediately if available, provided you have no aspirin allergy, active gastrointestinal bleeding, or stroke symptoms.',
      );
      guidance.add(
        'Loosen restrictive clothing around the neck and chest to facilitate unhindered breathing.',
      );
      guidance.add(
        'Call 999 immediately. Do not attempt to drive yourself to the hospital.',
      );
    } else if (risk == RiskLevel.medium) {
      guidance.add(
        'Rest in a comfortable position and monitor symptoms closely for the next 15 minutes.',
      );
      guidance.add(
        'If pain increases, radiates, or shortness of breath begins, re-triage or trigger SOS immediately.',
      );
      guidance.add(
        'Arrange immediate transportation to an urgent care or cardiovascular outpatient center.',
      );
    } else {
      guidance.add(
        'Symptoms currently reflect low acute risk. Continue to rest and drink water.',
      );
      guidance.add(
        'If chest tightness recurs or worsens, seek medical evaluation promptly.',
      );
    }

    return CardiacTriageResult(
      score: score,
      riskLevel: risk,
      alertLevel: alert,
      rulesFired: rulesFired,
      firstAidGuidance: guidance,
      shouldEscalateEmergency: risk == RiskLevel.critical || risk == RiskLevel.high,
    );
  }
}
