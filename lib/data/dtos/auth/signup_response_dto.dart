class SignupResponseDto {
  final String userId;

  SignupResponseDto({
    required this.userId,
  });

  factory SignupResponseDto.fromJson(Map<String, dynamic> json) {
    return SignupResponseDto(
      userId: json['user_id'] as String,
    );
  }
}