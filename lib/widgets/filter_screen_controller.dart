import 'package:flutter/material.dart';

class FilterController {
  String _nameQuery = '';
  String _locationQuery = '';
  bool _isSearchPressed = false;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final VoidCallback? onClear;

  FilterController({this.onClear});

  String get nameQuery => _nameQuery;
  String get locationQuery => _locationQuery;
  bool get isSearchPressed => _isSearchPressed;

  void updateNameQuery(String value) {
    _nameQuery = value.trim().toLowerCase();
  }

  void updateLocationQuery(String value) {
    _locationQuery = value.trim().toLowerCase();
  }

  void clearFilters() {
    _nameQuery = '';
    _locationQuery = '';
    _isSearchPressed = false;
    nameController.clear();
    locationController.clear();
    onClear?.call();
  }

  void triggerSearch() {
    _isSearchPressed = true;
    _nameQuery = nameController.text.trim().toLowerCase();
    _locationQuery = locationController.text.trim().toLowerCase();
  }

  void dispose() {
    nameController.dispose();
    locationController.dispose();
  }
}