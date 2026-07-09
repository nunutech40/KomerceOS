import 'dart:ui';

import 'package:flutter/material.dart';

import '../../styles.dart';

class CustomDropDown extends StatefulWidget {
  final String label;
  final List<String> items;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final String selectedItem;
  final bool isEnable;
  final bool isLoading;
  final VoidCallback? triggerMethod;

  const CustomDropDown({
    Key? key,
    required this.label,
    required this.items,
    this.onChanged,
    this.errorText,
    required this.selectedItem,
    this.isEnable = true,
    this.isLoading = false,
    this.triggerMethod,
  }) : super(key: key);

  @override
  _CustomDropDownState createState() => _CustomDropDownState();
  static GlobalKey<_CustomDropDownState> myWidgetKey = GlobalKey();
}

class _CustomDropDownState extends State<CustomDropDown> {
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  bool _isDropdownOpened = false;
  String _selectedItem = '';

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    getHeigth();
  }

  getHeigth() {
    height = PlatformDispatcher.instance.views.first.physicalSize.longestSide
        .toInt();
    setState(() {});
  }

  void closeOverlay() {
    if (_isDropdownOpened == true) {
      _overlayEntry.remove();
      _isDropdownOpened = false;
    }
  }

  @override
  void dispose() {
    _overlayEntry.remove();
    super.dispose();
  }

  int height = 0;
  final ScrollController _controller = ScrollController();

  heightBottomSheet(heightSize) {
    if (heightSize <= 1280) {
      return MediaQuery.of(context).size.height * 0.20;
    } else if (heightSize <= 1464) {
      return MediaQuery.of(context).size.height * 0.30;
    } else if (heightSize >= 1464) {
      return MediaQuery.of(context).size.height * 0.35;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor =
        widget.errorText != null && widget.errorText!.isNotEmpty
            ? errorColor
            : borderGray;

    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleDropdown,
        child: Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: borderColor,
              width: 0.7,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedItem,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
              widget.isLoading
                  ? const SizedBox(
                      height: 20.0,
                      width: 20.0,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                      ),
                    )
                  : const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDropdown() {
    FocusScope.of(context).unfocus();
    if (widget.isLoading) {
      return; // Do not allow opening the dropdown if it's loading
    }

    if (_isDropdownOpened) {
      _overlayEntry.remove();
      _isDropdownOpened = false;
    } else {
      _overlayEntry = _createOverlayEntry();
      Overlay.of(context).insert(_overlayEntry);
      _isDropdownOpened = true;
    }
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 6), // 6 pixels gap
          child: Material(
            color: Colors.transparent, // Transparent color
            elevation: 0, // No elevation
            child: SizedBox(
              height: heightBottomSheet(
                height,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Scrollbar(
                  thumbVisibility: true,
                  controller: _controller,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: borderGray, width: 0.7), // Your border
                      borderRadius:
                          BorderRadius.circular(8.0), // Rounded corners
                    ),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      controller: _controller,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 0.7),
                      itemCount: widget.items.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(widget.items[index]),
                            onTap: () {
                              setState(() {
                                _selectedItem = widget.items[index];
                                widget.onChanged?.call(widget.items[index]);
                                _overlayEntry.remove();
                                _isDropdownOpened =
                                    false; // Set it to false when an item is selected
                              });
                            });
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
