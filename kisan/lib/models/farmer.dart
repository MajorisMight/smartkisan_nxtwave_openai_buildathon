class Farmer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String profileImage;
  final String farmName;
  final String farmLocation;
  final double farmSize; // in acres
  final List<String> crops;
  final String experience; // years of experience
  final String bio;
  final bool isVerified;
  final DateTime joinDate;
  final double rating;
  final int totalReviews;
  final List<String> certifications;
  final String preferredLanguage;
  final bool notificationsEnabled;

  Farmer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.profileImage,
    required this.farmName,
    required this.farmLocation,
    required this.farmSize,
    required this.crops,
    required this.experience,
    required this.bio,
    required this.isVerified,
    required this.joinDate,
    required this.rating,
    required this.totalReviews,
    required this.certifications,
    required this.preferredLanguage,
    required this.notificationsEnabled,
  });

  factory Farmer.fromJson(Map<String, dynamic> json) {
    return Farmer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      profileImage: json['profileImage'] ?? '',
      farmName: json['farmName'] ?? '',
      farmLocation: json['farmLocation'] ?? '',
      farmSize: (json['farmSize'] ?? 0).toDouble(),
      crops: List<String>.from(json['crops'] ?? []),
      experience: json['experience'] ?? '',
      bio: json['bio'] ?? '',
      isVerified: json['isVerified'] ?? false,
      joinDate: DateTime.parse(json['joinDate'] ?? DateTime.now().toIso8601String()),
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      certifications: List<String>.from(json['certifications'] ?? []),
      preferredLanguage: json['preferredLanguage'] ?? 'English',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'farmName': farmName,
      'farmLocation': farmLocation,
      'farmSize': farmSize,
      'crops': crops,
      'experience': experience,
      'bio': bio,
      'isVerified': isVerified,
      'joinDate': joinDate.toIso8601String(),
      'rating': rating,
      'totalReviews': totalReviews,
      'certifications': certifications,
      'preferredLanguage': preferredLanguage,
      'notificationsEnabled': notificationsEnabled,
    };
  }
}
