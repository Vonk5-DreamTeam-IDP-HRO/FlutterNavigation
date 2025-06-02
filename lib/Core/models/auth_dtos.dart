class LoginRequestDto {
  final String username;
  final String password;
  late final String email;  // Added to match C# UserDto

  LoginRequestDto({
    required this.username,
    required this.password,
  }) {
    email = '$username@placeholder.com'; // Auto-generate placeholder email
  }

  Map<String, dynamic> toJson() => {
    'Username': username,  // Match C# model casing
    'Password': password,
    'Email': email,
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
    'Username': username,  // Match C# model casing
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
      token: json['Token'] ?? json['token'] as String,  // Support both PascalCase and camelCase
    );
  }
}
