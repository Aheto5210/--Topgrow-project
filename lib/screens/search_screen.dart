import 'package:flutter/material.dart';
import '../constants.dart';
import '../widgets/custom_appbar_search.dart';
import 'search_results.dart';

class SearchScreen extends StatefulWidget {
  static String id = 'search_screen';
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _retrySearch() {
    setState(() {}); // Trigger rebuild to retry Firestore query
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    return Scaffold(
      backgroundColor: iykBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomAppbarSearch(
              title: 'Products/Items',
              controller: _searchController,
            ),
            Expanded(
              child: _searchQuery.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      size: screenWidth * 0.12,
                      color: Colors.black54,
                    ),
                    SizedBox(height: (screenHeight * 0.02).clamp(8, 16)),
                    Text(
                      'Start searching for products',
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler
                            .scale(screenWidth * 0.045)
                            .clamp(14, 18),
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              )
                  : SearchResults(
                searchQuery: _searchQuery,
                onRetry: _retrySearch,
              ),
            ),
          ],
        ),
      ),
    );
  }
}