import 'package:equatable/equatable.dart';

/// User skin type
enum SkinType {
  /// Normal skin
  normal,
  
  /// Dry skin
  dry,
  
  /// Oily skin
  oily,
  
  /// Combination skin
  combination,
  
  /// Sensitive skin
  sensitive,
}

/// Account status
enum AccountStatus {
  /// Active account
  active,
  
  /// Email verification pending
  pendingVerification,
  
  /// Account scheduled for deletion
  pendingDeletion,
  
  /// Account suspended
  suspended,
}

/// User profile with personal and skincare information
class UserProfile extends Equatable {
  /// User ID
  final String id;
  
  /// User name
  final String? name;
  
  /// User email
  final String? email;
  
  /// User phone number
  final String? phoneNumber;
  
  /// User profile image path
  final String? profileImagePath;
  
  /// User skin type
  final SkinType skinType;
  
  /// User age range
  final String? ageRange;
  
  /// User gender
  final String? gender;
  
  /// User skin concerns
  final List<String> skinConcerns;
  
  /// User allergies
  final List<String> allergies;
  
  /// User preferred ingredients
  final List<String> preferredIngredients;
  
  /// User avoided ingredients
  final List<String> avoidedIngredients;
  
  /// Date when the user joined
  final DateTime? joinDate;
  
  /// Last login date
  final DateTime? lastLoginDate;
  
  /// Account status
  final AccountStatus accountStatus;
  
  /// Whether the user has completed onboarding
  final bool hasCompletedOnboarding;
  
  /// Create user profile
  const UserProfile({
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
  
  /// Create copy of user profile with modified fields
  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
    SkinType? skinType,
    String? ageRange,
    String? gender,
    List<String>? skinConcerns,
    List<String>? allergies,
    List<String>? preferredIngredients,
    List<String>? avoidedIngredients,
    DateTime? joinDate,
    DateTime? lastLoginDate,
    AccountStatus? accountStatus,
    bool? hasCompletedOnboarding,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      skinType: skinType ?? this.skinType,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      skinConcerns: skinConcerns ?? this.skinConcerns,
      allergies: allergies ?? this.allergies,
      preferredIngredients: preferredIngredients ?? this.preferredIngredients,
      avoidedIngredients: avoidedIngredients ?? this.avoidedIngredients,
      joinDate: joinDate ?? this.joinDate,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      accountStatus: accountStatus ?? this.accountStatus,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
  
  /// Convert to map for storage
  Map<String, dynamic> toMap() {
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
  
  /// Create from map
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phoneNumber'],
      profileImagePath: map['profileImagePath'],
      skinType: SkinType.values[map['skinType'] ?? 0],
      ageRange: map['ageRange'],
      gender: map['gender'],
      skinConcerns: List<String>.from(map['skinConcerns'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      preferredIngredients: List<String>.from(map['preferredIngredients'] ?? []),
      avoidedIngredients: List<String>.from(map['avoidedIngredients'] ?? []),
      joinDate: map['joinDate'] != null ? DateTime.parse(map['joinDate']) : null,
      lastLoginDate: map['lastLoginDate'] != null ? DateTime.parse(map['lastLoginDate']) : null,
      accountStatus: AccountStatus.values[map['accountStatus'] ?? 0],
      hasCompletedOnboarding: map['hasCompletedOnboarding'] ?? false,
    );
  }
  
  /// Create empty profile with a unique ID
  factory UserProfile.empty(String userId) {
    return UserProfile(
      id: userId,
      joinDate: DateTime.now(),
    );
  }
  
  /// Check if profile has sensitive data
  bool get hasSensitiveData => 
      email != null || phoneNumber != null || allergies.isNotEmpty;
  
  /// Get display name (returns name or 'User' if name is null)
  String get displayName => name ?? 'User';
  
  /// Whether profile is complete with necessary information
  bool get isProfileComplete => 
      name != null && skinType != SkinType.normal && 
      skinConcerns.isNotEmpty && hasCompletedOnboarding;
  
  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phoneNumber,
    profileImagePath,
    skinType,
    ageRange,
    gender,
    skinConcerns,
    allergies,
    preferredIngredients,
    avoidedIngredients,
    joinDate,
    lastLoginDate,
    accountStatus,
    hasCompletedOnboarding,
  ];
}