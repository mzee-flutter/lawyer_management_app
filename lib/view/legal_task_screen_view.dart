import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/system_design/rc_theme.dart';
import 'package:right_case/utils/snakebars_and_popUps/snake_bars.dart';
import 'package:right_case/view_model/cases_view_model/case_list_view_model.dart';

import '../models/case_models/legal_task_model.dart';
import '../view_model/cases_view_model/hearing_create_view_model/legal_task_view_model.dart';

// ─────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────
class _RC {
  static const navy = Color(0xFF1A2744);
  static const gold = Color(0xFFC8952A);
  static const background = Color(0xFFF7F5F1);
  static const surface = Color(0xFFFFFFFF);

  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
  static const textTertiary = Color(0xFF9CA3AF);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xFFB8C4D8);

  static const danger = Color(0xFFB91C1C);
  static const dangerSurface = Color(0xFFFEF2F2);
  static const dangerBorder = Color(0xFFFECACA);
  static const dangerText = Color(0xFF991B1B);

  static const warningSurface = Color(0xFFFFFBEB);
  static const warningBorder = Color(0xFFFDE68A);
  static const warningText = Color(0xFF92400E);

  static const successSurface = Color(0xFFF0FDF4);
  static const successBorder = Color(0xFFBBF7D0);
  static const successText = Color(0xFF166534);

  static const infoSurface = Color(0xFFEFF6FF);
  static const infoBorder = Color(0xFFBFDBFE);
  static const infoText = Color(0xFF1E40AF);

  static const divider = Color(0xFFE5E1D8);

  static BoxShadow get card => BoxShadow(
        color: Colors.black.withValues(alpha: 0.055),
        blurRadius: 10,
        offset: const Offset(0, 3),
      );

  // Priority colours
  static Color priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return danger;
      case TaskPriority.medium:
        return gold;
      case TaskPriority.low:
        return successText;
    }
  }

  static Color prioritySurface(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return dangerSurface;
      case TaskPriority.medium:
        return warningSurface;
      case TaskPriority.low:
        return successSurface;
    }
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class TaskBoardScreen extends StatefulWidget {
  const TaskBoardScreen({super.key});

  @override
  State<TaskBoardScreen> createState() => _TaskBoardScreenState();
}

class _TaskBoardScreenState extends State<TaskBoardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LegalTaskViewModel>().loadBoard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RC.background,
      appBar: _buildAppBar(),
      floatingActionButton: _AddFab(),
      body: Consumer<LegalTaskViewModel>(
        builder: (_, vm, __) => RefreshIndicator(
          color: _RC.navy,
          onRefresh: vm.refresh,
          child: _buildBody(vm),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _RC.navy,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Consumer<LegalTaskViewModel>(
        builder: (_, vm, __) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Legal tasks',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _RC.textOnDark)),
            Text(
              vm.board != null
                  ? '${vm.totalOpen} open · ${vm.overdueCount} overdue'
                  : 'Loading...',
              style: TextStyle(fontSize: 11.sp, color: _RC.textOnDarkMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(LegalTaskViewModel vm) {
    if (vm.isLoading) return const _Skeleton();
    if (vm.error != null) {
      return _ErrorState(message: vm.error!, onRetry: vm.refresh);
    }
    if (vm.board == null) return const SizedBox.shrink();

    final board = vm.board!;
    final allEmpty = board.totalOpen == 0 && board.completed.isEmpty;

    if (allEmpty) return const _EmptyState();

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Overdue — always shown first, red header
        if (board.overdue.isNotEmpty)
          _BucketSliver(
            bucket: TaskBucket.overdue,
            tasks: board.overdue,
            isUrgent: true,
          ),

        // This week
        if (board.thisWeek.isNotEmpty)
          _BucketSliver(
            bucket: TaskBucket.thisWeek,
            tasks: board.thisWeek,
          ),

        // Upcoming
        if (board.upcoming.isNotEmpty)
          _BucketSliver(
            bucket: TaskBucket.upcoming,
            tasks: board.upcoming,
          ),

        // No date
        if (board.noDate.isNotEmpty)
          _BucketSliver(
            bucket: TaskBucket.noDate,
            tasks: board.noDate,
          ),

        // Completed — collapsed by default
        if (board.completed.isNotEmpty)
          _CompletedBucketSliver(tasks: board.completed),

        SliverToBoxAdapter(child: SizedBox(height: 100.h)),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// FAB — opens Add Task sheet
// ─────────────────────────────────────────────
class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      backgroundColor: _RC.navy,
      foregroundColor: _RC.textOnDark,
      icon: const Icon(Icons.add),
      label:
          const Text('Add task', style: TextStyle(fontWeight: FontWeight.w500)),
      onPressed: () => _showAddTaskSheet(context),
    );
  }

  static void _showAddTaskSheet(BuildContext context) {
    final taskVM = context.read<LegalTaskViewModel>();
    taskVM.resetForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<LegalTaskViewModel>(),
        child: const _AddEditTaskSheet(),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Bucket sliver — header + task list
// ─────────────────────────────────────────────
class _BucketSliver extends StatelessWidget {
  final TaskBucket bucket;
  final List<LegalTaskModel> tasks;
  final bool isUrgent;

  const _BucketSliver({
    required this.bucket,
    required this.tasks,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _BucketHeader(
              bucket: bucket, count: tasks.length, isUrgent: isUrgent),
          SizedBox(height: 8.h),
          ...tasks.map((t) => _TaskCard(task: t)),
        ]),
      ),
    );
  }
}

class _BucketHeader extends StatelessWidget {
  final TaskBucket bucket;
  final int count;
  final bool isUrgent;
  const _BucketHeader(
      {required this.bucket, required this.count, required this.isUrgent});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
              color: isUrgent ? _RC.danger : _RC.gold,
              borderRadius: BorderRadius.circular(2)),
        ),
        SizedBox(width: 8.w),
        Text(
          bucket.label.toUpperCase(),
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.7,
            color: isUrgent ? _RC.dangerText : _RC.textSecondary,
          ),
        ),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
          decoration: BoxDecoration(
            color:
                isUrgent ? _RC.dangerSurface : _RC.navy.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isUrgent ? _RC.dangerText : _RC.navy,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Task card
// ─────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final LegalTaskModel task;
  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LegalTaskViewModel>();
    final isToggling = vm.isToggling(task.id);
    final isDeleting = vm.isDeleting(task.id);

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: _RC.dangerSurface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child:
            Icon(Icons.delete_outline_rounded, color: _RC.danger, size: 22.sp),
      ),
      confirmDismiss: (direction) async {
        final confirm = await _confirmDelete(context);
        if (confirm != true) return false;
        final success = await vm.deleteTask(task.id);

        if (!success && context.mounted) {
          SnakeBars.scaffoldMessenger("Failed to delete task", context);
        }
        return success;
      },
      onDismissed: (_) {
        // vm.deleteTask(task.id);
        // if (context.mounted) {
        //   SnakeBars.scaffoldMessenger("Task removed", context);
        // }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: task.isCompleted
              ? _RC.surface.withValues(alpha: 0.6)
              : _RC.surface,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [_RC.card],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Priority accent bar
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? _RC.divider
                      : _RC.priorityColor(task.priority),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14.r),
                    bottomLeft: Radius.circular(14.r),
                  ),
                ),
              ),
              // Checkbox
              ///To get the perfect circular shape using screen utils extensions then we must have to use
              ///same scaling extension for both height and width like (h,w,r)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                child: isToggling
                    ? Center(
                        child: SizedBox(
                          height: 20.r,
                          width: 20.r,
                          child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _RC.priorityColor(task.priority)),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => vm.toggleCompletion(task),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 20.w,
                          height: 20.w,
                          decoration: BoxDecoration(
                            color: task.isCompleted
                                ? _RC.priorityColor(task.priority)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: task.isCompleted
                                  ? _RC.priorityColor(task.priority)
                                  : _RC.divider,
                              width: 1.5,
                            ),
                          ),
                          child: task.isCompleted
                              ? Icon(Icons.check_rounded,
                                  size: 12.sp, color: Colors.white)
                              : null,
                        ),
                      ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h)
                      .copyWith(right: 12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.taskTitle,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: task.isCompleted
                              ? _RC.textTertiary
                              : _RC.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: _RC.textTertiary,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      // Case link
                      Row(
                        children: [
                          Icon(Icons.cases_outlined,
                              size: 10.sp, color: _RC.textSecondary),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              task.caseTitle,
                              style: TextStyle(
                                  fontSize: 10.sp, color: _RC.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      // Bottom meta row: due date + priority + auto badge
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          // Due date chip
                          if (!task.isCompleted)
                            _MetaChip(
                              icon: task.isOverdue
                                  ? Icons.warning_amber_rounded
                                  : Icons.schedule_outlined,
                              label: task.dueDateLabel,
                              color: task.isOverdue
                                  ? _RC.dangerText
                                  : _RC.textSecondary,
                              bg: task.isOverdue ? _RC.dangerSurface : null,
                            ),
                          // Priority badge
                          _MetaChip(
                            icon: Icons.flag_outlined,
                            label: task.priority.label,
                            color: task.isCompleted
                                ? _RC.textTertiary
                                : _RC.priorityColor(task.priority),
                            bg: task.isCompleted
                                ? null
                                : _RC.prioritySurface(task.priority),
                          ),
                          // Auto-generated badge
                          if (task.isAutoGenerated)
                            _MetaChip(
                              icon: Icons.auto_awesome_outlined,
                              label: 'Auto',
                              color: _RC.infoText,
                              bg: _RC.infoSurface,
                            ),
                        ],
                      ),
                      // Notes preview
                      if (task.notes != null &&
                          task.notes!.isNotEmpty &&
                          !task.isCompleted) ...[
                        SizedBox(height: 6.h),
                        Text(
                          task.notes!,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: _RC.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              // Edit button
              if (!task.isCompleted)
                Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined,
                            size: 16.sp, color: _RC.textTertiary),
                        onPressed: () => _showEditSheet(context, task),
                        constraints: BoxConstraints.tight(Size(32.w, 32.w)),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        title: const Text('Delete task?'),
        content: Text(
          'Delete "${task.taskTitle}"? This cannot be undone.',
          style: TextStyle(fontSize: 13.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: _RC.danger),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, LegalTaskModel task) {
    final taskVM = context.read<LegalTaskViewModel>();
    taskVM.setDueDate(task.dueDate);
    taskVM.setSelectedCaseId(task.caseId);
    taskVM.setTaskPriority(task.priority);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<LegalTaskViewModel>(),
        child: _AddEditTaskSheet(existingTask: task),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Completed bucket — collapsible
// ─────────────────────────────────────────────
class _CompletedBucketSliver extends StatefulWidget {
  final List<LegalTaskModel> tasks;
  const _CompletedBucketSliver({required this.tasks});

  @override
  State<_CompletedBucketSliver> createState() => _CompletedBucketSliverState();
}

class _CompletedBucketSliverState extends State<_CompletedBucketSliver> {
  final ValueNotifier<bool> _expandNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      sliver: ValueListenableBuilder<bool>(
        valueListenable: _expandNotifier,
        builder: (context, isExpanded, child) {
          return SliverList(
            delegate: SliverChildListDelegate([
              // Collapsible header
              GestureDetector(
                onTap: () => _expandNotifier.value = !_expandNotifier.value,
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 16,
                      decoration: BoxDecoration(
                        color: _RC.successText,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.7,
                        color: _RC.successText,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _RC.successSurface,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        '${widget.tasks.length}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _RC.successText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: _RC.textTertiary,
                      size: 18.sp,
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                SizedBox(height: 8.h),
                ...widget.tasks.map((t) => _TaskCard(task: t)),
              ],
            ]),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Add / Edit task bottom sheet
// ─────────────────────────────────────────────
class _AddEditTaskSheet extends StatefulWidget {
  final LegalTaskModel? existingTask;
  const _AddEditTaskSheet({this.existingTask});

  @override
  State<_AddEditTaskSheet> createState() => _AddEditTaskSheetState();
}

class _AddEditTaskSheetState extends State<_AddEditTaskSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _notesCtrl;

  final _formKey = GlobalKey<FormState>();

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleCtrl = TextEditingController(text: t?.taskTitle ?? '');
    _notesCtrl = TextEditingController(text: t?.notes ?? '');
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskVM = context.watch<LegalTaskViewModel>();
    final casesVM = context.read<CaseListViewModel>();
    final String? originalTaskCaseId = widget.existingTask?.caseId;

// 2. Check if that specific case actually exists in the current active list
    final bool caseExists = originalTaskCaseId == null ||
        casesVM.filterCases.any((c) => c.id == originalTaskCaseId);

    final String? safeValue =
        (casesVM.filterCases.isEmpty && originalTaskCaseId != null)
            ? null
            : originalTaskCaseId;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: _RC.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: _RC.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                Text(
                  _isEditing ? 'Edit task' : 'New task',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: _RC.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                DropdownButtonFormField<String>(
                  borderRadius: BorderRadius.circular(12.r),
                  dropdownColor: _RC.surface,
                  initialValue: safeValue,
                  items: [
                    if (originalTaskCaseId != null &&
                        !caseExists &&
                        casesVM.filterCases.isNotEmpty)
                      DropdownMenuItem<String>(
                        value: originalTaskCaseId,
                        enabled: false,
                        child: Text("Deleted case"),
                      ),
                    ...casesVM.filterCases.map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text("${c.caseNumber} — ${c.firstPartyName}"),
                      ),
                    ),
                  ],
                  onChanged: (value) => taskVM.setSelectedCaseId(value),
                  validator: (v) => v == null ? "Please select a case" : null,
                  decoration: _inputDecoration(
                    "Select a case",
                    Icons.cases_outlined,
                  ),
                ),
                SizedBox(height: 16.h),
                // Task title
                _FieldLabel('Task *'),
                SizedBox(height: 5.h),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _inputDecoration('e.g. Prepare written statement',
                      Icons.checklist_rounded),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Task title is required'
                      : null,
                ),
                SizedBox(height: 12.h),

                // Priority selector
                _FieldLabel('Priority'),
                SizedBox(height: 6.h),
                Row(
                  children: TaskPriority.values.map((p) {
                    final isSelected = taskVM.priority == p;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                            right: p != TaskPriority.low ? 8.w : 0),
                        child: GestureDetector(
                          onTap: () => taskVM.setTaskPriority(p),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: EdgeInsets.symmetric(vertical: 9.h),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _RC.prioritySurface(p)
                                  : _RC.background,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: isSelected
                                    ? _RC.priorityColor(p)
                                    : _RC.divider,
                                width: isSelected ? 1.5 : 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flag_outlined,
                                    size: 13.sp,
                                    color: isSelected
                                        ? _RC.priorityColor(p)
                                        : _RC.textTertiary),
                                SizedBox(width: 5.w),
                                Text(
                                  p.label,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? _RC.priorityColor(p)
                                        : _RC.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 12.h),

                // Due date picker
                _FieldLabel('Due date (optional)'),
                SizedBox(height: 5.h),
                GestureDetector(
                  onTap: () => _pickDate(context),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: _RC.background,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: _RC.divider, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 16.sp, color: _RC.textSecondary),
                        SizedBox(width: 10.w),
                        Text(
                          taskVM.dueDate != null
                              ? _formatDate(taskVM.dueDate!)
                              : 'Select a date',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: taskVM.dueDate != null
                                ? _RC.textPrimary
                                : _RC.textTertiary,
                          ),
                        ),
                        const Spacer(),
                        if (taskVM.dueDate != null)
                          GestureDetector(
                            onTap: () {
                              taskVM.setDueDate(null);
                            },
                            child: Icon(
                              Icons.close_rounded,
                              size: 16.sp,
                              color: _RC.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Notes
                _FieldLabel('Notes (optional)'),
                SizedBox(height: 5.h),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: _inputDecoration(
                    'Additional details...',
                    Icons.notes_outlined,
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 20.h),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _RC.navy,
                      foregroundColor: _RC.textOnDark,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r)),
                    ),
                    onPressed: taskVM.isCreating
                        ? null
                        : () => _submit(context, taskVM),
                    child: taskVM.isCreating
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isEditing ? 'Save changes' : 'Add task',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                if (taskVM.createError != null) ...[
                  SizedBox(height: 8.h),
                  Text(
                    taskVM.createError!,
                    style: TextStyle(fontSize: 12.sp, color: _RC.danger),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final taskVM = context.read<LegalTaskViewModel>();
    final picked = await showDatePicker(
      context: context,
      initialDate: taskVM.dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (_, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: _RC.navy),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      taskVM.setDueDate(picked);
    }
  }

  Future<void> _submit(BuildContext context, LegalTaskViewModel vm) async {
    if (!_formKey.currentState!.validate()) return;

    bool success;

    if (_isEditing) {
      success = await vm.editTask(
        taskId: widget.existingTask!.id,
        taskTitle: _titleCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        priority: vm.priority,
        dueDate: vm.dueDate,
      );
    } else {
      // See INTEGRATION.dart Step 5 for wiring the case selector
      if (vm.selectedCaseId == null) {
        SnakeBars.scaffoldMessenger("Please select a case", context);
        return;
      }
      success = await vm.createTask(
        caseId: vm.selectedCaseId!,
        taskTitle: _titleCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        priority: vm.priority,
        dueDate: vm.dueDate,
      );
    }

    if (success && context.mounted) Navigator.pop(context);
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18.sp, color: _RC.textSecondary),
      filled: true,
      fillColor: _RC.background,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: _RC.divider, width: 0.5)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: _RC.divider, width: 0.5)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: _RC.navy, width: 1.5)),
      hintStyle: TextStyle(color: _RC.textTertiary, fontSize: 12.sp),
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
    );
  }
}

// ─────────────────────────────────────────────
// Shared small widgets
// ─────────────────────────────────────────────
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? bg;
  const _MetaChip(
      {required this.icon, required this.label, required this.color, this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: bg != null
          ? BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6.r))
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.sp, color: color),
          SizedBox(width: 3.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: bg != null ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: _RC.textSecondary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                  color: RC.navy.withValues(alpha: 0.07),
                  shape: BoxShape.circle),
              child: Icon(
                Icons.checklist_rounded,
                size: 32.sp,
                color: RC.navy.withValues(alpha: 0.4),
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
            SizedBox(height: 16.h),
            Text('No tasks yet', style: RC.heading())
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
            SizedBox(height: 6.h),
            Text(
              'Tap the button below to add your first task,\nor save a hearing to auto-create one.',
              style: RC.body(color: RC.textSecondary),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: List.generate(
        4,
        (_) => Container(
          height: 90.h,
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: _RC.divider.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(14.r),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String? title;

  const _ErrorState({
    required this.message,
    required this.onRetry,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        // No borders, no shadows. It sits natively on whatever background it's placed over.
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Polite, Muted Icon
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: _RC.danger.withValues(alpha: 0.08), // Soft tint
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .cloud_off_rounded, // A softer conceptual icon than an alert triangle
                color: _RC.danger.withValues(alpha: 0.9),
                size: 32.sp,
              ),
            ).animate().scale(
                  duration: 400.ms,
                  curve: Curves.easeOutBack,
                ),

            SizedBox(height: 16.h),

            // 2. Integrated Typography (Using Standard UI Colors)
            Text(
              title ?? 'Couldn\'t load data',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: _RC
                    .textPrimary, // Blends perfectly with your standard app headers
                letterSpacing: -0.2,
              ),
            )
                .animate()
                .fadeIn(delay: 100.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),

            SizedBox(height: 6.h),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: _RC
                    .textSecondary, // Blends with your standard app subtitles
                height: 1.4,
              ),
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),

            SizedBox(height: 16.h),

            // 3. Tonal, Inline Action Button
            TextButton.icon(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: _RC.navy, // Your standard primary action color
                backgroundColor: _RC.navy
                    .withValues(alpha: 0.06), // Very soft "Tonal" background
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 16.sp),
              label: Text(
                'Try again',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.1,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 300.ms)
                .slideY(begin: 0.1, end: 0),
          ],
        ),
      ),
    );
  }
}
