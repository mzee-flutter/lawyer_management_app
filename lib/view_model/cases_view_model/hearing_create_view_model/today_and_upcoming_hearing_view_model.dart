import 'package:all/all.dart';

import '../../../models/case_models/today_hearing_model.dart';
import '../../../repository/case_repository/hearing_repository/today_and_upcoming_hearing_repo.dart';

/// One calendar date's worth of flagged conflict, for the "conflicts this
/// week" summary line under the week strip. Built client-side by grouping
/// already server-classified upcoming hearings by date — no conflict logic
/// is recomputed here, just grouped for display.
class UpcomingConflictGroup {
  final DateTime date;
  final String level; // 'hard' | 'soft'
  final List<TodayHearingModel> hearings;

  const UpcomingConflictGroup({
    required this.date,
    required this.level,
    required this.hearings,
  });
}

/// A single day's summary for the 7-day week strip: does it have any
/// hearings at all, and if so, what's the worst conflict level on it.
class DayOverview {
  final DateTime date;
  final bool hasHearings;
  final String conflictLevel; // 'none' | 'soft' | 'hard'

  const DayOverview({
    required this.date,
    required this.hasHearings,
    required this.conflictLevel,
  });
}

class AgendaViewModel extends ChangeNotifier {
  final AgendaRepository _agendaRepository = AgendaRepository();
  // ----------------------------------------------------------------
  // State
  // ----------------------------------------------------------------
  List<TodayHearingModel> _todayHearings = [];
  List<TodayHearingModel> _upcomingDeadlines = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetched;

  // ----------------------------------------------------------------
  // Public getters
  // ----------------------------------------------------------------

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasData =>
      _todayHearings.isNotEmpty || _upcomingDeadlines.isNotEmpty;

  /// Sorted by time — what goes in the "TODAY" section
  List<TodayHearingModel> get todayHearings => _todayHearings;

  /// Hearings ≤3 days away — the "UPCOMING" countdown rows.
  /// Today's hearings are excluded (they're in the TODAY section).
  List<TodayHearingModel> get deadlineCards => _upcomingDeadlines
      .where((h) => h.daysUntilHearing > 0 && h.isDeadlineCard)
      .toList();

  /// True if any two of today's hearings overlap within 60 minutes.
  /// Only hearings with an explicit, specific time are compared — hearings
  /// without one are all anchored to the same default court hour, so
  /// comparing them would flag two unrelated date-only entries on the
  /// same day as a false "scheduling conflict".
  bool get hasSchedulingConflict {
    final timedHearings =
        _todayHearings.where((h) => h.hasSpecificTime).toList();
    if (timedHearings.length < 2) return false;
    final sorted = [...timedHearings]
      ..sort((a, b) => a.hearingDateTime.compareTo(b.hearingDateTime));
    for (int i = 0; i < sorted.length - 1; i++) {
      final gap = sorted[i + 1]
          .hearingDateTime
          .difference(sorted[i].hearingDateTime)
          .inMinutes;
      if (gap < 60) return true;
    }
    return false;
  }

  /// The two conflicting hearings — for the alert banner detail
  List<TodayHearingModel> get conflictingHearings {
    if (!hasSchedulingConflict) return [];
    final timedHearings =
        _todayHearings.where((h) => h.hasSpecificTime).toList();
    final sorted = [...timedHearings]
      ..sort((a, b) => a.hearingDateTime.compareTo(b.hearingDateTime));
    for (int i = 0; i < sorted.length - 1; i++) {
      final gap = sorted[i + 1]
          .hearingDateTime
          .difference(sorted[i].hearingDateTime)
          .inMinutes;
      if (gap < 60) return [sorted[i], sorted[i + 1]];
    }
    return [];
  }

  /// True if today was flagged as a soft (not hard) conflict by the
  /// backend — e.g. two untimed hearings today, or a heavy same-day
  /// workload. A day is never flagged as both; hard takes priority, so
  /// this only matters when hasSchedulingConflict is false.
  bool get hasSoftConflictToday {
    if (hasSchedulingConflict) return false;
    return _todayHearings.any((h) => h.hasSoftConflict);
  }

  /// Short, human-readable explanation for today's soft conflict, derived
  /// from data already on hand — the /today endpoint doesn't need to also
  /// return a reasons list just for this.
  String get todaySoftConflictMessage {
    final scheduled = _todayHearings
        .where((h) => h.status.toLowerCase() == 'scheduled')
        .toList();
    final untimed = scheduled.where((h) => !h.hasSpecificTime).length;
    if (untimed >= 1 && scheduled.length >= 2) {
      return '$untimed of ${scheduled.length} hearings today still need a '
          'confirmed time — worth checking they don\'t clash.';
    }
    return '${scheduled.length} hearings scheduled today — a heavier day '
        'than usual.';
  }

  /// Hearings later in the week (1–7 days out) whose day was flagged with
  /// a hard or soft conflict, grouped by date. conflictLevel is already
  /// computed server-side per calendar day; this just groups the flat
  /// list for display — used for the short summary line under the week
  /// strip and can back a future "view all" list.
  List<UpcomingConflictGroup> get upcomingConflicts {
    final flagged = _upcomingDeadlines
        .where((h) => h.daysUntilHearing > 0 && h.conflictLevel != 'none')
        .toList();

    final Map<DateTime, List<TodayHearingModel>> byDate = {};
    for (final h in flagged) {
      final key = DateTime(
        h.hearingDateTime.year,
        h.hearingDateTime.month,
        h.hearingDateTime.day,
      );
      byDate.putIfAbsent(key, () => []).add(h);
    }

    final groups = byDate.entries.map((entry) {
      final level = entry.value.any((h) => h.hasHardConflict) ? 'hard' : 'soft';
      return UpcomingConflictGroup(
        date: entry.key,
        level: level,
        hearings: entry.value,
      );
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    return groups;
  }

  /// The single source of truth for the 7-day week strip. Built from the
  /// real hearing lists for every one of the 7 days — not reconstructed
  /// from daysUntilHearing offsets and not limited to only the ≤3-day
  /// deadline window or only flagged dates, which is what previously let
  /// days 4–7 with an ordinary (unflagged) hearing silently show as
  /// empty. Day 0 (today) reuses hasSchedulingConflict/hasSoftConflictToday
  /// directly so the strip's dot for today can never disagree with the
  /// alert banner above it.
  List<DayOverview> weekOverview() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final Map<DateTime, List<TodayHearingModel>> byDate = {};
    for (final h in _upcomingDeadlines) {
      if (h.daysUntilHearing <= 0) continue; // today handled separately below
      final key = DateTime(
        h.hearingDateTime.year,
        h.hearingDateTime.month,
        h.hearingDateTime.day,
      );
      byDate.putIfAbsent(key, () => []).add(h);
    }

    return List.generate(7, (i) {
      final date = today.add(Duration(days: i));

      if (i == 0) {
        final level = hasSchedulingConflict
            ? 'hard'
            : (hasSoftConflictToday ? 'soft' : 'none');
        return DayOverview(
          date: date,
          hasHearings: _todayHearings.isNotEmpty,
          conflictLevel: level,
        );
      }

      final hearings = byDate[date] ?? const [];
      final hasHard = hearings.any((h) => h.hasHardConflict);
      final hasSoft = hearings.any((h) => h.hasSoftConflict);
      return DayOverview(
        date: date,
        hasHearings: hearings.isNotEmpty,
        conflictLevel: hasHard ? 'hard' : (hasSoft ? 'soft' : 'none'),
      );
    });
  }

  /// Summary counts for the stat cards at the top of the dashboard
  int get todayHearingCount => _todayHearings.length;
  int get urgentDeadlineCount => deadlineCards
      .where((h) =>
          h.urgency == DeadlineUrgency.critical ||
          h.urgency == DeadlineUrgency.warning)
      .length;

  // ----------------------------------------------------------------
  // Data loading
  // ----------------------------------------------------------------

  /// Call this from the Dashboard screen's initState or on pull-to-refresh
  Future<void> loadAgenda() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      // Run both requests in parallel — saves one round-trip time
      final results = await Future.wait([
        _agendaRepository.getTodayHearings(),
        _agendaRepository.getUpcomingDeadlines(daysAhead: 7),
      ]);

      _todayHearings = results[0];
      _upcomingDeadlines = results[1];
      _lastFetched = DateTime.now();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() async {
    _todayHearings = [];
    _upcomingDeadlines = [];
    notifyListeners();
    await loadAgenda();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
