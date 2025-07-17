import 'package:flutter/material.dart';
import 'package:top_grow_project/widgets/custom_appbar.dart';

import 'Category_detail_screen.dart';

class BuyerHomeScreen extends StatelessWidget {
  static String id = 'buyer_home_screen';

  const BuyerHomeScreen({super.key});

  final List<Map<String, String>> categories = const [
    {'name': 'Meats', 'image': 'assets/images/beef.png'},
    {'name': 'Organic Produce', 'image': 'assets/images/organn.png'},
    {'name': 'Tubers', 'image': 'assets/images/yam.png'},
    {'name': 'Cereals', 'image': 'assets/images/grains.png'},
    {'name': 'Herbs', 'image': 'assets/images/herb.webp'},
    {'name': 'Legume', 'image': 'assets/images/legume.png'},
    {'name': 'Oils & Fats', 'image': 'assets/images/oil.png'},
    {'name': 'Fruits', 'image': 'assets/images/fruits.png'},
    {'name': 'Vegetables', 'image': 'assets/images/vegen.png'},
    {'name': 'Seeds & Seedlings', 'image': 'assets/images/seeds.png'},
    {'name': 'Dairy', 'image': 'assets/images/dairy.png'},
    {'name': 'Animal Products', 'image': 'assets/images/vet.png'},
  ];

  void _onCategoryTap(BuildContext context, String categoryName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(category: categoryName),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: Column(
        children: [
          CustomAppbar(
            hintText: "Search for any product",
            controller: TextEditingController(),
          ),
          SizedBox(height: 40),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: categories.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 20,
                crossAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () => _onCategoryTap(context, category['name']!),
                  child: Column(
                    children: [
                      Expanded(
                        child: Image.asset(
                          category['image']!,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 40,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        category['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
