import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/models/api_models.dart';
import 'package:ez_queue/services/api_service.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/widgets/ez_input_field.dart';
import 'package:ez_queue/utils/theme_helpers.dart';
import 'package:go_router/go_router.dart';

class DynamicFieldsPage extends ConsumerStatefulWidget {
  final List<ApiQueueService> services;

  const DynamicFieldsPage({Key? key, required this.services}) : super(key: key);

  @override
  ConsumerState<DynamicFieldsPage> createState() => _DynamicFieldsPageState();
}

class _DynamicFieldsPageState extends ConsumerState<DynamicFieldsPage> {
  bool _isLoading = true;
  List<ApiAcademicYear> _academics = [];
  List<ApiSubject> _subjects = [];
  final Map<int, Map<String, dynamic>> _formData = {};
  
  // Controllers
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _loadOptions();
    
    final existingData = ref.read(queueFormProvider).customFields;
    if (existingData.isNotEmpty) {
      existingData.forEach((serviceId, fields) {
        _formData[serviceId] = Map.from(fields);
      });
    }
  }

  @override
  void dispose() {
    _controllers.values.forEach((c) => c.dispose());
    super.dispose();
  }

  Future<void> _loadOptions() async {
    bool needsAcademics = false;
    bool needsSubjects = false;

    for (final service in widget.services) {
      for (final field in service.fields) {
        if (field.fieldType == 'academic_year') needsAcademics = true;
        if (field.fieldType == 'subject') needsSubjects = true;
      }
    }

    try {
      if (needsAcademics) {
        _academics = await apiService.getAcademics();
      }
      if (needsSubjects) {
        _subjects = await apiService.getSubjects();
      }
    } catch (e) {
      debugPrint('Failed to load dynamic options: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleFieldChange(int serviceId, String fieldName, dynamic value) {
    setState(() {
      _formData.putIfAbsent(serviceId, () => {});
      _formData[serviceId]![fieldName] = value;
    });
  }

  bool _validateForm() {
    for (final service in widget.services) {
      for (final field in service.fields) {
        if (field.isRequired) {
          final value = _formData[service.id]?[field.fieldName];
          if (value == null || value.toString().trim().isEmpty) {
            return false;
          }
        }
      }
    }
    return true;
  }

  void _proceed() {
    if (!_validateForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill out all required fields.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    ref.read(queueFormProvider.notifier).updateCustomFields(_formData);

    final hasDocs = widget.services.any((s) => s.documents.isNotEmpty);
    if (hasDocs) {
      context.push('/confirmation');
    } else {
      context.push('/details-information');
    }
  }

  TextEditingController _getController(int serviceId, String fieldName, String initialValue) {
    final key = '${serviceId}_$fieldName';
    if (!_controllers.containsKey(key)) {
      _controllers[key] = TextEditingController(text: initialValue);
    }
    return _controllers[key]!;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final servicesWithFields = widget.services.where((s) => s.fields.isNotEmpty).toList();

    return Scaffold(
      body: Column(
        children: [
          const TopNavBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(EZSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: EZSpacing.xl),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
                                'Additional Information',
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: EZSpacing.xs),
                              Text(
                                'Please provide required details for your service.',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  ...servicesWithFields.map((service) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: EZSpacing.lg),
                      child: EZCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (servicesWithFields.length > 1)
                              Padding(
                                padding: const EdgeInsets.only(bottom: EZSpacing.md),
                                child: Text(
                                  service.name,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                            
                            ...service.fields.map((field) {
                              final value = _formData[service.id]?[field.fieldName]?.toString() ?? '';
                              
                              Widget inputWidget;

                              if (field.fieldType == 'select' || field.fieldType == 'radio') {
                                inputWidget = DropdownButtonFormField<String>(
                                  decoration: ThemeHelpers.textInputDecoration(
                                    labelText: field.fieldLabel,
                                  ),
                                  value: value.isEmpty ? null : value,
                                  items: field.options.map((opt) {
                                    return DropdownMenuItem(
                                      value: opt,
                                      child: Text(opt),
                                    );
                                  }).toList(),
                                  onChanged: (val) => _handleFieldChange(service.id, field.fieldName, val),
                                );
                              } else if (field.fieldType == 'academic_year') {
                                final gracePeriodStr = field.validation['lapse_grace_period']?.toString();
                                
                                bool _isWithinGracePeriod(String? endDateStr, String? gpStr) {
                                  if (gpStr == null || gpStr.isEmpty) return true;
                                  if (endDateStr == null || endDateStr.isEmpty) return true;
                                  
                                  final end = DateTime.tryParse(endDateStr);
                                  if (end == null) return true;
                                  
                                  final now = DateTime.now();
                                  int years = 0;
                                  int months = 0;
                                  
                                  final yMatch = RegExp(r'(\d+)\s*y', caseSensitive: false).firstMatch(gpStr);
                                  final mMatch = RegExp(r'(\d+)\s*m', caseSensitive: false).firstMatch(gpStr);
                                  
                                  if (yMatch != null) years = int.tryParse(yMatch.group(1) ?? '0') ?? 0;
                                  if (mMatch != null) months = int.tryParse(mMatch.group(1) ?? '0') ?? 0;
                                  
                                  final cutoff = DateTime(now.year - years, now.month - months, now.day);
                                  return end.isAfter(cutoff) || end.isAtSameMomentAs(cutoff);
                                }
                                
                                final filteredAcademics = _academics.where((acad) => _isWithinGracePeriod(acad.endDate, gracePeriodStr)).toList();

                                inputWidget = DropdownButtonFormField<String>(
                                  decoration: ThemeHelpers.textInputDecoration(
                                    labelText: field.fieldLabel,
                                  ),
                                  value: value.isEmpty ? null : value,
                                  items: filteredAcademics.map((ay) {
                                    final termYear = '${ay.semester} - ${ay.name}';
                                    return DropdownMenuItem(
                                      value: termYear,
                                      child: Text(termYear),
                                    );
                                  }).toList(),
                                  onChanged: (val) => _handleFieldChange(service.id, field.fieldName, val),
                                );
                              } else if (field.fieldType == 'subject') {
                                final userCourseId = ref.read(queueFormProvider).courseId;
                                final filteredSubjects = _subjects.where((s) => s.courseId == null || s.courseId == userCourseId).toList();
                                
                                inputWidget = DropdownButtonFormField<String>(
                                  decoration: ThemeHelpers.textInputDecoration(
                                    labelText: field.fieldLabel,
                                  ),
                                  value: value.isEmpty ? null : value,
                                  items: filteredSubjects.map((subj) {
                                    return DropdownMenuItem(
                                      value: subj.code,
                                      child: Text('${subj.code} - ${subj.name}'),
                                    );
                                  }).toList(),
                                  onChanged: (val) => _handleFieldChange(service.id, field.fieldName, val),
                                );
                              } else {
                                TextInputType kbdType = TextInputType.text;
                                if (field.fieldType == 'number') kbdType = TextInputType.number;
                                if (field.fieldType == 'email') kbdType = TextInputType.emailAddress;
                                
                                final controller = _getController(service.id, field.fieldName, value);
                                
                                inputWidget = TextField(
                                  controller: controller,
                                  keyboardType: kbdType,
                                  decoration: ThemeHelpers.textInputDecoration(
                                    labelText: field.fieldLabel,
                                  ),
                                  onChanged: (val) => _handleFieldChange(service.id, field.fieldName, val),
                                );
                              }

                              return Padding(
                                padding: const EdgeInsets.only(bottom: EZSpacing.md),
                                child: EZInputField(
                                  child: inputWidget,
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(EZSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: EZButton(
                      isSecondary: true,
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: EZSpacing.md),
                  Expanded(
                    flex: 2,
                    child: EZButton(
                      onPressed: _proceed,
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
