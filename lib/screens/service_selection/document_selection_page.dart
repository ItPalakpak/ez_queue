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

  const DocumentSelectionPage({Key? key, required this.services})
    : super(key: key);

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
  List<dynamic> _selectedPurposes = [];
  bool _isOthersChecked = false;
  String _customPurpose = '';

  @override
  void initState() {
    super.initState();
    _loadAcademics();

    // Load initial from provider if exists
    final formData = ref.read(queueFormProvider);
    if (formData.selections.isNotEmpty) {
      _selections = List.from(formData.selections);
    }
    if (formData.extraDetails.isNotEmpty) {
      _extraDetails = Map.from(formData.extraDetails);
      if (_extraDetails['purposes'] != null) {
        final List<dynamic> p = _extraDetails['purposes'];
        for (var item in p) {
          if (item is String || item is int) {
            _selectedPurposes.add(item);
          }
        }
      }
      if (_extraDetails['custom_purpose'] != null) {
        _customPurpose = _extraDetails['custom_purpose'];
        if (_customPurpose.isNotEmpty) {
          _isOthersChecked = true;
        }
      }
      if (_extraDetails['previous_selections'] != null) {
        final List<dynamic> ps = _extraDetails['previous_selections'];
        _previousSelections = List<Map<String, dynamic>>.from(
          ps.map((e) => Map<String, dynamic>.from(e as Map)),
        );
      }
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
    } catch (e) {
      debugPrint('Failed to load academics: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _handleExtraChange(String key, dynamic value) {
    setState(() {
      _extraDetails[key] = value;
    });
  }

  Future<void> _selectDate(BuildContext context, String key) async {
    final DateTime initialDate = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      final formattedDate =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      _handleExtraChange(key, formattedDate);
    }
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
        });
      }
    });
  }

  final bool _allowMultipleSubselections =
      false; // Toggle this to enable multiple subselections per document

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
          });
        }
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

  void _handlePurposeToggle(dynamic purposeValue, bool selected) {
    setState(() {
      if (selected) {
        if (!_selectedPurposes.contains(purposeValue))
          _selectedPurposes.add(purposeValue);
      } else {
        _selectedPurposes.remove(purposeValue);
      }
    });
  }

  void _handleCustomPurposeChange(String value) {
    setState(() {
      _customPurpose = value;
    });
  }

  void _proceed() {
    final uniquePurposesMap = <int, ApiServicePurpose>{};
    for (var service in widget.services) {
      for (var p in service.purposes) {
        uniquePurposesMap[p.id] = p;
      }
    }
    final uniquePurposes = uniquePurposesMap.values.toList();

    final List<dynamic> finalPurposes = List.from(_selectedPurposes);
    final List<String> finalPurposesDisplay = _selectedPurposes.map((p) {
      if (p is int) {
        try {
          final purposeObj = uniquePurposes.firstWhere((up) => up.id == p);
          return purposeObj.name;
        } catch (_) {
          return p.toString();
        }
      }
      return p.toString();
    }).toList();

    if (_customPurpose.trim().isNotEmpty && _isOthersChecked) {
      finalPurposes.add(_customPurpose.trim());
      finalPurposesDisplay.add(_customPurpose.trim());
    }

    final prevDetailsStr = _previousSelections
        .map((s) {
          if (s['subselection_name'] != null) {
            return '${s['document_name']} - ${s['subselection_name']}';
          }
          return s['document_name'];
        })
        .join(', ');

    final updatedExtraDetails = Map<String, dynamic>.from(_extraDetails);
    updatedExtraDetails['purposes'] = finalPurposes;
    updatedExtraDetails['purposes_display'] = finalPurposesDisplay;
    updatedExtraDetails['custom_purpose'] = _customPurpose;
    updatedExtraDetails['previous_request_details'] = prevDetailsStr;
    updatedExtraDetails['previous_selections'] = _previousSelections;

    ref
        .read(queueFormProvider.notifier)
        .updateDocumentSelections(
          selections: _selections,
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

    // Deduplicate documents and purposes
    final uniqueDocsMap = <int, ApiServiceDocument>{};
    final uniquePurposesMap = <int, ApiServicePurpose>{};
    for (var service in widget.services) {
      for (var doc in service.documents) {
        uniqueDocsMap[doc.id] = doc;
      }
      for (var p in service.purposes) {
        uniquePurposesMap[p.id] = p;
      }
    }
    final uniqueDocs = uniqueDocsMap.values.toList();
    final uniquePurposes = uniquePurposesMap.values.toList();

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
                    if (uniquePurposes.isNotEmpty) ...[
                      const SizedBox(height: EZSpacing.lg),
                      _buildPart3Section(uniquePurposes),
                    ],
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

  Widget _buildReminderSection() {
    return EZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reminder',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
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
    return EZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Part 1: Complete entries below',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          EZInputField(
            child: TextField(
              readOnly: true,
              onTap: () => _selectDate(context, 'date_of_graduation'),
              decoration: ThemeHelpers.textInputDecoration(
                labelText: 'If a graduate, Date of Graduation',
              ).copyWith(suffixIcon: const Icon(Icons.calendar_today)),
              controller: TextEditingController(
                text: _extraDetails['date_of_graduation']?.toString() ?? '',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('If not, state the Last Semester & SY of Attendance:'),
          const SizedBox(height: 8),
          EZInputField(
            child: DropdownButtonFormField<String>(
              decoration: ThemeHelpers.textInputDecoration(
                labelText: 'Semester',
              ),
              initialValue:
                  _extraDetails['last_semester_attended']?.toString().isEmpty ??
                      true
                  ? null
                  : _extraDetails['last_semester_attended'],
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
                labelText: 'School Year',
              ),
              initialValue:
                  _extraDetails['last_sy_attended']?.toString().isEmpty ?? true
                  ? null
                  : _extraDetails['last_sy_attended'],
              items: _academics.map((ay) {
                return DropdownMenuItem(value: ay.name, child: Text(ay.name));
              }).toList(),
              onChanged: (val) => _handleExtraChange('last_sy_attended', val),
            ),
          ),
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
                      child: RadioGroup<int>(
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
                            final subSelectionIndex = docSelections.indexWhere(
                              (s) => s['document_subselection_id'] == sub.id,
                            );
                            final isSubSelected = subSelectionIndex != -1;
                            return _allowMultipleSubselections
                                ? CheckboxListTile(
                                    title: Text(sub.name),
                                    value: isSubSelected,
                                    onChanged: (val) =>
                                        _handlePreviousSubselectionToggle(
                                          doc.id,
                                          sub.id,
                                          sub.name,
                                          val ?? false,
                                        ),
                                  )
                                : RadioListTile<int>(
                                    title: Text(sub.name),
                                    value: sub.id,
                                  );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              );
            }).toList(),
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

  Widget _buildPart2Section(List<ApiServiceDocument> uniqueDocs) {
    return EZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Part 2: Check document/s you need',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...uniqueDocs.map((doc) {
            final docSelections = _selections
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
                  onChanged: (val) => _handleDocumentToggle(doc),
                ),
                if (isSelected && doc.subselections.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: RadioGroup<int>(
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
                              _allowMultipleSubselections
                                  ? CheckboxListTile(
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
                                    )
                                  : RadioListTile<int>(
                                      title: Text(sub.name),
                                      value: sub.id,
                                    ),
                              if (isSubSelected && sub.requiresAcademicPeriod)
                                Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Column(
                                    children: [
                                      // ignore: deprecated_member_use
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
                            ],
                          );
                        }).toList(),
                      ),
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

  Widget _buildPart3Section(List<ApiServicePurpose> uniquePurposes) {
    return EZCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Part 3: Please check the purpose of your request',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...uniquePurposes.map((purpose) {
            return CheckboxListTile(
              title: Text(purpose.name),
              value: _selectedPurposes.contains(purpose.id),
              onChanged: (val) =>
                  _handlePurposeToggle(purpose.id, val ?? false),
              controlAffinity: ListTileControlAffinity.leading,
            );
          }),
          CheckboxListTile(
            title: const Text('Others (Specify)'),
            value: _isOthersChecked,
            onChanged: (val) {
              setState(() {
                _isOthersChecked = val ?? false;
                if (!_isOthersChecked) {
                  _customPurpose = '';
                }
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_isOthersChecked)
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 8),
              child: EZInputField(
                child: TextField(
                  decoration: ThemeHelpers.textInputDecoration(
                    labelText: 'Specify other purpose',
                  ),
                  onChanged: _handleCustomPurposeChange,
                  controller: TextEditingController.fromValue(
                    TextEditingValue(
                      text: _customPurpose,
                      selection: TextSelection.collapsed(
                        offset: _customPurpose.length,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
