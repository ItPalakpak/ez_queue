import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/models/queue_form_data.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/widgets/ez_input_field.dart';
import 'package:ez_queue/utils/theme_helpers.dart';

/// Details information page.
/// Step 6: Captures Purpose and Items/Quantities for the service request.
class DetailsInformationPage extends ConsumerStatefulWidget {
  const DetailsInformationPage({super.key});

  @override
  ConsumerState<DetailsInformationPage> createState() =>
      _DetailsInformationPageState();
}

class _DetailsInformationPageState
    extends ConsumerState<DetailsInformationPage> {
  final TextEditingController _purposeController = TextEditingController();
  final List<ServiceItem> _items = [];
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();

  @override
  void dispose() {
    _purposeController.dispose();
    _itemNameController.dispose();
    _itemQuantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(queueFormProvider);

    // Validate that services are selected
    if (formData.serviceIds.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Please select services first.')),
      );
    }

    // Load saved data from provider
    if (formData.purpose != null && _purposeController.text.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _purposeController.text = formData.purpose!;
        }
      });
    }
    if (formData.items.isNotEmpty && _items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _items.addAll(formData.items);
          });
        }
      });
    }

    return Scaffold(
      body: Column(
        children: [
          const TopNavBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
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
                            child: Text('📝', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                        const SizedBox(width: EZSpacing.lg),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Additional Details',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: EZSpacing.xs),
                              Text(
                                'Provide purpose and items for your request',
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

                  // Selected services summary
                  if (formData.services.isNotEmpty) ...[
                    Text(
                      'Selected Services',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: EZSpacing.md),
                    EZCard(
                      padding: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(EZSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: formData.services.map((service) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: EZSpacing.xs,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  const SizedBox(width: EZSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      service,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: EZSpacing.xxl),
                  ],

                  // Purpose input
                  Text(
                    'Purpose',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  EZInputField(
                    child: TextField(
                      controller: _purposeController,
                      decoration: ThemeHelpers.textInputDecoration(
                        hintText:
                            'Describe the purpose for availing the service/s',
                      ),
                      maxLines: 3,
                      maxLength: 500,
                      textInputAction: TextInputAction.done,
                    ),
                  ),

                  const SizedBox(height: EZSpacing.xxl),

                  // Items / Quantities section
                  Text(
                    'Items / Quantities Needed',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.sm),
                  Text(
                    'Optional — add items if applicable',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: EZSpacing.md),
                  _buildItemsSection(),

                  const SizedBox(height: EZSpacing.xxl),

                  // Navigation buttons
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: EZButton(
                          isSecondary: true,
                          onPressed: () => context.pop(),
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: EZSpacing.md),
                      Expanded(
                        flex: 2,
                        child: EZButton(
                          onPressed: _handleContinue,
                          child: const Text('Continue'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build items/quantities section with add/remove.
  Widget _buildItemsSection() {
    return Column(
      children: [
        // Existing items list
        ..._items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: EZSpacing.md),
            child: EZCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                title: Text(item.name),
                subtitle: Text('Quantity: ${item.quantity}'),
                trailing: IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: () {
                    setState(() {
                      _items.removeAt(index);
                    });
                  },
                ),
              ),
            ),
          );
        }),

        // Add new item row
        EZCard(
          padding: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(EZSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item name
                Expanded(
                  flex: 3,
                  child: EZInputField(
                    child: TextField(
                      controller: _itemNameController,
                      decoration: ThemeHelpers.textInputDecoration(
                        hintText: 'Item name',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: EZSpacing.md,
                          vertical: EZSpacing.sm,
                        ),
                      ),
                      textInputAction: TextInputAction.next,
                      maxLength: 100,
                    ),
                  ),
                ),
                const SizedBox(width: EZSpacing.sm),
                // Quantity
                Expanded(
                  flex: 1,
                  child: EZInputField(
                    child: TextField(
                      controller: _itemQuantityController,
                      decoration: ThemeHelpers.textInputDecoration(
                        hintText: 'Qty',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: EZSpacing.md,
                          vertical: EZSpacing.sm,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      maxLength: 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: EZSpacing.sm),
                // Add button
                IconButton(
                  onPressed: _addItem,
                  icon: Icon(
                    Icons.add_circle,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  tooltip: 'Add Item',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Add an item to the items list.
  void _addItem() {
    final name = _itemNameController.text.trim();
    final quantityText = _itemQuantityController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an item name.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    final quantity = int.tryParse(quantityText) ?? 0;
    if (quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid quantity.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    setState(() {
      _items.add(ServiceItem(name: name, quantity: quantity));
      _itemNameController.clear();
      _itemQuantityController.clear();
    });
  }

  /// Handle continue button press.
  void _handleContinue() {
    // Save details information to state
    ref
        .read(queueFormProvider.notifier)
        .updateDetailsInfo(
          purpose: _purposeController.text.trim().isEmpty
              ? null
              : _purposeController.text.trim(),
          items: List<ServiceItem>.from(_items),
        );

    // Navigate to confirmation page
    context.push('/confirmation');
  }
}
