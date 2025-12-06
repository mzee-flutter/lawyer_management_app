import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    _isOpen = false;
  }

  void _showOverlay(BuildContext context, Size fieldSize, Offset fieldOffset) {
    if (_isOpen) {
      _removeOverlay();
      return;
    }

    final vm = widget.viewModel as dynamic;

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final availableHeight =
        screenHeight - fieldOffset.dy - fieldSize.height - bottomPadding - 6.h;

    final maxHeight = availableHeight > 150 ? availableHeight : 150;

    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, fieldSize.height + 6.h),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8.r),
                child: Container(
                  width: fieldSize.width,
                  constraints: BoxConstraints(maxHeight: maxHeight.toDouble()),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: _buildList(context, vm),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    _isOpen = true;
  }

  Widget _buildList(BuildContext context, dynamic vm) {
    final items = vm.items;
    final selectedId = vm.selectedId;

    if (items.isEmpty) {
      return SizedBox(
        height: 80.h,
        child: Center(child: Text("No items")),
      );
    }

    return Scrollbar(
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => Divider(height: 1.h),
        itemBuilder: (context, index) {
          final item = items[index];
          final id = widget.getId(item);
          final label = widget.getLabel(item);
          final bool isSelected = selectedId == id;

          return InkWell(
            onTap: () {
              _removeOverlay();
              vm.selectItem(id, label);
              widget.onSelected(id);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 14.r),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade200 : Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.blue.shade700 : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
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
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Consumer(
        builder: (context, _, __) {
          final dynamic v = widget.viewModel as dynamic;

          return GestureDetector(
            onTap: () {
              final renderBox = context.findRenderObject() as RenderBox?;
              if (renderBox != null) _onTapField(context, renderBox);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 14.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      v.selectedName ?? widget.label,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                  v.loading == true
                      ? SizedBox(
                          height: 16.h,
                          width: 18.w,
                          child: CircularProgressIndicator(strokeWidth: 2.w),
                        )
                      : Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
