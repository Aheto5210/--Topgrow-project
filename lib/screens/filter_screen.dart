import 'package:flutter/material.dart';
import 'package:top_grow_project/constants.dart';
import 'package:top_grow_project/widgets/filterheader.dart';
import 'package:top_grow_project/widgets/filter_text_field.dart';
import '../widgets/filter_bottom_bar.dart';

import 'filter_results.dart';

class FilterScreen extends StatefulWidget {
  static String id = 'filter_screen';
  const FilterScreen({super.key});

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  String _nameQuery = '';
  String _locationQuery = '';
  bool _isSearchPressed = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Update name query without triggering results
  void _updateNameQuery(String value) {
    setState(() {
      _nameQuery = value.trim().toLowerCase();
    });
  }

  // Update location query without triggering results
  void _updateLocationQuery(String value) {
    setState(() {
      _locationQuery = value.trim().toLowerCase();
    });
  }

  // Clear all filters and inputs
  void _clearFilters() {
    setState(() {
      _nameQuery = '';
      _locationQuery = '';
      _isSearchPressed = false;
      _nameController.clear();
      _locationController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: primaryGreen,
        content: Text('Filters cleared'),
      ),
    );
  }

  // Trigger search with current inputs
  void _triggerSearch() {
    setState(() {
      _isSearchPressed = true;
      _nameQuery = _nameController.text.trim().toLowerCase();
      _locationQuery = _locationController.text.trim().toLowerCase();
    });
  }

  // Check if search button should be enabled
  bool _canSearch() {
    return _nameController.text.isNotEmpty || _locationController.text.isNotEmpty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: iykBackgroundColor,
        body: Column(
          children: [

            FilterHeader(),

            FilterTextField(
              nameController: _nameController,
              locationController: _locationController,
              onNameChanged: _updateNameQuery,
              onLocationChanged: _updateLocationQuery,
            ),

            Expanded(
              child: FilterResults(
                isSearchPressed: _isSearchPressed,
                nameQuery: _nameQuery,
                locationQuery: _locationQuery,
              ),
            ),
            // Bottom bar with Clear and Search buttons
            FilterBottomBar(
              onClear: _clearFilters,
              onSearch: _triggerSearch,
              canSearch: _canSearch(),
              screenWidth: screenWidth,
              screenHeight: screenHeight,
            ),
          ],
        ),
      ),
    );
  }
}