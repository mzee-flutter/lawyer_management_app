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
  final ValueNotifier<bool> _isNotifierOpen = ValueNotifier<bool>(false);
  final ScrollController _dropdownScrollController = ScrollController();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  final Set<String> _expandedNodeIds = {};

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    _isNotifierOpen.value = false;
  }

  List<Map<String, dynamic>> _buildFlattenedItems(
    List<CourtCategoryModel> nodes, {
    int depth = 0,
    String? parentId,
  }) {
    final List<Map<String, dynamic>> flatList = [];
    for (final node in nodes) {
      flatList.add({'node': node, 'depth': depth, 'parentId': parentId});
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

  bool _traceAndExpandLineage(List<CourtCategoryModel> nodes, String targetId) {
    for (final node in nodes) {
      if (node.id == targetId) return true;
      final hasChildren =
          node.subcategories != null && node.subcategories!.isNotEmpty;
      if (hasChildren &&
          _traceAndExpandLineage(node.subcategories!, targetId)) {
        _expandedNodeIds.add(node.id);
        return true;
      }
    }
    return false;
  }

  void _showOverlay(BuildContext context, Size fieldSize, Offset fieldOffset) {
    if (_isNotifierOpen.value) {
      _removeOverlay();
      return;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight =
        screenHeight - fieldOffset.dy - fieldSize.height - bottomPadding - 12.h;
    final maxHeight = availableHeight > 320 ? availableHeight : 320.0;

    _overlay = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
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
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300, width: 1.w),
                  ),
                  child: StatefulBuilder(
                    builder: (sbContext, setOverlayState) {
                      final vm = sbContext.read<CourtTypeViewModel>();
                      final flattenedItems = _buildFlattenedItems(vm.courtType);

                      return Theme(
                        data: Theme.of(sbContext).copyWith(
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
                            itemBuilder: (_, index) {
                              final item = flattenedItems[index];
                              final CourtCategoryModel node = item['node'];
                              final int depth = item['depth'];

                              final hasChildren = node.subcategories != null &&
                                  node.subcategories!.isNotEmpty;
                              final isExpanded =
                                  _expandedNodeIds.contains(node.id);

                              // ─────────────────────────────────────────
                              // FIX 1: Depth-aware selection highlight.
                              // Only the DEEPEST selected leaf is shown as
                              // selected; ancestor rows are never falsely lit.
                              // ─────────────────────────────────────────
                              final bool isCurrentlySelected = switch (depth) {
                                0 => vm.selectedCourtId == node.id &&
                                    vm.selectedSubCourtId == null,
                                1 => vm.selectedSubCourtId == node.id &&
                                    vm.selectedSubSubCourtId == null,
                                _ => vm.selectedSubSubCourtId == node.id,
                              };

                              double leftPadding = 12.w;
                              Color cardBgColor = Colors.white;
                              TextStyle textStyle = TextStyle(
                                  color: Colors.black87, fontSize: 14.sp);
                              String displayPrefix = "";

                              if (depth == 0) {
                                leftPadding = 12.w;
                                cardBgColor = Colors.grey[300]!;
                                textStyle = TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                );
                              } else if (depth == 1) {
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
                                if (!hasChildren) {
                                  displayPrefix = "↳  ";
                                  cardBgColor = isCurrentlySelected
                                      ? Colors.blue.shade50
                                          .withValues(alpha: 0.5)
                                      : Colors.white;
                                }
                              } else {
                                // depth == 2 (Layer 3)
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
                                    // Parent node: toggle expand / collapse only
                                    setOverlayState(() {
                                      _expandedNodeIds.contains(node.id)
                                          ? _expandedNodeIds.remove(node.id)
                                          : _expandedNodeIds.add(node.id);
                                    });
                                  } else {
                                    // ───────────────────────────────────
                                    // FIX 2: Depth-aware VM update.
                                    // The overlay is the single source of
                                    // truth — parent onSelected() callback
                                    // must NOT call VM methods again.
                                    // ───────────────────────────────────
                                    switch (depth) {
                                      case 0:
                                        vm.selectCourtType(node.id, node.name);
                                      case 1:
                                        vm.selectSubCategoryById(node.id);
                                      default: // depth 2 +
                                        vm.selectSubSubCategoryById(node.id);
                                    }
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
    _isNotifierOpen.value = true;
  }

  Future<void> _onTapField(BuildContext context, RenderBox renderBox) async {
    final vm = context.read<CourtTypeViewModel>();
    if (vm.loading) return;

    if (vm.courtType.isEmpty) await vm.fetchCourtType();
    if (vm.courtType.isEmpty) return;

    // ─────────────────────────────────────────────────────────────────
    // FIX 3: Trace from the DEEPEST selected ID so every ancestor folder
    // (Layer 1 and Layer 2) is expanded before the overlay opens.
    // Old code only used selectedSubCourtId, which never expanded the
    // Layer-2 folder needed to reveal a Layer-3 item.
    // ─────────────────────────────────────────────────────────────────
    _expandedNodeIds.clear();
    final deepestId =
        vm.selectedSubSubCourtId ?? vm.selectedSubCourtId ?? vm.selectedCourtId;
    if (deepestId != null) {
      _traceAndExpandLineage(vm.courtType, deepestId);
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
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          final renderBox = context.findRenderObject() as RenderBox?;
          if (renderBox != null) _onTapField(context, renderBox);
        },
        child: Consumer<CourtTypeViewModel>(
          builder: (_, courtTypeVM, __) {
            final displayText = courtTypeVM.selectedSubSubCourtName ??
                courtTypeVM.selectedSubCourtName ??
                courtTypeVM.selectedCourtName ??
                widget.label;
            final hasSelection = courtTypeVM.selectedSubSubCourtId != null ||
                courtTypeVM.selectedSubCourtId != null ||
                courtTypeVM.selectedCourtId != null;

            return ValueListenableBuilder<bool>(
              valueListenable: _isNotifierOpen,
              builder: (_, isOpen, __) {
                return Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color:
                          isOpen ? Colors.grey.shade600 : Colors.grey.shade300,
                      width: isOpen ? 1.5.w : 1.w,
                    ),
                    boxShadow: isOpen
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
                            color: hasSelection
                                ? Colors.black87
                                : Colors.grey.shade500,
                            fontWeight: hasSelection
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      courtTypeVM.loading
                          ? SizedBox(
                              height: 16.r,
                              width: 16.r,
                              child: CircularProgressIndicator(
                                color: Colors.blue.shade700,
                                strokeWidth: 2.w,
                              ),
                            )
                          : Icon(
                              isOpen
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              color: Colors.black87,
                              size: 20.r,
                            ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
