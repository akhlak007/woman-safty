import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../models/emergency_contact.dart';
import '../providers/contacts_provider.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contactsProvider = context.watch<ContactsProvider>();
    final contacts = contactsProvider.contacts;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isDesktop = screenWidth >= 960;
        final isTablet = screenWidth >= 640 && screenWidth < 960;
        final horizontalPadding = isDesktop ? 36.0 : (isTablet ? 24.0 : 16.0);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              l10n?.myContacts ?? 'Emergency Contacts & Guardians',
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => _showAddEditContactDialog(context),
                    icon: const Icon(Icons.person_add_rounded, size: 18),
                    label: Text(
                      l10n?.addContact ?? 'Add Contact',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: contactsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomScrollView(
                        slivers: [
                          // Web Hero Banner Section
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                isDesktop ? 24 : 16,
                                horizontalPadding,
                                16,
                              ),
                              child: Container(
                                padding: EdgeInsets.all(isDesktop ? 30 : 20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? [
                                            const Color(0xFF1E1428),
                                            const Color(0xFF261332),
                                            const Color(0xFF0F172A),
                                          ]
                                        : [
                                            const Color(0xFF4C1D95),
                                            const Color(0xFF5B21B6),
                                            const Color(0xFF6D28D9),
                                          ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 18,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(25),
                                              borderRadius: BorderRadius.circular(999),
                                              border: Border.all(color: Colors.white.withAlpha(50)),
                                            ),
                                            child: const Text(
                                              'TRUSTED GUARDIAN NETWORK',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: 1.1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Emergency Guardian & Contact Directory',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isDesktop ? 28 : 20,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(maxWidth: 700),
                                            child: Text(
                                              'Your trusted contacts will be immediately alerted via direct SMS broadcast with your live GPS location during an emergency.',
                                              style: TextStyle(
                                                color: Colors.white.withAlpha(220),
                                                fontSize: 13,
                                                height: 1.45,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (isDesktop) ...[
                                      const SizedBox(width: 24),
                                      Container(
                                        padding: const EdgeInsets.all(18),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(20),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white.withAlpha(40), width: 2),
                                        ),
                                        child: const Icon(
                                          Icons.people_alt_rounded,
                                          color: Colors.white,
                                          size: 44,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Privacy & Consent Note Card
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: horizontalPadding,
                                vertical: 6,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(90),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant.withAlpha(70),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.privacy_tip_outlined,
                                      size: 22,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'To ensure safety compliance and prevent unauthorized tracking, contacts must verify consent before receiving continuous live location streaming.',
                                        style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Empty state or Multi-Column Grid
                          if (contacts.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.contact_phone_outlined,
                                        size: 68,
                                        color: theme.colorScheme.outlineVariant,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No Emergency Contacts Yet',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 480),
                                        child: Text(
                                          l10n?.minContactsNotice ??
                                              'We recommend adding at least 2 trusted emergency contacts who can receive your alerts and live GPS location.',
                                          textAlign: TextAlign.center,
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: FilledButton.icon(
                                          onPressed: () => _showAddEditContactDialog(context),
                                          icon: const Icon(Icons.add),
                                          label: Text(l10n?.addContact ?? 'Add First Contact'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                14,
                                horizontalPadding,
                                48,
                              ),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: isDesktop ? 2 : 1,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  mainAxisExtent: 185,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final contact = contacts[index];
                                    return _WebContactCard(
                                      contact: contact,
                                      onEdit: () => _showAddEditContactDialog(context, contact),
                                    );
                                  },
                                  childCount: contacts.length,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAddEditContactDialog(BuildContext context, [EmergencyContact? existing]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      constraints: const BoxConstraints(maxWidth: 640),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _AddEditContactSheet(existing: existing),
    );
  }
}

class _WebContactCard extends StatefulWidget {
  final EmergencyContact contact;
  final VoidCallback onEdit;

  const _WebContactCard({
    required this.contact,
    required this.onEdit,
  });

  @override
  State<_WebContactCard> createState() => _WebContactCardState();
}

class _WebContactCardState extends State<_WebContactCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final contactsProvider = context.read<ContactsProvider>();
    final contact = widget.contact;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _isHovered ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isHovered
                ? theme.colorScheme.primary.withAlpha(160)
                : theme.colorScheme.outlineVariant.withAlpha(70),
            width: _isHovered ? 1.5 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withAlpha(isDark ? 45 : 20),
                    blurRadius: 18,
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
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top details row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: contact.verified
                        ? const Color(0xFF10B981).withAlpha(25)
                        : theme.colorScheme.error.withAlpha(25),
                    child: Icon(
                      contact.verified
                          ? Icons.verified_user_rounded
                          : Icons.pending_actions_rounded,
                      color: contact.verified
                          ? const Color(0xFF10B981)
                          : theme.colorScheme.error,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                contact.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                contact.relation,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'P${contact.priority}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          contact.phone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (val) {
                      if (val == 'edit') {
                        widget.onEdit();
                      } else if (val == 'delete') {
                        _confirmDelete(context, contactsProvider, contact.id);
                      } else if (val == 'verify') {
                        _showManualVerifyDialog(context, contactsProvider, contact.id);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit Contact'),
                      ),
                      if (!contact.verified)
                        const PopupMenuItem(
                          value: 'verify',
                          child: Text('Enter Verification Code'),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete Contact'),
                      ),
                    ],
                  ),
                ],
              ),

              Divider(height: 1, color: theme.colorScheme.outlineVariant.withAlpha(60)),

              // Bottom status and action row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        contact.verified ? Icons.check_circle_rounded : Icons.info_outline,
                        size: 16,
                        color: contact.verified
                            ? const Color(0xFF10B981)
                            : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        contact.verified
                            ? (l10n?.verifiedConsent ?? 'Verified Guardian')
                            : (l10n?.pendingConsent ?? 'Pending Consent'),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: contact.verified
                              ? const Color(0xFF10B981)
                              : Colors.amber.shade800,
                        ),
                      ),
                    ],
                  ),
                  if (!contact.verified)
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: TextButton.icon(
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () async {
                          final code = await contactsProvider.requestConsent(contact.id);
                          if (context.mounted && code != null) {
                            _showConsentSentDialog(context, code);
                          }
                        },
                        icon: const Icon(Icons.send_rounded, size: 14),
                        label: Text(
                          l10n?.requestConsent ?? 'Send Verification SMS',
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ),
                    )
                  else
                    Row(
                      children: const [
                        Icon(Icons.lock_rounded, size: 13, color: Color(0xFF10B981)),
                        SizedBox(width: 4),
                        Text(
                          'SMS Live Alerts Active',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ContactsProvider provider,
    String contactId,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Emergency Contact'),
        content: const Text(
          'Are you sure you want to remove this contact from your emergency alert list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              provider.deleteContact(contactId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showConsentSentDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verification Code Issued'),
        content: Text(
          'A consent request has been created. The contact can confirm tracking permission using this code:\n\n'
          'Code: $code\n\n'
          '(In production, this code is dispatched via SMS gateway to the contact\'s phone).',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showManualVerifyDialog(
    BuildContext context,
    ContactsProvider provider,
    String contactId,
  ) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify Contact Consent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the 6-digit verification code received by this contact:'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Verification Code',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final success = await provider.verifyConsent(
                contactId,
                codeController.text.trim(),
              );
              if (context.mounted) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Contact verified successfully!'
                          : 'Invalid verification code. Please check and try again.',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }
}

class _AddEditContactSheet extends StatefulWidget {
  final EmergencyContact? existing;

  const _AddEditContactSheet({this.existing});

  @override
  State<_AddEditContactSheet> createState() => _AddEditContactSheetState();
}

class _AddEditContactSheetState extends State<_AddEditContactSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  String _relation = 'Family';
  int _priority = 1;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _phoneController = TextEditingController(text: widget.existing?.phone ?? '');
    _relation = widget.existing?.relation ?? 'Family';
    _priority = widget.existing?.priority ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ContactsProvider>();
    final contact = EmergencyContact(
      id: widget.existing?.id ?? '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relation: _relation,
      priority: _priority,
      verified: widget.existing?.verified ?? false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );

    if (widget.existing == null) {
      provider.addContact(contact);
    } else {
      provider.updateContact(contact);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existing == null
                    ? (l10n?.addContact ?? 'Add Emergency Contact')
                    : (l10n?.editContact ?? 'Edit Contact'),
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n?.contactName ?? 'Contact Name',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please enter contact name' : null,
              ),
              const SizedBox(height: 14),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: l10n?.contactPhone ?? 'Phone Number',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  hintText: '+8801XXXXXXXXX',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Please enter phone number' : null,
              ),
              const SizedBox(height: 14),

              // Relation Dropdown
              DropdownButtonFormField<String>(
                initialValue: _relation,
                decoration: InputDecoration(
                  labelText: l10n?.relation ?? 'Relationship',
                  prefixIcon: const Icon(Icons.people_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: EmergencyContact.commonRelations.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _relation = val);
                },
              ),
              const SizedBox(height: 14),

              // Priority Selector
              Text('Alert Priority (1 = Primary)', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 6),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('1 (Primary)')),
                  ButtonSegment(value: 2, label: Text('2')),
                  ButtonSegment(value: 3, label: Text('3')),
                ],
                selected: {_priority},
                onSelectionChanged: (set) {
                  setState(() => _priority = set.first);
                },
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _submit,
                child: Text(l10n?.save ?? 'Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
