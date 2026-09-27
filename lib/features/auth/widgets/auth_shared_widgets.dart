import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

// ─── Desktop Split-Screen Auth Layout ────────────────────────────────────────
// Left decorative panel (45%) + Right form panel (55%).

class AuthDesktopLayout extends StatelessWidget {
  final Widget leftPanel;
  final Widget rightPanel;

  const AuthDesktopLayout({
    super.key,
    required this.leftPanel,
    required this.rightPanel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 45,
          child: leftPanel,
        ),
        Expanded(
          flex: 55,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40.0,
                    vertical: 40.0,
                  ),
                  child: rightPanel,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Left Branding Panel ──────────────────────────────────────────────────────
// Deep gradient panel with feature bullet list — shared by all auth screens.

class AuthLeftPanel extends StatelessWidget {
  final AppLocalizations? l10n;

  const AuthLeftPanel({super.key, this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1A1060),
            theme.colorScheme.primary,
            const Color(0xFFB91C6E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -60,
            right: -60,
            child: _Circle(size: 220, opacity: 0.07),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: _Circle(size: 280, opacity: 0.05),
          ),
          Positioned(
            bottom: 120,
            right: -30,
            child: _Circle(size: 150, opacity: 0.04),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(48.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(60),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    size: 44,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n?.appName ?? 'SafeLife',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  l10n?.appTagline ??
                      'Unified Smart Emergency\nResponse Platform',
                  style: TextStyle(
                    color: Colors.white.withAlpha(200),
                    fontSize: 17,
                    height: 1.5,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 56),

                const AuthFeatureBullet(
                  icon: Icons.sos_rounded,
                  text: 'One-tap SOS with live GPS dispatch',
                ),
                const SizedBox(height: 20),
                const AuthFeatureBullet(
                  icon: Icons.local_hospital_rounded,
                  text: 'Instant ambulance & hospital finder',
                ),
                const SizedBox(height: 20),
                const AuthFeatureBullet(
                  icon: Icons.monitor_heart_rounded,
                  text: 'Heart attack & stroke symptom triage',
                ),
                const SizedBox(height: 20),
                const AuthFeatureBullet(
                  icon: Icons.share_location_rounded,
                  text: 'Consent-based live location sharing',
                ),

                const SizedBox(height: 56),

                // Trust badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withAlpha(40)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.white.withAlpha(230),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bangladesh Emergency Response Network',
                        style: TextStyle(
                          color: Colors.white.withAlpha(210),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Feature Bullet Row ───────────────────────────────────────────────────────

class AuthFeatureBullet extends StatelessWidget {
  final IconData icon;
  final String text;

  const AuthFeatureBullet({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withAlpha(220),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Decorative Circle ────────────────────────────────────────────────────────

class _Circle extends StatelessWidget {
  final double size;
  final double opacity;

  const _Circle({required this.size, required this.opacity});

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
