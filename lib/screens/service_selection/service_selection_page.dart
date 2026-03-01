import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/models/queue_form_data.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:go_router/go_router.dart';

/// Service selection page.
/// Allows users to select services, specify purpose, and add items/quantities.
class ServiceSelectionPage extends ConsumerStatefulWidget {
  const ServiceSelectionPage({super.key});

  @override
  ConsumerState<ServiceSelectionPage> createState() =>
      _ServiceSelectionPageState();
}

class _ServiceSelectionPageState extends ConsumerState<ServiceSelectionPage> {
  final Set<String> _selectedServices = <String>{};
  final TextEditingController _purposeController = TextEditingController();
  final List<ServiceItem> _items = [];
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();

  /// Sample department-services data.
  static const Map<String, List<String>> _departmentServices = {
    'Registrar': [
      'General Inquiry',
      'Complaint Resolution',
      'Account Assistance',
      'Student Information',
    ],
    'Library': ['Book Request', 'Book Return', 'Book Renewal'],
    'Office of the Student Affairs': [
      'Student Complaint',
      'Student Request',
      'Student Information',
    ],
    'Cashier': ['Payment', 'Payment Inquiry', 'Payment Refund'],
  };

  @override
  void dispose() {
    _purposeController.dispose();
    _itemNameController.dispose();
    _itemQuantityController.dispose();
    super.dispose();
  }

  List<String> _getAvailableServices(String? department) {
    if (department == null) return [];
    return _departmentServices[department] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final formData = ref.watch(queueFormProvider);
    final department = formData.department;
    final availableServices = _getAvailableServices(department);
    final brightness = ref.watch(brightnessProvider);
    final isDark = brightness == Brightness.dark;

    // Load saved data on first build
    if (formData.services.isNotEmpty && _selectedServices.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedServices.addAll(formData.services);
            if (formData.purpose != null) {
              _purposeController.text = formData.purpose!;
            }
            _items.addAll(formData.items);
          });
        }
      });
    }

    return Scaffold(
      body: Column(
        children: [
          // Top navigation bar
          const TopNavBar(),

          // Main content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Text(
                    'Select Services',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  if (department != null) ...[
                    const SizedBox(height: EZSpacing.xs),
                    Text(
                      'Department: $department',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: EZSpacing.xl),

                  // Service selection
                  Text(
                    'Select the Service/s you want to avail',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  _buildServiceSelector(availableServices),

                  const SizedBox(height: EZSpacing.xxl),

                  // Purpose input
                  Text(
                    'Purpose',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: EZSpacing.md),
                  TextField(
                    controller: _purposeController,
                    decoration: InputDecoration(
                      hintText:
                          'Describe the purpose for availing the service/s',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(EZSpacing.radiusMd),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
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

                  if (_selectedServices.isNotEmpty) ...[
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build service checkboxes.
  Widget _buildServiceSelector(List<String> availableServices) {
    if (availableServices.isEmpty) {
      return Text(
        'No services available for this department.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      );
    }

    return Column(
      children: availableServices.map((service) {
        final isSelected = _selectedServices.contains(service);
        return Card(
          margin: const EdgeInsets.only(bottom: EZSpacing.sm),
          color: isSelected
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1)
              : null,
          child: CheckboxListTile(
            title: Text(service),
            value: isSelected,
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  _selectedServices.add(service);
                } else {
                  _selectedServices.remove(service);
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
        );
      }).toList(),
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
          return Card(
            margin: const EdgeInsets.only(bottom: EZSpacing.sm),
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
          );
        }),

        // Add new item row
        Card(
          child: Padding(
            padding: const EdgeInsets.all(EZSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item name
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _itemNameController,
                    decoration: InputDecoration(
                      hintText: 'Item name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(EZSpacing.radiusSm),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: EZSpacing.md,
                        vertical: EZSpacing.sm,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: EZSpacing.sm),
                // Quantity
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _itemQuantityController,
                    decoration: InputDecoration(
                      hintText: 'Qty',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(EZSpacing.radiusSm),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: EZSpacing.md,
                        vertical: EZSpacing.sm,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
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
    if (_selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one service.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // Save service details to state
    ref
        .read(queueFormProvider.notifier)
        .updateServiceDetails(
          services: _selectedServices.toList(),
          purpose: _purposeController.text.trim().isEmpty
              ? null
              : _purposeController.text.trim(),
          items: List<ServiceItem>.from(_items),
        );

    // Navigate to user type selection page
    context.push('/user-type-selection');
  }
}
