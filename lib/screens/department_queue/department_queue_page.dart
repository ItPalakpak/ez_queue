import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/widgets/auto_loop_carousel.dart';
import 'package:ez_queue/widgets/ez_input_field.dart';
import 'package:ez_queue/utils/theme_helpers.dart';
import 'package:ez_queue/theme/app_theme.dart';
import 'package:ez_queue/providers/api_providers.dart';

/// Department-specific live queue display page (read-only).
/// Shows the live queue status mimicking the admin CCTV display.
class DepartmentQueuePage extends ConsumerStatefulWidget {
  final String? initialDepartment;

  const DepartmentQueuePage({super.key, this.initialDepartment});

  @override
  ConsumerState<DepartmentQueuePage> createState() =>
      _DepartmentQueuePageState();
}

class _DepartmentQueuePageState extends ConsumerState<DepartmentQueuePage> {
  int? _selectedDepartmentId;
  String? _selectedDepartmentName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(apiDepartmentsProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Gate the "Get A Ticket" button visibility
    final settingsAsync = ref.watch(apiSettingsProvider);
    final remoteQueuingEnabled = settingsAsync.maybeWhen(
      data: (s) => s.remoteQueuingEnabled,
      orElse: () => false,
    );

    // List of departments for dropdown
    final departmentsAsync = ref.watch(apiDepartmentsProvider);

    return Scaffold(
      body: Column(
        children: [
          const TopNavBar(),
          Expanded(
            child: departmentsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) =>
                  Center(child: Text('Failed to load departments: $err')),
              data: (departments) {
                if (departments.isEmpty) {
                  return const Center(
                    child: Text('No active departments available.'),
                  );
                }

                // If no selection is made, aggressively default to the first department
                if (_selectedDepartmentId == null) {
                  final initialDept =
                      widget.initialDepartment != null &&
                          widget.initialDepartment != 'Unknown'
                      ? departments
                                .where(
                                  (d) => d.name == widget.initialDepartment,
                                )
                                .firstOrNull ??
                            departments.first
                      : departments.first;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _selectedDepartmentId = initialDept.id;
                        _selectedDepartmentName = initialDept.name;
                      });
                    }
                  });
                  return const Center(child: CircularProgressIndicator());
                }

                // Poll live data for the actively selected department
                final liveQueueAsync = ref.watch(
                  apiDisplayQueueProvider(_selectedDepartmentId!),
                );

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(EZSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Combobox Selection
                      Text(
                        'Select Department',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: EZSpacing.md),
                      EZInputField(
                        child: DropdownButtonFormField<int>(
                          value: _selectedDepartmentId,
                          decoration: ThemeHelpers.dropdownInputDecoration(
                            labelText: 'Viewing Queue For',
                            prefixIcon: const Icon(Icons.business_outlined),
                          ),
                          items: departments.map((dept) {
                            return DropdownMenuItem<int>(
                              value: dept.id,
                              child: Text(
                                dept.name,
                                style: const TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize: 15,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (int? value) {
                            if (value != null) {
                              setState(() {
                                _selectedDepartmentId = value;
                                _selectedDepartmentName = departments
                                    .firstWhere((d) => d.id == value)
                                    .name;
                              });
                            }
                          },
                          isExpanded: true,
                          dropdownColor: Theme.of(context).colorScheme.surface,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: EZSpacing.xxl),

                      // Title
                      Text(
                        '$_selectedDepartmentName Live Status',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: EZSpacing.xl),

                      // Live Dashboard Display
                      liveQueueAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, st) =>
                            Center(child: Text('Live stream offline: $err')),
                        data: (liveData) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // UNIFIED STATION DASHBOARD (NOW SERVING + NEXT UP)
                              if (liveData.stations.isEmpty)
                                const Text('No stations currently open.')
                              else
                                AutoLoopCarousel(
                                  height: 540,
                                  interval: const Duration(seconds: 12),
                                  items: liveData.stations.map((station) {
                                    final bool isBusy =
                                        station.status == 'busy';

                                    // Filter waiting list based on exact backend assignments (Service & Course restrictions)
                                    final stationWaitingList = liveData.waiting
                                        .where(
                                          (t) =>
                                              station.waitingIds.contains(t.id),
                                        )
                                        .toList();

                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .extension<EZThemeExtension>()!
                                              .shadowColor,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          EZSpacing.radiusLg,
                                        ),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface
                                            .withValues(alpha: 0.5),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // STATION HEADER & NOW SERVING
                                          Container(
                                            padding: const EdgeInsets.fromLTRB(
                                              EZSpacing.xl,
                                              EZSpacing.lg,
                                              EZSpacing.xl,
                                              EZSpacing.lg,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isBusy
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.1)
                                                  : Colors.green.withValues(
                                                      alpha: 0.1,
                                                    ),
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(
                                                      EZSpacing.radiusLg - 1,
                                                    ),
                                                  ),
                                              border: Border(
                                                bottom: BorderSide(
                                                  color: Theme.of(context)
                                                      .extension<
                                                        EZThemeExtension
                                                      >()!
                                                      .shadowColor,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      station.stationName
                                                          .toUpperCase(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .onSurface
                                                                    .withValues(
                                                                      alpha:
                                                                          0.7,
                                                                    ),
                                                          ),
                                                    ),
                                                    Text(
                                                      'NOW SERVING',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelMedium
                                                          ?.copyWith(
                                                            letterSpacing: 2,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: EZSpacing.sm,
                                                ),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    isBusy
                                                        ? (station.currentTicket ??
                                                              '--')
                                                        : 'OPEN',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .displayMedium
                                                        ?.copyWith(
                                                          color: isBusy
                                                              ? Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primary
                                                              : Colors.green,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily:
                                                              'JetBrains Mono',
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // NEXT UP WAITLIST DIVIDER
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: EZSpacing.lg,
                                              vertical: EZSpacing.md,
                                            ),
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.surface,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'NEXT UP',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        letterSpacing: 1.5,
                                                      ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    '${stationWaitingList.length} Waiting',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .labelMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Divider(height: 1),

                                          // WAITLIST SCROLL
                                          Expanded(
                                            child: stationWaitingList.isEmpty
                                                ? Center(
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .check_circle_outline,
                                                          size: 48,
                                                          color: Colors.green
                                                              .withValues(
                                                                alpha: 0.5,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: EZSpacing.md,
                                                        ),
                                                        Text(
                                                          'Queue is empty',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .titleMedium
                                                              ?.copyWith(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .onSurface
                                                                        .withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : ListView.separated(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          EZSpacing.md,
                                                        ),
                                                    itemCount:
                                                        stationWaitingList
                                                            .length,
                                                    separatorBuilder:
                                                        (context, index) =>
                                                            const SizedBox(
                                                              height:
                                                                  EZSpacing.sm,
                                                            ),
                                                    itemBuilder: (context, index) {
                                                      final ticket =
                                                          stationWaitingList[index];
                                                      final bgColor =
                                                          ticket.isPriority
                                                          ? Theme.of(context)
                                                                .colorScheme
                                                                .error
                                                                .withValues(
                                                                  alpha: 0.1,
                                                                )
                                                          : Theme.of(context)
                                                                .colorScheme
                                                                .surface;

                                                      final borderColor =
                                                          ticket.isPriority
                                                          ? Theme.of(
                                                              context,
                                                            ).colorScheme.error
                                                          : Theme.of(context)
                                                                .extension<
                                                                  EZThemeExtension
                                                                >()!
                                                                .shadowColor;

                                                      return Container(
                                                        decoration: BoxDecoration(
                                                          color: bgColor,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                EZSpacing
                                                                    .radiusMd,
                                                              ),
                                                          border: Border.all(
                                                            color: borderColor,
                                                            width: 1.5,
                                                          ),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets.all(
                                                                EZSpacing.md,
                                                              ),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    child: FittedBox(
                                                                      fit: BoxFit
                                                                          .scaleDown,
                                                                      alignment:
                                                                          Alignment
                                                                              .centerLeft,
                                                                      child: Text(
                                                                        ticket
                                                                            .ticketNumber,
                                                                        style: TextStyle(
                                                                          fontFamily:
                                                                              'JetBrains Mono',
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              24,
                                                                          color:
                                                                              ticket.isPriority
                                                                              ? Theme.of(
                                                                                  context,
                                                                                ).colorScheme.error
                                                                              : null,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  if (ticket
                                                                      .isPriority)
                                                                    Container(
                                                                      padding: const EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            6,
                                                                        vertical:
                                                                            2,
                                                                      ),
                                                                      decoration: BoxDecoration(
                                                                        color: Theme.of(
                                                                          context,
                                                                        ).colorScheme.error,
                                                                        borderRadius:
                                                                            BorderRadius.circular(
                                                                              4,
                                                                            ),
                                                                      ),
                                                                      child: const Text(
                                                                        'PRIORITY',
                                                                        style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),

                              const SizedBox(height: EZSpacing.xxl),

                              // Info
                              EZCard(
                                padding: const EdgeInsets.all(EZSpacing.lg),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                    const SizedBox(width: EZSpacing.md),
                                    Expanded(
                                      child: Text(
                                        'Showing live display for $_selectedDepartmentName. '
                                        '(${liveData.totalWaiting} waiting overall)',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: EZSpacing.xl),
                            ],
                          );
                        },
                      ),

                      if (remoteQueuingEnabled)
                        SizedBox(
                          width: double.infinity,
                          child: EZButton(
                            onPressed: () {
                              context.push('/user-type-selection');
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_circle_outline),
                                SizedBox(width: 8),
                                Text('Get A Ticket'),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
