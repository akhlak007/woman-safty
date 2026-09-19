# 📄 PRD.md — Product Requirement Document

## SafeLife: A Unified Smart Emergency Response Platform for Women's Safety and Cardiovascular/Stroke Triage

### 1. What to Build

- **Product name:** SafeLife
- **One-line pitch:** One app, one-tap emergency help for women's safety threats and heart attack / stroke emergencies, with live location sent to family and responders.
- **Core purpose / problem it solves:**
  Women's safety tools and medical emergency tools exist as separate apps, which slows decisions and coordination in a crisis. SafeLife runs both on a single **unified emergency engine**: detect a situation, assess its priority, alert the right people, and share live location until help arrives.
- **Goals:**
  - *User goals:* get help within seconds, keep family informed, know when symptoms need urgent care.
  - *Project goals:* deliver a working Flutter + Firebase prototype, and measure it (alert latency, triage accuracy, usability) for the thesis.

### 2. Targeted User

- **Primary audience:** Women, elderly people, heart disease patients, stroke-risk patients.
- **Secondary audience:** Family members / emergency contacts, hospital staff, emergency responders, system administrators.
- **Their needs / pain points:**
  - Danger leaves no time to unlock a phone, open an app, and find a button.
  - Patients may be unable to operate the app during a stroke or cardiac event.
  - Families do not know where the person is or how serious the situation is.
  - Mobile data is unreliable in emergencies.
- **Use cases:**
  1. A woman feels followed at night and triggers SOS discreetly; her contacts receive her live location.
  2. An elderly user has chest pain, completes a symptom check, and is told to call emergency services with contacts alerted.
  3. A family member notices facial drooping in a relative and uses **bystander mode** to raise a stroke emergency.
  4. A user reports harassment after the fact through incident reporting.
  5. An admin reviews anonymized emergency statistics and hotspots.

### 3. Features

#### Must-have (MVP)
- [ ] User registration, login, profile — Firebase Auth (phone/email)
- [ ] Emergency contact setup with contact verification (consent from the contact)
- [ ] Medical info storage (blood group, conditions, medications, allergies)
- [ ] Smart SOS button with cancel countdown (e.g. 5 s)
- [ ] Live location sharing during an active emergency (throttled)
- [ ] Notifications to contacts via FCM **plus SMS fallback** with a map link
- [ ] Emergency case creation and case history
- [ ] Heart symptom triage with a documented scoring model
- [ ] Stroke FAST triage with **bystander mode**
- [ ] Smart Alert Engine with defined rules and escalation (Cloud Functions)
- [ ] One-tap call to national emergency numbers

#### Should-have
- [ ] Incident reporting (harassment, stalking, physical threat, violence, other) with optional photo/audio evidence
- [ ] Nearby hospital finder (Google Places)
- [ ] Alternative SOS triggers: power/volume button, shake, home-screen widget
- [ ] Timed check-in ("alert my contacts if I don't confirm arrival in N minutes")
- [ ] Bangla + English UI, large-text accessibility mode
- [ ] Lock-screen / quick-access Medical ID

#### Nice-to-have
- [ ] Ambulance request flow with status tracking (Requested → Accepted → On The Way → Arrived), **simulated partners**
- [ ] Responder / hospital web panel
- [ ] Admin dashboard: user analytics, emergency analytics, heat map (Flutter Web)
- [ ] Wearable heart-rate input (Health Connect / HealthKit)
- [ ] Fall detection using the accelerometer
- [ ] Fake-call feature, voice-keyword trigger
- [ ] Separate long-term cardiovascular risk model trained on a public dataset

#### Out of scope (for now)
- Real integration with government or hospital dispatch systems
- Diagnosis or medical treatment advice
- Video streaming, iOS-specific background hardening (unless time permits)

### 4. Success Metrics (used in thesis evaluation)

| Metric | How to measure | Target |
|---|---|---|
| Alert latency (trigger → contact notified) | Timestamps logged on device and in Cloud Functions | **TBD** (e.g. < 10 s on data) |
| SMS fallback delivery | Test with mobile data off | Delivered in **TBD** s |
| Location accuracy | Compare shared vs. actual position | **TBD** m |
| Battery drain during tracking | 30-min tracking test on 2–3 devices | **TBD** % per hour |
| Triage agreement | Rule engine output vs. clinician-labeled scenarios | **TBD** % (favor sensitivity) |
| Usability | SUS questionnaire with real participants | SUS ≥ 68 |
