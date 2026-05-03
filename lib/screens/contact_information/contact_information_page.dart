import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/widgets/ez_input_field.dart';
import 'package:ez_queue/widgets/ez_form_text_field.dart';
import 'package:ez_queue/utils/theme_helpers.dart';
import 'package:ez_queue/services/api_service.dart';
import 'package:ez_queue/providers/api_providers.dart';

/// Contact information page.
/// Step 3: Captures Phone, Email, and Queue Type/Priority selection.
/// Includes active queue checking like React Kiosk.
class ContactInformationPage extends ConsumerStatefulWidget {
  const ContactInformationPage({super.key});

  @override
  ConsumerState<ContactInformationPage> createState() =>
      _ContactInformationPageState();
}

class _ContactInformationPageState
    extends ConsumerState<ContactInformationPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'PH');

  // CHANGED: Parse the full number using the library to extract the exact
  // country/dial code, then strip only that prefix. This avoids the greedy
  // regex bug where +639888777654 would strip "639" instead of "63",
  // losing the first digit "9" of the local number.
  Future<void> _initPhoneNumber(String fullNumber) async {
    if (fullNumber.isEmpty || _contactNumberController.text.isNotEmpty) return;

    try {
      final parsed = await PhoneNumber.getRegionInfoFromPhoneNumber(fullNumber);
      final dialCode = parsed.dialCode ?? ''; // e.g. "+63"
      final isoCode = parsed.isoCode ?? 'PH'; // e.g. "PH"

      // Strip exactly the dial code from the full number
      String localNumber = fullNumber.replaceAll(RegExp(r'\s'), '');
      // Remove leading + from both for reliable prefix matching
      final dialDigits = dialCode.replaceAll('+', '');
      localNumber = localNumber.replaceFirst(RegExp(r'^\+'), '');
      if (dialDigits.isNotEmpty && localNumber.startsWith(dialDigits)) {
        localNumber = localNumber.substring(dialDigits.length);
      }

      if (mounted) {
        setState(() {
          _phoneNumber = PhoneNumber(isoCode: isoCode, dialCode: dialCode);
          _contactNumberController.text = _formatLocalNumber(localNumber);
        });
      }
    } catch (_) {
      // Fallback: strip leading + and digits manually
      if (mounted) {
        final cleaned = fullNumber.replaceAll(RegExp(r'\s'), '');
        final local = cleaned.replaceFirst(RegExp(r'^\+\d{1,3}'), '');
        setState(() {
          _contactNumberController.text = _formatLocalNumber(local);
        });
      }
    }
  }

  // CHANGED: Format local digits as "000 000 0000" for display in the controller.
  // e.g. "9888777654" → "988 877 7654"
  String _formatLocalNumber(String digits) {
    final d = digits.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length <= 3) return d;
    if (d.length <= 6) return '${d.substring(0, 3)} ${d.substring(3)}';
    return '${d.substring(0, 3)} ${d.substring(3, 6)} ${d.substring(6)}';
  }

  // Priority selection
  int _priorityWeight = 1;
  bool _isPWD = false;

  bool _isChecking = false;
  List<dynamic> _activeDepartments = [];
  Map<String, dynamic> _matchedData = {};

  @override
  void initState() {
    super.initState();
    _loadScannedContact();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _contactNumberController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  /// Load scanned contact info from QR code scan.
  Future<void> _loadScannedContact() async {
    final prefs = await SharedPreferences.getInstance();
    final scanned = prefs.getString('scanned_contact');
    if (scanned != null) {
      try {
        // Parse the string representation of a map
        final contact = _parseContactString(scanned);
        if (mounted) {
          if (contact['phone'] != null &&
              _contactNumberController.text.isEmpty) {
            await _initPhoneNumber(contact['phone']!);
          }
          if (contact['email'] != null && _emailController.text.isEmpty) {
            setState(() {
              _emailController.text = contact['email']!;
            });
          }
        }
        await prefs.remove('scanned_contact');
      } catch (e) {
        // Silently ignore parse errors from scanned contact data
      }
    }
  }

  /// Parse contact string from SharedPreferences.
  Map<String, String> _parseContactString(String str) {
    final result = <String, String>{};
    // Remove curly braces and split by comma
    final clean = str.replaceAll('{', '').replaceAll('}', '');
    final pairs = clean.split(',');
    for (final pair in pairs) {
      final parts = pair.split(':');
      if (parts.length == 2) {
        final key = parts[0].trim();
        final value = parts[1].trim();
        result[key] = value;
      }
    }
    return result;
  }

  /// Validate email format.
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(queueFormProvider);

    // Load saved data from provider
    if (formData.email != null && _emailController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _emailController.text = formData.email!;
        }
      });
    }
    // CHANGED: Parse and strip country code using the library so the
    // InternationalPhoneNumberInput widget doesn't double the prefix.
    if (formData.contactNumber != null &&
        _contactNumberController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _initPhoneNumber(formData.contactNumber!);
        }
      });
    }
    if (formData.priorityWeight != 1 && _priorityWeight == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _priorityWeight = formData.priorityWeight;
            _isPWD = formData.isPWD;
          });
        }
      });
    }

    final settingsAsync = ref.watch(apiSettingsProvider);
    final enablePriorityQueue = settingsAsync.when(
      data: (s) => s.enablePriority,
      loading: () => true,
      error: (_, __) => true,
    );

    return Scaffold(
      body: Column(
        children: [
          const TopNavBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step header - icon and text in one row
                    Container(
                      margin: const EdgeInsets.only(bottom: EZSpacing.xl),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text('📞', style: TextStyle(fontSize: 32)),
                            ),
                          ),
                          const SizedBox(width: EZSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Contact Information',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                const SizedBox(height: EZSpacing.xs),
                                Text(
                                  'How can we reach you?',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Phone Number input (separate line)
                    Text(
                      'Phone Number',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: EZSpacing.sm),
                    EZInputField(
                      child: InternationalPhoneNumberInput(
                        onInputChanged: (PhoneNumber number) {
                          _phoneNumber = number;
                        },
                        selectorConfig: const SelectorConfig(
                          selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                          showFlags: true,
                          setSelectorButtonAsPrefixIcon: true,
                          trailingSpace: false,
                          leadingPadding: 16.0,
                        ),
                        initialValue: _phoneNumber,
                        textFieldController: _contactNumberController,
                        inputDecoration: ThemeHelpers.textInputDecoration(
                          hintText: 'Enter your phone number',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          signed: true,
                          decimal: true,
                        ),
                        inputBorder: InputBorder.none,
                        formatInput: true,
                        autoValidateMode: AutovalidateMode.onUserInteraction,
                      ),
                    ),
                    const SizedBox(height: EZSpacing.sm),
                    Text(
                      'For SMS notifications regarding your position in the queue',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: EZSpacing.xl),

                    // Email input (separate line)
                    Text(
                      'Email Address',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: EZSpacing.sm),
                    EZFormTextField(
                      controller: _emailController,
                      hintText: 'Enter your email address',
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 255,
                      validator: (value) {
                        if (value != null &&
                            value.isNotEmpty &&
                            !_isValidEmail(value.trim())) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: EZSpacing.sm),
                    Text(
                      'For email notifications regarding your position in the queue',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),

                    const SizedBox(height: EZSpacing.xxl),

                    // Queue Type / Priority selection (card style like React)
                    if (enablePriorityQueue) ...[
                      Text(
                        '⭐ Queue Type',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: EZSpacing.md),
                      _buildPriorityCards(),
                      const SizedBox(height: EZSpacing.xxl),
                    ],

                    // ID Number for priority verification
                    if (_priorityWeight > 1) ...[
                      Text(
                        'ID Number (Optional)',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: EZSpacing.sm),
                      EZFormTextField(
                        controller: _idNumberController,
                        hintText: 'For priority verification purposes',
                        maxLength: 50,
                      ),
                      const SizedBox(height: EZSpacing.xxl),
                    ],

                    // Navigation buttons
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: EZButton(
                            isSecondary: true,
                            onPressed: _isChecking ? null : () => context.pop(),
                            child: const Text('Back'),
                          ),
                        ),
                        const SizedBox(width: EZSpacing.md),
                        Expanded(
                          flex: 2,
                          child: EZButton(
                            onPressed: _isChecking ? null : _handleContinue,
                            child: _isChecking
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Continue'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build priority selection cards (vertical list for consistency).
  Widget _buildPriorityCards() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final options = [
      _PriorityOption(
        value: 1,
        icon: '🕐',
        title: 'Regular Queue',
        subtitle: 'Standard waiting line',
        highlight: false,
      ),
      _PriorityOption(
        value: 2,
        icon: '👵',
        title: 'Senior/Pregnant',
        subtitle: 'Priority Queue',
        highlight: true,
      ),
      _PriorityOption(
        value: 3,
        icon: '♿',
        title: 'PWD',
        subtitle: 'Priority Queue',
        highlight: true,
      ),
    ];

    return Column(
      children: options.map((option) {
        final isSelected = _priorityWeight == option.value;

        return Padding(
          padding: const EdgeInsets.only(bottom: EZSpacing.md),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _priorityWeight = option.value;
                _isPWD = option.value > 1;
              });
            },
            child: EZCard(
              padding: const EdgeInsets.all(EZSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.1)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        option.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: EZSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: EZSpacing.xs),
                        Text(
                          option.subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(Icons.check_circle, color: colorScheme.primary),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Show active queue detected modal.
  void _showActiveQueueModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Text('⚠️ ', style: TextStyle(fontSize: 20)),
            Expanded(
              child: Text(
                'Active Queue Detected',
                style: TextStyle(fontSize: 16),
                softWrap: true,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'It looks like you already have an active queue in the following department(s):',
              ),
              const SizedBox(height: EZSpacing.md),
              ..._activeDepartments.map(
                (dept) => Padding(
                  padding: const EdgeInsets.only(bottom: EZSpacing.xs),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: EZSpacing.sm),
                      Text(dept['name'] ?? 'Unknown'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: EZSpacing.lg),
              if (_matchedData.isNotEmpty) ...[
                Text(
                  'Based on the following data you inputted:',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: EZSpacing.sm),
                ..._matchedData.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: EZSpacing.xs),
                    child: Text(
                      '${entry.key}: ${entry.value}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                const SizedBox(height: EZSpacing.lg),
              ],
              Text(
                'You will not be able to join the queue for these departments until your current turn is completed.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        actions: [
          EZButton(
            onPressed: () {
              Navigator.of(context).pop();
              _proceedSubmit();
            },
            child: const Text('Understood, Continue'),
          ),
        ],
      ),
    );
  }

  /// Proceed with submitting after checking for active tickets.
  void _proceedSubmit() {
    final disabledDepts = _activeDepartments
        .map<int>((d) => d['id'] as int)
        .toList();

    ref
        .read(queueFormProvider.notifier)
        .updateContactInfo(
          email: _emailController.text.trim(),
          contactNumber:
              _phoneNumber.phoneNumber ?? _contactNumberController.text.trim(),
          priorityWeight: _priorityWeight,
          isPWD: _isPWD,
          pwdSpecification: null,
          priorityIdNumber: _idNumberController.text.trim().isEmpty
              ? null
              : _idNumberController.text.trim(),
          disabledDepartments: disabledDepts,
        );

    // Navigate to department selection
    context.push('/department-selection');
  }

  /// Handle continue button press with active queue check.
  Future<void> _handleContinue() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final formData = ref.read(queueFormProvider);

      final payload = {
        'student_name': formData.fullName,
        'student_id': formData.idNumber,
        'employee_id': formData.idNumber,
        'phone':
            _phoneNumber.phoneNumber ?? _contactNumberController.text.trim(),
        'email': _emailController.text.trim(),
      };

      final result = await apiService.checkActiveTickets(payload);

      if (result['departments'] != null &&
          (result['departments'] as List).isNotEmpty) {
        setState(() {
          _activeDepartments = result['departments'] as List;
          _matchedData = result['matched_data'] as Map<String, dynamic>? ?? {};
        });
        if (mounted) {
          _showActiveQueueModal();
        }
      } else {
        // No active tickets, proceed directly
        if (mounted) {
          _proceedSubmitDirect();
        }
      }
    } catch (err) {
      // Proceed safely if API fails
      if (mounted) {
        _proceedSubmitDirect();
      }
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  /// Proceed directly without showing modal.
  void _proceedSubmitDirect() {
    ref
        .read(queueFormProvider.notifier)
        .updateContactInfo(
          email: _emailController.text.trim(),
          contactNumber:
              _phoneNumber.phoneNumber ?? _contactNumberController.text.trim(),
          priorityWeight: _priorityWeight,
          isPWD: _isPWD,
          pwdSpecification: null,
          priorityIdNumber: _idNumberController.text.trim().isEmpty
              ? null
              : _idNumberController.text.trim(),
        );

    context.push('/department-selection');
  }
}

/// Priority option data model.
class _PriorityOption {
  final int value;
  final String icon;
  final String title;
  final String subtitle;
  final bool highlight;

  _PriorityOption({
    required this.value,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.highlight,
  });
}
