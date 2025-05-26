class LoginRequestDto {
  final String username;
  final String password;

  LoginRequestDto({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'Username': username,  // Match C# property casing
    'Password': password,
  };
}

class RegisterRequestDto {
  final String username;
  final String email;
  final String password;

  RegisterRequestDto({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'Username': username,  // Match C# property casing
    'Email': email,
    'Password': password,
  };
}

class AuthResponseDto {
  final String token;

  AuthResponseDto({
    required this.token,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      token: json['token'] as String,
    );
  }
}
