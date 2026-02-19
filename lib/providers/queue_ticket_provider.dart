import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ez_queue/models/queue_ticket.dart';

/// Provider for current queue ticket state.
final queueTicketProvider =
    StateNotifierProvider<QueueTicketNotifier, QueueTicket?>((ref) {
  return QueueTicketNotifier();
});

/// Notifier for managing queue ticket state.
class QueueTicketNotifier extends StateNotifier<QueueTicket?> {
  QueueTicketNotifier() : super(null);

  /// Set the current queue ticket.
  void setTicket(QueueTicket ticket) {
    state = ticket;
  }

  /// Clear the current ticket.
  void clearTicket() {
    state = null;
  }
}

