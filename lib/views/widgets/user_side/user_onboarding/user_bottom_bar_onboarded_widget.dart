import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:stitches_africa/config/providers/bottom_bar_providers/user_side_bottom_bar_provider.dart';
import 'package:stitches_africa/constants/utilities.dart';
import 'package:stitches_africa/models/firebase_models/cart_model.dart';
import 'package:stitches_africa/services/firebase_services/firebase_firestore_functions.dart';
import 'package:stitches_africa/views/screens/user_side/main/home.dart';
import 'package:stitches_africa/views/screens/user_side/main/profile.dart';
import 'package:stitches_africa/views/screens/user_side/main/search.dart';
import 'package:stitches_africa/views/screens/user_side/main/tailors.dart';
import 'package:stitches_africa/views/screens/user_side/main/wishlist.dart';

class UserBottomBarOnboardedWidget extends ConsumerStatefulWidget {
  const UserBottomBarOnboardedWidget({super.key});

  @override
  ConsumerState<UserBottomBarOnboardedWidget> createState() =>
      _MyBottomBarState();
}

class _MyBottomBarState extends ConsumerState<UserBottomBarOnboardedWidget> {
  // Firebase Firestore utility functions
  final FirebaseFirestoreFunctions _firebaseFirestoreFunctions =
      FirebaseFirestoreFunctions();

  /// Retrieves the current user's ID from FirebaseAuth
  String _getCurrentUserId() {
    return FirebaseAuth.instance.currentUser!.uid;
  }

  /// Stream of cart items for the current user
  Stream<List<CartModel>> _getCartItemsStream() {
    return FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(_getCurrentUserId())
        .collection('user_cart_items')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartModel.fromDocument(
                  doc.data(),
                  totalItems: snapshot.docs.length,
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    // Watch the current index provider for navigation
    int _currentIndex = ref.watch(currentIndexProvider);

    // Define the cart document reference
    final DocumentReference cartDocRef = FirebaseFirestore.instance
        .collection('users_cart_items')
        .doc(_getCurrentUserId());

    final CollectionReference cartSubCollection =
        cartDocRef.collection('user_cart_items');

    // Define the different screen pages
    final List<Widget> screenPages = [
      HomeScreen(),
      const SearchScreen(),
      const TailorsScreen(),
      const WishlistScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Utilities.backgroundColor,
        title: _currentIndex == 0
            ? Text(
                'STITCHES AFRICA',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 22.sp,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
        centerTitle: true,
        actions: [
          /// Cart Icon with Item Count
          GestureDetector(
            onTap: () async {
              _showLoadingDialog(context);

              // Refresh cart items
              await _firebaseFirestoreFunctions.refreshCart(
                  ref, cartSubCollection);

              Navigator.pop(context);
              context.pushNamed('shoppingScreen');
            },
            child: Row(
              children: [
                StreamBuilder<List<CartModel>>(
                  stream: _getCartItemsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        '...',
                        style: TextStyle(fontSize: 12.sp),
                      );
                    } else if (snapshot.hasData) {
                      final totalItems = snapshot.data!.isEmpty
                          ? 0
                          : snapshot.data!.first.totalItems;
                      return Text(
                        '$totalItems',
                        style: TextStyle(fontSize: 12.sp),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
                SizedBox(width: 3.w),
                SvgPicture.asset(
                  'assets/icons/bag.svg',
                  height: 22.h,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: screenPages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        enableFeedback: false,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Utilities.backgroundColor,
        currentIndex: _currentIndex,
        onTap: (index) {
          ref.read(currentIndexProvider.notifier).state = index;
        },
        elevation: 0,
        selectedItemColor: Utilities.primaryColor,
        unselectedItemColor: Utilities.secondaryColor3,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11.sp,
        unselectedFontSize: 11.sp,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
        items: [
          _buildBottomNavItem(
            'Home',
            'assets/icons/logo2.svg',
            _currentIndex == 0,
          ),
          _buildBottomNavItem(
            'Search',
            'assets/icons/search.svg',
            _currentIndex == 1,
          ),
          _buildBottomNavItem(
            'Tailors',
            'assets/icons/sewing-needle.svg',
            _currentIndex == 2,
          ),
          _buildBottomNavItem(
            'Favorites',
            'assets/icons/bookmark.svg',
            _currentIndex == 3,
          ),
          _buildBottomNavItem(
            'Profile',
            'assets/icons/user-account-profile.svg',
            _currentIndex == 4,
          ),
        ],
      ),
    );
  }

  /// Builds a bottom navigation bar item
  BottomNavigationBarItem _buildBottomNavItem(
      String label, String assetPath, bool isSelected) {
    return BottomNavigationBarItem(
      label: label,
      icon: SvgPicture.asset(
        assetPath,
        height: 22.h,
        color: isSelected ? Utilities.primaryColor : Utilities.secondaryColor3,
      ),
    );
  }

  /// Displays a loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: Utilities.backgroundColor,
        ),
      ),
    );
  }
}
