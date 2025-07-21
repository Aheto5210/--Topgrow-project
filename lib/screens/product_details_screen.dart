import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:auto_size_text/auto_size_text.dart'; // For responsive text

import '../constants.dart';
import '../models/product.dart';
import '../widgets/full_zoom_page.dart';

class ProductDetailsScreen extends StatefulWidget {
  static const String id = 'product_details_screen';

  const ProductDetailsScreen({super.key});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();
  int _currentIndex = 0;
  final Map<int, PageController> _pageControllers = {};

  @override
  void dispose() {
    _carouselController.stopAutoPlay();
    _pageControllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  void _showFullScreenImage(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => FullScreenImageViewer(
              imageUrls: imageUrls,
              initialIndex: initialIndex,
            ),
      ),
    );
  }

  Future<void> _callFarmer(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number not available')),
      );
      return;
    }
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch phone call')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive calculations
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final scaleFactor = screenWidth / 375.0; // Reference width (e.g., iPhone 8)

    final Object? arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments == null || arguments is! Product) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: iykBackgroundColor,
          body: Center(
            child: AutoSizeText(
              'Product not found',
              style: TextStyle(
                fontFamily: 'qwerty',
                fontSize: 18 * scaleFactor,
                color: Colors.red,
              ),
              maxLines: 1,
              minFontSize: 14,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );
    }
    final Product product = arguments;

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 600 ? 600 : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                product.imageUrls.isNotEmpty
                    ? Stack(
                      children: [
                        GestureDetector(
                          onTap:
                              () => _showFullScreenImage(
                                context,
                                product.imageUrls,
                                _currentIndex,
                              ),
                          child: CarouselSlider(
                            carouselController: _carouselController,
                            options: CarouselOptions(
                              height: (screenHeight * 0.35).clamp(200, 300),
                              viewportFraction: 1.0,
                              enableInfiniteScroll:
                                  product.imageUrls.length > 1,
                              onPageChanged:
                                  product.imageUrls.length > 1
                                      ? (index, reason) {
                                        setState(() {
                                          _currentIndex = index;
                                        });
                                      }
                                      : null,
                            ),
                            items:
                                product.imageUrls.map((url) {
                                  return Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.image_not_supported,
                                        size: 60 * scaleFactor,
                                        color: const Color(0xff3B8751),
                                      );
                                    },
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value:
                                              loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                                  ? loadingProgress
                                                          .cumulativeBytesLoaded /
                                                      (loadingProgress
                                                              .expectedTotalBytes ??
                                                          1)
                                                  : null,
                                          strokeWidth: 4 * scaleFactor,
                                        ),
                                      );
                                    },
                                  );
                                }).toList(),
                          ),
                        ),
                        Positioned(
                          top: 16 * scaleFactor,
                          left: 8 * scaleFactor,
                          child: IconButton(
                            icon: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20 * scaleFactor,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        if (product.imageUrls.length > 1)
                          Positioned(
                            bottom: 8 * scaleFactor,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SmoothPageIndicator(
                                controller: PageController(
                                  initialPage: _currentIndex,
                                ),
                                count: product.imageUrls.length,
                                effect: WormEffect(
                                  dotHeight: 8 * scaleFactor,
                                  dotWidth: 8 * scaleFactor,
                                  activeDotColor: const Color(0xff3B8751),
                                  dotColor: Colors.white70,
                                ),
                                onDotClicked: (index) {
                                  _carouselController.animateToPage(index);
                                  setState(() {
                                    _currentIndex = index;
                                  });
                                },
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 12 * scaleFactor,
                          right: 12 * scaleFactor,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8 * scaleFactor,
                              vertical: 4 * scaleFactor,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(
                                8 * scaleFactor,
                              ),
                            ),
                            child: AutoSizeText(
                              '${_currentIndex + 1} / ${product.imageUrls.length}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12 * scaleFactor,
                              ),
                              maxLines: 1,
                              minFontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    )
                    : Container(
                      height: (screenHeight * 0.35).clamp(200, 300),
                      width: double.infinity,
                      decoration: BoxDecoration(color: Colors.grey[200]),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 60 * scaleFactor,
                            color: const Color(0xff3B8751),
                          ),
                          SizedBox(height: 8 * scaleFactor),
                          AutoSizeText(
                            'No images available',
                            style: TextStyle(
                              fontFamily: 'qwerty',
                              fontSize: 16 * scaleFactor,
                              color: Colors.black54,
                            ),
                            maxLines: 1,
                            minFontSize: 12,
                          ),
                        ],
                      ),
                    ),
                SizedBox(height: (screenHeight * 0.03).clamp(12, 20)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        flex: 3,
                        child: AutoSizeText(
                          product.name,
                          style: TextStyle(
                            fontFamily: 'qwerty',
                            fontSize: 24 * scaleFactor,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                          maxLines: 1,
                          minFontSize: 16,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: screenWidth * 0.4,
                          minWidth: 100,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12 * scaleFactor,
                            vertical: 6 * scaleFactor,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9D9D9),
                            borderRadius: BorderRadius.circular(
                              12 * scaleFactor,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AutoSizeText(
                                'GH₵ ${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontFamily: 'qwerty',
                                  fontSize: 16 * scaleFactor,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xff3B8751),
                                ),
                                maxLines: 1,
                                minFontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(width: 5 * scaleFactor),
                              AutoSizeText(
                                product.size,
                                style: TextStyle(
                                  fontFamily: 'qwerty',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 13 * scaleFactor,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                minFontSize: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (screenHeight * 0.02).clamp(10, 14)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 14 * scaleFactor,
                                  color: const Color(0xffDA4240),
                                ),
                                SizedBox(width: 4 * scaleFactor),
                                Flexible(
                                  child: AutoSizeText(
                                    product.location,
                                    style: TextStyle(
                                      fontFamily: 'qwerty',
                                      fontSize: 16 * scaleFactor,
                                      color: Colors.black54,
                                    ),
                                    maxLines: 1,
                                    minFontSize: 12,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: RichText(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Date Posted: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xff3B8751),
                                      fontSize: 12 * scaleFactor,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                        product.postedDate is Timestamp
                                            ? DateFormat.yMMMMd().format(
                                              (product.postedDate as Timestamp)
                                                  .toDate(),
                                            )
                                            : 'Unknown',
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Colors.black,
                                      fontSize: 10 * scaleFactor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: (screenHeight * 0.01).clamp(8, 12)),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _callFarmer(product.phoneNumber),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff3B8751),
                                  borderRadius: BorderRadius.circular(
                                    5 * scaleFactor,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15 * scaleFactor,
                                  vertical: 10 * scaleFactor,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_in_talk_outlined,
                                      color: Colors.white,
                                      size: 14 * scaleFactor,
                                    ),
                                    SizedBox(width: 6 * scaleFactor),
                                    AutoSizeText(
                                      'Call Farmer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14 * scaleFactor,
                                      ),
                                      maxLines: 1,
                                      minFontSize: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (screenHeight * 0.03).clamp(12, 20)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scaleFactor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        'Other Products',
                        style: TextStyle(
                          fontFamily: 'qwerty',
                          fontSize: 22 * scaleFactor,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        maxLines: 1,
                        minFontSize: 16,
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('products')
                                .limit(6)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: AutoSizeText(
                                'Error loading products',
                                style: TextStyle(
                                  fontFamily: 'qwerty',
                                  fontSize: 16 * scaleFactor,
                                  color: Colors.red,
                                ),
                                maxLines: 1,
                                minFontSize: 12,
                              ),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(
                                color: const Color(0xff3B8751),
                                strokeWidth: 4 * scaleFactor,
                              ),
                            );
                          }
                          final products =
                              snapshot.data!.docs
                                  .map((doc) => Product.fromFirestore(doc))
                                  .where((p) => p.id != product.id)
                                  .toList();
                          if (products.isEmpty) {
                            return Center(
                              child: AutoSizeText(
                                'No other products available',
                                style: TextStyle(
                                  fontFamily: 'qwerty',
                                  fontSize: 16 * scaleFactor,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                minFontSize: 12,
                              ),
                            );
                          }

                          return GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: EdgeInsets.all(10 * scaleFactor),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: screenWidth > 600 ? 3 : 2,
                                  crossAxisSpacing: 10 * scaleFactor,
                                  mainAxisSpacing: 10 * scaleFactor,
                                  childAspectRatio:
                                      screenWidth < 320
                                          ? 0.65
                                          : (screenWidth > 600 ? 0.8 : 0.7),
                                ),
                            itemCount:
                                products.length > 4 ? 4 : products.length,
                            itemBuilder: (context, index) {
                              final otherProduct = products[index];
                              final pageController =
                                  _pageControllers[index] ??= PageController();
                              return GestureDetector(
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      ProductDetailsScreen.id,
                                      arguments: otherProduct,
                                    ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(
                                      10 * scaleFactor,
                                    ),
                                    border: Border.all(
                                      color: const Color(0xffEAB916),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Stack(
                                          children: [
                                            PageView.builder(
                                              controller: pageController,
                                              itemCount:
                                                  otherProduct
                                                          .imageUrls
                                                          .isNotEmpty
                                                      ? otherProduct
                                                          .imageUrls
                                                          .length
                                                      : 1,
                                              itemBuilder: (
                                                context,
                                                pageIndex,
                                              ) {
                                                return ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                        top: Radius.circular(
                                                          10 * scaleFactor,
                                                        ),
                                                      ),
                                                  child:
                                                      otherProduct
                                                              .imageUrls
                                                              .isNotEmpty
                                                          ? Image.network(
                                                            otherProduct
                                                                .imageUrls[pageIndex],
                                                            width:
                                                                double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                size:
                                                                    40 *
                                                                    scaleFactor,
                                                              );
                                                            },
                                                            loadingBuilder: (
                                                              context,
                                                              child,
                                                              loadingProgress,
                                                            ) {
                                                              if (loadingProgress ==
                                                                  null)
                                                                return child;
                                                              return Center(
                                                                child: CircularProgressIndicator(
                                                                  value:
                                                                      loadingProgress.expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress.cumulativeBytesLoaded /
                                                                              (loadingProgress.expectedTotalBytes ??
                                                                                  1)
                                                                          : null,
                                                                  strokeWidth:
                                                                      4 *
                                                                      scaleFactor,
                                                                ),
                                                              );
                                                            },
                                                          )
                                                          : Center(
                                                            child: Icon(
                                                              Icons
                                                                  .image_not_supported,
                                                              size:
                                                                  40 *
                                                                  scaleFactor,
                                                            ),
                                                          ),
                                                );
                                              },
                                            ),
                                            if (otherProduct.imageUrls.length >
                                                1)
                                              Positioned(
                                                bottom: 8 * scaleFactor,
                                                left: 0,
                                                right: 0,
                                                child: Center(
                                                  child: SmoothPageIndicator(
                                                    controller: pageController,
                                                    count:
                                                        otherProduct
                                                            .imageUrls
                                                            .length,
                                                    effect: JumpingDotEffect(
                                                      dotHeight:
                                                          8 * scaleFactor,
                                                      dotWidth: 8 * scaleFactor,
                                                      activeDotColor:
                                                          const Color(
                                                            0xff3B8751,
                                                          ),
                                                      dotColor: Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.all(
                                          8.0 * scaleFactor,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Flexible(
                                                  child: AutoSizeText(
                                                    otherProduct.name,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          16 * scaleFactor,
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 12,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth: screenWidth * 0.3,
                                                    minWidth: 60,
                                                  ),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal:
                                                              8 * scaleFactor,
                                                          vertical:
                                                              4 * scaleFactor,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xffD9D9D9,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8 * scaleFactor,
                                                          ),
                                                    ),
                                                    child: Column(
                                                      children: [
                                                        AutoSizeText(
                                                          'GH₵ ${otherProduct.price.toStringAsFixed(0)}',
                                                          style: TextStyle(
                                                            fontSize:
                                                                14 *
                                                                scaleFactor,
                                                            color: const Color(
                                                              0xff3B8751,
                                                            ),
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          maxLines: 1,
                                                          minFontSize: 10,
                                                        ),
                                                        AutoSizeText(
                                                          otherProduct.size,
                                                          style: TextStyle(
                                                            fontSize:
                                                                12 *
                                                                scaleFactor,
                                                            color: Colors.grey,
                                                          ),
                                                          maxLines: 1,
                                                          minFontSize: 8,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4 * scaleFactor),
                                            Row(
                                              children: [
                                                ConstrainedBox(
                                                  constraints: BoxConstraints(
                                                    maxWidth: screenWidth * 0.4,
                                                    minWidth: 80,
                                                  ),
                                                  child: GestureDetector(
                                                    onTap:
                                                        () => _callFarmer(
                                                          otherProduct
                                                              .phoneNumber,
                                                        ),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: const Color(
                                                          0xff3B8751,
                                                        ),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              5 * scaleFactor,
                                                            ),
                                                      ),
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                            horizontal:
                                                                12 *
                                                                scaleFactor,
                                                            vertical:
                                                                5 * scaleFactor,
                                                          ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .phone_in_talk_outlined,
                                                            color: Colors.white,
                                                            size:
                                                                14 *
                                                                scaleFactor,
                                                          ),
                                                          SizedBox(
                                                            width:
                                                                6 * scaleFactor,
                                                          ),
                                                          AutoSizeText(
                                                            'Call Farmer',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  14 *
                                                                  scaleFactor,
                                                            ),
                                                            maxLines: 1,
                                                            minFontSize: 10,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4 * scaleFactor),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  size: 14 * scaleFactor,
                                                  color: const Color(
                                                    0xffDA4240,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 4 * scaleFactor,
                                                ),
                                                Expanded(
                                                  child: AutoSizeText(
                                                    otherProduct.location,
                                                    style: TextStyle(
                                                      fontSize:
                                                          12 * scaleFactor,
                                                      color: Colors.grey,
                                                    ),
                                                    maxLines: 1,
                                                    minFontSize: 8,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: (screenHeight * 0.03).clamp(12, 20)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
