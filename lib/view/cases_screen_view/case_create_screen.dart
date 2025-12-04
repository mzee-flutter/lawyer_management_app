import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_type_view_model.dart';

class CaseCreateScreen extends StatelessWidget {
  const CaseCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<CaseCreateViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Case"),
        backgroundColor: Colors.grey.shade300,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabels("Enter Registration Date"),
            ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              tileColor: Colors.grey.shade300,
              shape: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide.none,
              ),
              title: Text(
                vm.registrationDate == null
                    ? "Select Registration Date"
                    : vm.registrationDate.toString().split(" ").first,
              ),
              trailing: Icon(Icons.calendar_month),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (date != null) {
                  vm.registrationDate = date;
                  vm.notifyListeners();
                }
              },
            ),
            SizedBox(height: 12.h),

            _buildLabels('Enter Case Number'),
            _buildTextField(vm.caseNumberController),
            SizedBox(height: 12.h),

            _buildLabels("First Party"),
            _customDropDownButtonFormField(
              (value) => vm.firstPartyId = value.toString(),
              onTap: () {},
              item: [],
            ),
            SizedBox(height: 12.h),

            _buildLabels("Opposite Party"),
            _customDropDownButtonFormField(
              (value) => vm.secondPartyId = value.toString(),
              onTap: () {},
              item: [],
            ),

            SizedBox(height: 12.h),
            _buildLabels("Opposite Party Name"),
            _buildTextField(vm.oppositePartyNameController),
            SizedBox(height: 12.h),

            // inside your column children where you had the case type

            _buildLabels("Case Type*"),
            CustomDropdownFormField(
              label: "Select Case Type",
              onSelected: (id) {
                context.read<CaseCreateViewModel>().caseTypeId = id;
              },
            ),
            SizedBox(height: 12.h),

            // Notes
            _buildLabels("Enter Case Notes"),
            _buildTextField(
              vm.caseNotesController,
              maxLines: 3,
            ),
            SizedBox(height: 12.h),

            Row(
              children: [
                Expanded(child: Divider(endIndent: 5.w)),
                Text(
                  "Court Detail",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                  ),
                ),
                Expanded(child: Divider(indent: 5.w))
              ],
            ),

            _buildLabels("Court Category"),
            _customDropDownButtonFormField(
              (value) => vm.courtCategoryId = value.toString(),
              onTap: () {},
              item: [
                DropdownMenuItem(child: Text("this is the CourtCategory"))
              ],
            ),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Court Name'),
            CustomTextField(controller: vm.courtNameController),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Judge Name'),
            CustomTextField(controller: vm.judgeNameController),
            SizedBox(height: 12.h),

            _buildLabels("Case Stage"),
            _customDropDownButtonFormField(
              (value) => vm.caseStageId = value.toString(),
              onTap: () {},
              item: [DropdownMenuItem(child: Text("Cause is the CaseStage"))],
            ),
            SizedBox(height: 12.h),

            _buildLabels("Case Status"),
            _customDropDownButtonFormField(
              (value) => vm.caseStatusId = value.toString(),
              onTap: () {},
              item: [],
            ),
            SizedBox(height: 12.h),

            _buildLabels("Enter Legal Fee"),
            _buildTextField(vm.legalFeesController),

            SizedBox(height: 30),

            ElevatedButton(
              onPressed: vm.loading
                  ? null // disable button when loading
                  : () async {
                      await vm.createCase(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: vm.loading
                  ? CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_add_alt, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Add Case',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatter,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      cursorColor: Colors.grey.shade800,
      maxLength: maxLength,
      inputFormatters: inputFormatter,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade300,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLabels(String title) {
    return Text(
      title,
      style: TextStyle(color: Colors.grey.shade700, fontSize: 13.sp),
    );
  }

  Widget _customDropDownButtonFormField(
    void Function(dynamic newValue) onChange, {
    required void Function()? onTap,
    required List<DropdownMenuItem<dynamic>>? item,
    bool isLoading = false,
  }) {
    return Stack(
      children: [
        DropdownButtonFormField(
          iconDisabledColor: Colors.grey.shade900,
          decoration: InputDecoration(
            fillColor: Colors.grey.shade300,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                8.r,
              ),
              borderSide: BorderSide.none,
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
          ),
          items: item,
          onChanged: onChange,
          onTap: onTap,
        ),

        // LOADER OVERLAY INSIDE DROPDOWN FIELD
        if (isLoading)
          Positioned.fill(
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 12),
              color: Colors.transparent,
              child: SizedBox(
                height: 20.h,
                width: 20.w,
                child: CupertinoActivityIndicator(),
              ),
            ),
          ),
      ],
    );
  }
}

class CustomDropdownFormField extends StatefulWidget {
  final String label;
  final void Function(String id) onSelected;

  const CustomDropdownFormField({
    super.key,
    required this.label,
    required this.onSelected,
  });

  @override
  State<CustomDropdownFormField> createState() =>
      _CustomDropdownFormFieldState();
}

class _CustomDropdownFormFieldState extends State<CustomDropdownFormField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  void _removeOverlay() {
    _overlay?.remove();
    _overlay = null;
    _isOpen = false;
  }

  void _showOverlay(BuildContext context, Size fieldSize, Offset fieldOffset) {
    // if already open, close
    if (_isOpen) {
      _removeOverlay();
      return;
    }

    final vm = context.read<CaseTypeViewModel>();
    // final maxHeight = 193.0.h;
    // Calculate available space from the bottom of the field to the bottom of the screen
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding =
        MediaQuery.of(context).padding.bottom; // for safe area
    final availableHeight = screenHeight -
        fieldOffset.dy -
        fieldSize.height -
        bottomPadding -
        6.h; // 6 is your offset

    final maxHeight =
        availableHeight > 150 ? availableHeight : 150; // minimum height 150

    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Modal barrier to block rest of UI and close on tap
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),

            // The anchored dropdown (follows the target)
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, fieldSize.height + 6), // below the field
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: fieldSize.width, // same width as field
                  constraints: BoxConstraints(
                    maxHeight: maxHeight as double,
                  ),
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

  Widget _buildList(BuildContext context, CaseTypeViewModel vm) {
    final items = vm.caseTypes;
    final selectedId = vm.selectedCaseTypeId;
    if (items.isEmpty) {
      return SizedBox(
        height: 80.h,
        child: Center(child: Text("No items")),
      );
    }

    return Scrollbar(
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final type = items[index];
          final bool isSelected = selectedId == type.id;
          return InkWell(
            onTap: () {
              _removeOverlay();
              vm.selectCaseType(type.id, type.name);
              widget.onSelected(type.id);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 14.r),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade200 : Colors.white,
                borderRadius: BorderRadius.circular(
                  8.r,
                ),
              ),
              child: Text(
                type.name,
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
    final vm = context.read<CaseTypeViewModel>();

    // Avoid multiple taps
    if (vm.loading) return;

    // fetch only if empty (vm handles internal caching)
    if (vm.caseTypes.isEmpty) {
      await vm.fetchCaseTypes();
    }

    // if still empty, don't open
    if (vm.caseTypes.isEmpty) return;

    // show overlay anchored to the field
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    _showOverlay(context, size, offset);
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We wrap the field with CompositedTransformTarget so the follower can attach.
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: () {
          final renderBox =
              context.findRenderObject() as RenderBox?; // target render box
          if (renderBox != null) {
            _onTapField(context, renderBox);
          }
        },
        child: Consumer<CaseTypeViewModel>(
          builder: (context, vm, child) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 14.r),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      vm.selectedCaseTypeName ?? widget.label,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                  vm.loading
                      ? SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_drop_down),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
