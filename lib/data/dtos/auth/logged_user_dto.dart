class LoggedUserDto {
  final String id;
  final String email;
  final String name;
  final int rating;

  LoggedUserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.rating,
  });

  factory LoggedUserDto.fromJson(Map<String, dynamic> json) {
    return LoggedUserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      rating: json['rating'] as int,
    );
  }
}