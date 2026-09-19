import 'package:flutter_test/flutter_test.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/features/stroke_triage/models/stroke_triage_model.dart';

void main() {
  group('StrokeTriageScorer Unit Tests', () {
    test('Zero signs leads to low risk evaluation', () {
      const input = StrokeAssessmentInput(
        faceDroop: false,
        armWeakness: false,
        speechDifficulty: false,
        isBystanderMode: true,
      );

      final result = StrokeTriageScorer.evaluate(input);
      expect(result.riskLevel, RiskLevel.low);
      expect(result.alertLevel, AlertLevel.informational);
      expect(result.hasPositiveSign, isFalse);
      expect(result.positiveSigns, isEmpty);
    });

    test('Single positive face drooping triggers Level 4 Critical risk (Time is Brain principle)', () {
      const input = StrokeAssessmentInput(
        faceDroop: true,
        armWeakness: false,
        speechDifficulty: false,
        isBystanderMode: true,
      );

      final result = StrokeTriageScorer.evaluate(input);
      expect(result.riskLevel, RiskLevel.critical);
      expect(result.alertLevel, AlertLevel.critical);
      expect(result.hasPositiveSign, isTrue);
      expect(result.positiveSigns.length, 1);
      expect(result.positiveSigns.first, contains('Face Drooping'));
      expect(result.clinicalGuidance.any((g) => g.contains('999')), isTrue);
    });

    test('Arm weakness alone triggers Level 4 Critical risk', () {
      const input = StrokeAssessmentInput(
        faceDroop: false,
        armWeakness: true,
        speechDifficulty: false,
        isBystanderMode: false,
      );

      final result = StrokeTriageScorer.evaluate(input);
      expect(result.riskLevel, RiskLevel.critical);
      expect(result.hasPositiveSign, isTrue);
      expect(result.positiveSigns.first, contains('Arm Weakness'));
    });

    test('Speech difficulty alone triggers Level 4 Critical risk', () {
      const input = StrokeAssessmentInput(
        faceDroop: false,
        armWeakness: false,
        speechDifficulty: true,
        isBystanderMode: false,
      );

      final result = StrokeTriageScorer.evaluate(input);
      expect(result.riskLevel, RiskLevel.critical);
      expect(result.hasPositiveSign, isTrue);
      expect(result.positiveSigns.first, contains('Speech Difficulty'));
    });

    test('All 3 FAST signs positive triggers maximum urgency guidance and notes onset time', () {
      final onset = DateTime.now().subtract(const Duration(minutes: 45));
      final input = StrokeAssessmentInput(
        faceDroop: true,
        armWeakness: true,
        speechDifficulty: true,
        onsetTime: onset,
        isBystanderMode: true,
      );

      final result = StrokeTriageScorer.evaluate(input);
      expect(result.riskLevel, RiskLevel.critical);
      expect(result.hasPositiveSign, isTrue);
      expect(result.positiveSigns.length, 3);
      expect(result.onsetTime, isNotNull);
    });

    test('StrokeAssessmentInput and Result serialization round-trip', () {
      final onset = DateTime(2026, 9, 19, 8, 30);
      final input = StrokeAssessmentInput(
        faceDroop: true,
        armWeakness: false,
        speechDifficulty: true,
        onsetTime: onset,
        isBystanderMode: true,
      );

      final map = input.toMap();
      final reconstructed = StrokeAssessmentInput.fromMap(map);

      expect(reconstructed.faceDroop, isTrue);
      expect(reconstructed.armWeakness, isFalse);
      expect(reconstructed.speechDifficulty, isTrue);
      expect(reconstructed.isBystanderMode, isTrue);

      final result = StrokeTriageScorer.evaluate(reconstructed);
      final resultMap = result.toMap();
      final reconstructedResult = StrokeTriageResult.fromMap(resultMap);

      expect(reconstructedResult.riskLevel, result.riskLevel);
      expect(reconstructedResult.hasPositiveSign, result.hasPositiveSign);
      expect(reconstructedResult.positiveSigns.length, 2);
    });
  });
}
