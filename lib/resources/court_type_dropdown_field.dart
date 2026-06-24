import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/view_model/cases_view_model/court_type_view_model.dart';

class CourtTypeDropdownField extends StatefulWidget {
  final String label;
  final void Function(String id) onSelected;

  const CourtTypeDropdownField({
    super.key,
    required this.label,
    required this.onSelected,
  });

  @override
  State<CourtTypeDropdownField> createState() => _CourtTypeDropdownFieldState();
}

class _CourtTypeDropdownFieldState extends State<CourtTypeDropdownField> {
  final ScrollController _dropdownScrollController = ScrollController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;

  /// Tracks active expanded node IDs inside the overlay canvas view state
  final Set<String> _expandedNodeIds = {};

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    context.read<CourtTypeViewModel>().toggleCourtTypeDropdownOpening(false);
  }

  /// RECURSIVE ENGINE: Linearizes your tree matrix.
  /// Only goes deeper if the user explicitly clicked/expanded the parent folder branch.
  List<Map<String, dynamic>> _buildFlattenedItems(
    List<CourtCategoryModel> nodes, {
    int depth = 0,
    String? parentId,
  }) {
    List<Map<String, dynamic>> flatList = [];
    for (var node in nodes) {
      flatList.add({
        'node': node,
        'depth': depth,
        'parentId': parentId,
      });

      final hasChildren =
          node.subcategories != null && node.subcategories!.isNotEmpty;
      if (hasChildren && _expandedNodeIds.contains(node.id)) {
        flatList.addAll(_buildFlattenedItems(
          node.subcategories!,
          depth: depth + 1,
          parentId: node.id,
        ));
      }
    }
    return flatList;
  }

  /// LINEAGE TRACER ENGINE (Rule 2 Fix): Deep scans your whole tree list down
  /// to find the selected node, then maps all its historical direct ancestral parent
  /// folder IDs to [_expandedNodeIds] so they display pre-expanded.
  bool _traceAndExpandLineage(List<CourtCategoryModel> nodes, String targetId) {
    for (var node in nodes) {
      if (node.id == targetId) {
        return true; // Match target found
      }

      final hasChildren =
          node.subcategories != null && node.subcategories!.isNotEmpty;
      if (hasChildren) {
        final bool isTargetInSubtree =
            _traceAndExpandLineage(node.subcategories!, targetId);
        if (isTargetInSubtree) {
          _expandedNodeIds.add(
              node.id); // Ancestor parent identified! Add to expansion pool.
          return true;
        }
      }
    }
    return false;
  }

  void _showOverlay(BuildContext context, Size fieldSize, Offset fieldOffset) {
    if (context.read<CourtTypeViewModel>().isOpen) {
      _removeOverlay();
      return;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight =
        screenHeight - fieldOffset.dy - fieldSize.height - bottomPadding - 12.h;
    final maxHeight = availableHeight > 320 ? availableHeight : 320;

    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Safe Modal Dismiss Tap Barrier
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: Container(color: Colors.transparent),
              ),
            ),
            // Track Layer Target Positioning Follower
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, fieldSize.height + 6.h),
              child: Material(
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: fieldSize.width,
                  constraints: BoxConstraints(maxHeight: maxHeight.toDouble()),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300, width: 1.w),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      final vm = context.read<CourtTypeViewModel>();
                      final flattenedItems = _buildFlattenedItems(vm.courtType);

                      return Theme(
                        data: Theme.of(context).copyWith(
                          scrollbarTheme: ScrollbarThemeData(
                            thumbColor:
                                WidgetStateProperty.all(Colors.grey.shade400),
                            radius: Radius.circular(4.r),
                          ),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          controller: _dropdownScrollController,
                          child: ListView.builder(
                            controller: _dropdownScrollController,
                            shrinkWrap: true,
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            itemCount: flattenedItems.length,
                            itemBuilder: (context, index) {
                              final item = flattenedItems[index];
                              final CourtCategoryModel node = item['node'];
                              final int depth = item['depth'];

                              final hasChildren = node.subcategories != null &&
                                  node.subcategories!.isNotEmpty;
                              final isExpanded =
                                  _expandedNodeIds.contains(node.id);
                              final bool isCurrentlySelected =
                                  vm.selectedSubCourtId == node.id;

                              double leftPadding = 12.w;
                              Color cardBgColor = Colors.white;
                              TextStyle textStyle = TextStyle(
                                  color: Colors.black87, fontSize: 14.sp);
                              String displayPrefix = "";

                              // Rule 3 Implementation: If it doesn't have children, it is a select-safe action leaf node!
                              final bool isSelectableLeafNode = !hasChildren;

                              if (depth == 0) {
                                // Level 1: Root Base Header Categories
                                leftPadding = 12.w;
                                cardBgColor = Colors.grey[300]!;
                                textStyle = TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp);
                              } else if (depth == 1) {
                                // Level 2: Sub-category Layer
                                leftPadding = 24.w;
                                cardBgColor = Colors.grey[200]!;
                                textStyle = TextStyle(
                                  color: isCurrentlySelected
                                      ? Colors.blue.shade700
                                      : Colors.grey[800],
                                  fontWeight: isCurrentlySelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  fontSize: 13.5.sp,
                                );
                                if (isSelectableLeafNode) {
                                  displayPrefix = "↳  ";
                                  if (isCurrentlySelected) {
                                    cardBgColor = Colors.blue.shade50
                                        .withValues(alpha: 0.5);
                                  } else {
                                    cardBgColor = Colors
                                        .white; // Dynamic fallback if level-2 acts as a leaf node
                                  }
                                }
                              } else if (depth == 2) {
                                // Level 3: Deep Sub-sub category Layer
                                leftPadding = 38.w;
                                cardBgColor = isCurrentlySelected
                                    ? Colors.blue.shade50.withValues(alpha: 0.5)
                                    : Colors.white;
                                textStyle = TextStyle(
                                  color: isCurrentlySelected
                                      ? Colors.blue.shade700
                                      : Colors.black87,
                                  fontWeight: isCurrentlySelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14.sp,
                                );
                                displayPrefix = "↳  ";
                              }

                              return InkWell(
                                onTap: () {
                                  if (hasChildren) {
                                    // It has subcategories: Tapping toggles open/collapse states
                                    setOverlayState(() {
                                      if (_expandedNodeIds.contains(node.id)) {
                                        _expandedNodeIds.remove(node.id);
                                      } else {
                                        _expandedNodeIds.add(node.id);
                                      }
                                    });
                                  } else {
                                    // Rule 3 Complete Fix: Terminal Safe Leaf Node Found - Select and dismiss!
                                    vm.selectSubCourtType(node.id, node.name);

                                    final parent = vm.findParentOfSub(node.id);
                                    vm.selectedCourtId = parent?.id;
                                    vm.selectedCourtName = parent?.name;

                                    widget.onSelected(node.id);
                                    _removeOverlay();
                                  }
                                },
                                child: Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(
                                      vertical: 2.h, horizontal: 8.w),
                                  padding: EdgeInsets.symmetric(
                                          horizontal: 12.w, vertical: 12.h)
                                      .copyWith(left: leftPadding),
                                  decoration: BoxDecoration(
                                    color: cardBgColor,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "$displayPrefix${node.name}",
                                          style: textStyle,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (hasChildren)
                                        Icon(
                                          isExpanded
                                              ? Icons
                                                  .keyboard_arrow_down_rounded
                                              : Icons
                                                  .keyboard_arrow_right_rounded,
                                          size: 18.r,
                                          color: Colors.grey.shade600,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    context.read<CourtTypeViewModel>().toggleCourtTypeDropdownOpening(true);
  }

  Future<void> _onTapField(BuildContext context, RenderBox renderBox) async {
    final vm = context.read<CourtTypeViewModel>();
    if (vm.loading) return;

    if (vm.courtType.isEmpty) {
      await vm.fetchCourtType();
    }
    if (vm.courtType.isEmpty) return;

    // Rule 2 Complete Fix: Pre-expansion line execution sequence
    _expandedNodeIds.clear();
    if (vm.selectedSubCourtId != null) {
      _traceAndExpandLineage(vm.courtType, vm.selectedSubCourtId!);
    }

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    _showOverlay(context, size, offset);
  }

  @override
  void dispose() {
    _removeOverlay();
    _dropdownScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courtTypeVM = context.watch<CourtTypeViewModel>();
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) {
            _onTapField(context, renderBox);
          }
        },
        child: Consumer<CourtTypeViewModel>(
          builder: (context, vm, child) {
            final displayText =
                vm.selectedSubCourtName ?? vm.selectedCourtName ?? widget.label;
            final hasSelectedValue =
                vm.selectedSubCourtId != null || vm.selectedCourtId != null;

            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: courtTypeVM.isOpen
                      ? Colors.grey.shade600
                      : Colors.grey.shade300,
                  width: courtTypeVM.isOpen ? 1.5.w : 1.w,
                ),
                boxShadow: courtTypeVM.isOpen
                    ? [
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 0.08),
                          blurRadius: 6.r,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      displayText,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: hasSelectedValue
                            ? Colors.black87
                            : Colors.grey.shade500,
                        fontWeight: hasSelectedValue
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  vm.loading
                      ? SizedBox(
                          height: 16.r,
                          width: 16.r,
                          child: CircularProgressIndicator(
                            color: Colors.blue.shade700,
                            strokeWidth: 2.w,
                          ),
                        )
                      : Icon(
                          courtTypeVM.isOpen
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          color: Colors.black87,
                          size: 20.r,
                        ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
