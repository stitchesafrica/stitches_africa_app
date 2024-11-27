import 'package:go_router/go_router.dart';
import 'package:stitches_africa/services/auth_service/auth_service.dart';
import 'package:stitches_africa/views/bottom_bar.dart';
import 'package:stitches_africa/views/screens/auth/forgot_password_screen.dart';
import 'package:stitches_africa/views/screens/auth/guest_sceen.dart';
import 'package:stitches_africa/views/screens/auth/login_screen.dart';
import 'package:stitches_africa/views/screens/auth/register_tailor_screen.dart';
import 'package:stitches_africa/views/screens/auth/register_user_screen.dart';
import 'package:stitches_africa/views/screens/onboarding/onboarding_first_page.dart';
import 'package:stitches_africa/views/screens/onboarding/onboarding_second_page.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/contact_information_screen.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/featured_works_screen.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/personal_information.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/profile_setup.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/tailor_shop.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/tailor_shop/add_new_work.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_onboarding_screen/verify_tailor_address_screen.dart';
import 'package:stitches_africa/views/screens/tailor_side/screen_routes/tailor_orders_screen.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/profile/measurements/measurement_screen.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/profile/measurements/mobile_tailor_measurement_screen.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/profile/measurements/mobile_tailor_onboarding_screen.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/profile/measurements/update_user_measurement_screen.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/profile/orders_and_return_screen.dart';
import 'package:stitches_africa/views/screens/user_side/screen_routes/shopping_bag/shopping_bag_screen.dart';
import 'package:stitches_africa/views/tailor_bottom_bar.dart';

final GoRouter router = GoRouter(debugLogDiagnostics: true, routes: [
  GoRoute(
    path: '/',
    builder: (context, state) => AuthService(),
  ),
  GoRoute(
    path: '/onboarding1',
    name: 'onboarding1',
    builder: (context, state) => OnBoardingFirstPage(),
  ),
  GoRoute(
    path: '/onboarding2',
    name: 'onboarding2',
    builder: (context, state) => const OnBoardingSecondPage(),
  ),
  GoRoute(
      path: '/guest',
      name: 'guest',
      builder: (context, state) => const GuestPage(),
      routes: [
        GoRoute(
            path: 'login',
            name: 'login',
            builder: (context, state) => const LoginScreen(),
            routes: [
              GoRoute(
                path: 'forgotPassword',
                name: 'forgotPassword',
                builder: (context, state) => ForgotPasswordScreen(),
              ),
            ]),
        GoRoute(
          path: 'registerUser',
          name: 'registerUser',
          builder: (context, state) => const RegisterUserScreen(),
        ),
        GoRoute(
          path: 'registerTailor',
          name: 'registerTailor',
          builder: (context, state) => const RegisterTailorScreen(),
        ),
      ]),
  GoRoute(
      path: '/userHome',
      name: 'userHome',
      builder: (context, state) => MyBottomBar(),
      routes: [
        // GoRoute(
        //   path: 'searchedItemScreen',
        //   name: 'searchedItemScreen',
        //   builder: (context, state) =>  SearchedItemRoute(),
        // ),
        GoRoute(
          path: '/measurementsScreen',
          name: 'measurementsScreen',
          builder: (context, state) => MeasurementScreen(),
          routes: [
            GoRoute(
              path: 'mobileTailorMeasurementScreen',
              name: 'mobileTailorMeasurementScreen',
              builder: (context, state) => MobileTailorMeasurementScreen(),
              routes: [
                GoRoute(
                  path: 'mobileTailorOnBoardingScreen',
                  name: 'mobileTailorOnBoardingScreen',
                  builder: (context, state) => MobileTailorOnboardingScreen(),
                ),
                GoRoute(
                  path: 'updateUserMeasurementScreen',
                  name: 'updateUserMeasurementScreen',
                  builder: (context, state) =>
                      const UpdateUserMeasurementScreen(),
                ),
              ],
            ),
          ],
        ),
      ]),
  GoRoute(
      path: '/tailorHome',
      name: 'tailorHome',
      builder: (context, state) => TailorBottomBar(),
      routes: const [
        // GoRoute(
        //   path: 'searchedItemScreen',
        //   name: 'searchedItemScreen',
        //   builder: (context, state) =>  SearchedItemRoute(),
        // ),
      ]),
  GoRoute(
      path: '/profileSetup',
      name: 'profileSetup',
      builder: (context, state) => const ProfileSetup(),
      routes: const []),
  GoRoute(
      path: '/personalInformation',
      name: 'personalInformation',
      builder: (context, state) => const PersonalInformation(),
      routes: const []),
  GoRoute(
      path: '/verifyTailorAddressScreen',
      name: 'verifyTailorAddressScreen',
      builder: (context, state) => const VerifyTailorAddressScreen(),
      routes: const []),
  GoRoute(
    path: '/userOrdersScreen',
    name: 'userOrdersScreen',
    builder: (context, state) => OrdersAndReturnScreen(),
  ),
  GoRoute(
      path: '/contactInfo',
      name: 'contactInfo',
      builder: (context, state) => const ContactInformationScreen(),
      routes: const []),
  GoRoute(
      path: '/featuredWorks',
      name: 'featuredWorks',
      builder: (context, state) => FeaturedWorksScreen(),
      routes: const []),
  GoRoute(
    path: '/tailorShop',
    name: 'tailorShop',
    builder: (context, state) => TailorShop(),
    routes: [
      GoRoute(
        path: 'addNewWork',
        name: 'addNewWork',
        builder: (context, state) => const AddNewWork(),
      ),
    ],
  ),
  GoRoute(
    path: '/shoppingScreen',
    name: 'shoppingScreen',
    builder: (context, state) => ShoppingBagScreen(),
    routes: const [],
  ),
  GoRoute(
    path: '/brandProfile',
    name: 'brandProfile',
    builder: (context, state) => ShoppingBagScreen(),
  ),
  GoRoute(
    path: '/tailorOrdersScreen',
    name: 'tailorOrdersScreen',
    builder: (context, state) => const TailorOrdersScreen(),
    routes: const [],
  ),
]);
