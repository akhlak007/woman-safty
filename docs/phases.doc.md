# 🗺️ phases.doc.md — Breakdown into Manageable Phases

## SafeLife Project Phases

### Phase 0: Setup & Foundations
- Create the Flutter project and folder structure; set up the Firebase project (Auth, Firestore, FCM, Functions, Storage)
- Configure Firebase Emulator Suite, lints, theme, localization (en/bn), and routing
- Draft Firestore security rules v1
- Confirm the emergency numbers and SMS gateway choice

### Phase 1: Login & Authentication + Profile
- Registration, login, logout, password/OTP reset
- Profile management: name, phone, blood group, medical history, medications
- Emergency contact setup with contact verification/consent
- Onboarding: permission explainers, privacy policy, medical disclaimer

### Phase 2: Dashboard & Smart SOS (MVP core)
- Home dashboard with the SOS button, quick actions, and status card
- SOS flow: cancel countdown → emergency case creation → FCM + SMS to contacts
- Live location sharing (foreground service, throttled) and a contact-side tracking view
- Offline behavior: queue events and send the SMS fallback
- **Milestone: working end-to-end SOS demo**

### Phase 3: CRUD Operations & Triage Modules
- CRUD for contacts, medical info, incident reports, and emergency history
- Heart symptom questionnaire and rule-based scoring engine (Low → Critical)
- Stroke FAST assessment with bystander mode (any positive sign = Emergency)
- Form validation, list/detail views, search and filter for history

### Phase 4: Smart Alert Engine & Additional Features
- Cloud Functions alert engine: level assignment, escalation on no-acknowledgement, retries, dedup
- Contact acknowledgement flow ("I'm on my way")
- Nearby hospital finder (Google Places) and one-tap emergency calling
- Ambulance request flow with status timeline (simulated partners)
- Alternative SOS triggers (shake / power button / widget), timed check-in
- Notifications and settings/preferences (theme, language, accessibility)

### Phase 5: Admin Dashboard & Responder Panel
- Flutter Web admin: total/active users, registered patients
- Emergency analytics by type (safety / heart / stroke), response statistics
- Heat map and incident distribution (synthetic or anonymized data)
- Responder/hospital panel to accept and update requests

### Phase 6: Testing & Quality Assurance
- Unit tests (scoring engine, alert rules), widget tests, emulator-based integration tests
- Security-rules tests; permission-denied and no-network scenarios
- Performance: alert latency, battery drain, location accuracy, load test of the alert pipeline
- Clinician review of triage rules; usability testing with SUS

### Phase 7: Deployment, Evaluation & Thesis
- Release build (APK / Play internal testing); deploy web panels to Firebase Hosting
- Collect evaluation data and compare against the success metrics in the PRD
- Write up results, limitations, and future work (wearables, fall detection, real dispatch integration)
