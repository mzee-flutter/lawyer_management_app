import 'package:flutter/foundation.dart';

import '../../../models/case_models/legal_task_model.dart';
import '../../../repository/case_repository/hearing_repository/legal_task_repo.dart';

class LegalTaskViewModel extends ChangeNotifier {
  final LegalTaskRepository _legalTaskRepository = LegalTaskRepository();

  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────
  TaskBoardModel? _board;
  bool _isLoading = false;
  String? _error;

  DateTime? _dueDate;
  DateTime? get dueDate => _dueDate;

  void setDueDate(DateTime? newDate) {
    _dueDate = newDate;
    notifyListeners();
  }

  String? _selectedCaseId;
  String? get selectedCaseId => _selectedCaseId;

  void setSelectedCaseId(String? newId) {
    _selectedCaseId = newId;
    notifyListeners();
  }

  TaskPriority _priority = TaskPriority.medium;
  TaskPriority get priority => _priority;

  void setTaskPriority(TaskPriority newPriority) {
    _priority = newPriority;
    notifyListeners();
  }

  // Per-task loading — toggling a checkbox shouldn't freeze the whole screen
  final Set<String> _togglingIds = {};
  final Set<String> _deletingIds = {};

  bool _isCreating = false;
  String? _createError;

  // ─────────────────────────────────────────────
  // Public getters
  // ─────────────────────────────────────────────
  TaskBoardModel? get board => _board;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCreating => _isCreating;
  String? get createError => _createError;

  bool isToggling(String taskId) => _togglingIds.contains(taskId);
  bool isDeleting(String taskId) => _deletingIds.contains(taskId);

  bool get hasOverdue => (_board?.overdueCount ?? 0) > 0;
  int get overdueCount => _board?.overdueCount ?? 0;
  int get totalOpen => _board?.totalOpen ?? 0;

  // ─────────────────────────────────────────────
  // Initial load
  // ─────────────────────────────────────────────
  Future<void> loadBoard({String? caseId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _board = await _legalTaskRepository.getTaskBoard(caseId: caseId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({String? caseId}) async {
    _board = null;
    await loadBoard(caseId: caseId);
  }

  // ─────────────────────────────────────────────
  // Toggle completion — optimistic update
  // ─────────────────────────────────────────────
  Future<void> toggleCompletion(LegalTaskModel task) async {
    if (_board == null) return;
    _togglingIds.add(task.id);

    // 1. Apply optimistically
    final optimistic = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? DateTime.now() : null,
    );
    _board = _board!.withUpdatedTask(optimistic);
    notifyListeners();

    try {
      // 2. Confirm with server
      final confirmed = await _legalTaskRepository.toggleCompletion(
        taskId: task.id,
        isCompleted: !task.isCompleted,
      );
      // 3. Replace optimistic with confirmed server response
      _board = _board!.withUpdatedTask(confirmed);
    } catch (e) {
      // 4. Revert on failure
      _board = _board!.withUpdatedTask(task);
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _togglingIds.remove(task.id);
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // Create task manually (from Add Task sheet)
  // ─────────────────────────────────────────────
  Future<bool> createTask({
    required String caseId,
    required String taskTitle,
    String? notes,
    required TaskPriority priority,
    DateTime? dueDate,
  }) async {
    _isCreating = true;
    _createError = null;
    notifyListeners();
    try {
      final newTask = await _legalTaskRepository.createTask(
        caseId: caseId,
        taskTitle: taskTitle,
        notes: notes,
        priority: priority.apiValue,
        dueDate: dueDate,
      );
      // Add to board locally — no re-fetch needed
      _board = _board?.withNewTask(newTask);
      return true;
    } catch (e) {
      _createError = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ─────────────────────────────────────────────
  // Auto-create task from hearing save
  // Called by HearingViewModel after a successful POST /hearings
  //
  // Usage in your HearingCreateViewModel:
  //   await context.read<LegalTaskViewModel>().createAutoTask(
  //     caseId:        hearing.caseId,
  //     hearingId:     hearing.id,
  //     hearingDateTime: hearing.hearingDateTime,
  //     caseTitle:     hearing.caseTitle,
  //   );
  // ─────────────────────────────────────────────
  Future<void> createAutoTask({
    required String caseId,
    required String hearingId,
    required DateTime hearingDateTime,
    required String caseTitle,
  }) async {
    try {
      // Due date: 1 day before the hearing — lawyer needs prep time
      var dueDate = hearingDateTime.subtract(const Duration(days: 1));
      final now = DateTime.now();
      if (dueDate.isBefore(now)) {
        dueDate = now;
      }

      final newTask = await _legalTaskRepository.createTask(
        caseId: caseId,
        taskTitle: 'Prepare for hearing — $caseTitle',
        notes: 'Auto-created when hearing was scheduled.',
        priority: TaskPriority.high.apiValue,
        dueDate: dueDate,
        isAutoGenerated: true,
        sourceHearingId: hearingId,
      );
      _board = _board?.withNewTask(newTask);
      notifyListeners();
    } catch (e) {
      // 409 = duplicate auto-task — silent, not an error
      // Any other error — also silent (hearing save already succeeded)
      debugPrint('Auto-task creation skipped: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Edit task
  // ─────────────────────────────────────────────
  Future<bool> editTask({
    required String taskId,
    String? taskTitle,
    String? notes,
    TaskPriority? priority,
    DateTime? dueDate,
  }) async {
    try {
      final updated = await _legalTaskRepository.updateTask(
        taskId: taskId,
        taskTitle: taskTitle,
        notes: notes,
        priority: priority?.apiValue,
        dueDate: dueDate,
      );
      _board = _board?.withUpdatedTask(updated);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Delete task
  // ─────────────────────────────────────────────
  Future<bool> deleteTask(String taskId) async {
    _deletingIds.add(taskId);
    notifyListeners();
    try {
      await _legalTaskRepository.deleteTask(taskId);
      _board = _board?.withRemovedTask(taskId);
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _deletingIds.remove(taskId);
      notifyListeners();
    }
  }

  void clearCreateError() {
    _createError = null;
    notifyListeners();
  }

  void resetForm() {
    _dueDate = null;
    _selectedCaseId = null;
    _priority = TaskPriority.medium;
  }
}
