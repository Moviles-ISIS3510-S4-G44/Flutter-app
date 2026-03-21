class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final bool isSuperuser;
  final String? profilePictureUrl;

  // getters so the rest of the app can use uid/name
  String get uid => id;
  String get name => '$firstName $lastName'.trim();

  const AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.isActive = true,
    this.isSuperuser = false,
    this.profilePictureUrl,
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    bool? isActive,
    bool? isSuperuser,
    String? profilePictureUrl,
    String? name,
    String? photoUrl,
  }) {
    // split name into first/last if passed as single string
    String resolvedFirst = firstName ?? this.firstName;
    String resolvedLast = lastName ?? this.lastName;
    if (name != null) {
      final parts = name.trim().split(' ');
      resolvedFirst = parts.first;
      resolvedLast = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: resolvedFirst,
      lastName: resolvedLast,
      isActive: isActive ?? this.isActive,
      isSuperuser: isSuperuser ?? this.isSuperuser,
      profilePictureUrl: photoUrl ?? profilePictureUrl ?? this.profilePictureUrl,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }
}
