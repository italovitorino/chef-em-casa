class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'role': 'CLIENT',
      };
}

class TokenResponse {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String refreshToken;

  const TokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) => TokenResponse(
        accessToken: json['accessToken'] as String,
        tokenType: json['tokenType'] as String,
        expiresIn: json['expiresIn'] as int,
        refreshToken: json['refreshToken'].toString(),
      );
}

class UserResponse {
  final String id;
  final String name;
  final String email;
  final String role;

  const UserResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'].toString(),
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
      );
}
