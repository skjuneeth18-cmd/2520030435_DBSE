import 'blood_availability.dart';

/// Blood bank center model.
class BloodBank {
  const BloodBank({
    required this.id,
    required this.name,
    required this.affiliatedHospital,
    required this.area,
    required this.city,
    required this.address,
    required this.phone,
    required this.openHours,
    required this.isVerified,
    this.stockSeed,
  });

  final String id;
  final String name;
  final String affiliatedHospital; // '' if standalone
  final String area;
  final String city;
  final String address;
  final String phone;
  final String openHours;
  final bool isVerified;

  final int? stockSeed;

  FacilityStock get stock => FacilityStock.mock(stockSeed ?? id.hashCode.abs());

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'affiliatedHospital': affiliatedHospital,
        'area': area,
        'city': city,
        'address': address,
        'phone': phone,
        'openHours': openHours,
        'isVerified': isVerified,
      };
}
