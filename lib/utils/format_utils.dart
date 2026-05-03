/// Duration formatting utility — Dart equivalent of the frontend's dateUtils.formatDuration.
/// Converts a minute value into a human-readable duration string.
/// Automatically selects the largest appropriate unit and only shows non-zero parts.

const _durationUnits = <String, int>{
  'month': 43200, // 30 days
  'week': 10080, // 7 days
  'day': 1440,
  'hour': 60,
  'minute': 1,
};

const _unitLabelsFull = <String, String>{
  'month': 'month',
  'week': 'week',
  'day': 'day',
  'hour': 'hour',
  'minute': 'minute',
};

const _unitLabelsFullPl = <String, String>{
  'month': 'months',
  'week': 'weeks',
  'day': 'days',
  'hour': 'hours',
  'minute': 'minutes',
};

const _unitLabelsCompact = <String, String>{
  'month': 'mo',
  'week': 'w',
  'day': 'd',
  'hour': 'h',
  'minute': 'm',
};

/// Convert a minute value into a human-readable duration string.
///
/// [minutes] — duration in minutes (can be fractional).
/// [compact] — use short labels ("1h 30m" vs "1 hour 30 minutes").
/// [maxParts] — max number of unit parts to show.
String formatDuration(
  num? minutes, {
  bool compact = false,
  int maxParts = 3,
}) {
  if (minutes == null || minutes == 0) {
    return compact ? '0m' : '0 min';
  }

  final totalSeconds = (minutes.abs() * 60).floor();
  final labels = compact ? _unitLabelsCompact : _unitLabelsFull;
  final labelsPl = compact ? _unitLabelsCompact : _unitLabelsFullPl;
  final parts = <String>[];

  var remaining = totalSeconds;

  for (final entry in _durationUnits.entries) {
    if (parts.length >= maxParts) break;

    final unitSeconds = entry.value * 60;
    final count = remaining ~/ unitSeconds;

    if (count > 0) {
      final label = count == 1 ? labels[entry.key]! : labelsPl[entry.key]!;
      parts.add(compact ? '$count$label' : '$count $label');
      remaining -= count * unitSeconds;
    }
  }

  if (parts.isEmpty) {
    return compact ? '<1s' : '< 1 second';
  }

  return parts.join(compact ? ' ' : ', ');
}
