import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../constants.dart';
import '../models/product.dart';
import '../service/product_services.dart';

// Form sheet for adding or updating products with multiple image upload functionality.
class ProductFormSheet extends StatefulWidget {
  final Product? product;
  const ProductFormSheet({super.key, this.product});

  @override
  State<ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  String? _category, _size;
  List<String> _imageUrls = [];
  List<String> _locations = [];
  OverlayEntry? _overlayEntry;
  final FocusNode _categoryFocus = FocusNode();
  final FocusNode _locationFocus = FocusNode();
  final FocusNode _sizeFocus = FocusNode();
  final GlobalKey _categoryKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _sizeKey = GlobalKey();
  final ProductService _productService = ProductService();
  bool _isUploading = false; // Track upload state

  @override
  void initState() {
    super.initState();
    _fetchRegions();
    _locationController.addListener(_updateLocationDropdown);
    if (widget.product != null) {
      _productNameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _locationController.text = widget.product!.location;
      _category = widget.product!.category;
      _size = widget.product!.size;
      _imageUrls = List.from(widget.product!.imageUrls); // Defensive copy
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _categoryFocus.dispose();
    _locationFocus.dispose();
    _sizeFocus.dispose();
    _removeOverlay();
    super.dispose();
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
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _fetchRegions,
            ),
          ),
        );
      }
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      constraints: const BoxConstraints(minHeight: 56),
    );
  }

  void _showDropdown({
    required List<String> items,
    required Function(String?) onSelected,
    required GlobalKey fieldKey,
  }) {
    _removeOverlay();
    final RenderBox? renderBox = fieldKey.currentContext?.findRenderObject() as RenderBox?;
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
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(item),
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
    final query = _locationController.text.toLowerCase();
    if (query.isEmpty) {
      _removeOverlay();
      return;
    }

    final filteredLocations = _locations
        .where((location) => location.toLowerCase().contains(query))
        .toList();

    if (filteredLocations.isNotEmpty) {
      _showDropdown(
        items: filteredLocations,
        onSelected: (value) {
          if (value != null) {
            _locationController.text = value;
            _locationController.selection = TextSelection.fromPosition(
              TextPosition(offset: value.length),
            );
          }
        },
        fieldKey: _locationKey,
      );
    } else {
      _removeOverlay();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final padding = screenSize.width * 0.03;

    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      height: screenSize.height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.height * 0.01,
                    horizontal: padding,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Spacer(),
                      Text(
                        widget.product != null ? 'Edit Product' : 'Add Product',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: screenSize.width * 0.05,
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
                TextFormField(
                  controller: _productNameController,
                  decoration: _buildInputDecoration('Name of Product'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter product name';
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  focusNode: _categoryFocus,
                  readOnly: true,
                  decoration: _buildInputDecoration('Category').copyWith(
                    suffixIcon: _category != null
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _category = null;
                        });
                      },
                    )
                        : const Icon(CupertinoIcons.chevron_down, size: 20),
                  ),
                  controller: TextEditingController(text: _category ?? ''),
                  onTap: () {
                    _categoryFocus.requestFocus();
                    _showDropdown(
                      items: Constants.categories,
                      onSelected: (value) {
                        setState(() {
                          _category = value;
                        });
                      },
                      fieldKey: _categoryKey,
                    );
                  },
                  validator: (value) {
                    if (_category == null) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                  key: _categoryKey,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  focusNode: _locationFocus,
                  controller: _locationController,
                  decoration: _buildInputDecoration('Location'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter or select a location';
                    }
                    return null;
                  },
                  key: _locationKey,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  focusNode: _sizeFocus,
                  readOnly: true,
                  decoration: _buildInputDecoration('Size').copyWith(
                    suffixIcon: _size != null
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        setState(() {
                          _size = null;
                        });
                      },
                    )
                        : const Icon(CupertinoIcons.chevron_down, size: 20),
                  ),
                  controller: TextEditingController(text: _size ?? ''),
                  onTap: () {
                    _sizeFocus.requestFocus();
                    _showDropdown(
                      items: Constants.sizes,
                      onSelected: (value) {
                        setState(() {
                          _size = value;
                        });
                      },
                      fieldKey: _sizeKey,
                    );
                  },
                  validator: (value) {
                    if (_size == null) {
                      return 'Please select a size';
                    }
                    return null;
                  },
                  key: _sizeKey,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _priceController,
                  decoration: _buildInputDecoration('Price').copyWith(
                    suffixText: 'GHS',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _isUploading
                      ? null // Disable button while uploading
                      : () async {
                    setState(() {
                      _isUploading = true; // Start loader
                    });
                    try {
                      final picker = ImagePicker();
                      final pickedFiles = await picker.pickMultiImage();
                      if (pickedFiles.isEmpty) {
                        if (mounted) {
                          setState(() {
                            _isUploading = false; // Stop loader if no images picked
                          });
                        }
                        return;
                      }
                      final uploadedUrls = await _productService.uploadImages(pickedFiles);
                      if (mounted) {
                        setState(() {
                          if (uploadedUrls.isNotEmpty) {
                            _imageUrls.addAll(uploadedUrls);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Images uploaded successfully!'),
                                backgroundColor: Color(0xff3B8751),
                              ),
                            );
                          }
                          _isUploading = false; // Stop loader
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        setState(() {
                          _isUploading = false; // Stop loader on error
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to upload images: $e'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    }
                  },
                  icon: _isUploading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.cloud_upload),
                  label: Text(_isUploading ? 'Uploading...' : 'Upload Images'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(double.infinity, screenSize.height * 0.06),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                if (_imageUrls.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _imageUrls.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    _imageUrls[index],
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.error),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _imageUrls.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 50),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_imageUrls.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please upload at least one image'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }
                      final productName = _productNameController.text;
                      final price = double.tryParse(_priceController.text) ?? 0.0;
                      try {
                        await _productService.saveProduct(
                          name: productName,
                          price: price,
                          category: _category!,
                          location: _locationController.text,
                          size: _size!,
                          imageUrls: _imageUrls,
                          id: widget.product?.id,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Product "$productName" ${widget.product != null ? 'updated' : 'saved'} successfully'),
                              backgroundColor: const Color(0xff3B8751),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving product: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff3B8751),
                    minimumSize: Size(double.infinity, screenSize.height * 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    widget.product != null ? 'Update' : 'Save',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: screenSize.height * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}