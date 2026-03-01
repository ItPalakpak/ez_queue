import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

/// Personal information page.
/// Allows users to input their full name, email address, and contact number.
class PersonalInformationPage extends ConsumerStatefulWidget {
  const PersonalInformationPage({super.key});

  @override
  ConsumerState<PersonalInformationPage> createState() =>
      _PersonalInformationPageState();
}

class _PersonalInformationPageState
    extends ConsumerState<PersonalInformationPage> {
  PhoneNumber _phoneNumber = PhoneNumber(
    isoCode: 'PH',
  ); // default to Philippines
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    super.dispose();
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
    // Load saved data from provider
    final formData = ref.watch(queueFormProvider);
    if (formData.fullName != null && _fullNameController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _fullNameController.text = formData.fullName!;
        }
      });
    }
    if (formData.email != null && _emailController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _emailController.text = formData.email!;
        }
      });
    }
    if (formData.contactNumber != null &&
        _contactNumberController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _contactNumberController.text = formData.contactNumber!;
        }
      });
    }
    final brightness = ref.watch(brightnessProvider);
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Top navigation bar
          const TopNavBar(),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page title
                    Text(
                      'Personal Information',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: EZSpacing.xl),

                    // Full name input
                    Text(
                      'Full Name',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter your full name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            EZSpacing.radiusMd,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: EZSpacing.xxl),

                    // Email input
                    Text(
                      'Email Address',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        hintText: 'Enter your email address',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            EZSpacing.radiusMd,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        if (!_isValidEmail(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: EZSpacing.sm),
                    // Note about email usage
                    Padding(
                      padding: const EdgeInsets.only(left: EZSpacing.xs),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: EZSpacing.xs),
                          Expanded(
                            child: Text(
                              'Your email will be used to send you notifications about your queue status.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: EZSpacing.xxl),

                    // Contact number input
                    Text(
                      'Contact Number',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    InternationalPhoneNumberInput(
                      onInputChanged: (PhoneNumber number) {
                        _phoneNumber = number;
                      },
                      onInputValidated: (bool isValid) {
                        // optional: track validity in real-time
                      },
                      selectorConfig: const SelectorConfig(
                        selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
                        showFlags: true,
                      ),
                      initialValue: _phoneNumber,
                      textFieldController: _contactNumberController,
                      inputDecoration: InputDecoration(
                        hintText: 'Enter your contact number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(
                            EZSpacing.radiusMd,
                          ),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surface,
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        signed: true,
                        decimal: true,
                      ),
                      inputBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                      ),
                      formatInput: true,
                      autoValidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    const SizedBox(height: EZSpacing.xxl),

                    // Continue button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _handleContinue,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: EZSpacing.md,
                            horizontal: EZSpacing.lg,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              EZSpacing.radiusMd,
                            ),
                          ),
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.secondary,
                          foregroundColor: isDark ? Colors.white : Colors.black,
                        ),
                        child: Text(
                          'Continue',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                        ),
                      ),
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

  /// Handle continue button press.
  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Save personal information to state
      ref
          .read(queueFormProvider.notifier)
          .updatePersonalInfo(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            contactNumber:
                _phoneNumber.phoneNumber ??
                _contactNumberController.text.trim(), // saves as +639XXXXXXXXX
          );

      // Navigate to confirmation page
      context.push('/confirmation');
    }
  }
}
