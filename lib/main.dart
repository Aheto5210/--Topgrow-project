import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:top_grow_project/buyer_bot_nav.dart';
import 'package:top_grow_project/provider/auth_provider.dart';
import 'package:top_grow_project/screens/about_topgrow_screen.dart';
import 'package:top_grow_project/screens/buyer_filter_screen.dart';
import 'package:top_grow_project/screens/buyer_home_screen.dart';
import 'package:top_grow_project/screens/buyer_interest_screen.dart';
import 'package:top_grow_project/screens/buyer_profile_screen.dart';
import 'package:top_grow_project/screens/buyer_search_screen.dart';
import 'package:top_grow_project/screens/buyer_store_screen.dart';
import 'package:top_grow_project/screens/contact_top_screen.dart';
import 'package:top_grow_project/screens/farmer_home_screen.dart';
import 'package:top_grow_project/screens/filter_screen.dart';
import 'package:top_grow_project/screens/product_details_screen.dart';
import 'package:top_grow_project/screens/product_screen.dart';
import 'package:top_grow_project/screens/profile_screen.dart';
import 'package:top_grow_project/screens/search_screen.dart';
import 'package:top_grow_project/screens/views_screen.dart';
import 'firebase_options.dart';
import 'package:top_grow_project/screens/buyer_login_screen.dart';
import 'package:top_grow_project/screens/buyer_signup_screen.dart';
import 'package:top_grow_project/screens/farmer_signup_screen.dart';
import 'package:top_grow_project/screens/farmer_login_screen.dart';
import 'package:top_grow_project/screens/role_selection.dart';
import 'package:top_grow_project/screens/welcome_screen.dart';

import 'home_bot_nav.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider()),
    // Provide AuthProvider
    ],
    child: MaterialApp(
    debugShowCheckedModeBanner: false,
        initialRoute: WelcomeScreen.id,
        routes: {
          WelcomeScreen.id: (context) => WelcomeScreen(),
          RoleSelection.id: (context) => RoleSelection(),
          FarmerSigninScreen.id: (context) => FarmerSigninScreen(),
          FarmerSignupScreen.id: (context) => FarmerSignupScreen(),
          BuyerSigninScreen.id: (context) => BuyerSigninScreen(),
          BuyerSignupScreen.id: (context) => BuyerSignupScreen(),
          FarmerHomeScreen.id: (context) => FarmerHomeScreen(),
          BuyerHomeScreen.id: (context) => BuyerHomeScreen(),
          ProductScreen.id: (context) => ProductScreen(),
          ProfileScreen.id: (context) => ProfileScreen(),
          ViewsScreen.id: (context) => ViewsScreen(),
          HomeBotnav.id: (context) => HomeBotnav(),
          SearchScreen.id: (context) => SearchScreen(),
          FilterScreen.id: (context) => FilterScreen(),
          ProductDetailsScreen.id : (context) => ProductDetailsScreen(),
          BuyerBotNav.id : (context) => BuyerBotNav(),
          BuyerStoreScreen.id : (context) => BuyerStoreScreen(),
          BuyerInterestScreen.id : (context) => BuyerInterestScreen(),
          BuyerProfileScreen.id : (context) => BuyerProfileScreen(),
          BuyerSearchScreen.id : (context) => BuyerSearchScreen(),
          BuyerFilterScreen.id : (context) => BuyerFilterScreen(),
          AboutTopgrowScreen.id : (context) => AboutTopgrowScreen(),
          ContactTopScreen.id: (context) => ContactTopScreen(),
        },
      ),
    );
  }
}
