class TokenDto {
  final String accessToken;
  final String tokenType;

  TokenDto({
    required this.accessToken,
    required this.tokenType,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }
}