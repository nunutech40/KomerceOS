import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:komtim_partner/common/global/design_system/app_colors.dart';
import 'package:komtim_partner/common/global/widgets/custom_button_next_unhire.dart';
import 'package:komtim_partner/common/global/widgets/custom_outline_button.dart';
import 'package:komtim_partner/common/styles.dart';

void bottomSheetFilter(
    BuildContext context, String currentStatus, String currentDate,
    {required void Function(String) onStatusClicked,
    required void Function(String) onDateClicked,
    required void Function() onResetClicked}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext context) {
      return FractionallySizedBox(
        heightFactor: 0.85,
        child: _FilterSheetContent(
          currentStatus: currentStatus,
          currentDate: currentDate,
          onStatusClicked: onStatusClicked,
          onDateClicked: onDateClicked,
          onResetClicked: onResetClicked,
        ),
      );
    },
  );
}

class _FilterSheetContent extends StatefulWidget {
  final String currentStatus;
  final String currentDate;
  final void Function(String) onStatusClicked;
  final void Function(String) onDateClicked;
  final void Function() onResetClicked;

  const _FilterSheetContent({
    required this.currentStatus,
    required this.currentDate,
    required this.onStatusClicked,
    required this.onDateClicked,
    required this.onResetClicked,
  });

  @override
  State<_FilterSheetContent> createState() => _FilterSheetContentState();
}

class _FilterSheetContentState extends State<_FilterSheetContent> {
  late String _selectedStatus;
  late String _selectedDate;
  bool _isStatusExpanded = true;
  bool _isDateExpanded = true;

  final List<String> _statusOptions = [
    'Semua',
    'Diajukan',
    'Disetujui',
    'Ditolak',
    'Dibatalkan',
    'Selesai',
  ];

  final List<String> _dateOptions = [
    'Hari ini',
    '7 Hari Terakhir',
    'Semua',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus;
    _selectedDate = widget.currentDate;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 20),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  const Text(
                    'Filter',
                    style: TextStyle(
                      color: AppColors.black0A0A,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Status Section
                  const Text(
                    'Status',
                    style: TextStyle(
                      color: AppColors.black0A0A,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownSection(
                    value: _selectedStatus,
                    isExpanded: _isStatusExpanded,
                    onToggle: () {
                      setState(() {
                        _isStatusExpanded = !_isStatusExpanded;
                      });
                    },
                  ),
                  if (_isStatusExpanded)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 240),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _statusOptions.length,
                          itemBuilder: (context, index) {
                            final option = _statusOptions[index];
                            return _buildOptionItem(
                              text: option,
                              isSelected: _selectedStatus == option,
                              onTap: () {
                                setState(() {
                                  _selectedStatus = option;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Date Section
                  const Text(
                    'Tanggal',
                    style: TextStyle(
                      color: AppColors.black0A0A,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildDropdownSection(
                    value: _selectedDate,
                    isExpanded: _isDateExpanded,
                    onToggle: () {
                      setState(() {
                        _isDateExpanded = !_isDateExpanded;
                      });
                    },
                  ),
                  if (_isDateExpanded)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: Scrollbar(
                        thumbVisibility: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _dateOptions.length,
                          itemBuilder: (context, index) {
                            final option = _dateOptions[index];
                            return _buildOptionItem(
                              text: option,
                              isSelected: _selectedDate == option,
                              onTap: () {
                                setState(() {
                                  _selectedDate = option;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          // Bottom buttons
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: CustomOutlineButton(
                      text: 'Reset Filter',
                      onPressed: () {
                        widget.onResetClicked();
                        Navigator.pop(context);
                      },
                      color: primaryColor,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: CustomButtonNextUnhire(
                      text: 'Terapkan Filter',
                      onPressed: () {
                        // Set status first, then trigger dateClicked
                        // which will fire the API with both filters
                        widget.onStatusClicked(_selectedStatus);
                        widget.onDateClicked(_selectedDate);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSection({
    required String value,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: gray737373,
                fontSize: 14,
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
              color: gray737373,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? const Color(0xFFF95E16) : AppColors.black0A0A,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
