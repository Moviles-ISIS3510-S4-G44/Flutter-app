class UserDto {
  final String id;
  final String name;
  final String email;
  final int rating;

  UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.rating,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      rating: json['rating'],
    );
  }
}