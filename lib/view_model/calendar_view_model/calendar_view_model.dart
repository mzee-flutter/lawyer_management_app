// lib/viewmodels/calendar_viewmodel.dart
//
// Drives the entire calendar screen.
// Follows your AgendaViewModel pattern with ChangeNotifier.
//
// Responsibilities:
//   - Month navigation (prev/next with auto-fetch)
//   - Selected day detail panel state
//   - Adjournment history loading (per case, on demand)
//   - Cache: stores fetched months so navigating back is instant

import 'package:flutter/foundation.dart';

import '../../models/case_models/calendar_hearing_model.dart';
import '../../repository/case_repository/hearing_repository/calendar_repository.dart';

class CalendarViewModel extends ChangeNotifier {
  final CalendarRepository _calendarRepository = CalendarRepository();

  // ──────────────────────────────────────────────────────────────
  // State
  // ──────────────────────────────────────────────────────────────

  // Currently displayed month
  DateTime _focusedMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  // Currently selected day (tapped on calendar)
  DateTime? _selectedDay;

  // Month data cache — key: "YYYY-MM"
  // Avoids re-fetching when navigating back to a month
  final Map<String, CalendarMonthModel> _monthCache = {};

  // Adjournment cache — key: caseId
  final Map<String, AdjournmentHistoryModel> _adjournmentCache = {};

  // Loading states — separate flags so skeleton appears only where needed
  bool _isMonthLoading = false;
  bool _isAdjournmentLoading = false;

  // Error messages
  String? _monthError;
  String? _adjournmentError;

  // ──────────────────────────────────────────────────────────────
  // Public getters
  // ──────────────────────────────────────────────────────────────

  DateTime get focusedMonth => _focusedMonth;
  DateTime? get selectedDay => _selectedDay;

  bool get isMonthLoading => _isMonthLoading;
  bool get isAdjournmentLoading => _isAdjournmentLoading;
  String? get monthError => _monthError;
  String? get adjournmentError => _adjournmentError;

  // Current month's data — null while loading
  CalendarMonthModel? get currentMonth => _monthCache[_cacheKey(_focusedMonth)];

  // O(1) lookup of a day — built from the month's dayMap
  CalendarDayModel? dayData(DateTime date) {
    final month = _monthCache[_cacheKey(DateTime(date.year, date.month))];
    return month?.dayMap[DateTime(date.year, date.month, date.day)];
  }

  // Selected day's full data
  CalendarDayModel? get selectedDayData =>
      _selectedDay != null ? dayData(_selectedDay!) : null;

  // Adjournment history for a case (null = not yet loaded)
  AdjournmentHistoryModel? adjournmentHistory(String caseId) =>
      _adjournmentCache[caseId];

  // Month label for the AppBar — "June 2026"
  String get focusedMonthLabel {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  // Whether the user can navigate to next month
  // Allow up to 12 months in the future
  bool get canGoForward {
    final limit = DateTime(DateTime.now().year + 1, DateTime.now().month);
    return _focusedMonth.isBefore(limit);
  }

  // Whether the user can navigate to previous month
  // Allow up to 24 months in the past
  bool get canGoBack {
    final limit = DateTime(DateTime.now().year - 2, DateTime.now().month);
    return _focusedMonth.isAfter(limit);
  }

  // ──────────────────────────────────────────────────────────────
  // Month navigation
  // ──────────────────────────────────────────────────────────────

  Future<void> goToNextMonth() async {
    if (!canGoForward) return;
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    _selectedDay = null;
    notifyListeners();
    await _loadMonthIfNeeded();
  }

  Future<void> goToPreviousMonth() async {
    if (!canGoBack) return;
    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    _selectedDay = null;
    notifyListeners();
    await _loadMonthIfNeeded();
  }

  Future<void> goToMonth(DateTime month) async {
    _focusedMonth = DateTime(month.year, month.month);
    _selectedDay = null;
    notifyListeners();
    await _loadMonthIfNeeded();
  }

  // ──────────────────────────────────────────────────────────────
  // Day selection
  // ──────────────────────────────────────────────────────────────

  void selectDay(DateTime day) {
    // Tapping the same day deselects it (collapses the detail panel)
    if (_selectedDay != null &&
        _selectedDay!.year == day.year &&
        _selectedDay!.month == day.month &&
        _selectedDay!.day == day.day) {
      _selectedDay = null;
    } else {
      _selectedDay = day;
    }
    notifyListeners();
  }

  void clearSelection() {
    _selectedDay = null;
    notifyListeners();
  }

  // ──────────────────────────────────────────────────────────────
  // Adjournment history — loaded on demand when user taps a case
  // ──────────────────────────────────────────────────────────────

  Future<void> loadAdjournmentHistory(String caseId) async {
    // Return immediately if already cached
    if (_adjournmentCache.containsKey(caseId)) return;

    _isAdjournmentLoading = true;
    _adjournmentError = null;
    notifyListeners();

    try {
      final history =
          await _calendarRepository.getAdjournmentHistory(caseId: caseId);
      _adjournmentCache[caseId] = history;
    } catch (e) {
      _adjournmentError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isAdjournmentLoading = false;
      notifyListeners();
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Initial load — call from CalendarScreen.initState()
  // ──────────────────────────────────────────────────────────────

  Future<void> initialLoad() async {
    await _loadMonthIfNeeded();
  }

  // Refresh current month — clears cache for this month only
  Future<void> refreshCurrentMonth() async {
    final key = _cacheKey(_focusedMonth);
    _monthCache.remove(key);
    await _loadMonthIfNeeded();
  }

  // ──────────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────────

  Future<void> _loadMonthIfNeeded() async {
    final key = _cacheKey(_focusedMonth);
    if (_monthCache.containsKey(key)) return; // already cached

    _isMonthLoading = true;
    _monthError = null;
    notifyListeners();

    try {
      final month = await _calendarRepository.getCalendarMonth(
        year: _focusedMonth.year,
        month: _focusedMonth.month,
      );
      _monthCache[key] = month;
    } catch (e) {
      _monthError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isMonthLoading = false;
      notifyListeners();
    }
  }

  String _cacheKey(DateTime month) => '${month.year}-${month.month}';
}
