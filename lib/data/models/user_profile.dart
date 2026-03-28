class UserProfile {
  const UserProfile({
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.email,
    required this.country,
    required this.phoneNumber,
    required this.gender,
    required this.language,
    this.avatarUrl,
  });

  final String firstName;
  final String lastName;
  final String dateOfBirth;
  final String email;
  final String country;
  final String phoneNumber;
  final String gender;
  final String language;
  final String? avatarUrl;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      firstName: (json['firstName'] as String?) ?? '',
      lastName: (json['lastName'] as String?) ?? '',
      dateOfBirth: (json['dateOfBirth'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      country: (json['country'] as String?) ?? '',
      phoneNumber: (json['phoneNumber'] as String?) ?? '',
      gender: (json['gender'] as String?) ?? '',
      language: (json['language'] as String?) ?? 'English',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }

  String get displayName => '$firstName $lastName'.trim();

  String get fullName {
    final String value = '$lastName $firstName'.trim();
    return value.isEmpty ? displayName : value;
  }

  String get initials {
    final String first = firstName.isEmpty ? '' : firstName[0];
    final String last = lastName.isEmpty ? '' : lastName[0];
    return '$last$first'.toUpperCase();
  }

  bool get hasEmptyRequiredField =>
      firstName.isEmpty ||
      lastName.isEmpty ||
      dateOfBirth.isEmpty ||
      email.isEmpty ||
      country.isEmpty ||
      phoneNumber.isEmpty ||
      gender.isEmpty;

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? email,
    String? country,
    String? phoneNumber,
    String? gender,
    String? language,
    String? avatarUrl,
  }) {
    return UserProfile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      country: country ?? this.country,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      language: language ?? this.language,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'country': country,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'language': language,
      'avatarUrl': avatarUrl,
    };
  }
}
