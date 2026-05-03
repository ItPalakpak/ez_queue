import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/models/queue_ticket.dart';

/// Provider for current queue ticket state.
final queueTicketProvider =
    StateNotifierProvider<QueueTicketNotifier, List<QueueTicket>>((ref) {
  return QueueTicketNotifier();
});

/// Notifier for managing queue ticket state.
class QueueTicketNotifier extends StateNotifier<List<QueueTicket>> {
  QueueTicketNotifier() : super([]);

  /// Set the current queue tickets.
  void setTickets(List<QueueTicket> tickets) {
    state = tickets;
  }

  /// Clear the current tickets.
  void clearTickets() {
    state = [];
  }
}

