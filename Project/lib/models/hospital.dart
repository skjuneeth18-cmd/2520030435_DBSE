import 'blood_availability.dart';

/// Hospital model for Top-10 Hospitals list and detail screens.
class Hospital {
  const Hospital({
    required this.id,
    required this.name,
    required this.area,
    required this.city,
    required this.address,
    required this.phone,
    required this.hasBloodBank,
    required this.hasEmergency,
    required this.doctorCount,
    required this.specialties,
    required this.isVerified,
    required this.rating,
    this.stockSeed,
  });

  final String id;
  final String name;
  final String area;
  final String city;
  final String address;
  final String phone;
  final bool hasBloodBank;
  final bool hasEmergency;
  final int doctorCount;
  final List<String> specialties;
  final bool isVerified;
  final double rating;

  /// Deterministic seed used by FacilityStock.mock for Phase 1 stock data.
  final int? stockSeed;

  FacilityStock get stock => FacilityStock.mock(stockSeed ?? id.hashCode.abs());

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'area': area,
        'city': city,
        'address': address,
        'phone': phone,
        'hasBloodBank': hasBloodBank,
        'hasEmergency': hasEmergency,
        'doctorCount': doctorCount,
        'specialties': specialties,
        'isVerified': isVerified,
        'rating': rating,
      };
}
