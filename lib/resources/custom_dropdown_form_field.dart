import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomDropdownFormField<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String Function(T) getId;
  final String Function(T) getLabel;
  final void Function(String id) onSelected;
  final ChangeNotifier viewModel;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    required this.items,
    required this.getId,
    required this.getLabel,
    required this.onSelected,
    required this.viewModel,
  });

  @override
  State<CustomDropdownFormField<T>> createState() =>
      _CustomDropdownFormFieldState<T>();
}

class _CustomDropdownFormFieldState<T>
    extends State<CustomDropdownFormField<T>> {
  final ScrollController _dropdownScrollController = ScrollController();
  final ValueNotifier<bool> _isOpenNotifier = ValueNotifier<bool>(false);

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    _isOpenNotifier.value = false;
  }

  void _showOverlay(BuildContext context, Size fieldSize, Offset fieldOffset) {
    if (_isOpenNotifier.value) {
      _removeOverlay();
      return;
    }

    final vm = widget.viewModel as dynamic;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final availableHeight =
        screenHeight - fieldOffset.dy - fieldSize.height - bottomPadding - 12.h;
    final maxHeight = availableHeight > 160 ? availableHeight : 250;

    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: Container(color: Colors.transparent),
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
                  constraints: BoxConstraints(maxHeight: maxHeight.toDouble()),
                  decoration: BoxDecoration(
                    // Monochromatic canvas matching court dropdown
                    color: Colors.grey[50],

                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade300, width: 1.w),
                  ),
                  child: Theme(
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
                        itemCount: vm.items.length,
                        itemBuilder: (context, index) {
                          final item = vm.items[index];
                          final id = widget.getId(item);
                          final label = widget.getLabel(item);
                          final bool isSelected = vm.selectedId == id;

                          return InkWell(
                            onTap: () {
                              _removeOverlay();
                              vm.selectItem(id, label);
                              widget.onSelected(id);
                            },
                            child: Container(
                              width: double.infinity,
                              margin: EdgeInsets.symmetric(
                                  vertical: 2.h, horizontal: 8.w),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.blue.shade50.withValues(alpha: 0.5)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                isSelected
                                    ? "↳  $label"
                                    : label, // Tonal indicator branch asset helper
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.blue.shade700
                                      : Colors.black87,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    _isOpenNotifier.value = true;
  }

  Future<void> _onTapField(BuildContext context, RenderBox renderBox) async {
    final vm = widget.viewModel as dynamic;
    if (vm.loading == true) return;

    if (vm.items.isEmpty) {
      await vm.fetchItems();
    }
    if (vm.items.isEmpty) return;

    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    _showOverlay(context, size, offset);
  }

  @override
  void dispose() {
    _removeOverlay();
    _dropdownScrollController.dispose();
    _isOpenNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, child) {
          final dynamic v = widget.viewModel as dynamic;
          final hasSelectedValue = v.selectedName != null;

          return ValueListenableBuilder<bool>(
            valueListenable: _isOpenNotifier,
            builder: (context, isOpen, child) {
              return GestureDetector(
                onTap: () {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  if (renderBox != null) _onTapField(context, renderBox);
                },
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.grey[
                        50], // Tones converted from harsh dark grey[300] to soft minimal 50
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
                          v.selectedName ?? widget.label,
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
                      v.loading == true
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
                ),
              );
            },
          );
        },
      ),
    );
  }
}
