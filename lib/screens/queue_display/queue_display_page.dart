import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/providers/queue_ticket_provider.dart';
import 'package:ez_queue/providers/api_providers.dart';
import 'package:ez_queue/utils/api_config.dart';
import 'package:ez_queue/theme/spacing.dart';
import 'package:ez_queue/widgets/top_nav_bar.dart';
import 'package:ez_queue/widgets/ez_button.dart';
import 'package:ez_queue/widgets/ez_card.dart';
import 'package:ez_queue/widgets/auto_loop_carousel.dart';
import 'package:go_router/go_router.dart';
import 'package:ez_queue/theme/app_theme.dart';

/// Queue display page showing current queue status specifically targeting a tracked user ticket.
class QueueDisplayPage extends ConsumerStatefulWidget {
  final String? trackedTicketNumber;
  final int? trackedDepartmentId;
  final String? trackedDepartmentName;

  const QueueDisplayPage({
    super.key,
    this.trackedTicketNumber,
    this.trackedDepartmentId,
    this.trackedDepartmentName,
  });

  @override
  ConsumerState<QueueDisplayPage> createState() => _QueueDisplayPageState();
}

class _QueueDisplayPageState extends ConsumerState<QueueDisplayPage> {
  // Track state
  String? _displayTicketNumber;
  int? _displayDepartmentId;
  String? _displayDepartmentName;

  @override
  void initState() {
    super.initState();

    // Resolve which ticket we are tracking securely
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.trackedTicketNumber != null &&
          widget.trackedDepartmentId != null) {
        setState(() {
          _displayTicketNumber = widget.trackedTicketNumber;
          _displayDepartmentId = widget.trackedDepartmentId;
          _displayDepartmentName = widget.trackedDepartmentName ?? 'Department';
        });
      } else {
        // Fallback to local tickets if not explicitly routed from Tracker
        final localTickets = ref.read(queueTicketProvider);
        if (localTickets.isNotEmpty) {
          final first = localTickets.first;
          setState(() {
            _displayTicketNumber = first.ticketNumber;
            _displayDepartmentId = first.departmentId;
            _displayDepartmentName = first.departmentName;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If we're fully missing any tracking capabilities
    if (_displayDepartmentId == null || _displayTicketNumber == null) {
      return Scaffold(
        body: Column(
          children: [
            const TopNavBar(),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 64,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: EZSpacing.lg),
                    Text(
                      'No Active Ticket Found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Pull the live stream tied explicitly to the department holding this user's ticket
    final liveQueueAsync = ref.watch(
      apiDisplayQueueProvider(_displayDepartmentId!),
    );

    // CHANGED: Debug logging to trace live queue data resolution
    liveQueueAsync.when(
      loading: () =>
          debugPrint('[QueueDisplay] Loading... baseUrl=${ApiConfig.baseUrl}'),
      error: (err, _) => debugPrint(
        '[QueueDisplay] ERROR: $err, baseUrl=${ApiConfig.baseUrl}',
      ),
      data: (data) {
        final allTicketNumbers = data.waiting
            .map((t) => t.ticketNumber)
            .toList();
        debugPrint(
          '[QueueDisplay] Data received. Waiting tickets: $allTicketNumbers, myTicket: $_displayTicketNumber',
        );
        for (final s in data.stations) {
          debugPrint(
            '[QueueDisplay] Station ${s.stationName}: waitingIds=${s.waitingIds}, currentTicket=${s.currentTicket}',
          );
        }
      },
    );

    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              const TopNavBar(),
              Align(
                alignment: Alignment.topRight,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: EZSpacing.sm,
                      right: 100,
                    ),
                    child: IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Row(
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                const SizedBox(width: EZSpacing.sm),
                                const Text('Important Reminders'),
                              ],
                            ),
                            content: const Text(
                              '• Always maintain an internet connection\n\n'
                              '• Wait for notifications via email and this app for queue status updates',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.warning_amber_rounded),
                      color: Colors.orange,
                      tooltip: 'Important Reminders',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Main Live Screen (Adapted from DepartmentQueuePage)
          Expanded(
            child: liveQueueAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, st) =>
                  Center(child: Text('Live Dashboard Offline: $err')),
              data: (liveData) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(EZSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$_displayDepartmentName Live Status',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: EZSpacing.xl),

                      // UNIFIED STATION DASHBOARD (NOW SERVING + NEXT UP)
                      if (liveData.stations.isEmpty)
                        const Text('No stations currently open.')
                      else
                        AutoLoopCarousel(
                          height: 540,
                          interval: const Duration(seconds: 12),
                          items: liveData.stations.map((station) {
                            final bool isBusy = station.status == 'busy';

                            // Filter waiting list based on exact backend assignments (Service & Course restrictions)
                            final stationWaitingList = liveData.waiting
                                .where((t) => station.waitingIds.contains(t.id))
                                .toList();

                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).extension<EZThemeExtension>()!.shadowColor,
                                ),
                                borderRadius: BorderRadius.circular(
                                  EZSpacing.radiusLg,
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.surface.withValues(alpha: 0.5),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                          : Colors.green.withValues(alpha: 0.1),
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(
                                          EZSpacing.radiusLg - 1,
                                        ),
                                      ),
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Theme.of(context)
                                              .extension<EZThemeExtension>()!
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
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              station.stationName.toUpperCase(),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleLarge
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.7),
                                                  ),
                                            ),
                                            Text(
                                              'NOW SERVING',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium
                                                  ?.copyWith(
                                                    letterSpacing: 2,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: EZSpacing.sm),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              if (isBusy &&
                                                  station.currentTicket ==
                                                      _displayTicketNumber) ...[
                                                Icon(
                                                  Icons.star,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                                  size: 36,
                                                ),
                                                const SizedBox(width: 8),

                                                const SizedBox(width: 16),
                                              ],
                                              Text(
                                                isBusy
                                                    ? (station.currentTicket ??
                                                          '--')
                                                    : 'OPEN',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .displayMedium
                                                    ?.copyWith(
                                                      color: isBusy
                                                          ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                          : Colors.green,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontFamily:
                                                          'JetBrains Mono',
                                                    ),
                                              ),
                                            ],
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
                                          MainAxisAlignment.spaceBetween,
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
                                                    .withValues(alpha: 0.7),
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.5,
                                              ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary
                                                .withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            '${stationWaitingList.length} Waiting',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
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
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.check_circle_outline,
                                                  size: 48,
                                                  color: Colors.green
                                                      .withValues(alpha: 0.5),
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
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : ListView.separated(
                                            padding: const EdgeInsets.all(
                                              EZSpacing.md,
                                            ),
                                            itemCount:
                                                stationWaitingList.length,
                                            separatorBuilder:
                                                (context, index) =>
                                                    const SizedBox(
                                                      height: EZSpacing.sm,
                                                    ),
                                            itemBuilder: (context, index) {
                                              final ticket =
                                                  stationWaitingList[index];
                                              // CHANGED: Only highlight the user's ticket in the station
                                              // they are actually assigned to (via waitingIds), not in
                                              // every station that happens to have a matching number.
                                              final isUsersTicket =
                                                  ticket.ticketNumber ==
                                                      _displayTicketNumber &&
                                                  station.waitingIds.contains(
                                                    ticket.id,
                                                  );
                                              // CHANGED: More prominent highlight for user's own ticket
                                              // so they can easily spot their position in line.
                                              final bgColor = isUsersTicket
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .primary
                                                        .withValues(alpha: 0.15)
                                                  : ticket.isPriority
                                                  ? Theme.of(context)
                                                        .colorScheme
                                                        .error
                                                        .withValues(alpha: 0.1)
                                                  : Theme.of(
                                                      context,
                                                    ).colorScheme.surface;

                                              final borderColor = isUsersTicket
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.primary
                                                  : ticket.isPriority
                                                  ? Theme.of(
                                                      context,
                                                    ).colorScheme.error
                                                  : Theme.of(context)
                                                        .extension<
                                                          EZThemeExtension
                                                        >()!
                                                        .shadowColor;

                                              // CHANGED: Wrap user's ticket with a glow/shine effect
                                              // and add a "YOU" badge so their position is unmistakable.
                                              Widget ticketRow = Container(
                                                decoration: BoxDecoration(
                                                  color: bgColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        EZSpacing.radiusMd,
                                                      ),
                                                  border: Border.all(
                                                    color: borderColor,
                                                    width: isUsersTicket
                                                        ? 3.0
                                                        : 1.5,
                                                  ),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
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
                                                              alignment: Alignment
                                                                  .centerLeft,
                                                              child: Text(
                                                                ticket
                                                                    .ticketNumber,
                                                                style: TextStyle(
                                                                  fontFamily:
                                                                      'JetBrains Mono',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 24,
                                                                  color:
                                                                      isUsersTicket
                                                                      ? Theme.of(
                                                                          context,
                                                                        ).colorScheme.primary
                                                                      : ticket
                                                                            .isPriority
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
                                                                  .isPriority &&
                                                              !isUsersTicket)
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        6,
                                                                    vertical: 2,
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
                                                                  fontSize: 12,
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            )
                                                          else if (isUsersTicket)
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        8,
                                                                    vertical: 3,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(
                                                                  context,
                                                                ).colorScheme.surface,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      4,
                                                                    ),
                                                                border: Border.all(
                                                                  color: Theme.of(
                                                                    context,
                                                                  ).colorScheme.primary,
                                                                  width: 1.5,
                                                                ),
                                                              ),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  Icon(
                                                                    Icons.star,
                                                                    color: Theme.of(
                                                                      context,
                                                                    ).colorScheme.primary,
                                                                    size: 14,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 4,
                                                                  ),
                                                                  Text(
                                                                    'YOU · #${index + 1}',
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Theme.of(
                                                                        context,
                                                                      ).colorScheme.primary,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );

                                              // CHANGED: Add a subtle animated glow behind the user's ticket
                                              if (isUsersTicket) {
                                                ticketRow = Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          EZSpacing.radiusMd +
                                                              2,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                        blurRadius: 8,
                                                        spreadRadius: 2,
                                                      ),
                                                    ],
                                                  ),
                                                  child: ticketRow,
                                                );
                                              }

                                              return ticketRow;
                                            },
                                          ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: EZSpacing.xxxl),
                      const SizedBox(height: EZSpacing.xl),

                      // YOUR TICKET PINNED TO THE BOTTOM
                      Center(
                        child: Text(
                          'YOUR ACTIVE TICKET',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),
                      const SizedBox(height: EZSpacing.sm),
                      EZCard(
                        padding: const EdgeInsets.all(EZSpacing.xl),
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _displayTicketNumber ?? '--',
                              style: Theme.of(context).textTheme.displayLarge
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2,
                                  ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: EZSpacing.xxl),

                      // Cancel queue button (only show if this device generated the ticket)
                      if (ref
                          .watch(queueTicketProvider)
                          .any(
                            (t) => t.ticketNumber == _displayTicketNumber,
                          )) ...[
                        SizedBox(
                          width: double.infinity,
                          child: EZButton(
                            isSecondary: true,
                            onPressed: () {
                              context.push('/cancel-queue');
                            },
                            child: const Text('Cancel Queue'),
                          ),
                        ),
                      ],

                      const SizedBox(height: EZSpacing.xxl),
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
