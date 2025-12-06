import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:right_case/models/case_models/case_model.dart';
import 'package:right_case/resources/custom_text_fields.dart';
import 'package:right_case/view_model/cases_view_model/case_create_view_model.dart';
import 'package:flutter/material.dart';
import 'package:right_case/view_model/cases_view_model/case_stage_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_status_view_model.dart';
import 'package:right_case/view_model/cases_view_model/case_type_view_model.dart';
import 'package:right_case/resources/custom_dropdown_form_field.dart';
import 'package:right_case/view_model/cases_view_model/court_type_view_model.dart';

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
            Consumer<CaseTypeViewModel>(
              builder:
                  (BuildContext context, CaseTypeViewModel caseTypeVM, child) {
                return CustomDropdownFormField(
                  label: "Select Case Type",
                  items: caseTypeVM.items,
                  getId: (item) => item.id,
                  getLabel: (item) => item.name,
                  onSelected: (String id) {
                    caseTypeVM.selectItem(
                      id,
                      caseTypeVM.items.firstWhere((type) => type.id == id).name,
                    );
                  },
                  viewModel: caseTypeVM,
                );
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
            _buildLabels("Court Category*"),
            CourtTypeDropdownField(
              label: "Select court category",
              onSelected: (id) {
                context.read<CourtTypeViewModel>().selectedCourtId = id;
              },
            ),
            // Consumer<CourtTypeViewModel>(
            //   builder: (BuildContext context, courtTypeVM, child) {
            //     return CourtTypeDropdownField(
            //         label: "Court Category",
            //         items: courtTypeVM.items,
            //         getId: (item) => item.id,
            //         getLabel: (item) => item.name,
            //         onSelected: (String id) {
            //           courtTypeVM.selectItem(
            //             id,
            //             courtTypeVM.items
            //                 .firstWhere((court) => court.id == id)
            //                 .name,
            //           );
            //         },
            //         viewModel: courtTypeVM);
            //   },
            // ),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Court Name'),
            CustomTextField(controller: vm.courtNameController),
            SizedBox(height: 12.h),

            CustomTextField.fieldLabel('Enter Judge Name'),
            CustomTextField(controller: vm.judgeNameController),
            SizedBox(height: 12.h),

            _buildLabels("Case Stage"),
            Consumer<CaseStageViewModel>(
              builder: (BuildContext context, caseStageVM, child) {
                return CustomDropdownFormField(
                  label: "Case Stage",
                  items: caseStageVM.items,
                  getId: (item) => item.id,
                  getLabel: (item) => item.name,
                  onSelected: (String id) {
                    caseStageVM.selectItem(
                      id,
                      caseStageVM.items
                          .firstWhere((stage) => stage.id == id)
                          .name,
                    );
                  },
                  viewModel: caseStageVM,
                );
              },
            ),
            SizedBox(height: 12.h),

            _buildLabels("Case Status"),
            Consumer<CaseStatusViewModel>(
                builder: (BuildContext context, caseStatusVM, child) {
              return CustomDropdownFormField(
                label: "Case Status",
                items: caseStatusVM.items,
                getId: (item) => item.id,
                getLabel: (item) => item.name,
                onSelected: (String id) {
                  caseStatusVM.selectItem(
                    id,
                    caseStatusVM.items
                        .firstWhere((status) => status.id == id)
                        .name,
                  );
                },
                viewModel: caseStatusVM,
              );
            }),
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
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlay;
  bool _isOpen = false;

  // Track expanded items
  final Set<String> _expandedItems = {};

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

    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final availableHeight =
        screenHeight - fieldOffset.dy - fieldSize.height - bottomPadding - 6.h;
    final maxHeight = availableHeight > 150 ? availableHeight : 150;

    _overlay = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            // Modal barrier
            Positioned.fill(
              child: GestureDetector(
                onTap: _removeOverlay,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ),

            // Dropdown anchored
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, fieldSize.height + 6),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: fieldSize.width,
                  constraints: BoxConstraints(maxHeight: maxHeight.toDouble()),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: StatefulBuilder(
                    builder: (context, setOverlayState) {
                      void toggleExpanded(String id) {
                        setState(() {
                          if (_expandedItems.contains(id)) {
                            _expandedItems.remove(id);
                          } else {
                            _expandedItems.add(id);
                          }
                        });
                        setOverlayState(() {}); // rebuild overlay
                      }

                      return Scrollbar(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: _buildCourtTilesWithToggle(toggleExpanded),
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
    _isOpen = true;
  }

  List<Widget> _buildCourtTilesWithToggle(void Function(String) toggleExpanded,
      {double indent = 0}) {
    final vm = context.read<CourtTypeViewModel>();
    final items = vm.courtType;
    final selectedId = vm.selectedCourtId;

    return items.map((item) {
      bool isSelected = selectedId == item.id;
      bool isExpanded = _expandedItems.contains(item.id);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              toggleExpanded(item.id);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  horizontal: 12.r + indent, vertical: 14.r),
              decoration: BoxDecoration(
                color: isSelected ? Colors.grey.shade200 : Colors.white,
                borderRadius: BorderRadius.circular(
                  8.r,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.blue.shade700 : Colors.black,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 18.r,
                  ),
                ],
              ),
            ),
          ),
          Divider(height: 1.h, color: Colors.grey.shade300),

          // Subcategories
          if (isExpanded)
            ...item.subcategories!.map((sub) =>
                _buildSubTile(sub, selectedId, indent + 20, toggleExpanded))
        ],
      );
    }).toList();
  }

  Widget _buildSubTile(CourtCategoryModel sub, String? selectedId,
      double indent, void Function(String) toggleExpanded) {
    final isSelected = selectedId == sub.id;
    final hasChildren =
        sub.subcategories != null && sub.subcategories!.isNotEmpty;
    final isExpanded = _expandedItems.contains(sub.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: hasChildren
              ? () {
                  toggleExpanded(sub.id);
                }
              : () {
                  _removeOverlay();
                  context
                      .read<CourtTypeViewModel>()
                      .selectCourtType(sub.id, sub.name);
                  widget.onSelected(sub.id);
                },
          child: Container(
            width: double.infinity,
            padding:
                EdgeInsets.symmetric(horizontal: 12.r + indent, vertical: 14.r),
            color: isSelected ? Colors.grey.shade200 : Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    sub.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.blue.shade700 : Colors.black,
                    ),
                  ),
                ),
                if (hasChildren)
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_right,
                    size: 18.r,
                  ),
              ],
            ),
          ),
        ),
        Divider(height: 1.h, color: Colors.grey.shade300),
        if (hasChildren && isExpanded)
          ...sub.subcategories!.map((child) =>
              _buildSubTile(child, selectedId, indent + 20, toggleExpanded)),
      ],
    );
  }

  Future<void> _onTapField(BuildContext context, RenderBox renderBox) async {
    final vm = context.read<CourtTypeViewModel>();

    if (vm.loading) return;

    if (vm.courtType.isEmpty) {
      await vm.fetchCourtType();
    }

    if (vm.courtType.isEmpty) return;

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
                      vm.selectedCourtName ?? widget.label,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                  ),
                  vm.loading
                      ? SizedBox(
                          height: 16.h,
                          width: 18.w,
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
