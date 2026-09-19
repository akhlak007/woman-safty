import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const OnboardingScreen({super.key, required this.onComplete});

  static const String keyCompleted = 'onboarding_completed';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.keyCompleted, true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final steps = [
      _OnboardingStep(
        title: l10n?.onboardingStep1Title ?? 'Unified Smart Emergency Engine',
        description: l10n?.onboardingStep1Desc ??
            'Instant emergency alerts for women\'s safety threats, acute heart attack symptoms, and stroke emergencies.',
        icon: Icons.emergency_rounded,
        iconColor: theme.colorScheme.primary,
      ),
      _OnboardingStep(
        title: l10n?.onboardingStep2Title ?? 'Consent-Based Live Tracking',
        description: l10n?.onboardingStep2Desc ??
            'Your verified emergency contacts receive your live GPS location and SMS alerts only when an emergency is active.',
        icon: Icons.share_location_rounded,
        iconColor: theme.colorScheme.secondary,
      ),
      _OnboardingStep(
        title: l10n?.onboardingStep3Title ?? 'Ethical & Medical Notice',
        description: l10n?.onboardingStep3Desc ??
            'SafeLife is a symptom-based triage and emergency coordination platform, not a diagnostic medical device. Call 999 for immediate acute response.',
        icon: Icons.shield_rounded,
        iconColor: theme.colorScheme.tertiary,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Header
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(color: theme.colorScheme.outline),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: steps.length,
                  itemBuilder: (context, index) {
                    final step = steps[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            color: step.iconColor.withAlpha(30),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            step.icon,
                            size: 54,
                            color: step.iconColor,
                          ),
                        ),
                        const SizedBox(height: 36),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Page Indicator Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Bottom Action Button
              FilledButton(
                onPressed: () {
                  if (_currentPage == steps.length - 1) {
                    _finishOnboarding();
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Text(
                  _currentPage == steps.length - 1
                      ? (l10n?.acceptAndContinue ?? 'I Understand & Accept')
                      : (l10n?.getStarted ?? 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
  });
}
