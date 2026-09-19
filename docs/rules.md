# 📜 rules.md — Project Rules, Standards & Guidelines

## SafeLife Project Rules

### 1. What to Use

- Feature-first folder structure with Provider for state management
- Repository pattern: UI → Provider → Repository → Firebase service
- Cloud Functions for **all alert-engine logic**. The client only creates events.
- `const` constructors, null safety, and `flutter_lints`
- Localization via ARB files (`en`, `bn`); no hard-coded UI strings
- Emergency numbers and alert thresholds in one constants file (verify local numbers, e.g. Bangladesh national emergency **999**, women & children helpline **109**, before release)
- Firestore Security Rules with role-based access (user, contact, responder, admin)

### 2. What to Avoid

- ❌ Putting alert logic only on the client (it fails if the app is killed or offline)
- ❌ Writing a Firestore document for every location tick (cost + rate limits); throttle or use Realtime Database
- ❌ Hard-coded API keys or secrets in source control
- ❌ Storing sensitive data in plain `SharedPreferences`
- ❌ Calling the triage "diagnosis" or "detection" in UI or documents. Use **"symptom-based triage / risk assessment."**
- ❌ Requesting all permissions at app launch; ask in context with an explanation
- ❌ Adding heavy or unmaintained packages without checking maintenance status

### 3. Libraries & Dependencies

| Purpose | Package (**verify current versions**) |
|---|---|
| State | `provider` |
| Firebase | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_database`, `firebase_messaging`, `firebase_storage`, `firebase_crashlytics` |
| Maps & location | `google_maps_flutter`, `geolocator`, `geocoding` |
| Background work | `flutter_background_service` or foreground-service plugin (**TBD**) |
| Permissions | `permission_handler` |
| Calling / links | `url_launcher` |
| Local storage | `shared_preferences`, `flutter_secure_storage` |
| Localization | `flutter_localizations`, `intl` |
| Connectivity | `connectivity_plus` |
| Testing | `flutter_test`, `mocktail`, `fake_cloud_firestore` |

Version guideline: pin to stable releases, commit `pubspec.lock`, and update dependencies deliberately, not automatically.

### 4. Error Handling

- Wrap every network, location, and permission call in try/catch and map failures to typed app errors.
- **Emergency path must degrade gracefully:** no internet → queue the event and send the SMS fallback; no GPS → use last known location and say so; notification failure → retry, then SMS.
- User-facing messages are short, plain, and localized. Never show raw exceptions.
- Log errors to Crashlytics (no personal or medical data in logs).
- Every alert send is recorded with status (`sent`, `delivered`, `acked`, `failed`) for auditing.

### 5. Boundaries of AI

**AI assistant CAN:**
- Generate boilerplate, UI screens, providers, repositories, tests, and Cloud Function scaffolding
- Explain packages, suggest architecture, and review code
- Draft documentation and thesis text

**AI assistant CANNOT / MUST NOT:**
- Invent clinical thresholds, weights, or medical claims. Scoring rules must cite a source and be marked "pending clinician review."
- Present the app as a diagnostic or replacement for professional care
- Write secrets, real API keys, or real personal data into code or docs
- Silently change the alert-level rules, security rules, or data model. Propose the change, then update `architecture.md` and `memory.md`.
- Make up package APIs. If unsure, say so and check the official documentation.
- Skip ahead of the current phase without instruction

### 6. General Rules

- **Code style:** `dart format`, `flutter analyze` clean before every commit; follow Effective Dart.
- **Naming:** files `snake_case.dart`, classes `PascalCase`, variables/methods `camelCase`, constants `kCamelCase` or `UPPER_SNAKE` (be consistent).
- **Commits:** Conventional Commits, e.g. `feat(sos): add cancel countdown`, `fix(alert): dedupe repeated triggers`.
- **Security & privacy:**
  - Collect only what is needed; get explicit consent for location and medical data.
  - Encrypt sensitive fields at rest where practical; enforce least-privilege Firestore rules.
  - Retention policy: delete live-location trails after the emergency closes plus a defined period (**TBD**).
  - **Misuse protection:** contacts must accept before receiving tracking; users can stop sharing at any time; sharing is always visibly indicated.
  - Show a medical disclaimer during onboarding and on triage screens.
  - Check whether human-participant testing needs institutional ethics approval.
- **Performance & scalability:** throttle location updates, batch related writes, paginate lists, and test alert latency under load.
- **Documentation:** doc comments on public classes and services; update `/docs` when architecture or rules change.
- **Testing:** unit tests for the scoring engine and alert rules (highest priority), widget tests for the SOS and triage flows, and integration tests for the alert pipeline against the Firebase emulator.
