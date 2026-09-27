import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safelife/app/routes.dart';
import 'package:safelife/app/theme/risk_level_theme.dart';
import 'package:safelife/core/constants/alert_constants.dart';
import 'package:safelife/core/constants/emergency_numbers.dart';
import 'package:safelife/features/auth/providers/auth_provider.dart';
import 'package:safelife/features/profile/models/emergency_contact.dart';
import 'package:safelife/features/profile/providers/contacts_provider.dart';
import 'package:safelife/features/sos/providers/sos_provider.dart';
import 'package:safelife/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLocale;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;

  const DashboardScreen({
    super.key,
    required this.onToggleTheme,
    required this.onToggleLocale,
    required this.currentLocale,
    required this.currentThemeMode,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _servicesKey = GlobalKey();
  final GlobalKey _helplinesKey = GlobalKey();
  final GlobalKey _prepKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 550),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final auth = context.watch<SafeLifeAuthProvider>();
    final contacts = context.watch<ContactsProvider>();
    final sos = context.watch<SosProvider>();
    final copy = _DashboardCopy(widget.currentLocale.languageCode == 'bn');
    final riskTheme = theme.extension<RiskLevelTheme>() ?? RiskLevelTheme.light;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 960;
        final isTablet = screenWidth >= 600 && screenWidth < 960;
        final contentHorizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

        return Scaffold(
          appBar: isDesktop
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(74),
                  child: _WebTopNavBar(
                    auth: auth,
                    currentLocale: widget.currentLocale,
                    currentThemeMode: widget.currentThemeMode,
                    onToggleLocale: widget.onToggleLocale,
                    onToggleTheme: widget.onToggleTheme,
                    copy: copy,
                    l10n: l10n,
                    onScrollToServices: () => _scrollToKey(_servicesKey),
                    onScrollToHelplines: () => _scrollToKey(_helplinesKey),
                    onScrollToPrep: () => _scrollToKey(_prepKey),
                    onSosPressed: () => _handleSos(context, sos),
                  ),
                )
              : AppBar(
                  title: Text(
                    l10n?.appName ?? 'SafeLife',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  actions: [
                    if (!auth.isAuthenticated)
                      TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
                        child: Text(
                          l10n?.signIn ?? 'Sign In',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Language / ভাষা',
                      onPressed: widget.onToggleLocale,
                      icon: Text(
                        widget.currentLocale.languageCode == 'bn' ? 'EN' : 'বাং',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),

                  ],
                ),
          drawer: isDesktop
              ? null
              : _NavigationDrawer(
                  auth: auth,
                  contacts: contacts,
                  currentLocale: widget.currentLocale,
                  currentThemeMode: widget.currentThemeMode,
                  onToggleLocale: widget.onToggleLocale,
                  onToggleTheme: widget.onToggleTheme,
                  copy: copy,
                ),
          body: SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              key: const PageStorageKey('dashboard-scroll'),
              padding: EdgeInsets.fromLTRB(
                contentHorizontalPadding,
                isDesktop ? 28 : 16,
                contentHorizontalPadding,
                48,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1320),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (sos.hasActiveEmergency) ...[
                        _ActiveEmergencyBanner(
                          copy: copy,
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.sosActive),
                        ),
                        const SizedBox(height: 24),
                      ],
                      _WebHeroSection(
                        copy: copy,
                        hasActiveEmergency: sos.hasActiveEmergency,
                        sosLabel: l10n?.sos ?? 'SOS',
                        isDesktop: isDesktop,
                        verifiedContacts: contacts.verifiedContacts.length,
                        bloodGroup: auth.userProfile?.bloodGroup,
                        onSos: () => _handleSos(context, sos),
                        onAmbulance: () => Navigator.of(context).pushNamed(AppRoutes.ambulance),
                        onProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                        onContacts: () => Navigator.of(context).pushNamed(AppRoutes.contacts),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        key: _helplinesKey,
                        child: _WebHelplineStrip(copy: copy),
                      ),
                      SizedBox(height: isDesktop ? 56 : 38),
                      Container(
                        key: _servicesKey,
                        child: Column(
                          children: [
                            _SectionHeading(
                              eyebrow: copy.sectionEyebrow,
                              title: copy.sectionTitle,
                              subtitle: copy.sectionSubtitle,
                            ),
                            const SizedBox(height: 24),
                            _ServicesGrid(
                              services: _services(
                                context,
                                l10n,
                                riskTheme,
                                sos,
                                copy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isDesktop ? 56 : 38),
                      Container(
                        key: _prepKey,
                        child: _PreparednessPanel(
                          copy: copy,
                          bloodGroup: auth.userProfile?.bloodGroup,
                          verifiedContacts: contacts.verifiedContacts.length,
                          isDesktop: isDesktop,
                          onProfile: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                          onContacts: () => Navigator.of(context).pushNamed(AppRoutes.contacts),
                          onSos: () => _handleSos(context, sos),
                        ),
                      ),
                      SizedBox(height: isDesktop ? 48 : 32),
                      _ProjectInfoMarquee(
                        copy: copy,
                        isDesktop: isDesktop,
                      ),
                      SizedBox(height: isDesktop ? 44 : 28),
                      _TrustStats(copy: copy),
                      const SizedBox(height: 28),
                      _Disclaimer(text: l10n?.disclaimer),
                      SizedBox(height: isDesktop ? 56 : 36),
                      _WebFooter(
                        copy: copy,
                        l10n: l10n,
                        isDesktop: isDesktop,
                        auth: auth,
                        onToggleLocale: widget.onToggleLocale,
                        onToggleTheme: widget.onToggleTheme,
                        currentThemeMode: widget.currentThemeMode,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  List<_ServiceData> _services(
    BuildContext context,
    AppLocalizations? l10n,
    RiskLevelTheme riskTheme,
    SosProvider sos,
    _DashboardCopy copy,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final auth = context.read<SafeLifeAuthProvider>();
    return [
      _ServiceData(
        title: l10n?.womenSafety ?? 'Women Safety',
        subtitle: copy.womenSafetyDescription,
        icon: Icons.security_rounded,
        color: scheme.primary,
        onTap: () => _handleSos(context, sos),
      ),
      _ServiceData(
        title: l10n?.cardiacEmergency ?? 'Heart Attack / Cardiac',
        subtitle: copy.cardiacDescription,
        icon: Icons.favorite_rounded,
        color: riskTheme.getColor(RiskLevel.high),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.heartTriage),
      ),
      _ServiceData(
        title: l10n?.strokeEmergency ?? 'Stroke (FAST)',
        subtitle: copy.strokeDescription,
        icon: Icons.medical_services_rounded,
        color: riskTheme.getColor(RiskLevel.critical),
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.strokeTriage),
      ),
      _ServiceData(
        title: l10n?.ambulanceRequestTitle ?? 'Request Ambulance',
        subtitle: copy.ambulanceDescription,
        icon: Icons.airport_shuttle_rounded,
        color: scheme.error,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.ambulance),
      ),
      _ServiceData(
        title: l10n?.hospitalDirectoryTitle ?? 'Emergency Hospitals',
        subtitle: copy.hospitalDescription,
        icon: Icons.local_hospital_rounded,
        color: scheme.secondary,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.hospitals),
      ),
      _ServiceData(
        title: l10n?.safetyTimerTitle ?? 'Safety Timer',
        subtitle: copy.timerDescription,
        icon: Icons.timer_rounded,
        color: Colors.amber.shade800,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.safetyTimer),
      ),
      _ServiceData(
        title: l10n?.incidentReportTitle ?? 'Report Safety Incident',
        subtitle: copy.reportDescription,
        icon: Icons.report_problem_outlined,
        color: Colors.deepOrange.shade700,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.incidentReport),
      ),
      _ServiceData(
        title: l10n?.emergencyHistoryTitle ?? 'Emergency History',
        subtitle: copy.historyDescription,
        icon: Icons.history_rounded,
        color: Colors.blueGrey.shade700,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.history),
      ),
      if (auth.canAccessResponder)
        _ServiceData(
          title: l10n?.responderPanelTitle ?? 'Responder Panel',
          subtitle: copy.responderDescription,
          icon: Icons.dashboard_customize_outlined,
          color: Colors.teal.shade700,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.responder),
        ),
      if (auth.canAccessAdmin)
        _ServiceData(
          title: l10n?.adminPortalTitle ?? 'Admin Analytics',
          subtitle: copy.adminDescription,
          icon: Icons.analytics_outlined,
          color: Colors.indigo.shade700,
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.admin),
        ),
    ];
  }

  void _handleSos(BuildContext context, SosProvider sos) {
    if (!context.read<SafeLifeAuthProvider>().isAuthenticated) {
      Navigator.of(context).pushNamed(AppRoutes.login);
      return;
    }
    if (sos.hasActiveEmergency) {
      Navigator.of(context).pushNamed(AppRoutes.sosActive);
      return;
    }
    _showSosCountdownDialog(context);
  }

  void _showSosCountdownDialog(BuildContext context) {
    final auth = context.read<SafeLifeAuthProvider>();
    final contacts = context.read<ContactsProvider>().verifiedContacts;
    final sos = context.read<SosProvider>();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _CountdownDialog(
        userId: auth.user?.uid ?? '',
        userName:
            auth.userProfile?.name ?? auth.user?.displayName ?? 'SafeLife User',
        userPhone: auth.userProfile?.phone ?? auth.user?.phoneNumber ?? '',
        contacts: contacts,
        language: widget.currentLocale.languageCode,
        sosProvider: sos,
        onDispatched: () {
          Navigator.of(dialogContext).pop();
          Navigator.of(context).pushNamed(AppRoutes.sosActive);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE WEB HOVER CARD WIDGET
// ─────────────────────────────────────────────────────────────────────────────

class _HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double hoverTranslateY;
  final Color? hoverBorderColor;
  final BorderRadius? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  const _HoverCard({
    required this.child,
    this.onTap,
    this.hoverTranslateY = -4.0,
    this.hoverBorderColor,
    this.borderRadius,
    this.color,
    this.padding,
  });

  @override
  State<_HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<_HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = widget.borderRadius ?? BorderRadius.circular(16);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? widget.hoverTranslateY : 0, 0),
        decoration: BoxDecoration(
          color: widget.color ?? theme.colorScheme.surface,
          borderRadius: radius,
          border: Border.all(
            color: _isHovered
                ? (widget.hoverBorderColor ?? theme.colorScheme.primary.withAlpha(160))
                : theme.colorScheme.outlineVariant.withAlpha(70),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: (widget.hoverBorderColor ?? theme.colorScheme.primary).withAlpha(isDark ? 50 : 25),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 25 : 8),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          child: InkWell(
            borderRadius: radius,
            onTap: widget.onTap,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOP WEB NAVIGATION BAR (Desktop width >= 960px)
// ─────────────────────────────────────────────────────────────────────────────

class _WebTopNavBar extends StatelessWidget {
  final SafeLifeAuthProvider auth;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final VoidCallback onToggleLocale;
  final VoidCallback onToggleTheme;
  final _DashboardCopy copy;
  final AppLocalizations? l10n;
  final VoidCallback onScrollToServices;
  final VoidCallback onScrollToHelplines;
  final VoidCallback onScrollToPrep;
  final VoidCallback onSosPressed;

  const _WebTopNavBar({
    required this.auth,
    required this.currentLocale,
    required this.currentThemeMode,
    required this.onToggleLocale,
    required this.onToggleTheme,
    required this.copy,
    required this.l10n,
    required this.onScrollToServices,
    required this.onScrollToHelplines,
    required this.onScrollToPrep,
    required this.onSosPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722).withAlpha(245) : Colors.white.withAlpha(245),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(70),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? 30 : 10),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1360),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            child: Row(
              children: [
                // Brand logo & name
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFDC2626).withAlpha(70),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.health_and_safety_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n?.appName ?? 'SafeLife',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.4,
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  copy.systemReady,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 28),

                // Navigation links
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _WebNavLink(
                          label: copy.navServices,
                          onTap: onScrollToServices,
                        ),
                        const SizedBox(width: 6),
                        _WebNavLink(
                          label: copy.navHelplines,
                          onTap: onScrollToHelplines,
                        ),
                        const SizedBox(width: 6),
                        _WebNavLink(
                          label: copy.navPrep,
                          onTap: onScrollToPrep,
                        ),
                        const SizedBox(width: 6),
                        _WebNavLink(
                          label: l10n?.hospitalDirectoryTitle ?? 'Hospitals',
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.hospitals),
                        ),
                        const SizedBox(width: 6),
                        _WebNavLink(
                          label: l10n?.ambulanceRequestTitle ?? 'Ambulance',
                          onTap: () => Navigator.of(context).pushNamed(AppRoutes.ambulance),
                        ),
                      ],
                    ),
                  ),
                ),

                // Utility actions
                _WebIconButton(
                  tooltip: 'Language / ভাষা',
                  onTap: onToggleLocale,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        currentLocale.languageCode == 'bn' ? 'English' : 'বাংলা',
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Account state
                if (auth.isAuthenticated) ...[
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                (auth.userProfile?.name.isNotEmpty == true
                                        ? auth.userProfile!.name[0]
                                        : (auth.user?.email?[0] ?? 'U'))
                                    .toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 110),
                              child: Text(
                                auth.userProfile?.name.isNotEmpty == true
                                    ? auth.userProfile!.name
                                    : (auth.user?.email ?? 'User'),
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: l10n?.signOut ?? 'Sign Out',
                    icon: Icon(Icons.logout_rounded, size: 19, color: theme.colorScheme.error),
                    onPressed: () => _confirmSignOut(context, auth, copy, l10n),
                  ),
                ] else ...[
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.login),
                    child: Text(
                      l10n?.signIn ?? 'Sign In',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(AppRoutes.register),
                    child: Text(
                      l10n?.signUp ?? 'Create Account',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],

                const SizedBox(width: 14),

                // Rapid SOS CTA button
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFFDC2626).withAlpha(120),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onSosPressed,
                    icon: const Icon(Icons.emergency_rounded, size: 20),
                    label: Text(
                      copy.navSos,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmSignOut(
    BuildContext context,
    SafeLifeAuthProvider auth,
    _DashboardCopy copy,
    AppLocalizations? l10n,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.logoutConfirmTitle ?? copy.signOut),
        content: Text(l10n?.logoutConfirmMessage ?? copy.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n?.cancel ?? copy.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              auth.signOut();
            },
            child: Text(l10n?.signOut ?? copy.signOut),
          ),
        ],
      ),
    );
  }
}

class _WebNavLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _WebNavLink({required this.label, required this.onTap});

  @override
  State<_WebNavLink> createState() => _WebNavLinkState();
}

class _WebNavLinkState extends State<_WebNavLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: _hovered ? FontWeight.w800 : FontWeight.w600,
              color: _hovered ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _WebIconButton extends StatefulWidget {
  final Widget child;
  final String tooltip;
  final VoidCallback onTap;

  const _WebIconButton({
    required this.child,
    required this.tooltip,
    required this.onTap,
  });

  @override
  State<_WebIconButton> createState() => _WebIconButtonState();
}

class _WebIconButtonState extends State<_WebIconButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _hovered
                  ? theme.colorScheme.surfaceContainerHighest.withAlpha(140)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESPONSIVE WEB HERO / LANDING SECTION
// ─────────────────────────────────────────────────────────────────────────────

class _WebHeroSection extends StatelessWidget {
  final _DashboardCopy copy;
  final bool hasActiveEmergency;
  final String sosLabel;
  final bool isDesktop;
  final int verifiedContacts;
  final String? bloodGroup;
  final VoidCallback onSos;
  final VoidCallback onAmbulance;
  final VoidCallback onProfile;
  final VoidCallback onContacts;

  const _WebHeroSection({
    required this.copy,
    required this.hasActiveEmergency,
    required this.sosLabel,
    required this.isDesktop,
    required this.verifiedContacts,
    required this.bloodGroup,
    required this.onSos,
    required this.onAmbulance,
    required this.onProfile,
    required this.onContacts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final leftContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Live Network Status Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(24),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withAlpha(55)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  copy.heroBadge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Web Headline
        Text(
          copy.heroTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            color: Colors.white,
            fontSize: isDesktop ? 46 : 30,
            height: 1.12,
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
          ),
        ),
        const SizedBox(height: 16),

        // Subtitle
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Text(
            copy.heroDescription,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.white.withAlpha(230),
              fontSize: isDesktop ? 16 : 14,
              height: 1.6,
            ),
          ),
        ),
        const SizedBox(height: 28),

        // CTAs Cluster
        Wrap(
          spacing: 14,
          runSpacing: 12,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  shadowColor: const Color(0xFFDC2626).withAlpha(160),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 26 : 20,
                    vertical: isDesktop ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onSos,
                icon: const Icon(Icons.emergency_rounded, size: 22),
                label: Text(
                  hasActiveEmergency ? copy.viewActiveEmergency : sosLabel,
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white70, width: 1.5),
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 22 : 18,
                    vertical: isDesktop ? 18 : 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onAmbulance,
                icon: const Icon(Icons.airport_shuttle_rounded, size: 22),
                label: Text(
                  copy.requestAmbulance,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 26),

        // Trust reassurance badges
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _HeroFeatureChip(icon: Icons.flash_on_rounded, text: copy.instantDispatch),
            _HeroFeatureChip(icon: Icons.lock_outline_rounded, text: copy.encryptedLocation),
            _HeroFeatureChip(icon: Icons.timer_outlined, text: copy.zeroDelay),
          ],
        ),
      ],
    );

    final rightConsole = Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(45)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 26,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      copy.emergencyReadinessTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      copy.securePrivateReady,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Medical ID card inside hero
          _ConsoleQuickTile(
            icon: Icons.medical_information_rounded,
            title: copy.medicalId,
            subtitle: bloodGroup ?? copy.addBloodGroup,
            onTap: onProfile,
          ),
          const SizedBox(height: 12),

          // Trusted Contacts card inside hero
          _ConsoleQuickTile(
            icon: Icons.people_alt_rounded,
            title: copy.trustedContacts,
            subtitle: copy.verifiedCount(verifiedContacts),
            onTap: onContacts,
          ),
          const SizedBox(height: 18),

          // Bottom quick action prompt
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: Color(0xFFFBBF24), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    copy.rapidTriggerNote,
                    style: TextStyle(
                      color: Colors.white.withAlpha(220),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.all(isDesktop ? 44 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E112A),
            Color(0xFF380811),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withAlpha(35)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(flex: 6, child: leftContent),
                const SizedBox(width: 40),
                Expanded(flex: 5, child: rightConsole),
              ],
            )
          : Column(
              children: [
                leftContent,
                const SizedBox(height: 28),
                rightConsole,
              ],
            ),
    );
  }
}

class _HeroFeatureChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _HeroFeatureChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFFF87171), size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withAlpha(235),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _ConsoleQuickTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ConsoleQuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  State<_ConsoleQuickTile> createState() => _ConsoleQuickTileState();
}

class _ConsoleQuickTileState extends State<_ConsoleQuickTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white.withAlpha(45) : Colors.white.withAlpha(25),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered ? Colors.white.withAlpha(120) : Colors.white.withAlpha(40),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(widget.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withAlpha(200),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white.withAlpha(_hovered ? 255 : 160),
                size: 14,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TOLL-FREE DIRECT HELPLINE STRIP (Responsive 3-column / 2 / 1)
// ─────────────────────────────────────────────────────────────────────────────

class _WebHelplineStrip extends StatelessWidget {
  final _DashboardCopy copy;

  const _WebHelplineStrip({required this.copy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = [
      _HelplineData(
        copy.nationalEmergency,
        EmergencyNumbers.nationalEmergency,
        Icons.phone_in_talk_rounded,
        theme.colorScheme.error,
        copy.nationalEmergencyDesc,
      ),
      _HelplineData(
        copy.womenAndChildren,
        EmergencyNumbers.womenAndChildrenHelpline,
        Icons.support_agent_rounded,
        theme.colorScheme.primary,
        copy.womenAndChildrenDesc,
      ),
      _HelplineData(
        copy.nationalHelpDesk,
        EmergencyNumbers.nationalHelpDesk,
        Icons.info_outline_rounded,
        theme.colorScheme.secondary,
        copy.nationalHelpDeskDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.dialer_sip_rounded, size: 20, color: Color(0xFFDC2626)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                copy.quickHelplines,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 900
                ? 3
                : constraints.maxWidth >= 560
                    ? 2
                    : 1;
            const gap = 16.0;
            final itemWidth = (constraints.maxWidth - (columns - 1) * gap) / columns;

            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: actions
                  .map(
                    (action) => SizedBox(
                      width: itemWidth,
                      child: _HoverHelplineCard(data: action, copy: copy),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class _HelplineData {
  final String title;
  final String number;
  final IconData icon;
  final Color color;
  final String description;

  const _HelplineData(this.title, this.number, this.icon, this.color, this.description);
}

class _HoverHelplineCard extends StatelessWidget {
  final _HelplineData data;
  final _DashboardCopy copy;

  const _HoverHelplineCard({required this.data, required this.copy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _HoverCard(
      hoverTranslateY: -4,
      hoverBorderColor: data.color,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.all(18),
      onTap: () async {
        var launched = false;
        try {
          launched = await EmergencyNumbers.makeEmergencyCall(data.number);
        } catch (_) {
          launched = false;
        }
        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(copy.callFailed(data.number))),
          );
        }
      },
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: data.color.withAlpha(25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(data.icon, color: data.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: data.color.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        copy.tollFree,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: data.color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${copy.call} ${data.number}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.call_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION HEADING
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withAlpha(20),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            eyebrow,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 28,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.55,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICES GRID (Responsive 3 / 2 / 1 with Interactive Hover Lift)
// ─────────────────────────────────────────────────────────────────────────────

class _ServiceData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ServiceData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class _ServicesGrid extends StatelessWidget {
  final List<_ServiceData> services;

  const _ServicesGrid({required this.services});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1080
            ? 3
            : constraints.maxWidth >= 640
                ? 2
                : 1;
        const gap = 18.0;
        final itemWidth = (constraints.maxWidth - (columns - 1) * gap) / columns;

        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: services
              .map(
                (service) => SizedBox(
                  width: itemWidth,
                  child: _HoverServiceCard(data: service),
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _HoverServiceCard extends StatefulWidget {
  final _ServiceData data;

  const _HoverServiceCard({required this.data});

  @override
  State<_HoverServiceCard> createState() => _HoverServiceCardState();
}

class _HoverServiceCardState extends State<_HoverServiceCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -5 : 0, 0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered
                ? widget.data.color.withAlpha(160)
                : theme.colorScheme.outlineVariant.withAlpha(70),
            width: _isHovered ? 1.6 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: widget.data.color.withAlpha(isDark ? 50 : 25),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 25 : 8),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.data.onTap,
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.data.color.withAlpha(_isHovered ? 40 : 22),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.data.icon,
                      color: widget.data.color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.data.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.data.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(_isHovered ? 3 : 0, 0, 0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: _isHovered ? widget.data.color : theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREPAREDNESS PANEL (Desktop 2-column, Mobile 1-column)
// ─────────────────────────────────────────────────────────────────────────────

class _PreparednessPanel extends StatelessWidget {
  final _DashboardCopy copy;
  final String? bloodGroup;
  final int verifiedContacts;
  final bool isDesktop;
  final VoidCallback onProfile;
  final VoidCallback onContacts;
  final VoidCallback onSos;

  const _PreparednessPanel({
    required this.copy,
    required this.bloodGroup,
    required this.verifiedContacts,
    required this.isDesktop,
    required this.onProfile,
    required this.onContacts,
    required this.onSos,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final profileLinks = LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 440;
        final children = [
          _ProfileLink(
            icon: Icons.medical_information_outlined,
            title: copy.medicalId,
            value: bloodGroup ?? copy.addBloodGroup,
            onTap: onProfile,
          ),
          _ProfileLink(
            icon: Icons.contacts_outlined,
            title: copy.trustedContacts,
            value: copy.verifiedCount(verifiedContacts),
            onTap: onContacts,
          ),
        ];

        if (stack) {
          return Column(
            children: [children[0], const SizedBox(height: 12), children[1]],
          );
        }
        return Row(
          children: [
            Expanded(child: children[0]),
            const SizedBox(width: 14),
            Expanded(child: children[1]),
          ],
        );
      },
    );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withAlpha(20),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            copy.prepareEyebrow,
            style: TextStyle(
              color: theme.colorScheme.error,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          copy.prepareTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: isDesktop ? 26 : 22,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          copy.prepareDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.6,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 22),
        profileLinks,
      ],
    );

    final sosConsole = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withAlpha(14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.colorScheme.error.withAlpha(45)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Material(
              color: theme.colorScheme.error,
              elevation: 8,
              shadowColor: theme.colorScheme.error.withAlpha(160),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onSos,
                child: SizedBox(
                  width: 156,
                  height: 156,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.crisis_alert_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                        const SizedBox(height: 6),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            copy.sosNow,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: copy.isBangla ? 18 : 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: copy.isBangla ? 0.0 : 1.5,
                              height: 1.15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            copy.tapForEmergency,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );

    return Container(
      padding: EdgeInsets.all(isDesktop ? 36 : 24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(90),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(theme.brightness == Brightness.dark ? 30 : 10),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: isDesktop
          ? Row(
              children: [
                Expanded(flex: 6, child: content),
                const SizedBox(width: 36),
                Expanded(flex: 4, child: sosConsole),
              ],
            )
          : Column(
              children: [
                content,
                const SizedBox(height: 26),
                sosConsole,
              ],
            ),
    );
  }
}

class _ProfileLink extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ProfileLink({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _HoverCard(
      hoverTranslateY: -3,
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.edit_outlined, size: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// AUTO-MOVING PROJECT INFORMATION MARQUEE (ONE SIDE TO ANOTHER)
// ─────────────────────────────────────────────────────────────────────────────

class _ProjectInfoMarquee extends StatefulWidget {
  final _DashboardCopy copy;
  final bool isDesktop;

  const _ProjectInfoMarquee({
    required this.copy,
    required this.isDesktop,
  });

  @override
  State<_ProjectInfoMarquee> createState() => _ProjectInfoMarqueeState();
}

class _ProjectInfoMarqueeState extends State<_ProjectInfoMarquee> {
  final ScrollController _scrollController = ScrollController();
  Timer? _timer;
  bool _isHovered = false;
  static const double _step = 1.0;
  static const Duration _interval = Duration(milliseconds: 32);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _timer?.cancel();
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || _isHovered || !_scrollController.hasClients) return;
      final max = _scrollController.position.maxScrollExtent;
      if (max <= 0) return;
      final current = _scrollController.offset;
      final next = current + _step;
      if (next >= max / 2) {
        _scrollController.jumpTo(next - (max / 2));
      } else {
        _scrollController.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final copy = widget.copy;

    final singleItems = [
      _ProjectInfoItem(
        tag: copy.infoMissionTag,
        title: copy.infoMissionTitle,
        description: copy.infoMissionDesc,
        icon: Icons.shield_rounded,
        color: const Color(0xFFE11D48),
      ),
      _ProjectInfoItem(
        tag: copy.infoSosTag,
        title: copy.infoSosTitle,
        description: copy.infoSosDesc,
        icon: Icons.crisis_alert_rounded,
        color: const Color(0xFFDC2626),
      ),
      _ProjectInfoItem(
        tag: copy.infoTriageTag,
        title: copy.infoTriageTitle,
        description: copy.infoTriageDesc,
        icon: Icons.favorite_rounded,
        color: const Color(0xFFEA580C),
      ),
      _ProjectInfoItem(
        tag: copy.infoTimerTag,
        title: copy.infoTimerTitle,
        description: copy.infoTimerDesc,
        icon: Icons.timer_outlined,
        color: const Color(0xFF4F46E5),
      ),
      _ProjectInfoItem(
        tag: copy.infoHelplineTag,
        title: copy.infoHelplineTitle,
        description: copy.infoHelplineDesc,
        icon: Icons.support_agent_rounded,
        color: const Color(0xFF9333EA),
      ),
      _ProjectInfoItem(
        tag: copy.infoMedicalIdTag,
        title: copy.infoMedicalIdTitle,
        description: copy.infoMedicalIdDesc,
        icon: Icons.medical_information_outlined,
        color: const Color(0xFF0D9488),
      ),
      _ProjectInfoItem(
        tag: copy.infoAmbulanceTag,
        title: copy.infoAmbulanceTitle,
        description: copy.infoAmbulanceDesc,
        icon: Icons.airport_shuttle_rounded,
        color: const Color(0xFF2563EB),
      ),
      _ProjectInfoItem(
        tag: copy.infoBilingualTag,
        title: copy.infoBilingualTitle,
        description: copy.infoBilingualDesc,
        icon: Icons.g_translate_rounded,
        color: const Color(0xFF059669),
      ),
    ];

    // Duplicate for seamless infinite horizontal auto-moving loop
    final marqueeItems = [...singleItems, ...singleItems];
    final cardWidth = widget.isDesktop ? 320.0 : 276.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      copy.projectInfoEyebrow,
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    copy.projectInfoTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      fontSize: widget.isDesktop ? 23 : 19,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withAlpha(80),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withAlpha(50),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _isHovered ? Colors.amber : const Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isHovered ? copy.pausedOnHover : copy.liveStream,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        // Auto-moving Marquee Row
        MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
                PointerDeviceKind.trackpad,
              },
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  for (int i = 0; i < marqueeItems.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    SizedBox(
                      width: cardWidth,
                      height: 146,
                      child: _ProjectInfoCard(item: marqueeItems[i]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProjectInfoItem {
  final String tag;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const _ProjectInfoItem({
    required this.tag,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class _ProjectInfoCard extends StatelessWidget {
  final _ProjectInfoItem item;

  const _ProjectInfoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.color.withAlpha(50),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: item.color.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: item.color.withAlpha(22),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(item.icon, color: item.color, size: 17),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.tag.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: item.color,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              item.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TRUST & IMPACT METRICS BAND
// ─────────────────────────────────────────────────────────────────────────────

class _TrustStats extends StatelessWidget {
  final _DashboardCopy copy;

  const _TrustStats({required this.copy});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('24/7', copy.emergencyAccess),
      ('3', copy.nationalHelplines),
      ('10+', copy.integratedServices),
      ('2', copy.supportedLanguages),
    ];
    final error = Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [error, const Color(0xFF7A0C13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: error.withAlpha(90),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 720 ? 4 : 2;
          final itemWidth = constraints.maxWidth / columns;

          return Wrap(
            runSpacing: 24,
            children: stats
                .map(
                  (stat) => SizedBox(
                    width: itemWidth,
                    child: Column(
                      children: [
                        Text(
                          stat.$1,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stat.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withAlpha(225),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MEDICAL & CLINICAL DISCLAIMER
// ─────────────────────────────────────────────────────────────────────────────

class _Disclaimer extends StatelessWidget {
  final String? text;

  const _Disclaimer({this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(60),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text ??
                  'SafeLife supports emergency assistance and symptom triage. It does not replace professional medical diagnosis, emergency medical personnel, or police dispatch.',
              style: theme.textTheme.bodySmall?.copyWith(height: 1.5, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPREHENSIVE RESPONSIVE WEBSITE FOOTER
// ─────────────────────────────────────────────────────────────────────────────

class _WebFooter extends StatelessWidget {
  final _DashboardCopy copy;
  final AppLocalizations? l10n;
  final bool isDesktop;
  final SafeLifeAuthProvider auth;
  final VoidCallback onToggleLocale;
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const _WebFooter({
    required this.copy,
    required this.l10n,
    required this.isDesktop,
    required this.auth,
    required this.onToggleLocale,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final brandCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'SafeLife Platform',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            copy.footerDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.55,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.error.withAlpha(20),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.call_rounded, size: 16, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  copy.footerEmergencyNote,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final servicesCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.footerColServices,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _FooterLink(
          label: copy.isBangla ? 'নারী সুরক্ষা নেটওয়ার্ক' : 'Women Protection & Care',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.sosActive),
        ),
        _FooterLink(
          label: copy.isBangla ? 'কার্ডিয়াক জরুরি সেবা' : 'Cardiac Emergency Care',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.heartTriage),
        ),
        _FooterLink(
          label: copy.isBangla ? 'স্ট্রোক কেয়ার ও পরামর্শ' : 'Stroke Emergency Care (FAST)',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.strokeTriage),
        ),
        _FooterLink(
          label: l10n?.ambulanceRequestTitle ?? 'Ambulance Request',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.ambulance),
        ),
        _FooterLink(
          label: l10n?.hospitalDirectoryTitle ?? 'Emergency Hospitals',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.hospitals),
        ),
      ],
    );

    final toolsCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.footerColTools,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _FooterLink(
          label: l10n?.safetyTimerTitle ?? 'Safety Timer',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.safetyTimer),
        ),
        _FooterLink(
          label: l10n?.incidentReportTitle ?? 'Report Safety Incident',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.incidentReport),
        ),
        _FooterLink(
          label: l10n?.medicalProfile ?? 'Medical ID Profile',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.profile),
        ),
        _FooterLink(
          label: l10n?.emergencyContacts ?? 'Trusted Contacts',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.contacts),
        ),
        _FooterLink(
          label: l10n?.emergencyHistoryTitle ?? 'Emergency History',
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.history),
        ),
      ],
    );

    final controlsCol = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          copy.footerColAccess,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
        ),
        const SizedBox(height: 12),
        _FooterLink(
          label: 'Language / ভাষা (${copy.isBangla ? 'English' : 'বাংলা'})',
          onTap: onToggleLocale,
        ),

        if (auth.canAccessResponder)
          _FooterLink(
            label: l10n?.responderPanelTitle ?? 'Responder Panel',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.responder),
          ),
        if (auth.canAccessAdmin)
          _FooterLink(
            label: l10n?.adminPortalTitle ?? 'Admin Analytics',
            onTap: () => Navigator.of(context).pushNamed(AppRoutes.admin),
          ),
      ],
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? 40 : 20,
        vertical: 36,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131722) : const Color(0xFFF1F3F5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withAlpha(70),
        ),
      ),
      child: Column(
        children: [
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 4, child: brandCol),
                    const SizedBox(width: 28),
                    Expanded(flex: 3, child: servicesCol),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: toolsCol),
                    const SizedBox(width: 20),
                    Expanded(flex: 3, child: controlsCol),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    brandCol,
                    const SizedBox(height: 28),
                    servicesCol,
                    const SizedBox(height: 24),
                    toolsCol,
                    const SizedBox(height: 24),
                    controlsCol,
                  ],
                ),
          const SizedBox(height: 36),
          Divider(color: theme.colorScheme.outlineVariant.withAlpha(70)),
          const SizedBox(height: 18),
          if (isDesktop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    copy.footerRights,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        copy.securePrivateReady,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.footerRights,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_rounded, size: 14),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        copy.securePrivateReady,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(6),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: _hovered ? FontWeight.w800 : FontWeight.w500,
              color: _hovered
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE EMERGENCY BANNER
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveEmergencyBanner extends StatelessWidget {
  final VoidCallback onTap;
  final _DashboardCopy copy;

  const _ActiveEmergencyBanner({required this.onTap, required this.copy});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _HoverCard(
      hoverTranslateY: -3,
      color: theme.colorScheme.error,
      borderRadius: BorderRadius.circular(18),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  copy.activeEmergency,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  copy.activeEmergencyDescription,
                  style: TextStyle(color: Colors.white.withAlpha(225), fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 16,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MOBILE NAVIGATION DRAWER
// ─────────────────────────────────────────────────────────────────────────────

class _NavigationDrawer extends StatelessWidget {
  final SafeLifeAuthProvider auth;
  final ContactsProvider contacts;
  final Locale currentLocale;
  final ThemeMode currentThemeMode;
  final VoidCallback onToggleLocale;
  final VoidCallback onToggleTheme;
  final _DashboardCopy copy;

  const _NavigationDrawer({
    required this.auth,
    required this.contacts,
    required this.currentLocale,
    required this.currentThemeMode,
    required this.onToggleLocale,
    required this.onToggleTheme,
    required this.copy,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final profile = auth.userProfile;

    void open(String route) {
      Navigator.of(context).pop();
      Navigator.of(context).pushNamed(route);
    }

    Widget item(IconData icon, String title, String route) {
      return ListTile(
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => open(route),
      );
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.error, const Color(0xFF861017)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.health_and_safety_rounded,
                          color: Color(0xFFC51620),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              copy.navigation,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                              ),
                            ),
                            Text(
                              profile?.name.isNotEmpty == true
                                  ? profile!.name
                                  : (auth.user?.email ?? 'SafeLife User'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${profile?.bloodGroup ?? copy.bloodGroupNotSet}  •  ${copy.verifiedContactCount(contacts.verifiedContacts.length)}',
                    style: TextStyle(color: Colors.white.withAlpha(225)),
                  ),
                ],
              ),
            ),
            item(
              Icons.badge_outlined,
              l10n?.medicalProfile ?? 'Medical Profile',
              AppRoutes.profile,
            ),
            item(
              Icons.people_alt_outlined,
              l10n?.emergencyContacts ?? 'Emergency Contacts',
              AppRoutes.contacts,
            ),
            item(
              Icons.report_problem_outlined,
              l10n?.incidentReportTitle ?? 'Report Safety Incident',
              AppRoutes.incidentReport,
            ),
            item(
              Icons.history_rounded,
              l10n?.emergencyHistoryTitle ?? 'Emergency History',
              AppRoutes.history,
            ),
            item(
              Icons.local_hospital_outlined,
              l10n?.hospitalDirectoryTitle ?? 'Emergency Hospitals',
              AppRoutes.hospitals,
            ),
            item(
              Icons.airport_shuttle_outlined,
              l10n?.ambulanceRequestTitle ?? 'Request Ambulance',
              AppRoutes.ambulance,
            ),
            item(
              Icons.timer_outlined,
              l10n?.safetyTimerTitle ?? 'Safety Timer',
              AppRoutes.safetyTimer,
            ),
            item(
              Icons.settings_outlined,
              l10n?.settingsTitle ?? 'Settings & Preferences',
              AppRoutes.settings,
            ),
            if (auth.canAccessResponder) ...[
              const Divider(height: 24),
              item(
                Icons.dashboard_customize_outlined,
                l10n?.responderPanelTitle ?? 'Responder Panel',
                AppRoutes.responder,
              ),
            ],
            if (auth.canAccessAdmin)
              item(
                Icons.analytics_outlined,
                l10n?.adminPortalTitle ?? 'Admin Analytics',
                AppRoutes.admin,
              ),
            if (auth.canAccessResponder) const Divider(height: 24),
            if (!auth.isAuthenticated) ...[
              item(
                Icons.login_rounded,
                l10n?.signIn ?? 'Sign In',
                AppRoutes.login,
              ),
              item(
                Icons.person_add_alt_1_rounded,
                l10n?.signUp ?? 'Create Account',
                AppRoutes.register,
              ),
              const Divider(height: 24),
            ],
            ListTile(
              leading: const Icon(Icons.language_rounded),
              title: const Text('Language / ভাষা'),
              trailing: Text(
                currentLocale.languageCode == 'bn' ? 'বাংলা' : 'English',
              ),
              onTap: onToggleLocale,
            ),

            if (auth.isAuthenticated) ...[
              const Divider(height: 24),
              ListTile(
                leading: Icon(
                  Icons.logout_rounded,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  l10n?.signOut ?? 'Sign Out',
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n?.logoutConfirmTitle ?? copy.signOut),
                      content: Text(
                        l10n?.logoutConfirmMessage ?? copy.signOutConfirmation,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: Text(l10n?.cancel ?? copy.cancel),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop();
                            auth.signOut();
                          },
                          child: Text(l10n?.signOut ?? copy.signOut),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DASHBOARD COPY (Bangla / English)
// ─────────────────────────────────────────────────────────────────────────────

class _DashboardCopy {
  final bool isBangla;

  const _DashboardCopy(this.isBangla);

  String _text(String english, String bangla) => isBangla ? bangla : english;

  String get navigation => _text('Navigation', 'নেভিগেশন');
  String get bloodGroupNotSet =>
      _text('Blood group not set', 'রক্তের গ্রুপ যোগ করা হয়নি');
  String verifiedContactCount(int count) =>
      _text('$count verified contacts', '$count জন যাচাইকৃত যোগাযোগ');
  String get appearance => _text('Appearance', 'থিম ও প্রদর্শন');
  String get dark => _text('Dark', 'ডার্ক');
  String get light => _text('Light', 'লাইট');
  String get signOut => _text('Sign Out', 'সাইন আউট');
  String get signOutConfirmation => _text(
    'Are you sure you want to sign out?',
    'আপনি কি নিশ্চিতভাবে সাইন আউট করতে চান?',
  );
  String get cancel => _text('Cancel', 'বাতিল');

  String get heroBadge =>
      _text('24/7 EMERGENCY RESPONSE', '২৪/৭ জরুরি সহায়তা নেটওয়ার্ক');
  String get heroTitle => _text(
    'Fast help when\nevery second matters.',
    'প্রতিটি মুহূর্তে\nদ্রুত ও নির্ভরযোগ্য সহায়তা।',
  );
  String get heroDescription => _text(
    'Women’s safety, clinical triage, ambulance dispatch, and trusted contacts in one calm, reliable experience.',
    'নারীর নিরাপত্তা, জরুরি স্বাস্থ্য যাচাই, অ্যাম্বুলেন্স ও বিশ্বস্ত যোগাযোগ—সব এক নির্ভরযোগ্য অভিজ্ঞতায়।',
  );
  String get viewActiveEmergency =>
      _text('View active emergency', 'সক্রিয় জরুরি অবস্থা দেখুন');
  String get requestAmbulance =>
      _text('Request ambulance', 'অ্যাম্বুলেন্স অনুরোধ করুন');
  String get securePrivateReady =>
      _text('Secure • Private • Ready', 'নিরাপদ • গোপনীয় • প্রস্তুত');

  String get sectionEyebrow =>
      _text('CARE THAT MOVES WITH YOU', 'আপনার সঙ্গে থাকা জরুরি সেবা');
  String get sectionTitle => _text(
    'Emergency services, all in one place',
    'সব জরুরি সেবা একই জায়গায়',
  );
  String get sectionSubtitle => _text(
    'Immediate safety support, medical triage, dispatch, and follow-up tools designed for every screen.',
    'তাৎক্ষণিক নিরাপত্তা সহায়তা, স্বাস্থ্য যাচাই, প্রেরণ ও পরবর্তী সেবা—সব পর্দার জন্য তৈরি।',
  );

  String get womenSafetyDescription => _text(
    'Discreet SOS, trusted contacts, and live location support',
    'গোপন এসওএস, বিশ্বস্ত যোগাযোগ ও লাইভ অবস্থান সহায়তা',
  );
  String get cardiacDescription => _text(
    'Guided symptom check and risk-based emergency action',
    'নির্দেশিত উপসর্গ যাচাই ও ঝুঁকিভিত্তিক জরুরি পদক্ষেপ',
  );
  String get strokeDescription => _text(
    'Face, arm, speech, and onset-time assessment',
    'মুখ, হাত, কথা ও উপসর্গ শুরুর সময় যাচাই',
  );
  String get ambulanceDescription => _text(
    'Emergency dispatch request with progress tracking',
    'অগ্রগতি পর্যবেক্ষণসহ জরুরি অ্যাম্বুলেন্স অনুরোধ',
  );
  String get hospitalDescription => _text(
    'Nearby cardiac, stroke, ICU, and 24/7 facilities',
    'নিকটস্থ হৃদরোগ, স্ট্রোক, আইসিইউ ও ২৪/৭ হাসপাতাল',
  );
  String get timerDescription => _text(
    'Timed journey check-in with automatic SOS escalation',
    'সময়ভিত্তিক যাত্রা চেক-ইন ও স্বয়ংক্রিয় এসওএস',
  );
  String get reportDescription => _text(
    'Confidential harassment, stalking, or threat reporting',
    'হয়রানি, অনুসরণ বা হুমকির গোপনীয় প্রতিবেদন',
  );
  String get historyDescription => _text(
    'Review previous alerts, assessments, and activity',
    'আগের সতর্কতা, মূল্যায়ন ও কার্যক্রম দেখুন',
  );
  String get responderDescription => _text(
    'Prioritized emergency queue and response workflow',
    'অগ্রাধিকারভিত্তিক জরুরি সারি ও সাড়া দেওয়ার কার্যক্রম',
  );
  String get adminDescription => _text(
    'Platform metrics, incident hotspots, and evaluation data',
    'প্ল্যাটফর্ম পরিসংখ্যান, ঘটনা হটস্পট ও মূল্যায়ন তথ্য',
  );

  String get nationalEmergency =>
      _text('National Emergency', 'জাতীয় জরুরি সেবা');
  String get nationalEmergencyDesc =>
      _text('Police, Fire & Ambulance', 'পুলিশ, ফায়ার ও অ্যাম্বুলেন্স');
  String get womenAndChildren =>
      _text('Women & Children', 'নারী ও শিশু সহায়তা');
  String get womenAndChildrenDesc =>
      _text('Helpline for violence & harassment', 'সহিংসতা ও হয়রানি প্রতিরোধ হেল্পলাইন');
  String get nationalHelpDesk => _text('National Help Desk', 'জাতীয় তথ্যসেবা');
  String get nationalHelpDeskDesc =>
      _text('Government services & info desk', 'সরকারি সেবা ও জরুরি তথ্য ডেস্ক');

  String get call => _text('Call', 'কল করুন');
  String get tollFree => _text('Toll-Free', 'টোল-ফ্রি');
  String callFailed(String number) => _text(
    'Could not open the phone app. Please call $number manually.',
    'ফোন অ্যাপ খোলা যায়নি। অনুগ্রহ করে নিজে $number নম্বরে কল করুন।',
  );

  String get prepareEyebrow =>
      _text('PREPARE BEFORE AN EMERGENCY', 'জরুরি অবস্থার আগেই প্রস্তুত থাকুন');
  String get prepareTitle => _text(
    'Your emergency profile can save critical minutes.',
    'আপনার জরুরি প্রোফাইল মূল্যবান সময় বাঁচাতে পারে।',
  );
  String get prepareDescription => _text(
    'Keep your blood group, conditions, medication, and trusted contacts ready for responders. Your information remains under your control.',
    'রক্তের গ্রুপ, রোগ, ওষুধ ও বিশ্বস্ত যোগাযোগের তথ্য প্রস্তুত রাখুন। আপনার তথ্যের নিয়ন্ত্রণ আপনার কাছেই থাকে।',
  );
  String get medicalId => _text('Medical ID', 'মেডিকেল আইডি');
  String get addBloodGroup => _text('Add blood group', 'রক্তের গ্রুপ যোগ করুন');
  String get trustedContacts => _text('Trusted contacts', 'বিশ্বস্ত যোগাযোগ');
  String verifiedCount(int count) =>
      _text('$count verified', '$count জন যাচাইকৃত');
  String get sosNow => _text('SOS NOW', 'এখনই এসওএস');
  String get tapForEmergency =>
      _text('Tap for emergency alert', 'জরুরি সতর্কতার জন্য চাপুন');

  String get emergencyAccess => _text('Emergency access', 'জরুরি সেবা');
  String get nationalHelplines =>
      _text('National helplines', 'জাতীয় হেল্পলাইন');
  String get integratedServices => _text('Integrated services', 'সমন্বিত সেবা');
  String get supportedLanguages => _text('Supported languages', 'সমর্থিত ভাষা');
  String get footerTitle =>
      _text('SafeLife emergency support', 'সেফলাইফ জরুরি সহায়তা');
  String get footerSubtitle => _text(
    'Women’s safety and emergency medical support',
    'নারীর নিরাপত্তা ও জরুরি চিকিৎসা সহায়তা',
  );
  String get activeEmergency =>
      _text('ACTIVE EMERGENCY IN PROGRESS', 'সক্রিয় জরুরি সহায়তা চলছে');
  String get activeEmergencyDescription => _text(
    'Tap to view live coordinates and responder tracking',
    'লাইভ অবস্থান ও সহায়তাকারীর অগ্রগতি দেখতে চাপুন',
  );

  // Web additions
  String get navServices => _text('Services', 'সেবাসমূহ');
  String get navHelplines => _text('Helplines', 'হেল্পলাইন');
  String get navPrep => _text('Preparedness', 'জরুরি প্রস্তুতি');
  String get navSos => _text('SOS ALERT', 'দ্রুত এসওএস');
  String get systemReady => _text('24/7 ACTIVE', '২৪/৭ সক্রিয়');
  String get instantDispatch => _text('Instant Dispatch', 'তাৎক্ষণিক প্রেরণ');
  String get encryptedLocation => _text('Encrypted GPS', 'এনক্রিপ্টেড জিপিএস');
  String get zeroDelay => _text('Zero Delay', 'দ্রুত ট্রায়াজ');
  String get callHotline => _text('Call 999', '৯৯৯-এ কল করুন');
  String get quickHelplines => _text('DIRECT TOLL-FREE EMERGENCY HELPLINES', 'সরাসরি জাতীয় জরুরি হটলাইন (টোল-ফ্রি)');
  String get emergencyReadinessTitle => _text('Emergency Readiness', 'জরুরি প্রস্তুতি ড্যাশবোর্ড');
  String get rapidTriggerNote => _text('One touch transmits live GPS & medical ID to guardians', 'এক চাপে অভিভাবক ও উদ্ধারকারীর কাছে লাইভ জিপিএস ও মেডিকেল আইডি পৌঁছায়');
  String get footerColServices => _text('Emergency & Triage', 'জরুরি ও স্বাস্থ্য সেবা');
  String get footerColTools => _text('Safety Tools', 'নিরাপত্তা সুবিধাসমূহ');
  String get footerColAccess => _text('System & Access', 'সিস্টেম ও এক্সেস');
  String get footerDesc => _text(
    'SafeLife is an integrated safety and medical emergency response network designed to safeguard lives with zero-latency response.',
    'সেফলাইফ একটি সমন্বিত নারী নিরাপত্তা ও জরুরি চিকিৎসা সাড়া নেটওয়ার্ক, যা দ্রুততম সময়ে মানুষের জীবন বাঁচাতে নিবেদিত।',
  );
  String get footerEmergencyNote => _text(
    'Direct Hotline: Dial 999 for National Emergency Dispatch',
    'সরাসরি হটলাইন: জাতীয় জরুরি সেবার জন্য ৯৯৯ ডায়াল করুন',
  );
  String get footerRights => _text(
    '© 2026 SafeLife Emergency Response Network. All rights reserved.',
    '© ২০২৬ সেফলাইফ জরুরি সাড়া নেটওয়ার্ক। সর্বস্বত্ব সংরক্ষিত।',
  );

  // Project Info Marquee
  String get projectInfoEyebrow => _text(
        'ABOUT SAFELIFE PLATFORM',
        'সেফলাইফ প্ল্যাটফর্ম পরিচিতি',
      );
  String get projectInfoTitle => _text(
        'Project Architecture & Core Highlights',
        'প্ল্যাটফর্মের মূল সুবিধা ও কাঠামো',
      );
  String get liveStream => _text('Live Stream', 'চলমান তথ্য');
  String get pausedOnHover => _text('Paused', 'স্থগিত');

  String get infoMissionTitle => _text('Integrated Emergency Care', 'সমন্বিত জরুরি সেবা');
  String get infoMissionTag => _text('Platform Mission', 'মূল লক্ষ্য');
  String get infoMissionDesc => _text(
        'All-in-one emergency ecosystem uniting women\'s safety, symptom triage, ambulance dispatch, and hospital network.',
        'নারী নিরাপত্তা, স্বাস্থ্য যাচাই, অ্যাম্বুলেন্স প্রেরণ ও হাসপাতাল ডিরেক্টরি সমন্বিত এক নির্ভরযোগ্য সেবা ব্যবস্থা।',
      );

  String get infoSosTitle => _text('Discreet SOS & SMS Fallback', 'গোপন এসওএস ও এসএমএস');
  String get infoSosTag => _text('Immediate Response', 'তাৎক্ষণিক সাড়া');
  String get infoSosDesc => _text(
        'One-tap distress trigger with live GPS tracking, cancelable countdown, and automatic SMS fallback for low-network areas.',
        'এক চাপে লাইভ জিপিএস ট্র্যাকিং ও নেটওয়ার্ক দুর্বলতায় স্বয়ংক্রিয় অফলাইন এসএমএস সতর্কবার্তা প্রেরণ।',
      );

  String get infoTriageTitle => _text('Clinical Triage Algorithms', 'ক্লিনিক্যাল ট্রায়াজ');
  String get infoTriageTag => _text('Medical AI / Rules', 'চিকিৎসা যাচাই');
  String get infoTriageDesc => _text(
        'Evidence-based cardiac risk scoring and FAST stroke assessment favoring early life-saving escalation.',
        'হার্ট অ্যাটাক ও স্ট্রোকের মতো জটিল পরিস্থিতিতে সময় নষ্ট না করে দ্রুত ঝুঁকিনির্ধারণ ও হাসপাতালে নির্দেশনা।',
      );

  String get infoTimerTitle => _text('Walk-With-Me Safety Timer', 'নিরাপদ যাত্রা টাইমার');
  String get infoTimerTag => _text('Transit Shield', 'যাত্রা সুরক্ষা');
  String get infoTimerDesc => _text(
        'Automated arrival countdown that automatically escalates alerts to guardians if a transit check-in is missed.',
        'একাকী চলাচলের সময় যাত্রা টাইমার—সময়মতো গন্তব্যে না পৌঁছালে স্বয়ংক্রিয়ভাবে অভিভাবককে সতর্ক করে।',
      );

  String get infoHelplineTitle => _text('National Helpline Integration', 'জাতীয় জরুরি হটলাইন');
  String get infoHelplineTag => _text('Toll-Free Access', 'টোল-ফ্রি হটলাইন');
  String get infoHelplineDesc => _text(
        'Direct toll-free access to Bangladesh National Emergency 999, Women & Child Helpline 109, and Gov Desk 333.',
        'জাতীয় জরুরি সেবা ৯৯৯, নারী ও শিশু নির্যাতন প্রতিরোধ হেল্পলাইন ১০৯ এবং সরকারি তথ্যসেবা ৩৩৩ এর সরাসরি সংযোগ।',
      );

  String get infoMedicalIdTitle => _text('Instant Medical ID Access', 'জরুরি মেডিকেল আইডি');
  String get infoMedicalIdTag => _text('Health Profile', 'স্বাস্থ্য তথ্য');
  String get infoMedicalIdDesc => _text(
        'Blood group, chronic conditions, and allergy data kept ready for responders in critical golden hour care.',
        'জরুরি চিকিৎসা নিশ্চিত করতে রক্তের গ্রুপ, রোগ ও ওষুধের বিবরণ চিকিৎসকদের জন্য প্রস্তুত রাখা।',
      );

  String get infoAmbulanceTitle => _text('Priority Ambulance Routing', 'অ্যাম্বুলেন্স নেটওয়ার্ক');
  String get infoAmbulanceTag => _text('Dispatch Network', 'দ্রুত প্রেরণ');
  String get infoAmbulanceDesc => _text(
        'Real-time BLS/ALS ambulance requests with status tracking and 24/7 trauma emergency directory.',
        'লাইভ ট্র্যাকিং সুবিধাসহ প্রাথমিক ও বিশেষায়িত অ্যাম্বুলেন্স প্রেরণ ও সার্বক্ষণিক ট্রমা সেন্টার তথ্য।',
      );

  String get infoBilingualTitle => _text('Bilingual & Responsive', 'দ্বিভাষিক ও রেসপনসিভ');
  String get infoBilingualTag => _text('Accessibility', 'সহজ ব্যবহারযোগ্য');
  String get infoBilingualDesc => _text(
        'Native Bangla and English support designed for low-latency performance across phones, tablets, and web.',
        'মোবাইল, ট্যাবলেট ও কম্পিউটার সব ধরনের স্ক্রিনে তাৎক্ষণিক বাংলা ও ইংরেজি ভাষায় ব্যবহারের সুবিধা।',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// COUNTDOWN DIALOG (Preserved 100% of state, timer, and dispatch logic)
// ─────────────────────────────────────────────────────────────────────────────

class _CountdownDialog extends StatefulWidget {
  final String userId;
  final String userName;
  final String userPhone;
  final List<EmergencyContact> contacts;
  final String language;
  final SosProvider sosProvider;
  final VoidCallback onDispatched;

  const _CountdownDialog({
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.contacts,
    required this.language,
    required this.sosProvider,
    required this.onDispatched,
  });

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _remaining = AlertConstants.defaultCountdownSeconds;
  Timer? _timer;
  bool _cancelled = false;
  bool _isDispatching = false;
  String? _dispatchError;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _cancelled) return;
      if (_remaining > 1) {
        setState(() => _remaining--);
      } else {
        unawaited(_dispatchNow());
      }
    });
  }

  Future<void> _dispatchNow() async {
    if (_cancelled || _isDispatching) return;
    _timer?.cancel();
    setState(() {
      _isDispatching = true;
      _dispatchError = null;
    });
    final emergency = await widget.sosProvider.dispatchEmergency(
      userId: widget.userId,
      userName: widget.userName,
      userPhone: widget.userPhone,
      contacts: widget.contacts,
      language: widget.language,
      type: EmergencyType.safety,
    );
    if (!mounted) return;
    if (emergency != null) {
      _cancelled = true;
      widget.onDispatched();
      return;
    }
    setState(() {
      _isDispatching = false;
      _dispatchError =
          widget.sosProvider.errorMessage ??
          (widget.language == 'bn'
              ? 'জরুরি সতর্কতা পাঠানো যায়নি। অনুগ্রহ করে ৯৯৯ নম্বরে কল করে আবার চেষ্টা করুন।'
              : 'Emergency alert could not be sent. Please call 999 and try again.');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n?.countdownTitle ?? 'Emergency Alert Triggering',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.countdownWarning(_remaining) ??
                'Alerting emergency contacts in $_remaining seconds',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: _remaining / AlertConstants.defaultCountdownSeconds,
                  strokeWidth: 8,
                  color: theme.colorScheme.error,
                  backgroundColor: theme.colorScheme.error.withAlpha(40),
                ),
              ),
              Text(
                '$_remaining',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (_dispatchError != null) ...[
            const SizedBox(height: 16),
            Text(
              _dispatchError!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isDispatching
              ? null
              : () {
                  _cancelled = true;
                  _timer?.cancel();
                  Navigator.of(context).pop();
                },
          child: Text(l10n?.cancel ?? 'Cancel / I’m Safe'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: Colors.white,
          ),
          onPressed: _isDispatching ? null : _dispatchNow,
          child: _isDispatching
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.language == 'bn' ? 'এখনই পাঠান' : 'Dispatch Now'),
        ),
      ],
    );
  }
}
