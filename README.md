# SafeLife

SafeLife is a responsive Flutter emergency-support application focused on women’s safety and urgent medical response in Bangladesh. It brings personal safety tools, emergency contacts, ambulance requests, nearby hospitals, and cardiac/stroke triage into one bilingual experience.

[![Live Demo](https://img.shields.io/badge/Live%20Demo-womansafety--215e2.web.app-success?style=for-the-badge&logo=firebase)](https://womansafety-215e2.web.app)

🌐 **Live Application:** [https://womansafety-215e2.web.app](https://womansafety-215e2.web.app)  
🚀 **Alternative Mirror:** [https://womansafety-215e2.firebaseapp.com](https://womansafety-215e2.firebaseapp.com)

The application is designed to reduce the number of decisions a person must make during a stressful situation. Its dashboard provides direct access to SOS support and Bangladesh’s national helplines while keeping preparation tools—such as a medical profile and trusted contacts—close at hand.

> SafeLife supports emergency assistance and symptom triage. It is not a medical diagnostic device and does not replace professional emergency services. Call **999** immediately in a life-threatening situation.

## What the application provides

### Emergency SOS

- Prominent SOS controls on the responsive dashboard.
- A cancelable countdown to reduce accidental alerts.
- Emergency case creation through the shared SOS provider.
- Live-location and responder-status screen for active emergencies.
- Alerts prepared for verified trusted contacts.
- SMS fallback support when configured on a supported device.

### Women’s safety tools

- Confidential incident reports for harassment, stalking, threats, or unsafe situations.
- Optional location attachment to incident reports.
- A “Walk With Me” safety timer with automatic SOS escalation when a check-in is missed.
- Emergency-contact management with verification and consent-oriented tracking rules.
- Emergency history for reviewing earlier alerts and assessments.

### Medical emergency triage

- Cardiac symptom questionnaire with rule-based risk levels and emergency guidance.
- Stroke F.A.S.T. assessment covering face, arm, speech, and symptom-onset time.
- Safety-focused first-aid information and escalation prompts.
- Medical profile for blood group, conditions, allergies, and medication details.

The triage flows intentionally favor early escalation when symptoms may indicate a serious emergency. They provide guidance, not a diagnosis.

### Ambulance and hospital support

- Ambulance request flow with BLS/ALS options.
- Dispatch progress states from request through arrival.
- Hospital directory with distance calculation and capability filters.
- Direct phone and map actions where the current platform supports them.

### Response and administration

- Responder panel with a priority-sorted emergency queue and response lifecycle actions.
- Admin dashboard with platform summaries, severity distribution, and incident hotspots.
- Firebase Cloud Functions for emergency escalation and aggregate metrics.

### Accessibility and localization

- English and Bangla interfaces with an instant language toggle.
- Light and dark themes.
- Responsive phone, tablet, desktop, and web layouts.
- Scroll-safe navigation and content-driven cards that avoid fixed-height overflow.
- Semantic controls and large emergency touch targets.

## Dashboard design

The dashboard uses a red-and-white emergency-service visual language:

- An emergency hero with direct SOS and ambulance actions.
- One-tap cards for **999**, **109**, and **333**.
- An adaptive service grid: one column on phones, two on tablets, and three on large screens.
- A preparedness panel for medical information and trusted contacts.
- A scrollable navigation drawer that remains usable on short screens.

Content is constrained on large displays for readability and expands naturally on smaller screens. Breakpoints are derived from the available component width so the layout also behaves correctly inside split-screen windows.

## Emergency numbers

| Number | Service |
| --- | --- |
| **999** | Bangladesh National Emergency Service |
| **109** | National Helpline Centre for Violence Against Women and Children |
| **333** | National Information and Service Helpline |

Calls are opened through the device’s phone handler. Browser and desktop behavior depends on the operating system and available calling application.

## Technology

- Flutter and Dart
- Provider for application state
- Firebase Authentication, Firestore, Realtime Database, Messaging, and Storage
- Geolocator for device location
- Shared Preferences and secure storage for local state
- URL Launcher for phone and map actions
- Flutter localization for English and Bangla

## Project structure

```text
lib/
├── app/                   # Routes, application setup, and themes
├── core/                  # Constants, errors, and platform services
├── features/
│   ├── admin/             # Analytics and incident hotspots
│   ├── ambulance/         # Ambulance booking and dispatch state
│   ├── auth/              # Login, registration, and onboarding
│   ├── dashboard/         # Responsive emergency dashboard
│   ├── heart_triage/      # Cardiac risk assessment
│   ├── history/           # Emergency history
│   ├── hospitals/         # Facility directory and routing
│   ├── incident_report/   # Confidential incident reports
│   ├── profile/           # Medical profile and trusted contacts
│   ├── responder/         # Responder command panel
│   ├── safety_timer/      # Timed journey check-ins
│   ├── settings/          # Language, theme, and preferences
│   ├── sos/               # SOS state and active emergency flow
│   └── stroke_triage/     # Stroke F.A.S.T. assessment
└── l10n/                  # English and Bangla translations

functions/                 # Firebase Cloud Functions
test/                      # Unit and widget tests
docs/                      # Product, design, and architecture notes
```

## Getting started

### Requirements

- Flutter SDK compatible with Dart `^3.13.0`
- Chrome for web development, or a configured Android/iOS emulator
- A Firebase project when using live authentication and cloud services

### Install and run

```bash
flutter pub get
flutter run -d chrome
```

To use another connected device:

```bash
flutter devices
flutter run -d <device-id>
```

The repository contains Firebase configuration files for the project structure. Use environment-appropriate Firebase credentials before deploying your own build.

## Quality checks

Run static analysis and the complete automated test suite before submitting changes:

```bash
flutter analyze
flutter test
```

The tests cover authentication models, SOS behavior, cardiac and stroke triage, safety timers, ambulance requests, hospitals, incident reports, responder workflows, analytics, settings, themes, and responsive dashboard layouts.

## Deployment

The web application is deployed on Firebase Hosting with integrated Cloud Firestore security rules:

- **Live URL:** [https://womansafety-215e2.web.app](https://womansafety-215e2.web.app)
- **Alternative Mirror:** [https://womansafety-215e2.firebaseapp.com](https://womansafety-215e2.firebaseapp.com)
- **Firebase Project Console:** [https://console.firebase.google.com/project/womansafety-215e2/overview](https://console.firebase.google.com/project/womansafety-215e2/overview)

### Deploy updates

```bash
# 1. Build optimized web release bundle
flutter build web --release

# 2. Deploy Firestore security rules and web hosting
firebase deploy --only firestore:rules,hosting
```

## Firebase functions

The `functions/` directory contains the TypeScript serverless functions. From that directory:

```bash
npm install
npm run build
```

Deploy only after selecting and validating the intended Firebase project.

## Privacy and safety principles

- Request only the permissions needed for the current action.
- Share continuous location only with verified, consent-based contacts.
- Keep incident reports confidential and minimize identifying data.
- Make emergency escalation explicit and provide an accidental-trigger cancel window.
- Never present rule-based triage as a clinical diagnosis.
- Preserve direct access to national emergency services even when app services are unavailable.

## License and project context

SafeLife is an academic/thesis-oriented emergency-response project. Review local medical, privacy, telecommunications, and emergency-service requirements before adapting it for production use.
