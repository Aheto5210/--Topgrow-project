import 'package:flutter/material.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/service/product_services.dart';

class FilterTextField extends StatefulWidget {
  final TextEditingController nameController;
  final TextEditingController locationController;
  final Function(String) onNameChanged;
  final Function(String) onLocationChanged;

  const FilterTextField({
    super.key,
    required this.nameController,
    required this.locationController,
    required this.onNameChanged,
    required this.onLocationChanged,
  });

  @override
  State<FilterTextField> createState() => _FilterTextFieldState();
}

class _FilterTextFieldState extends State<FilterTextField> {
  final ProductService _productService = ProductService();
  List<String> _locations = [];
  OverlayEntry? _overlayEntry;
  final GlobalKey _locationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _fetchRegions();
    widget.locationController.addListener(_updateLocationDropdown);
  }

  Future<void> _fetchRegions() async {
    try {
      final regions = await _productService.fetchRegions();
      if (mounted) {
        setState(() {
          _locations = regions;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load regions: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showDropdown(List<String> items, Function(String?) onSelected) {
    _removeOverlay();
    final RenderBox? renderBox = _locationKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeOverlay,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: position.dx,
              top: position.dy + size.height,
              width: size.width,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(borderRadius),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(
                          item,
                          style: TextStyle(
                            fontFamily: 'qwerty',
                            fontSize: MediaQuery.of(context).textScaler.scale(16).clamp(14, 18),
                          ),
                        ),
                        onTap: () {
                          onSelected(item);
                          _removeOverlay();
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateLocationDropdown() {
    final query = widget.locationController.text.toLowerCase();
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    final filteredLocations = _locations
        .where((location) => location.toLowerCase().contains(query))
        .toList();

    if (filteredLocations.isNotEmpty) {
      _showDropdown(filteredLocations, (value) {
        if (value != null) {
          widget.locationController.text = value;
          widget.locationController.selection =
              TextSelection.fromPosition(TextPosition(offset: value.length));
          widget.onLocationChanged(value);
        }
      });
    } else {
      _removeOverlay();
    }
  }

  @override
  void dispose() {
    widget.locationController.removeListener(_updateLocationDropdown);
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: (screenWidth * 0.05).clamp(16, 32),
        vertical: (screenHeight * 0.02).clamp(8, 16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: widget.nameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Name of product',
              hintStyle: TextStyle(
                fontFamily: 'qwerty',
                fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                color: Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.shopping_cart,
                color: Colors.grey[600],
                size: textScaler.scale(screenWidth * 0.06).clamp(20, 24),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(color: primaryGreen),
              ),
            ),
            style: TextStyle(
              fontFamily: 'qwerty',
              fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
              color: Colors.black,
            ),
            onChanged: widget.onNameChanged,
          ),
          SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
          TextField(
            controller: widget.locationController,
            decoration: InputDecoration(
              hintText: 'Location',
              hintStyle: TextStyle(
                fontFamily: 'qwerty',
                fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
                color: Colors.grey[600],
              ),
              prefixIcon: Icon(
                Icons.location_on,
                color: Colors.grey[600],
                size: textScaler.scale(screenWidth * 0.06).clamp(20, 24),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: const BorderSide(color: primaryGreen),
              ),
            ),
            style: TextStyle(
              fontFamily: 'qwerty',
              fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
              color: Colors.black,
            ),
            onChanged: widget.onLocationChanged,
            key: _locationKey,
          ),
        ],
      ),
    );
  }
}