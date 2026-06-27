/// Customer account — mirrors the backend `User` model
/// (/api/user/auth/otp/verify → data.user).
class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.dob,
    this.profilePicUrl,
    this.status,
    this.fcmToken,
  });

  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? dob;
  final String? profilePicUrl;
  final String? status;
  final String? fcmToken;

  factory User.fromJson(Map<String, dynamic> j) => User(
        id: j['id']?.toString() ?? '',
        name: j['name']?.toString() ?? '',
        phone: j['phone']?.toString() ?? '',
        email: j['email']?.toString(),
        dob: j['dob']?.toString(),
        profilePicUrl: j['profilePicUrl']?.toString(),
        status: j['status']?.toString(),
        fcmToken: j['fcmToken']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'dob': dob,
        'profilePicUrl': profilePicUrl,
        'status': status,
      };
}

/// Result of a successful OTP verification.
class AuthResult {
  const AuthResult({
    required this.token,
    required this.user,
    required this.isNewAccount,
  });

  final String token;
  final User user;
  final bool isNewAccount; // false = existing customer logged in
}
