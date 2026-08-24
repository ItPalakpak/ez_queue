import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/models/api_models.dart';
import 'package:ez_queue/providers/queue_form_provider.dart';
import 'package:ez_queue/screens/confirmation/confirmation_page.dart';
import 'package:http/http.dart' as http;
import 'package:ez_queue/utils/api_config.dart';
import 'dart:convert';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/widgets/ez_input_field.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/utils/theme_helpers.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:go_router/go_router.dart';

class DocumentSelectionPage extends ConsumerStatefulWidget {
  final List<ApiQueueService> services;

  const DocumentSelectionPage({super.key, required this.services});

  @override
  ConsumerState<DocumentSelectionPage> createState() =>
      _DocumentSelectionPageState();
}

class _DocumentSelectionPageState extends ConsumerState<DocumentSelectionPage> {
  bool _isLoading = true;
  List<ApiAcademicYear> _academics = [];

  // Form State
  Map<String, dynamic> _extraDetails = {
    'is_authorized_person': false,
    'has_authorization_letter': false,
    'has_owner_id_photocopy': false,
    'has_authorized_person_id': false,
    'date_of_graduation': null,
    'last_semester_attended': null,
    'last_sy_attended': null,
    'already_requested_before': false,
    'previous_request_details': null,
    'previous_request_date': null,
    'is_cleared': false,
  };

  List<Map<String, dynamic>> _selections = [];
  List<Map<String, dynamic>> _previousSelections = [];

  // CHANGED: Mutually exclusive single-open accordion state
  String? _openSection = 'reminder';

  void _toggleSection(String section) {
    setState(() {
      _openSection = _openSection == section ? null : section;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAcademics();

    // Load initial from provider if exists
    final formData = ref.read(queueFormProvider);
    final userType = formData.userType;

    if (formData.selections.isNotEmpty) {
      _selections = List.from(formData.selections);
    }
    if (formData.extraDetails.isNotEmpty) {
      _extraDetails = Map.from(formData.extraDetails);
      if (_extraDetails['previous_selections'] != null) {
        final List<dynamic> ps = _extraDetails['previous_selections'];
        _previousSelections = List<Map<String, dynamic>>.from(
          ps.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
    }

    // CHANGED: Automatically clear restricted fields based on client role
    if (userType == 'alumni' || userType == 'faculty') {
      _extraDetails['last_semester_attended'] = null;
      _extraDetails['last_sy_attended'] = null;
    } else if (userType == 'student') {
      _extraDetails['date_of_graduation'] = null;
    }
  }

  Future<void> _loadAcademics() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/kiosk/academics'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> academicsJson = data['data'];
          setState(() {
            _academics = academicsJson
                .map((e) => ApiAcademicYear.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        }
      }
    } catch (_) {} finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleExtraChange(String field, dynamic value) {
    setState(() {
      _extraDetails[field] = value;
      if (field == 'date_of_graduation' && value != null && value.toString().isNotEmpty) {
        _extraDetails['last_semester_attended'] = null;
        _extraDetails['last_sy_attended'] = null;
      } else if ((field == 'last_semester_attended' || field == 'last_sy_attended') &&
          value != null &&
          value.toString().isNotEmpty) {
        _extraDetails['date_of_graduation'] = null;
      }
    });
  }

  Future<void> _selectDate(BuildContext context, String key) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _handleExtraChange(key, formattedDate);
    }
  }

  // CHANGED: Specific purpose resolution per level (only show purposes explicitly configured on the document or subselection)
  List<_PurposeOption> _resolvePurposesFor(ApiServiceDocument doc, [int? subId]) {
    // 1. Subselection-level purposes
    if (subId != null) {
      final sub = doc.subselections.where((s) => s.id == subId).firstOrNull;
      if (sub != null && sub.purposes.isNotEmpty) {
        final list = <_PurposeOption>[];
        for (var p in sub.purposes) {
          final name = p is Map ? (p['name']?.toString() ?? '') : p.toString();
          final isActive = p is Map ? (p['is_active'] != false) : true;
          if (isActive && name.isNotEmpty) {
            list.add(_PurposeOption(
              id: p is Map && p['id'] != null ? p['id'] : name,
              name: name,
              level: 'subselection',
              context: '${doc.name} - ${sub.name}',
            ));
          }
        }
        return list;
      }
      return [];
    }

    // 2. Document-level purposes
    if (doc.purposes.isNotEmpty) {
      final list = <_PurposeOption>[];
      for (var p in doc.purposes) {
        final name = p is Map ? (p['name']?.toString() ?? '') : p.toString();
        final isActive = p is Map ? (p['is_active'] != false) : true;
        if (isActive && name.isNotEmpty) {
          list.add(_PurposeOption(
            id: p is Map && p['id'] != null ? p['id'] : name,
            name: name,
            level: 'document',
            context: doc.name,
          ));
        }
      }
      return list;
    }

    return [];
  }

  void _handleDocumentToggle(ApiServiceDocument doc) {
    setState(() {
      final exists = _selections.any((s) => s['service_document_id'] == doc.id);
      if (exists) {
        _selections.removeWhere((s) => s['service_document_id'] == doc.id);
      } else {
        _selections.add({
          'service_document_id': doc.id,
          'document_name': doc.name,
          'document_subselection_id': null,
          'subselection_name': null,
          'academic_year_id': null,
          'academic_year_name': null,
          'semester': null,
          'purposes': <dynamic>[],
          'custom_purpose': '',
        });
      }
    });
  }

  final bool _allowMultipleSubselections = true;

  void _handleSubselectionToggle(
    int docId,
    int subId,
    String subName,
    bool requiresPeriod,
    bool checked,
  ) {
    setState(() {
      if (checked || !_allowMultipleSubselections) {
        if (!_allowMultipleSubselections) {
          _selections.removeWhere((s) => s['service_document_id'] == docId);
        } else {
          _selections.removeWhere(
            (s) =>
                s['service_document_id'] == docId &&
                s['document_subselection_id'] == null,
          );
        }

        final doc = widget.services
            .expand((s) => s.documents)
            .firstWhere((d) => d.id == docId);
        _selections.add({
          'service_document_id': docId,
          'document_name': doc.name,
          'document_subselection_id': subId,
          'subselection_name': subName,
          'academic_year_id': null,
          'academic_year_name': null,
          'semester': null,
          'purposes': <dynamic>[],
          'custom_purpose': '',
        });
      } else {
        _selections.removeWhere(
          (s) =>
              s['service_document_id'] == docId &&
              s['document_subselection_id'] == subId,
        );
        final hasOtherSubselections = _selections.any(
          (s) => s['service_document_id'] == docId,
        );
        if (!hasOtherSubselections) {
          final doc = widget.services
              .expand((s) => s.documents)
              .firstWhere((d) => d.id == docId);
          _selections.add({
            'service_document_id': docId,
            'document_name': doc.name,
            'document_subselection_id': null,
            'subselection_name': null,
            'academic_year_id': null,
            'academic_year_name': null,
            'semester': null,
            'purposes': <dynamic>[],
            'custom_purpose': '',
          });
        }
      }
    });
  }

  void _handleDocPurposeToggle(int docId, int? subId, String purposeName, bool isChecked) {
    setState(() {
      final index = _selections.indexWhere(
        (s) =>
            s['service_document_id'] == docId &&
            (subId != null
                ? s['document_subselection_id'] == subId
                : (s['document_subselection_id'] == null || subId == null)),
      );
      if (index != -1) {
        final curPurposes = List<dynamic>.from(_selections[index]['purposes'] ?? []);
        if (isChecked) {
          if (!curPurposes.contains(purposeName)) {
            curPurposes.add(purposeName);
          }
        } else {
          curPurposes.remove(purposeName);
        }
        _selections[index]['purposes'] = curPurposes;
      }
    });
  }

  void _handleDocCustomPurposeChange(int docId, int? subId, String value) {
    setState(() {
      final index = _selections.indexWhere(
        (s) =>
            s['service_document_id'] == docId &&
            (subId != null
                ? s['document_subselection_id'] == subId
                : (s['document_subselection_id'] == null || subId == null)),
      );
      if (index != -1) {
        _selections[index]['custom_purpose'] = value;
      }
    });
  }

  void _handlePreviousDocumentToggle(ApiServiceDocument doc) {
    setState(() {
      final exists = _previousSelections.any(
        (s) => s['service_document_id'] == doc.id,
      );
      if (exists) {
        _previousSelections.removeWhere(
          (s) => s['service_document_id'] == doc.id,
        );
      } else {
        _previousSelections.add({
          'service_document_id': doc.id,
          'document_name': doc.name,
          'document_subselection_id': null,
          'subselection_name': null,
        });
      }
    });
  }

  void _handlePreviousSubselectionToggle(
    int docId,
    int subId,
    String subName,
    bool checked,
  ) {
    setState(() {
      if (checked || !_allowMultipleSubselections) {
        if (!_allowMultipleSubselections) {
          _previousSelections.removeWhere(
            (s) => s['service_document_id'] == docId,
          );
        } else {
          _previousSelections.removeWhere(
            (s) =>
                s['service_document_id'] == docId &&
                s['document_subselection_id'] == null,
          );
        }

        final doc = widget.services
            .expand((s) => s.documents)
            .firstWhere((d) => d.id == docId);
        _previousSelections.add({
          'service_document_id': docId,
          'document_name': doc.name,
          'document_subselection_id': subId,
          'subselection_name': subName,
        });
      } else {
        _previousSelections.removeWhere(
          (s) =>
              s['service_document_id'] == docId &&
              s['document_subselection_id'] == subId,
        );
        final hasOtherSubselections = _previousSelections.any(
          (s) => s['service_document_id'] == docId,
        );
        if (!hasOtherSubselections) {
          final doc = widget.services
              .expand((s) => s.documents)
              .firstWhere((d) => d.id == docId);
          _previousSelections.add({
            'service_document_id': docId,
            'document_name': doc.name,
            'document_subselection_id': null,
            'subselection_name': null,
          });
        }
      }
    });
  }

  void _handlePeriodChange(int docId, int subId, String field, dynamic value) {
    setState(() {
      final index = _selections.indexWhere(
        (s) =>
            s['service_document_id'] == docId &&
            s['document_subselection_id'] == subId,
      );
      if (index != -1) {
        _selections[index][field] = value;
        if (field == 'academic_year_id') {
          final ay = _academics.firstWhere(
            (a) => a.id == value,
            orElse: () => ApiAcademicYear(id: value, name: '', semester: ''),
          );
          _selections[index]['academic_year_name'] = ay.name.isNotEmpty
              ? ay.name
              : null;
        }
      }
    });
  }

  void _proceed() {
    final allSelectedPurposes = <dynamic>[];
    final allSelectedPurposesDisplay = <String>[];
    final docPurposesMap = <String, List<String>>{};

    final updatedSelections = _selections.map((s) {
      final copy = Map<String, dynamic>.from(s);
      final itemPurps = List<dynamic>.from(copy['purposes'] ?? []);
      final customPurp = (copy['custom_purpose'] ?? '').toString().trim();
      if (customPurp.isNotEmpty && !itemPurps.contains(customPurp)) {
        itemPurps.add(customPurp);
      }
      final docName = (copy['document_name'] ?? 'Document').toString();

      if (itemPurps.isNotEmpty) {
        if (!docPurposesMap.containsKey(docName)) {
          docPurposesMap[docName] = [];
        }
        for (var p in itemPurps) {
          final pStr = p.toString();
          if (!docPurposesMap[docName]!.contains(pStr)) {
            docPurposesMap[docName]!.add(pStr);
          }
          if (!allSelectedPurposes.contains(p)) {
            allSelectedPurposes.add(p);
          }
          if (!allSelectedPurposesDisplay.contains(pStr)) {
            allSelectedPurposesDisplay.add(pStr);
          }
        }
      }
      copy['purposes'] = itemPurps.map((e) => e.toString()).toList();
      return copy;
    }).toList();

    final prevDetailsStr = _previousSelections
        .map((s) {
          if (s['subselection_name'] != null) {
            return '${s['document_name']} - ${s['subselection_name']}';
          }
          return s['document_name'];
        })
        .join(', ');

    final updatedExtraDetails = Map<String, dynamic>.from(_extraDetails);
    final userType = ref.read(queueFormProvider).userType;
    if (userType == 'alumni' || userType == 'faculty') {
      updatedExtraDetails['last_semester_attended'] = null;
      updatedExtraDetails['last_sy_attended'] = null;
    } else if (userType == 'student') {
      updatedExtraDetails['date_of_graduation'] = null;
    }

    updatedExtraDetails['purposes'] = allSelectedPurposes;
    updatedExtraDetails['purposes_display'] = allSelectedPurposesDisplay;
    updatedExtraDetails['document_purposes'] = docPurposesMap;
    updatedExtraDetails['previous_request_details'] = prevDetailsStr;
    updatedExtraDetails['previous_selections'] = _previousSelections;

    ref
        .read(queueFormProvider.notifier)
        .updateDocumentSelections(
          selections: updatedSelections,
          extraDetails: updatedExtraDetails,
        );

    final hasFields = widget.services.any((s) => s.fields.isNotEmpty);
    if (hasFields) {
      context.push('/dynamic-fields', extra: widget.services);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ConfirmationPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Deduplicate documents
    final uniqueDocsMap = <int, ApiServiceDocument>{};
    for (var service in widget.services) {
      for (var doc in service.documents) {
        uniqueDocsMap[doc.id] = doc;
      }
    }
    final uniqueDocs = uniqueDocsMap.values.toList();

    return Scaffold(
      body: Column(
        children: [
          const TopNavBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await _loadAcademics();
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(EZSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildReminderSection(),
                    const SizedBox(height: EZSpacing.lg),
                    _buildPart1Section(uniqueDocs),
                    const SizedBox(height: EZSpacing.lg),
                    _buildPart2Section(uniqueDocs),
                  ],
                ),
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
                      onPressed: _selections.isNotEmpty ? _proceed : null,
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

  Widget _buildAccordionCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return EZCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 14.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReminderSection() {
    return _buildAccordionCard(
      title: 'Reminder',
      isExpanded: _openSection == 'reminder',
      onToggle: () => _toggleSection('reminder'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RadioGroup<bool>(
            groupValue: _extraDetails['is_authorized_person'],
            onChanged: (val) => _handleExtraChange('is_authorized_person', val),
            child: Column(
              children: [
                RadioListTile<bool>(
                  title: const Text(
                    'A. If requested by the person himself/herself named in the document, a valid Identification (ID) card must be presented.',
                  ),
                  value: false,
                ),
                RadioListTile<bool>(
                  title: const Text(
                    'B. If requested by an authorized person, the following items must be presented:',
                  ),
                  value: true,
                ),
              ],
            ),
          ),
          if (_extraDetails['is_authorized_person'] == true) ...[
            Padding(
              padding: const EdgeInsets.only(left: 32),
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('Authorization letter'),
                    value: _extraDetails['has_authorization_letter'],
                    onChanged: (val) =>
                        _handleExtraChange('has_authorization_letter', val),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Photocopy of valid ID of the authorizing person',
                    ),
                    value: _extraDetails['has_owner_id_photocopy'],
                    onChanged: (val) =>
                        _handleExtraChange('has_owner_id_photocopy', val),
                  ),
                  CheckboxListTile(
                    title: const Text(
                      'Photocopy of valid ID of the authorized person',
                    ),
                    value: _extraDetails['has_authorized_person_id'],
                    onChanged: (val) =>
                        _handleExtraChange('has_authorized_person_id', val),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPart1Section(List<ApiServiceDocument> uniqueDocs) {
    final userType = ref.watch(queueFormProvider).userType;
    final bool isAlumniOrFaculty = userType == 'alumni' || userType == 'faculty';
    final bool isStudent = userType == 'student';

    final showGraduation = isAlumniOrFaculty
        ? true
        : isStudent
            ? false
            : ((_extraDetails['last_semester_attended'] == null ||
                    _extraDetails['last_semester_attended'].toString().isEmpty) &&
                (_extraDetails['last_sy_attended'] == null ||
                    _extraDetails['last_sy_attended'].toString().isEmpty));

    final showSemesterAndSy = isStudent
        ? true
        : isAlumniOrFaculty
            ? false
            : (_extraDetails['date_of_graduation'] == null ||
                _extraDetails['date_of_graduation'].toString().isEmpty);

    return _buildAccordionCard(
      title: 'Part 1: Complete entries below',
      isExpanded: _openSection == 'part1',
      onToggle: () => _toggleSection('part1'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showGraduation) ...[
            EZInputField(
              child: TextField(
                readOnly: true,
                onTap: () => _selectDate(context, 'date_of_graduation'),
                decoration: ThemeHelpers.textInputDecoration(
                  labelText: 'If a graduate, Date of Graduation',
                ).copyWith(
                  suffixIcon: _extraDetails['date_of_graduation'] != null &&
                          _extraDetails['date_of_graduation']
                              .toString()
                              .isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () =>
                              _handleExtraChange('date_of_graduation', null),
                        )
                      : const Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: _extraDetails['date_of_graduation']?.toString() ?? '',
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (showSemesterAndSy) ...[
            const Text('If a student, state the Last Semester & SY of Attendance:'),
            const SizedBox(height: 8),
            EZInputField(
              child: DropdownButtonFormField<String>(
                decoration: ThemeHelpers.textInputDecoration(
                  labelText: 'Semester',
                ),
                initialValue: _extraDetails['last_semester_attended'],
                items: const [
                  DropdownMenuItem(
                    value: '1st Semester',
                    child: Text('1st Semester'),
                  ),
                  DropdownMenuItem(
                    value: '2nd Semester',
                    child: Text('2nd Semester'),
                  ),
                  DropdownMenuItem(value: 'Summer', child: Text('Summer')),
                ],
                onChanged: (val) =>
                    _handleExtraChange('last_semester_attended', val),
              ),
            ),
            const SizedBox(height: 16),
            EZInputField(
              child: DropdownButtonFormField<String>(
                decoration: ThemeHelpers.textInputDecoration(
                  labelText: 'School Year/Academic Year',
                ),
                initialValue: _extraDetails['last_sy_attended'],
                items: _academics.map((ay) {
                  return DropdownMenuItem(value: ay.name, child: Text(ay.name));
                }).toList(),
                onChanged: (val) => _handleExtraChange('last_sy_attended', val),
              ),
            ),
            const SizedBox(height: 16),
            if ((_extraDetails['last_semester_attended'] != null &&
                    _extraDetails['last_semester_attended']
                        .toString()
                        .isNotEmpty) ||
                (_extraDetails['last_sy_attended'] != null &&
                    _extraDetails['last_sy_attended']
                        .toString()
                        .isNotEmpty)) ...[
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    _handleExtraChange('last_semester_attended', null);
                    _handleExtraChange('last_sy_attended', null);
                  },
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text('Clear Semester & SY'),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
          const SizedBox(height: 16),
          const Text('Already requested credential/s before?'),
          RadioGroup<bool>(
            groupValue: _extraDetails['already_requested_before'],
            onChanged: (val) =>
                _handleExtraChange('already_requested_before', val),
            child: Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('YES'),
                    value: true,
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('NO'),
                    value: false,
                  ),
                ),
              ],
            ),
          ),
          if (_extraDetails['already_requested_before'] == true) ...[
            const SizedBox(height: 8),
            const Text(
              'If yes, please specify the document(s):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...uniqueDocs.map((doc) {
              final docSelections = _previousSelections
                  .where((s) => s['service_document_id'] == doc.id)
                  .toList();
              final isSelected = docSelections.isNotEmpty;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CheckboxListTile(
                    title: Text(
                      doc.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    value: isSelected,
                    onChanged: (val) => _handlePreviousDocumentToggle(doc),
                  ),
                  if (isSelected && doc.subselections.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8, left: 16),
                      child: _allowMultipleSubselections
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: doc.subselections.map((sub) {
                                final subSelectionIndex = docSelections.indexWhere(
                                  (s) => s['document_subselection_id'] == sub.id,
                                );
                                final isSubSelected = subSelectionIndex != -1;
                                return CheckboxListTile(
                                  title: Text(sub.name),
                                  value: isSubSelected,
                                  onChanged: (val) =>
                                      _handlePreviousSubselectionToggle(
                                        doc.id,
                                        sub.id,
                                        sub.name,
                                        val ?? false,
                                      ),
                                );
                              }).toList(),
                            )
                          : RadioGroup<int>(
                              groupValue: docSelections.isNotEmpty
                                  ? docSelections.first['document_subselection_id']
                                  : null,
                              onChanged: (val) {
                                if (val != null) {
                                  final selectedSub = doc.subselections.firstWhere(
                                    (s) => s.id == val,
                                  );
                                  _handlePreviousSubselectionToggle(
                                    doc.id,
                                    val,
                                    selectedSub.name,
                                    true,
                                  );
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: doc.subselections.map((sub) {
                                  return RadioListTile<int>(
                                    title: Text(sub.name),
                                    value: sub.id,
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 8),
            EZInputField(
              child: TextField(
                readOnly: true,
                onTap: () => _selectDate(context, 'previous_request_date'),
                decoration: ThemeHelpers.textInputDecoration(
                  labelText: 'Date requested',
                ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
                controller: TextEditingController(
                  text:
                      _extraDetails['previous_request_date']?.toString() ?? '',
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text('Cleared?'),
          RadioGroup<bool>(
            groupValue: _extraDetails['is_cleared'],
            onChanged: (val) => _handleExtraChange('is_cleared', val),
            child: Column(
              children: [
                RadioListTile<bool>(
                  title: const Text('Yes. (Attach clearance form)'),
                  value: true,
                ),
                RadioListTile<bool>(
                  title: const Text('No. (Avail clearance form first)'),
                  value: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CHANGED: Document & Subselection contextual purposes widget (only shown when purposes are configured)
  Widget _buildDocumentPurposesView({
    required ApiServiceDocument doc,
    int? subId,
    String? subName,
    required Map<String, dynamic>? selectionItem,
  }) {
    final purposes = _resolvePurposesFor(doc, subId);
    if (purposes.isEmpty) return const SizedBox.shrink();

    final curPurposes = List<dynamic>.from(selectionItem?['purposes'] ?? []);
    final curCustom = (selectionItem?['custom_purpose'] ?? '').toString();
    final isCustomChecked = curCustom.isNotEmpty;

    final theme = Theme.of(context);
    final title = subName != null ? 'Purpose(s) for $subName:' : 'Purpose(s) for ${doc.name}:';

    return Padding(
      padding: EdgeInsets.only(
        left: 32,
        right: subName != null ? 0 : 16,
        bottom: subName != null ? 8 : 16,
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 8, bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            ...purposes.map((purpose) {
              final isChecked = curPurposes.contains(purpose.name) || curPurposes.contains(purpose.id);
              return CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Row(
                  children: [
                    Expanded(child: Text(purpose.name, style: const TextStyle(fontSize: 14))),
                    if (purpose.level != 'service')
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          purpose.level == 'subselection' ? 'Sub-option' : 'Doc',
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
                value: isChecked,
                onChanged: (val) => _handleDocPurposeToggle(doc.id, subId, purpose.name, val ?? false),
                controlAffinity: ListTileControlAffinity.leading,
              );
            }),
            CheckboxListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: const Text('Others (Specify)', style: TextStyle(fontSize: 14)),
              value: isCustomChecked,
              onChanged: (val) {
                _handleDocCustomPurposeChange(
                  doc.id,
                  subId,
                  (val ?? false) ? (curCustom.isNotEmpty ? curCustom : ' ') : '',
                );
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            if (isCustomChecked)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: EZInputField(
                  child: TextField(
                    decoration: ThemeHelpers.textInputDecoration(
                      labelText: 'Specify other purpose',
                    ),
                    controller: TextEditingController.fromValue(
                      TextEditingValue(
                        text: curCustom.trim(),
                        selection: TextSelection.collapsed(
                          offset: curCustom.trim().length,
                        ),
                      ),
                    ),
                    onChanged: (val) => _handleDocCustomPurposeChange(doc.id, subId, val),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPart2Section(List<ApiServiceDocument> uniqueDocs) {
    return _buildAccordionCard(
      title: 'Part 2: Check document/s you need',
      isExpanded: _openSection == 'part2',
      onToggle: () => _toggleSection('part2'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...uniqueDocs.map((doc) {
            final docSelections = _selections
                .where((s) => s['service_document_id'] == doc.id)
                .toList();
            final isSelected = docSelections.isNotEmpty;
            final hasSubselections = doc.subselections.isNotEmpty;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  title: Text(
                    doc.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: isSelected,
                  onChanged: (val) => _handleDocumentToggle(doc),
                ),

                // Subselections
                if (isSelected && hasSubselections)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16, left: 16),
                    child: _allowMultipleSubselections
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: doc.subselections.map((sub) {
                              final subSelectionIndex = docSelections.indexWhere(
                                (s) => s['document_subselection_id'] == sub.id,
                              );
                              final isSubSelected = subSelectionIndex != -1;
                              final subSelection = isSubSelected
                                  ? docSelections[subSelectionIndex]
                                  : null;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CheckboxListTile(
                                    title: Text(sub.name),
                                    value: isSubSelected,
                                    onChanged: (val) =>
                                        _handleSubselectionToggle(
                                          doc.id,
                                          sub.id,
                                          sub.name,
                                          sub.requiresAcademicPeriod,
                                          val ?? false,
                                        ),
                                  ),
                                  if (isSubSelected &&
                                      sub.requiresAcademicPeriod)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 32),
                                      child: Column(
                                        children: [
                                          EZInputField(
                                            child: DropdownButtonFormField<int>(
                                              decoration:
                                                  ThemeHelpers.textInputDecoration(
                                                    labelText: 'Academic Year',
                                                  ),
                                              initialValue:
                                                  subSelection!['academic_year_id'],
                                              items: _academics.map((ay) {
                                                return DropdownMenuItem(
                                                  value: ay.id,
                                                  child: Text(ay.name),
                                                );
                                              }).toList(),
                                              onChanged: (val) =>
                                                  _handlePeriodChange(
                                                    doc.id,
                                                    sub.id,
                                                    'academic_year_id',
                                                    val,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          EZInputField(
                                            child: DropdownButtonFormField<String>(
                                              decoration:
                                                  ThemeHelpers.textInputDecoration(
                                                    labelText: 'Semester',
                                                  ),
                                              initialValue:
                                                  subSelection['semester'],
                                              items: const [
                                                DropdownMenuItem(
                                                  value: '1st Semester',
                                                  child: Text('1st Semester'),
                                                ),
                                                DropdownMenuItem(
                                                  value: '2nd Semester',
                                                  child: Text('2nd Semester'),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Summer',
                                                  child: Text('Summer'),
                                                ),
                                              ],
                                              onChanged: (val) =>
                                                  _handlePeriodChange(
                                                    doc.id,
                                                    sub.id,
                                                    'semester',
                                                    val,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                  // Subselection-level Contextual Purposes (only shown if configured)
                                  if (isSubSelected)
                                    _buildDocumentPurposesView(
                                      doc: doc,
                                      subId: sub.id,
                                      subName: sub.name,
                                      selectionItem: subSelection,
                                    ),
                                ],
                              );
                            }).toList(),
                          )
                        : RadioGroup<int>(
                            groupValue: docSelections.isNotEmpty
                                ? docSelections.first['document_subselection_id']
                                : null,
                            onChanged: (val) {
                              if (val != null) {
                                final selectedSub = doc.subselections.firstWhere(
                                  (s) => s.id == val,
                                );
                                _handleSubselectionToggle(
                                  doc.id,
                                  val,
                                  selectedSub.name,
                                  selectedSub.requiresAcademicPeriod,
                                  true,
                                );
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: doc.subselections.map((sub) {
                                final subSelectionIndex = docSelections.indexWhere(
                                  (s) => s['document_subselection_id'] == sub.id,
                                );
                                final isSubSelected = subSelectionIndex != -1;
                                final subSelection = isSubSelected
                                    ? docSelections[subSelectionIndex]
                                    : null;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RadioListTile<int>(
                                      title: Text(sub.name),
                                      value: sub.id,
                                    ),
                                    if (isSubSelected && sub.requiresAcademicPeriod)
                                      Padding(
                                        padding: const EdgeInsets.only(left: 32),
                                        child: Column(
                                          children: [
                                            EZInputField(
                                              child: DropdownButtonFormField<int>(
                                                decoration:
                                                    ThemeHelpers.textInputDecoration(
                                                      labelText: 'Academic Year',
                                                    ),
                                                initialValue:
                                                    subSelection!['academic_year_id'],
                                                items: _academics.map((ay) {
                                                  return DropdownMenuItem(
                                                    value: ay.id,
                                                    child: Text(ay.name),
                                                  );
                                                }).toList(),
                                                onChanged: (val) =>
                                                  _handlePeriodChange(
                                                    doc.id,
                                                    sub.id,
                                                    'academic_year_id',
                                                    val,
                                                  ),
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            EZInputField(
                                              child: DropdownButtonFormField<String>(
                                                decoration:
                                                    ThemeHelpers.textInputDecoration(
                                                      labelText: 'Semester',
                                                    ),
                                                initialValue:
                                                    subSelection['semester'],
                                                items: const [
                                                  DropdownMenuItem(
                                                    value: '1st Semester',
                                                    child: Text('1st Semester'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: '2nd Semester',
                                                    child: Text('2nd Semester'),
                                                  ),
                                                  DropdownMenuItem(
                                                    value: 'Summer',
                                                    child: Text('Summer'),
                                                  ),
                                                ],
                                                onChanged: (val) =>
                                                    _handlePeriodChange(
                                                      doc.id,
                                                      sub.id,
                                                      'semester',
                                                      val,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (isSubSelected)
                                      _buildDocumentPurposesView(
                                        doc: doc,
                                        subId: sub.id,
                                        subName: sub.name,
                                        selectionItem: subSelection,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                  ),

                // Document-level Contextual Purposes (only shown if configured and document has no subselections)
                if (isSelected && !hasSubselections)
                  _buildDocumentPurposesView(
                    doc: doc,
                    subId: null,
                    subName: null,
                    selectionItem: docSelections.firstWhere(
                      (s) => s['document_subselection_id'] == null,
                      orElse: () => docSelections.first,
                    ),
                  ),

                const Divider(),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _PurposeOption {
  final dynamic id;
  final String name;
  final String level;
  final String? context;

  _PurposeOption({
    required this.id,
    required this.name,
    required this.level,
    this.context,
  });
}

