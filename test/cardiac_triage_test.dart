import 'package:flutter_test/flutter_test.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/features/heart_triage/models/cardiac_triage_model.dart';

void main() {
  group('CardiacTriageScorer Unit Tests', () {
    test('Low risk when minimal or no symptoms', () {
      const input = CardiacSymptomInput(
        chestPain: false,
        chestPainSeverity: 1,
        painRadiates: false,
        shortnessOfBreath: false,
        diaphoresis: false,
        nauseaOrDizziness: false,
        durationOver10Min: false,
        ageOver55: false,
        hasHypertension: false,
        hasDiabetes: false,
        priorCardiacHistory: false,
      );

      final result = CardiacTriageScorer.evaluate(input);
      expect(result.riskLevel, RiskLevel.low);
      expect(result.alertLevel, AlertLevel.informational);
      expect(result.shouldEscalateEmergency, false);
      expect(result.score, 0);
    });

    test('Critical risk immediately fired for classic radiating chest pain with diaphoresis', () {
      const input = CardiacSymptomInput(
        chestPain: true,
        chestPainSeverity: 9,
        painRadiates: true,
        shortnessOfBreath: true,
        diaphoresis: true,
        nauseaOrDizziness: true,
        durationOver10Min: true,
        hasHypertension: true,
        priorCardiacHistory: true,
      );

      final result = CardiacTriageScorer.evaluate(input);
      expect(result.riskLevel, RiskLevel.critical);
      expect(result.alertLevel, AlertLevel.critical);
      expect(result.shouldEscalateEmergency, true);
      expect(result.firstAidGuidance, isNotEmpty);
      expect(
        result.firstAidGuidance.any((s) => s.toLowerCase().contains('aspirin')),
        isTrue,
      );
      expect(result.rulesFired.any((r) => r.contains('arm, shoulder, neck, or jaw')), isTrue);
    });

    test('Medium risk for chest tightness persisting over 10 minutes', () {
      const input = CardiacSymptomInput(
        chestPain: true,
        chestPainSeverity: 5,
        painRadiates: false,
        shortnessOfBreath: false,
        diaphoresis: false,
        nauseaOrDizziness: false,
        durationOver10Min: true,
      );

      final result = CardiacTriageScorer.evaluate(input);
      expect(result.riskLevel, RiskLevel.medium);
      expect(result.alertLevel, AlertLevel.emergencyContactAlert);
    });

    test('CardiacSymptomInput and Result serialization round-trip', () {
      const input = CardiacSymptomInput(
        chestPain: true,
        chestPainSeverity: 8,
        painRadiates: true,
        shortnessOfBreath: false,
        diaphoresis: false,
        nauseaOrDizziness: true,
        durationOver10Min: true,
        hasDiabetes: true,
        priorCardiacHistory: true,
      );

      final map = input.toMap();
      final reconstructed = CardiacSymptomInput.fromMap(map);

      expect(reconstructed.chestPain, isTrue);
      expect(reconstructed.painRadiates, isTrue);
      expect(reconstructed.chestPainSeverity, 8);
      expect(reconstructed.hasDiabetes, isTrue);

      final result = CardiacTriageScorer.evaluate(reconstructed);
      final resultMap = result.toMap();
      final reconstructedResult = CardiacTriageResult.fromMap(resultMap);

      expect(reconstructedResult.riskLevel, result.riskLevel);
      expect(reconstructedResult.score, result.score);
      expect(reconstructedResult.shouldEscalateEmergency, result.shouldEscalateEmergency);
    });
  });
}
