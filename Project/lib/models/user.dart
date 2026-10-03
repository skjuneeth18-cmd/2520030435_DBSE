/// Role of an account, deciding which dashboard it sees (Phase 3).
enum UserRole { donor, hospitalAdmin, bloodBankAdmin }

extension UserRoleX on UserRole {
  String get label => switch (this) {
        UserRole.donor => 'Donor / User',
        UserRole.hospitalAdmin => 'Hospital Admin',
        UserRole.bloodBankAdmin => 'Blood Bank Admin',
      };
}

/// Application user model (mock: stored in the auth service).
class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.bloodGroup,
    required this.area,
    this.city = 'Hyderabad',
    this.age,      this.role = UserRole.donor,
      this.managedFacilityId,
      this.kycRecordId,
    });

  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String bloodGroup; // e.g. 'O+'
  final String area; // e.g. 'Kukatpally'
  final String city;
  final int? age; // donor age for eligibility (Phase 2)
  final UserRole role; // dashboard to show (Phase 3)
  final String? managedFacilityId; // 'h01' / 'bb01' for admins
  final String? kycRecordId; // Phase 4: linked KYC record

  bool get isAdmin => role != UserRole.donor;

  bool get hasKYC => kycRecordId != null;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  AppUser copyWith({
    String? fullName,
    String? phone,
    String? bloodGroup,
    String? area,
    String? city,
    int? age,
    UserRole? role,
    String? managedFacilityId,
    String? kycRecordId,
  }) {
    return AppUser(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      area: area ?? this.area,
      city: city ?? this.city,
      age: age ?? this.age,
      role: role ?? this.role,
      managedFacilityId: managedFacilityId ?? this.managedFacilityId,
      kycRecordId: kycRecordId ?? this.kycRecordId,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'bloodGroup': bloodGroup,
        'area': area,
        'city': city,
        'age': age,
        'role': role.name,
        'managedFacilityId': managedFacilityId,
        'kycRecordId': kycRecordId,
      };

  factory AppUser.fromMap(Map<String, dynamic> map) => AppUser(
        id: map['id'] as String,
        fullName: map['fullName'] as String,
        email: map['email'] as String,
        phone: map['phone'] as String,
        bloodGroup: map['bloodGroup'] as String,
        area: map['area'] as String,
        city: map['city'] as String? ?? 'Hyderabad',
        age: (map['age'] as num?)?.toInt(),
        role: UserRole.values.firstWhere(
          (r) => r.name == (map['role'] as String?),
          orElse: () => UserRole.donor,
        ),
        managedFacilityId: map['managedFacilityId'] as String?,
        kycRecordId: map['kycRecordId'] as String?,
      );
}
