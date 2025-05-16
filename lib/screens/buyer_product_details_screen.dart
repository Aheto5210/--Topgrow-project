import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';
import '../models/product.dart';
import '../service/interest_service.dart';
import '../widgets/full_zoom_page.dart';

class BuyerProductDetailsScreen extends StatefulWidget {
  static const String id = 'buyer_product_details_screen';

  const BuyerProductDetailsScreen({super.key});

  @override
  _BuyerProductDetailsScreenState createState() =>
      _BuyerProductDetailsScreenState();
}

class _BuyerProductDetailsScreenState extends State<BuyerProductDetailsScreen> {
  final CarouselSliderController _carouselController =
  CarouselSliderController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _carouselController.stopAutoPlay();
    super.dispose();
  }

  Future<void> _markInterested(BuildContext context, Product product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to mark interest')),
      );
      return;
    }

    try {
      final interestService = InterestService();
      final isNowInterested = await interestService.toggleInterest(product.id);
      setState(() {}); // Update UI to reflect new interest state
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            isNowInterested
                ? 'Product marked as interested'
                : 'Product unmarked from interests',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error marking interest: $e')));
    }
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textScaler = MediaQuery.of(context).textScaler;

    final Object? arguments = ModalRoute.of(context)!.settings.arguments;
    if (arguments == null || arguments is! Product) {
      return Scaffold(
        backgroundColor: iykBackgroundColor,
        body: Center(
          child: Text(
            'Product not found',
            style: TextStyle(
              fontFamily: 'qwerty',
              fontSize: textScaler.scale(screenWidth * 0.045).clamp(14, 18),
              color: Colors.red,
            ),
          ),
        ),
      );
    }
    final Product product = arguments;
    final isInterested =
        FirebaseAuth.instance.currentUser != null &&
            product.interestedBuyers.contains(
              FirebaseAuth.instance.currentUser!.uid,
            );

    return Scaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
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
                        height: (screenHeight * 0.35).clamp(250, 300),
                        viewportFraction: 1.0,
                        enableInfiniteScroll: product.imageUrls.length > 1,
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
                            return const Icon(
                              Icons.image_not_supported,
                              size: 80,
                              color: Color(0xff3B8751),
                            );
                          },
                          loadingBuilder: (
                              context,
                              child,
                              loadingProgress,
                              ) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  if (product.imageUrls.length > 1)
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: SmoothPageIndicator(
                          controller: PageController(
                            initialPage: _currentIndex,
                          ),
                          count: product.imageUrls.length,
                          effect: const WormEffect(
                            dotHeight: 8,
                            dotWidth: 8,
                            activeDotColor: Color(0xff3B8751),
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
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${_currentIndex + 1} / ${product.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              )
                  : Container(
                height: (screenHeight * 0.35).clamp(250, 300),
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.grey[200]),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 80,
                        color: Color(0xff3B8751),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No images available',
                        style: TextStyle(
                          fontFamily: 'qwerty',
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: (screenHeight * 0.03).clamp(16, 24)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        product.name,
                        style: TextStyle(
                          fontFamily: 'qwerty',
                          fontSize: textScaler
                              .scale(screenWidth * 0.06)
                              .clamp(20, 24),
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'GH₵ ${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontFamily: 'qwerty',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff3B8751),
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.visible,
                            maxLines: 1,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            product.size,
                            style: const TextStyle(
                              fontFamily: 'qwerty',
                              fontWeight: FontWeight.w400,
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.visible,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: (screenHeight * 0.02).clamp(12, 16)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Color(0xffDA4240),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.location,
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
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Date Posted: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff3B8751),
                                  fontSize: 12,
                                ),
                              ),
                              TextSpan(
                                text: DateFormat.yMMMMd().format(
                                  product.postedDate,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: (screenHeight * 0.01).clamp(8, 12)),
                    IconButton(
                      onPressed: () => _markInterested(context, product),
                      icon: Icon(
                        isInterested ? Icons.favorite : Icons.favorite_border,
                        color: isInterested ? Colors.red : Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _callFarmer(product.phoneNumber),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xff3B8751),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone_in_talk_outlined,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      'Call Farmer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: (screenHeight * 0.03).clamp(16, 24)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Other Products',
                      style: TextStyle(
                        fontFamily: 'qwerty',
                        fontSize: textScaler
                            .scale(screenWidth * 0.06)
                            .clamp(18, 22),
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream:
                      FirebaseFirestore.instance
                          .collection('products')
                          .limit(6)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                              'Error loading products',
                              style: TextStyle(
                                fontFamily: 'qwerty',
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            ),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xff3B8751),
                            ),
                          );
                        }
                        final products =
                        snapshot.data!.docs
                            .map((doc) => Product.fromFirestore(doc))
                            .where((p) => p.id != product.id)
                            .toList();
                        if (products.isEmpty) {
                          return const Center(
                            child: Text(
                              'No other products available',
                              style: TextStyle(
                                fontFamily: 'qwerty',
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.7,
                          ),
                          itemCount: products.length > 2 ? 2 : products.length,
                          itemBuilder: (context, index) {
                            final otherProduct = products[index];
                            final isOtherProductInterested =
                                FirebaseAuth.instance.currentUser != null &&
                                    otherProduct.interestedBuyers.contains(
                                      FirebaseAuth.instance.currentUser!.uid,
                                    );
                            final PageController pageController =
                            PageController();
                            return GestureDetector(
                              onTap:
                                  () => Navigator.pushNamed(
                                context,
                                BuyerProductDetailsScreen.id,
                                arguments: otherProduct,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(0xffEAB916),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            itemBuilder: (context, pageIndex) {
                                              return ClipRRect(
                                                borderRadius:
                                                const BorderRadius.vertical(
                                                  top: Radius.circular(10),
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
                                                    return const Center(
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 50,
                                                      ),
                                                    );
                                                  },
                                                )
                                                    : const Center(
                                                  child: Icon(
                                                    Icons
                                                        .image_not_supported,
                                                    size: 50,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          if (otherProduct.imageUrls.length > 1)
                                            Positioned(
                                              bottom: 8,
                                              left: 0,
                                              right: 0,
                                              child: Center(
                                                child: SmoothPageIndicator(
                                                  controller: pageController,
                                                  count:
                                                  otherProduct
                                                      .imageUrls
                                                      .length,
                                                  effect:
                                                  const JumpingDotEffect(
                                                    dotHeight: 8,
                                                    dotWidth: 8,
                                                    activeDotColor: Color(
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
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  otherProduct.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xffD9D9D9,
                                                  ),
                                                  borderRadius:
                                                  BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      'GH₵ ${otherProduct.price.toStringAsFixed(0)}',
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Color(
                                                          0xff3B8751,
                                                        ),
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      otherProduct.size,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    () => _callFarmer(
                                                  otherProduct.phoneNumber,
                                                ),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: const Color(
                                                      0xff3B8751,
                                                    ),
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      5,
                                                    ),
                                                  ),
                                                  child: const Padding(
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                      horizontal: 9,
                                                      vertical: 5,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .phone_in_talk_outlined,
                                                          color: Colors.white,
                                                          size: 14,
                                                        ),
                                                        SizedBox(width: 6),
                                                        Text(
                                                          'Call Farmer',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                onPressed: () =>
                                                    _markInterested(
                                                        context, otherProduct),
                                                icon: Icon(
                                                  isOtherProductInterested
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  color:
                                                  isOtherProductInterested
                                                      ? Colors.red
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 14,
                                                color: Color(0xffDA4240),
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  otherProduct.location,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                  ),
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

              SizedBox(height: (screenHeight * 0.03).clamp(16, 24)),
            ],
          ),
        ),
      ),
    );
  }
}