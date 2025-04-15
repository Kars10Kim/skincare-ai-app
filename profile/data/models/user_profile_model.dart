import 'package:hive/hive.dart';

import '../../domain/entities/user_profile.dart';

part 'user_profile_model.g.dart';

/// User profile model for Hive storage
@HiveType(typeId: 4)
class UserProfileModel extends HiveObject {
  /// User ID
  @HiveField(0)
  final String id;
  
  /// User name
  @HiveField(1)
  final String? name;
  
  /// User email
  @HiveField(2)
  final String? email;
  
  /// User phone number
  @HiveField(3)
  final String? phoneNumber;
  
  /// User profile image path
  @HiveField(4)
  final String? profileImagePath;
  
  /// User skin type
  @HiveField(5)
  final SkinType skinType;
  
  /// User age range
  @HiveField(6)
  final String? ageRange;
  
  /// User gender
  @HiveField(7)
  final String? gender;
  
  /// User skin concerns
  @HiveField(8)
  final List<String> skinConcerns;
  
  /// User allergies
  @HiveField(9)
  final List<String> allergies;
  
  /// User preferred ingredients
  @HiveField(10)
  final List<String> preferredIngredients;
  
  /// User avoided ingredients
  @HiveField(11)
  final List<String> avoidedIngredients;
  
  /// Date when the user joined
  @HiveField(12)
  final DateTime? joinDate;
  
  /// Last login date
  @HiveField(13)
  final DateTime? lastLoginDate;
  
  /// Account status
  @HiveField(14)
  final AccountStatus accountStatus;
  
  /// Whether the user has completed onboarding
  @HiveField(15)
  final bool hasCompletedOnboarding;
  
  /// Create user profile model
  UserProfileModel({
    required this.id,
    this.name,
    this.email,
    this.phoneNumber,
    this.profileImagePath,
    this.skinType = SkinType.normal,
    this.ageRange,
    this.gender,
    this.skinConcerns = const [],
    this.allergies = const [],
    this.preferredIngredients = const [],
    this.avoidedIngredients = const [],
    this.joinDate,
    this.lastLoginDate,
    this.accountStatus = AccountStatus.active,
    this.hasCompletedOnboarding = false,
  });
  
  /// Create model from entity
  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      id: profile.id,
      name: profile.name,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      profileImagePath: profile.profileImagePath,
      skinType: profile.skinType,
      ageRange: profile.ageRange,
      gender: profile.gender,
      skinConcerns: List<String>.from(profile.skinConcerns),
      allergies: List<String>.from(profile.allergies),
      preferredIngredients: List<String>.from(profile.preferredIngredients),
      avoidedIngredients: List<String>.from(profile.avoidedIngredients),
      joinDate: profile.joinDate,
      lastLoginDate: profile.lastLoginDate,
      accountStatus: profile.accountStatus,
      hasCompletedOnboarding: profile.hasCompletedOnboarding,
    );
  }
  
  /// Convert to entity
  UserProfile toEntity() {
    return UserProfile(
      id: id,
      name: name,
      email: email,
      phoneNumber: phoneNumber,
      profileImagePath: profileImagePath,
      skinType: skinType,
      ageRange: ageRange,
      gender: gender,
      skinConcerns: List<String>.from(skinConcerns),
      allergies: List<String>.from(allergies),
      preferredIngredients: List<String>.from(preferredIngredients),
      avoidedIngredients: List<String>.from(avoidedIngredients),
      joinDate: joinDate,
      lastLoginDate: lastLoginDate,
      accountStatus: accountStatus,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }
  
  /// Create from JSON map
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      profileImagePath: json['profileImagePath'],
      skinType: SkinType.values[json['skinType'] ?? 0],
      ageRange: json['ageRange'],
      gender: json['gender'],
      skinConcerns: List<String>.from(json['skinConcerns'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      preferredIngredients: List<String>.from(json['preferredIngredients'] ?? []),
      avoidedIngredients: List<String>.from(json['avoidedIngredients'] ?? []),
      joinDate: json['joinDate'] != null ? DateTime.parse(json['joinDate']) : null,
      lastLoginDate: json['lastLoginDate'] != null ? DateTime.parse(json['lastLoginDate']) : null,
      accountStatus: AccountStatus.values[json['accountStatus'] ?? 0],
      hasCompletedOnboarding: json['hasCompletedOnboarding'] ?? false,
    );
  }
  
  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'profileImagePath': profileImagePath,
      'skinType': skinType.index,
      'ageRange': ageRange,
      'gender': gender,
      'skinConcerns': skinConcerns,
      'allergies': allergies,
      'preferredIngredients': preferredIngredients,
      'avoidedIngredients': avoidedIngredients,
      'joinDate': joinDate?.toIso8601String(),
      'lastLoginDate': lastLoginDate?.toIso8601String(),
      'accountStatus': accountStatus.index,
      'hasCompletedOnboarding': hasCompletedOnboarding,
    };
  }
}

/// SkinType adapter for Hive
@HiveType(typeId: 5)
enum SkinType {
  @HiveField(0)
  normal,
  
  @HiveField(1)
  dry,
  
  @HiveField(2)
  oily,
  
  @HiveField(3)
  combination,
  
  @HiveField(4)
  sensitive,
}

/// AccountStatus adapter for Hive
@HiveType(typeId: 6)
enum AccountStatus {
  @HiveField(0)
  active,
  
  @HiveField(1)
  pendingVerification,
  
  @HiveField(2)
  pendingDeletion,
  
  @HiveField(3)
  suspended,
}