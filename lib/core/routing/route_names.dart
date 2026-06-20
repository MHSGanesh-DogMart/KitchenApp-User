class RouteNames {
  RouteNames._();

  static const String boot = '/';
  static const String splash = '/splash';

  // Padosi auth flow (Phase 2)
  static const String onboarding = '/onboarding';        // legacy alias for splash
  static const String authIntro = '/auth/intro';
  static const String login = '/auth/login';
  // (otp route removed — login handles OTP inline on the same screen.)
  static const String locationPermission = '/auth/location-permission';
  static const String savedAddresses = '/auth/addresses';

  // Tabs
  static const String home = '/home';
  static const String discover = '/discover';
  static const String community = '/community';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Sub-flows
  static const String cookDetail = '/cook-detail';
  static const String dishDetail = '/dish-detail';
  static const String schedule = '/schedule';
  static const String cart = '/cart';
  static const String coupons = '/coupons';
  static const String checkout = '/checkout';
  static const String paymentMethod = '/payment-method';
  static const String orderPlaced = '/order-placed';
  static const String orderTracking = '/order-tracking';
  static const String selectLocation = '/select-location';
  static const String discoverSearch = '/discover/search';
  static const String specialty = '/discover/specialty';
  static const String favourites = '/discover/favourites';

  // Phase 5 — Community
  static const String postDetail = '/community/post';
  static const String createPost = '/community/create';

  // Phase 8 — States
  static const String stateNoCooks = '/state/no-cooks';
  static const String stateEmptyCart = '/state/empty-cart';
  static const String stateNoResults = '/state/no-results';
  static const String statePaymentFailed = '/state/payment-failed';
  static const String stateOffline = '/state/offline';
  static const String stateNoRider = '/state/no-rider';

  // (Phase 7 cook-side routes were moved to the Padosi Partner app.)

  // Phase 6 — Profile sub-screens
  static const String addressesList = '/profile/addresses';
  static const String payments = '/profile/payments';
  static const String invite = '/profile/invite';
  static const String language = '/profile/language';
  static const String help = '/profile/help';

  // Phase 4 — Orders
  static const String deliveryOtp = '/orders/delivery-otp';
  static const String pickupCode = '/orders/pickup-code';
  static const String chat = '/orders/chat';
  static const String rate = '/orders/rate';
  static const String reportProblem = '/orders/report';
  static const String refundStatus = '/orders/refund-status';
  static const String cancelOrder = '/orders/cancel';
  static const String orderDetail = '/orders/detail';

  // Profile sub — added screens
  static const String refunds = '/profile/refunds';
  static const String giftCards = '/profile/gift-cards';
  static const String rewards = '/profile/rewards';

  // Legacy / reserved
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String search = '/search';
  static const String detail = '/detail';
}
