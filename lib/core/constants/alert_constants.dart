/// Emergency Alert Engine Constants and Escalation Thresholds
class AlertConstants {
  const AlertConstants._();

  /// Default SOS cancel countdown window in seconds before alert dispatch
  static const int defaultCountdownSeconds = 5;

  /// Live location throttling interval in seconds
  static const int locationUpdateIntervalSeconds = 10;

  /// Level 2 acknowledgement timeout in seconds before escalating to Level 3 (configurable N)
  static const int level2AcknowledgementTimeoutSeconds = 60;

  /// Level 3 acknowledgement timeout in seconds before escalating to Level 4 (configurable M)
  static const int level3AcknowledgementTimeoutSeconds = 120;

  /// Number of SMS retry attempts before marking alert as failed
  static const int maxSmsRetryAttempts = 3;
}

/// Alert priority levels handled by the SafeLife Alert Engine
enum AlertLevel {
  /// Level 1: Low-risk triage, informational guidance, logged locally/cloud
  informational(1, 'Informational'),

  /// Level 2: User SOS or medium triage, emergency contacts notified via FCM + SMS
  emergencyContactAlert(2, 'Emergency Contact Alert'),

  /// Level 3: High-risk triage or unacknowledged Level 2, repeat alerts & call prompt
  highPriority(3, 'High Priority'),

  /// Level 4: Critical cardiac, stroke FAST positive, or unacknowledged Level 3
  critical(4, 'Critical');

  final int value;
  final String label;
  const AlertLevel(this.value, this.label);
}

/// Clinical & safety triage risk levels
enum RiskLevel {
  low('Low'),
  medium('Medium'),
  high('High'),
  critical('Critical');

  final String label;
  const RiskLevel(this.label);
}

/// Unified Emergency Types supported across the SafeLife pipeline
enum EmergencyType {
  safety('safety', 'Women Safety'),
  cardiac('cardiac', 'Heart Attack / Cardiac'),
  stroke('stroke', 'Stroke (FAST)');

  final String code;
  final String displayName;
  const EmergencyType(this.code, this.displayName);
}
