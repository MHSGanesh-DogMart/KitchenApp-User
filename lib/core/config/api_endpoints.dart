class ApiEndpoints {
  ApiEndpoints._();

  // ── Customer auth (two-step OTP) ──
  static const String userSendOtp = '/api/user/auth/otp/send';
  static const String userVerifyOtp = '/api/user/auth/otp/verify';
  static const String userCuisines = '/api/user/cuisines';

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
