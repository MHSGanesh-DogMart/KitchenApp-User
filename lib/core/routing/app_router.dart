import 'package:flutter/material.dart';

// Phase 2 — Auth screens
import '../../presentation/screens/auth/location_permission_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/saved_addresses_screen.dart';
import '../../presentation/screens/auth/splash_screen.dart' as auth_splash;
import '../../presentation/screens/common/tab_shell.dart';
// Phase 8 — Empty/error states
import '../../presentation/screens/common/states.dart';
// (Phase 7 cook-side imports removed — cook flow now lives in the
// separate Padosi Partner app.)
// Phase 6 — Profile sub-screens
import '../../presentation/screens/profile/addresses_list_screen.dart';
import '../../presentation/screens/profile/edit_profile_screen.dart';
import '../../presentation/screens/profile/gift_cards_screen.dart';
import '../../presentation/screens/profile/help_screen.dart';
import '../../presentation/screens/profile/invite_screen.dart';
import '../../presentation/screens/profile/language_screen.dart';
import '../../presentation/screens/profile/payments_screen.dart';
import '../../presentation/screens/profile/refunds_screen.dart';
import '../../presentation/screens/profile/rewards_screen.dart';
import '../../presentation/screens/profile/settings_screen.dart';
// Phase 5 — Community
import '../../presentation/screens/community/create_post_screen.dart';
import '../../presentation/screens/community/post_detail_screen.dart';
// Phase 4 — Orders
import '../../presentation/screens/orders/cancel_screen.dart';
import '../../presentation/screens/orders/chat_screen.dart';
import '../../presentation/screens/orders/delivery_otp_screen.dart';
import '../../presentation/screens/orders/notifications_screen.dart';
import '../../presentation/screens/orders/order_detail_screen.dart';
import '../../presentation/screens/orders/pickup_code_screen.dart';
import '../../presentation/screens/orders/rate_screen.dart';
import '../../presentation/screens/orders/refund_status_screen.dart';
import '../../presentation/screens/orders/report_screen.dart';
import '../../presentation/screens/orders/tracking_screen.dart' as p4_track;
// Phase 3 — Discover + Order flow
import '../../presentation/screens/discover/cart_screen.dart' as p3_cart;
import '../../presentation/screens/discover/add_address_screen.dart';
import '../../presentation/screens/discover/cook_detail_screen.dart' as p3_cook;
import '../../presentation/screens/discover/coupons_screen.dart';
import '../../presentation/screens/discover/dish_detail_screen.dart';
import '../../presentation/screens/discover/favourites_screen.dart';
import '../../presentation/screens/discover/order_placed_screen.dart';
import '../../models/order.dart';
import '../../presentation/screens/discover/payment_method_screen.dart';
import '../../presentation/screens/discover/schedule_screen.dart';
import '../../presentation/screens/discover/search_screen.dart';
import '../../presentation/screens/discover/specialty_screen.dart';
// Legacy / pre-Phase-2 screens (still in use)
import '../../presentation/screens/padosi/location/location_result.dart';
import '../../presentation/screens/padosi/location/select_location_screen.dart';
import '../../presentation/screens/padosi/mock/mock_data.dart';
import '../../presentation/screens/splash/splash_screen.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      // ── Boot ──
      case RouteNames.boot:
      case RouteNames.splash:
        return _page(const SplashScreen(), settings);

      // ── Phase 2 auth flow ──
      case RouteNames.onboarding:
        return _page(const auth_splash.AuthSplashScreen(), settings);
      case RouteNames.login:
        return _page(const LoginScreen(), settings);
      // (RouteNames.otp removed — login now handles OTP inline.)
      case RouteNames.locationPermission:
        return _page(const LocationPermissionScreen(), settings);
      case RouteNames.savedAddresses:
        return _page(const SavedAddressesScreen(), settings);

      // ── Tabs ──
      case RouteNames.home:
      case RouteNames.discover:
      case RouteNames.community:
      case RouteNames.orders:
      case RouteNames.profile:
        return _page(
          TabShell(initialIndex: _tabIndex(settings.name!)),
          settings,
        );

      // ── Phase 3: Discover + Order flow ──
      case RouteNames.discoverSearch:
        return _page(const SearchScreen(), settings);
      case RouteNames.specialty:
        final category = (settings.arguments as String?) ?? 'Jain food';
        return _page(SpecialtyScreen(category: category), settings);
      case RouteNames.favourites:
        return _page(const FavouritesScreen(), settings);
      case RouteNames.cookDetail:
        final cook = settings.arguments as Cook? ?? MockData.sunita;
        return _page(p3_cook.CookDetailScreen(cook: cook), settings);
      case RouteNames.dishDetail:
        final args = settings.arguments as Map? ?? const {};
        return _page(
          DishDetailScreen(
            dish: args['dish'] as Dish? ?? MockData.sunita.menu.first,
            cookName: args['cookName'] as String?,
            dishId: args['dishId'] as String?,
          ),
          settings,
        );
      case RouteNames.schedule:
        return _page(const ScheduleScreen(), settings);
      case RouteNames.cart:
        // Cart is fully server-backed now — no args needed.
        return _page(const p3_cart.CartScreen(), settings);
      case RouteNames.coupons:
        return _page(const CouponsScreen(), settings);
      case RouteNames.checkout:
        // Cart + checkout are one screen now — both routes show the cart.
        return _page(const p3_cart.CartScreen(), settings);
      case RouteNames.addAddress:
        return _page(const AddAddressScreen(), settings);
      case RouteNames.paymentMethod:
        return _page(const PaymentMethodScreen(), settings);
      case RouteNames.orderPlaced:
        final args = settings.arguments as Map? ?? const {};
        return _page(
          OrderPlacedScreen(
            order: args['order'] as Order?,
            total: (args['total'] as int?) ?? 0,
          ),
          settings,
        );
      case RouteNames.orderTracking:
        final args = settings.arguments as Map? ?? const {};
        return _page(
          p4_track.TrackingScreen(cook: args['cook'] as Cook?),
          settings,
        );
      case RouteNames.deliveryOtp:
        return _page(const DeliveryOtpScreen(), settings);
      case RouteNames.pickupCode:
        return _page(const PickupCodeScreen(), settings);
      case RouteNames.chat:
        return _page(const ChatScreen(), settings);
      case RouteNames.rate:
        return _page(const RateScreen(), settings);
      case RouteNames.reportProblem:
        return _page(const ReportScreen(), settings);
      case RouteNames.refundStatus:
        return _page(const RefundStatusScreen(), settings);
      case RouteNames.cancelOrder:
        return _page(const CancelScreen(), settings);
      case RouteNames.orderDetail:
        final args = settings.arguments as Map? ?? const {};
        return _page(
          OrderDetailScreen(orderId: args['orderId'] as String?),
          settings,
        );
      case RouteNames.notifications:
        return _page(const NotificationsScreen(), settings);

      // ── Phase 5: Community ──
      case RouteNames.postDetail:
        return _page(const PostDetailScreen(), settings);
      case RouteNames.createPost:
        return _page(const CreatePostScreen(), settings);

      // ── Phase 6: Profile sub-screens ──
      case RouteNames.editProfile:
        return _page(const EditProfileScreen(), settings);
      case RouteNames.addressesList:
        return _page(const AddressesListScreen(), settings);
      case RouteNames.payments:
        return _page(const PaymentsScreen(), settings);
      case RouteNames.refunds:
        return _page(const RefundsScreen(), settings);
      case RouteNames.giftCards:
        return _page(const GiftCardsScreen(), settings);
      case RouteNames.rewards:
        return _page(const RewardsScreen(), settings);
      case RouteNames.invite:
        return _page(const InviteScreen(), settings);
      case RouteNames.settings:
        return _page(const SettingsScreen(), settings);
      case RouteNames.language:
        return _page(const LanguageScreen(), settings);
      case RouteNames.help:
        return _page(const HelpScreen(), settings);

      // ── Phase 8: Empty / error states ──
      case RouteNames.stateNoCooks:
        return _page(const NoCooksScreen(), settings);
      case RouteNames.stateEmptyCart:
        return _page(const EmptyCartScreen(), settings);
      case RouteNames.stateNoResults:
        return _page(const NoResultsScreen(), settings);
      case RouteNames.statePaymentFailed:
        return _page(const PaymentFailedScreen(), settings);
      case RouteNames.stateOffline:
        return _page(const OfflineScreen(), settings);
      case RouteNames.stateNoRider:
        return _page(const NoRiderScreen(), settings);

      // (Phase 7 cook-side routes moved to the Padosi Partner app.)
      case RouteNames.selectLocation:
        return _page(
          SelectLocationScreen(initial: settings.arguments as LocationResult?),
          settings,
        );

      default:
        return _page(const _NotFound(), settings);
    }
  }

  static int _tabIndex(String name) => switch (name) {
    RouteNames.discover => 1,
    RouteNames.community => 2,
    RouteNames.orders => 3,
    RouteNames.profile => 4,
    _ => 0,
  };

  static MaterialPageRoute _page(Widget child, RouteSettings settings) =>
      MaterialPageRoute(builder: (_) => child, settings: settings);
}

class _NotFound extends StatelessWidget {
  const _NotFound();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Route not found')));
}
