# 🧠 memory.md — Project Memory (Progress & Decisions)

### 1. Memory
- Project: **SafeLife**, thesis project (Flutter + Firebase, Provider).
- Positioning: *unified emergency engine*, not two apps combined. Emergency types are pluggable.
- Terminology: use **"symptom-based triage / risk assessment"**, never "detection/diagnosis."
- Language: Bangla-first UI with English toggle. Target region: Bangladesh (verified emergency numbers: 999, 109, 333).
- Connected Firebase Project: `womansafety-215e2`.
- Scoring weights are **not final**; they require published sources and clinician review.

### 2. What Happened
- [Initial] Project idea analyzed. Key gaps identified: undefined risk scoring, no alert rules, no responder side, no privacy/misuse protection, missing backend (Cloud Functions), SOS reliability (SMS fallback, background location, cancel countdown), stroke self-assessment logic flaw (bystander mode added).
- [Phase 0 Complete] Initialized Flutter project with package `com.safelife.app`.
  - Configured Material 3 theme system with deep rose `#C2185B` seed and custom `RiskLevelTheme` extension.
  - Implemented bilingual localization skeleton (Bangla-first `bn`, English `en`).
  - Implemented Bangladesh emergency numbers (999, 109, 333) with URL launcher integration.
  - Interactive foundation Dashboard with accessible central SOS button and 5-second countdown.
- [Phase 1 Complete] Login & Authentication + Profile module fully established:
  - Linked to Firebase project `womansafety-215e2` with auto-generated `lib/firebase_options.dart`.
  - Implemented `UserProfile` model with blood group, chronic conditions, medications, allergies.
  - Implemented `EmergencyContact` model with consent verification tracking to prevent misuse/stalking.
  - Built `AuthRepository`, `ProfileRepository`, `ContactsRepository` with test-safe fallbacks.
  - Implemented Provider state management: `SafeLifeAuthProvider`, `ProfileProvider`, `ContactsProvider`.
  - Created Material 3 UI screens: `OnboardingScreen`, `LoginScreen`, `RegisterScreen`, `ForgotPasswordScreen`, `MedicalProfileScreen`, and `EmergencyContactsScreen`.
  - Added Navigation Drawer to `DashboardScreen` with user info header, Medical ID & contacts shortcuts, and logout flow.
  - Full test suite: 14 automated unit and widget tests passing; `flutter analyze` reporting 0 issues.
- [Phase 2 Complete] Dashboard & Smart SOS (MVP Core) implemented and verified:
  - Unified `EmergencyCase`, `EmergencyLocation`, `EmergencyStatus`, and `ContactAlertRecord` models with bidirectional serialization and immutable `copyWith`.
  - `LocationService` wrapping `geolocator` with high-accuracy position fixes, throttled streaming, and graceful offline degradation.
  - `SmsFallbackService` producing localized English and Bangla emergency payloads with direct Google Maps URLs, user identity, and 999 national helpline routing.
  - `EmergencyRepository` with dual Firestore (`emergencies/{id}`) and local `SharedPreferences` offline cache for zero data loss in low-connectivity settings.
  - `SosProvider` managing 5-second countdown cancel window, emergency case dispatch, background GPS streaming, contact alerting, and case resolution.
  - `ActiveEmergencyScreen` with pulsing beacon animation, real-time coordinates, external Google Maps launcher, contact delivery badges, 999 direct dialing, and "I'm Safe" resolution confirmation dialog.
  - `DashboardScreen` wired with real-time active emergency alert banner and SOS dispatch modal.
  - Comprehensive automated test suite: 26 unit and widget tests passing; `flutter analyze` 0 issues.

- [Phase 3 Complete] Clinical Triage Engines (Cardiovascular & Stroke), Incident Reporting, and Emergency History:
  - Implemented `CardiacSymptomInput`, `CardiacTriageResult`, and `CardiacTriageScorer` with AHA/ESC-aligned pre-hospital scoring (0-2 Low, 3-4 Medium, 5-6 High, 7+ or classic radiating pain = Critical) and first-aid recommendations (300mg soluble aspirin caution, rest, 999).
  - Implemented `CardiacTriageScreen` featuring acute symptoms questionnaire, severity slider, comorbidity chips, dynamic risk badge, first-aid step cards, and unified SOS alert escalation.
  - Implemented `StrokeAssessmentInput`, `StrokeTriageResult`, and `StrokeTriageScorer` utilizing the American Stroke Association F.A.S.T. protocol with default Bystander Mode, symptom onset time picker, and instant Level 4 Critical risk escalation ("Time is Brain").
  - Implemented `StrokeTriageScreen` supporting both Bystander Observation Mode and Self-Assessment Mode, interactive F-A-S testing, and rapid emergency dispatch.
  - Implemented `IncidentReport` model and `IncidentReportRepository` with dual Firestore (`incidentReports/{id}`) and local offline cache for confidential harassment, stalking, and threat logging.
  - Implemented `IncidentReportScreen` with category chips, multiline description, GPS tagging, and past confidential reports tab.
  - Enhanced `EmergencyRepository` with `streamEmergencyHistory(userId)` and local history caching for offline viewing.
  - Built `EmergencyHistoryScreen` with category filters (All, Safety, Cardiac, Stroke), risk badges, status chips, and detailed case dialogs with external Google Maps launching.
  - Wired all triage engines and history routes into `SafeLifeApp` and `DashboardScreen` (Drawer and service tiles).
  - Expanded test suite: 42/42 tests passing with `flutter analyze` reporting 0 issues.

- [Phase 4 Complete] Hospital & Ambulance Directory, Safety Timed Check-in, Responder Tracking, and Settings:
  - Pre-seeded Bangladesh emergency facility directory (`HospitalRepository`) with verified Dhaka tertiary and specialized hospitals (NICVD, NINS, DMCH, SSMCH, United, Square, Evercare, LabAid Cardiac, Kurmitola General, BSMMU).
  - Geodesic distance calculation using Haversine formula based on real-time user GPS coordinates.
  - Clinical facility filtering for acute catheterization lab (Cath Lab / Primary PCI), stroke thrombolysis (tPA / acute stroke unit), 24/7 emergency care, and intensive care units (ICU).
  - Built `HospitalDirectoryScreen` with interactive capability filter chips, real-time search, external Google Maps route navigation, and direct telephone calling.
  - Implemented `AmbulanceBooking` model and `AmbulanceRepository` supporting Basic Life Support (BLS) and Advanced Cardiac Life Support (ALS) equipment tiers.
  - Built `AmbulanceProvider` and `AmbulanceRequestScreen` with simulated real-time dispatch timeline progression (`requested` -> `dispatched` -> `enRoute` -> `arrived`), driver contact card, vehicle registration, and direct 999 & Red Crescent phone shortcuts.
  - Implemented `SafetyTimerProvider` and `SafetyTimerScreen` ("Walk With Me") with custom commute presets (5m, 15m, 30m, 60m), real-time circular countdown clock, warning state under 2 minutes, and automatic fail-safe SOS dispatch if arrival is not confirmed before expiration.
  - Implemented `SettingsScreen` with bilingual language toggle (Bangla / English), Material 3 Dark / Light theme switcher, emergency countdown duration selector (3s, 5s, 10s), quick links to Medical ID & Emergency Contacts, and clinical ethical notices.
  - Integrated all Phase 4 modules into `SafeLifeApp` routes and `DashboardScreen` service tiles & Navigation Drawer.
  - Total automated test suite: 60/60 tests passing with `flutter analyze` reporting 0 issues.

- [Phase 5 Complete] Admin Dashboard, Responder Command Panel, Regional Incident Analytics, and Cloud Functions Alert Escalation Architecture:
  - Implemented `PlatformKPIs`, `EmergencyDistribution`, and `RiskSeverityBreakdown` models in `features/admin/models/analytics_summary.dart`.
  - Implemented `IncidentHotspot` model and `AdminAnalyticsRepository` with 7 pre-seeded Dhaka regional incident clusters (Dhanmondi, Gulshan/Banani, Mirpur 10, Old Dhaka, Uttara, Mohakhali/Tejgaon, Motijheel) with ThreatLevel classification.
  - Implemented `AdminDashboardScreen` providing interactive KPI metrics, emergency type distribution bars, triage severity breakdowns, regional hotspot explorers, and thesis evaluation dataset export dialog.
  - Implemented `ResponderCase` model and `ResponderRepository` with local demo cases ordered by Level 4 Critical risk priority first, real-time Firestore streaming, unit dispatch assignment, lifecycle status updates (`pending` -> `accepted` -> `dispatched` -> `onScene` -> `resolved`), and clinical notes logging.
  - Built `ResponderProvider` state management and `ResponderPanelScreen` with responsive mobile & desktop command layouts, critical queue badge, emergency triage symptom indicators inspection, live GPS coordinates, and 1-tap phone dialer.
  - Created Cloud Functions codebase in `functions/` (`package.json`, `tsconfig.json`, `src/index.ts`) establishing:
    - `onEmergencyCreated`: 4-tier alert level assessment, FCM push notifications to verified contacts, timeout escalation schedule (N=60s ACK timeout, M=120s responder fallback), SMS fallback via Twilio/HTTP gateway.
    - `onIncidentReportLogged`: Anonymized incident aggregation into Dhaka hotspot clusters.
    - `getEvaluationMetrics`: Callable HTTPS endpoint aggregating platform KPIs, latency benchmarks, and triage distributions for thesis evaluation.
  - Integrated `/admin` and `/responder` into `SafeLifeApp` routes and `DashboardScreen` Navigation Drawer and service tiles.
  - Comprehensive test suite: 78 automated unit and widget tests passing across 16 test suites; `flutter analyze` 0 issues.

- [Phase 6 Complete] Web & Big-Screen Responsiveness, RenderFlex Overflow Elimination, and Browser UX:
  - Redesigned `DashboardScreen` into a responsive two-column Bento Grid on large viewports (width >= 960px, maxWidth 1200px) and centered mobile layout (maxWidth 600px). Refactored `_ServiceTile` to prevent horizontal text overflows.
  - Refactored `AdminDashboardScreen` with a centered `maxWidth: 1200` layout, side-by-side distribution and triage severity charts, and `FittedBox` scale protection on KPI cards.
  - Refactored `ResponderPanelScreen` with flexible status chips and overflow-safe master-detail headers.
  - Centered and constrained all screens with dedicated desktop bounds: `HospitalDirectoryScreen` (1000px), `AmbulanceRequestScreen` (850px), `SafetyTimerScreen` (700px), `CardiacTriageScreen` (850px), `StrokeTriageScreen` (850px), `IncidentReportScreen` (850px), `EmergencyHistoryScreen` (950px), `MedicalProfileScreen` (800px), `EmergencyContactsScreen` (850px), `SettingsScreen` (800px), `ActiveEmergencyScreen` (800px), and Auth screens (480px-520px).
  - Resolved `Row` flex overflow on authentication screens using responsive `Wrap` widgets.
  - Zero compilation or lint errors (`flutter analyze` reports 0 issues); 100% test pass rate (78/78 tests across 16 test suites passing).

### 3. Currently Working
- **Status:** All phases (Phases 0 through 6) are 100% complete, fully responsive for desktop web / mobile, zero overflows, and completely verified!
- **Platform Health:** 78/78 automated tests passing, 0 analysis issues, full bilingual English/Bengali coverage, and running live in Chrome.

### 4. Open Questions (TBD)
- Production Firebase project deployment credentials for Cloud Functions deploy (`firebase deploy --only functions`).
- Selection of live Bangladesh SMS gateway (e.g., Greenweb, BulkSMSBD, or Twilio) for deployment environment variables.
- Clinician/supervisor review of final thesis evaluation metrics.

### 5. Updates
- Date: 2026-09-19 — Phase 0 completed successfully.
- Date: 2026-09-19 — Phase 1 completed successfully.
- Date: 2026-09-19 — Phase 2 completed successfully with 26/26 tests passing and 0 analysis issues.
- Date: 2026-09-19 — Phase 3 completed successfully with 42/42 tests passing and 0 analysis issues.
- Date: 2026-09-19 — Phase 4 completed successfully with 60/60 tests passing and 0 analysis issues.
- Date: 2026-09-19 — Phase 5 completed successfully with 78/78 tests passing and 0 analysis issues.
- Date: 2026-09-19 — Phase 6 completed successfully: desktop web responsiveness, zero overflows, and 78/78 tests passing.
