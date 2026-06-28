class ApiEndpoints {
  ApiEndpoints._();

  // ── Customer auth (two-step OTP) ──
  static const String userSendOtp = '/api/user/auth/otp/send';
  static const String userVerifyOtp = '/api/user/auth/otp/verify';
  static const String userCuisines = '/api/user/cuisines';
  static const String userCoupons = '/api/user/coupons';
  static const String userHome = '/api/user/home';

  // ── Browse (kitchens & dishes) ──
  static const String userKitchens = '/api/user/kitchens';
  static String userKitchenById(String id) => '/api/user/kitchens/$id';
  static String userKitchenMenu(String id) => '/api/user/kitchens/$id/menu';
  static const String userDishes = '/api/user/dishes';
  static String userDishById(String id) => '/api/user/dishes/$id';

  // ── Cart (server-side, single kitchen) ──
  static const String userCart = '/api/user/cart';
  static const String userCartAdd = '/api/user/cart/add';
  static const String userCartIncrement = '/api/user/cart/increment';
  static const String userCartDecrement = '/api/user/cart/decrement';
  static String userCartItem(String menuItemId) => '/api/user/cart/item/$menuItemId';
  static const String userCartCoupon = '/api/user/cart/coupon';

  // ── Orders + payment ──
  static const String userOrderCheckout = '/api/user/orders/checkout';
  static const String userOrderVerify = '/api/user/orders/verify';
  static const String userOrders = '/api/user/orders';
  static String userOrderById(String id) => '/api/user/orders/$id';

  // ── Addresses ──
  static const String userAddresses = '/api/user/addresses';
  static String userAddressById(String id) => '/api/user/addresses/$id';
  static String userAddressDefault(String id) => '/api/user/addresses/$id/default';

  // ── Wishlist ──
  static const String userWishlist = '/api/user/wishlist';
  static String userWishlistItem(String type, String id) =>
      '/api/user/wishlist/$type/$id';

  // ── Customer profile (token-based; id derived from JWT) ──
  static const String userMe = '/api/user/me';
  static const String userUpload = '/api/user/upload';

  // ── FCM (multi-device), logout, delete account ──
  static const String userFcmToken = '/api/user/fcm-token';
  static const String userLogout = '/api/user/logout';
  static const String userDeleteAccount = '/api/user/account';

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';

  static const String me = '/user/me';
  static const String updateProfile = '/user/me';
  static const String uploadImage = '/media/upload';
  static const String uploadImages = '/media/upload-multi';

  static const String notifications = '/notifications';
  static const String registerFcmToken = '/user/fcm-token';
}
