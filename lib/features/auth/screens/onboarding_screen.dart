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

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bgAnimController;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      title: 'Unified Smart Emergency Engine',
      description:
          'Instant emergency alerts for women\'s safety threats, acute heart attack symptoms, and stroke emergencies — all in one platform.',
      icon: Icons.emergency_rounded,
      gradient: [Color(0xFF1A1060), Color(0xFF4F2CC7)],
      accent: Color(0xFF7C5CFF),
    ),
    _OnboardingStep(
      title: 'Consent-Based Live Tracking',
      description:
          'Your verified emergency contacts receive your live GPS location and SMS alerts only when an emergency is active.',
      icon: Icons.share_location_rounded,
      gradient: [Color(0xFF0D4F3C), Color(0xFF116A51)],
      accent: Color(0xFF22C55E),
    ),
    _OnboardingStep(
      title: 'Ethical & Medical Notice',
      description:
          'SafeLife is a symptom-based triage and emergency coordination platform, not a diagnostic medical device. Always call 999 for immediate acute response.',
      icon: Icons.shield_rounded,
      gradient: [Color(0xFF7C0000), Color(0xFFB91C1C)],
      accent: Color(0xFFF87171),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
  }

  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingScreen.keyCompleted, true);
    widget.onComplete();
  }

  void _goToNextPage() {
    if (_currentPage == _steps.length - 1) {
      _finishOnboarding();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final size = MediaQuery.sizeOf(context);
    final isDesktop = size.width >= 900;
    final step = _steps[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: step.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isDesktop
              ? _buildDesktopLayout(l10n, step, size)
              : _buildMobileLayout(l10n, step, size),
        ),
      ),
    );
  }

  // ─── Desktop Layout ──────────────────────────────────────────────────────

  Widget _buildDesktopLayout(
      AppLocalizations? l10n, _OnboardingStep step, Size size) {
    return Row(
      children: [
        // Left — illustration / icon side (55%)
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -80,
                left: -80,
                child: _DecorativeCircle(size: 260, opacity: 0.12),
              ),
              Positioned(
                bottom: -60,
                right: -40,
                child: _DecorativeCircle(size: 200, opacity: 0.10),
              ),
              Positioned(
                top: size.height * 0.3,
                left: -30,
                child: _DecorativeCircle(size: 130, opacity: 0.08),
              ),

              // Content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(60.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App branding
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            l10n?.appName ?? 'SafeLife',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 64),

                      // Large animated icon
                      TweenAnimationBuilder<double>(
                        key: ValueKey(_currentPage),
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.elasticOut,
                        builder: (_, val, child) => Transform.scale(
                          scale: val,
                          child: child,
                        ),
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withAlpha(50),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(40),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            step.icon,
                            size: 90,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Step counter
                      Text(
                        'Step ${_currentPage + 1} of ${_steps.length}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(160),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / _steps.length,
                          backgroundColor: Colors.white.withAlpha(30),
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Right — text + action side (45%)
        Expanded(
          flex: 45,
          child: Container(
            color: Colors.white.withAlpha(12),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Padding(
                  padding: const EdgeInsets.all(52.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skip
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: _finishOnboarding,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withAlpha(180),
                          ),
                          child: const Text('Skip'),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Step content (PageView for desktop carousel)
                      SizedBox(
                        height: 220,
                        child: PageView.builder(
                          controller: _pageController,
                          physics: const BouncingScrollPhysics(),
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemCount: _steps.length,
                          itemBuilder: (context, index) {
                            final s = _steps[index];
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  s.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  s.description,
                                  style: TextStyle(
                                    color: Colors.white.withAlpha(210),
                                    fontSize: 16,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 52),

                      // Page dots
                      Row(
                        children: List.generate(
                          _steps.length,
                          (i) => _PageDot(
                            active: i == _currentPage,
                            color: step.accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Action buttons
                      Row(
                        children: [
                          if (_currentPage > 0) ...[
                            _GhostButton(
                              label: 'Previous',
                              onTap: () => _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: _OnboardingPrimaryButton(
                              label: _currentPage == _steps.length - 1
                                  ? (l10n?.acceptAndContinue ??
                                      'I Understand & Accept')
                                  : (_currentPage == 0
                                      ? (l10n?.getStarted ?? 'Get Started')
                                      : (l10n?.getStarted ?? 'Continue')),
                              accent: step.accent,
                              onTap: _goToNextPage,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Mobile Layout ───────────────────────────────────────────────────────

  Widget _buildMobileLayout(
      AppLocalizations? l10n, _OnboardingStep step, Size size) {
    return Column(
      children: [
        // Skip button
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: _finishOnboarding,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white.withAlpha(180),
            ),
            child: const Text('Skip'),
          ),
        ),

        // PageView
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _steps.length,
            itemBuilder: (context, index) {
              final s = _steps[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon
                    TweenAnimationBuilder<double>(
                      key: ValueKey(index),
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.elasticOut,
                      builder: (_, val, child) =>
                          Transform.scale(scale: val, child: child),
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(20),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(40),
                            width: 2,
                          ),
                        ),
                        child: Icon(s.icon, size: 64, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 36),
                    Text(
                      s.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withAlpha(210),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bottom controls
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
          child: Column(
            children: [
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _steps.length,
                  (i) => _PageDot(
                    active: i == _currentPage,
                    color: step.accent,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Button
              _OnboardingPrimaryButton(
                label: _currentPage == _steps.length - 1
                    ? (l10n?.acceptAndContinue ?? 'I Understand & Accept')
                    : (_currentPage == 0
                        ? (l10n?.getStarted ?? 'Get Started')
                        : (l10n?.getStarted ?? 'Continue')),
                accent: step.accent,
                onTap: _goToNextPage,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Decorative Circle ────────────────────────────────────────────────────────

class _DecorativeCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorativeCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha((opacity * 255).round()),
      ),
    );
  }
}

// ─── Page Dot ─────────────────────────────────────────────────────────────────

class _PageDot extends StatelessWidget {
  final bool active;
  final Color color;

  const _PageDot({required this.active, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(right: 8),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? Colors.white : Colors.white.withAlpha(70),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// ─── Primary Button ───────────────────────────────────────────────────────────

class _OnboardingPrimaryButton extends StatefulWidget {
  final String label;
  final Color accent;
  final VoidCallback onTap;
  final bool fullWidth;

  const _OnboardingPrimaryButton({
    required this.label,
    required this.accent,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  State<_OnboardingPrimaryButton> createState() =>
      _OnboardingPrimaryButtonState();
}

class _OnboardingPrimaryButtonState extends State<_OnboardingPrimaryButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: _hovered ? Colors.white : Colors.white.withAlpha(235),
            foregroundColor: widget.accent,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: _hovered ? 6 : 2,
          ),
          onPressed: widget.onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 18, color: widget.accent),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Ghost Button ─────────────────────────────────────────────────────────────

class _GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GhostButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withAlpha(50)),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────────

class _OnboardingStep {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;

  const _OnboardingStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.accent,
  });
}
