import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_card.dart';

/// User type selection page - Card based layout matching React Kiosk.
/// Step 1: Select user type via visual cards with icons.
class UserTypeSelectionPage extends ConsumerStatefulWidget {
  const UserTypeSelectionPage({super.key});

  @override
  ConsumerState<UserTypeSelectionPage> createState() =>
      _UserTypeSelectionPageState();
}

/// User type data model matching React kiosk structure.
class _UserType {
  final String id;
  final String icon;
  final String label;
  final String description;

  const _UserType({
    required this.id,
    required this.icon,
    required this.label,
    required this.description,
  });
}

class _UserTypeSelectionPageState
    extends ConsumerState<UserTypeSelectionPage> {
  /// Available user types matching React kiosk.
  static const List<_UserType> _userTypes = [
    _UserType(
      id: 'student',
      icon: '🎓',
      label: 'Student',
      description: 'Currently enrolled student',
    ),
    _UserType(
      id: 'alumni',
      icon: '👔',
      label: 'Alumni',
      description: 'Graduated alumni',
    ),
    _UserType(
      id: 'faculty',
      icon: '🧑\u200d🏫',
      label: 'Faculty/Staff',
      description: 'Faculty or staff member',
    ),
    _UserType(
      id: 'visitor',
      icon: '👥',
      label: 'Visitor',
      description: 'Guest or visitor',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          const TopNavBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Step header - matches React kiosk style
                  Container(
                    margin: const EdgeInsets.only(bottom: EZSpacing.xl),
                    child: Column(
                      children: [
                        // Icon
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '🏷️',
                              style: TextStyle(fontSize: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: EZSpacing.lg),
                        // Title
                        Text(
                          'Who are you?',
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: EZSpacing.sm),
                        // Subtitle
                        Text(
                          'Select your user type to continue',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User type cards grid
                  _buildUserTypeGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the user type selection cards in a grid layout.
  Widget _buildUserTypeGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 3.5,
            crossAxisSpacing: EZSpacing.md,
            mainAxisSpacing: EZSpacing.md,
          ),
          itemCount: _userTypes.length,
          itemBuilder: (context, index) {
            final userType = _userTypes[index];
            return _buildUserTypeCard(context, userType);
          },
        );
      },
    );
  }

  /// Build individual user type card.
  Widget _buildUserTypeCard(BuildContext context, _UserType userType) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () => _handleSelect(userType.id),
      child: EZCard(
        padding: const EdgeInsets.all(EZSpacing.md),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  userType.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: EZSpacing.md),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userType.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: EZSpacing.xs),
                  Text(
                    userType.description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle user type selection.
  void _handleSelect(String userTypeId) {
    // Convert to proper display format for storage
    final displayUserType = switch (userTypeId) {
      'student' => 'Student',
      'alumni' => 'Alumni',
      'faculty' => 'Faculty/Staff',
      'visitor' => 'Visitor',
      _ => userTypeId,
    };

    // Save user type to state
    ref
        .read(queueFormProvider.notifier)
        .updateUserType(userType: displayUserType);

    // Navigate to identity information page
    context.push('/identity-information');
  }
}
