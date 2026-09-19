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
    final contactsProvider = context.watch<ContactsProvider>();
    final contacts = contactsProvider.contacts;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.myContacts ?? 'Emergency Contacts'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditContactDialog(context),
        icon: const Icon(Icons.person_add_rounded),
        label: Text(l10n?.addContact ?? 'Add Contact'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 850),
            child: contactsProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : contacts.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contact_phone_outlined,
                            size: 64,
                            color: theme.colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Emergency Contacts Yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n?.minContactsNotice ??
                                'We recommend adding at least 2 trusted emergency contacts who can receive your alerts and location.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: () => _showAddEditContactDialog(context),
                            icon: const Icon(Icons.add),
                            label: Text(l10n?.addContact ?? 'Add First Contact'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: contacts.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.privacy_tip_outlined,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'To prevent misuse, contacts must consent before receiving continuous live location tracking.',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final contact = contacts[index - 1];
                      return _ContactCard(contact: contact);
                    },
                  ),
            ),
          ),
        ),
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

class _ContactCard extends StatelessWidget {
  final EmergencyContact contact;

  const _ContactCard({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final contactsProvider = context.read<ContactsProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: contact.verified
                      ? theme.colorScheme.primary.withAlpha(25)
                      : theme.colorScheme.error.withAlpha(25),
                  child: Icon(
                    contact.verified
                        ? Icons.check_circle_rounded
                        : Icons.pending_actions_rounded,
                    color: contact.verified
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              contact.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              contact.relation,
                              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contact.phone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (val) {
                    if (val == 'delete') {
                      _confirmDelete(context, contactsProvider, contact.id);
                    } else if (val == 'verify') {
                      _showManualVerifyDialog(context, contactsProvider, contact.id);
                    }
                  },
                  itemBuilder: (ctx) => [
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
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      contact.verified ? Icons.verified_rounded : Icons.info_outline,
                      size: 16,
                      color: contact.verified
                          ? theme.colorScheme.primary
                          : theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      contact.verified
                          ? (l10n?.verifiedConsent ?? 'Verified (Consent Granted)')
                          : (l10n?.pendingConsent ?? 'Pending Consent'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: contact.verified
                            ? theme.colorScheme.primary
                            : theme.colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                if (!contact.verified)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: () async {
                      final code = await contactsProvider.requestConsent(contact.id);
                      if (context.mounted && code != null) {
                        _showConsentSentDialog(context, code);
                      }
                    },
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: Text(l10n?.requestConsent ?? 'Send Request'),
                  ),
              ],
            ),
          ],
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
