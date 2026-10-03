import '../models/benefit.dart';

/// Participating hospital display info for the benefits brochure.
class ParticipatingHospital {
  const ParticipatingHospital({
    required this.id,
    required this.name,
    required this.type, // 'hospital' or 'bloodbank'
    required this.area,
  });

  final String id;
  final String name;
  final String type;
  final String area;
}

/// Phase 4 seed benefits (mock data).
///
/// Benefits are scoped to specific hospitals. Each benefit has an expiry
/// window so inactive ones can be filtered out.
List<Benefit> kBenefits = [
  Benefit(
    id: 'b01',
    title: 'Free Annual Health Checkup',
    description:
        'One free comprehensive health checkup per year at participating hospitals. Includes basic vitals, CBC and lipid profile.',
    benefitType: BenefitType.freeCheckup,
    participatingHospitalIds: ['h01', 'h02', 'h03'],
    isValidFrom: DateTime(2026, 1, 1),
    isValidUntil: DateTime(2027, 1, 1),
  ),
  Benefit(
    id: 'b02',
    title: 'Doctor Consultation Discount',
    description:
        '20% off on doctor consultation fees at partner hospitals. Valid for first-time visitors and returning donors.',
    benefitType: BenefitType.consultationDiscount,
    discountPercent: 20,
    participatingHospitalIds: ['h01', 'h02', 'h04', 'h05'],
    isValidFrom: DateTime(2026, 1, 1),
    isValidUntil: DateTime(2027, 1, 1),
  ),
  Benefit(
    id: 'b03',
    title: 'Diagnostic Test Discount',
    description:
        '15% discount on in-house diagnostic tests. Valid with donor certificate at the billing counter.',
    benefitType: BenefitType.diagnosticDiscount,
    discountPercent: 15,
    participatingHospitalIds: ['h03', 'h06', 'h07'],
    isValidFrom: DateTime(2026, 1, 1),
    isValidUntil: DateTime(2027, 1, 1),
  ),
  Benefit(
    id: 'b04',
    title: 'Partner Blood Bank Priority',
    description:
        'Verified donors get priority reservation for rare blood groups at participating blood banks during emergencies.',
    benefitType: BenefitType.partnerHospitalBenefit,
    participatingHospitalIds: ['bb01', 'bb02', 'bb03', 'bb04', 'bb05'],
    isValidFrom: DateTime(2026, 1, 1),
    isValidUntil: DateTime(2027, 1, 1),
  ),
  Benefit(
    id: 'b05',
    title: 'Free Liver Function Test',
    description:
        'One free Liver Function Test per verified donor per year at City Care hospitals.',
    benefitType: BenefitType.freeCheckup,
    participatingHospitalIds: ['h01', 'h02'],
    isValidFrom: DateTime(2026, 6, 1),
    isValidUntil: DateTime(2027, 6, 1),
  ),
  Benefit(
    id: 'b06',
    title: 'Family Consultation Pass',
    description:
        'One complimentary consultation pass for a family member at partner hospitals, valid for 6 months from issue.',
    benefitType: BenefitType.consultationDiscount,
    discountPercent: 100,
    participatingHospitalIds: ['h04', 'h05', 'h08'],
    isValidFrom: DateTime(2026, 1, 1),
    isValidUntil: DateTime(2027, 1, 1),
  ),
  Benefit(
    id: 'b07',
    title: 'Blood Bank Donation Camp Priority',
    description:
        'Verified donors get early access registration for upcoming donation camps at participating blood banks.',
    benefitType: BenefitType.partnerHospitalBenefit,
    participatingHospitalIds: ['bb06', 'bb07', 'bb08'],
    isValidFrom: DateTime(2026, 1, 1),
    isValidUntil: DateTime(2027, 1, 1),
  ),
  Benefit(
    id: 'b08',
    title: 'Seasonal Health Screening',
    description:
        'Free seasonal health screening camp access for verified donors twice a year at partner hospitals.',
    benefitType: BenefitType.freeCheckup,
    participatingHospitalIds: ['h09', 'h10', 'h11', 'h12'],
    isValidFrom: DateTime(2026, 1, 1),
    isValidUntil: DateTime(2027, 1, 1),
  ),
];

const List<ParticipatingHospital> kParticipatingHospitals = [
  ParticipatingHospital(id: 'h01', name: 'City Care Hospital', type: 'hospital', area: 'Kukatpally'),
  ParticipatingHospital(id: 'h02', name: 'Lifeline Hospital', type: 'hospital', area: 'Banjara Hills'),
  ParticipatingHospital(id: 'h03', name: 'Prince Hospital', type: 'hospital', area: 'Secunderabad'),
  ParticipatingHospital(id: 'h04', name: 'Omega Hospital', type: 'hospital', area: 'Dilsukhnagar'),
  ParticipatingHospital(id: 'h05', name: 'Richie Rich Memorial Hospital', type: 'hospital', area: 'Gachibowli'),
  ParticipatingHospital(id: 'h06', name: 'Care Hospital', type: 'hospital', area: 'Jubilee Hills'),
  ParticipatingHospital(id: 'h07', name: 'Aaditya Hospital', type: 'hospital', area: 'Madhapur'),
  ParticipatingHospital(id: 'h08', name: 'Apollo Hospital', type: 'hospital', area: 'Somajiguda'),
  ParticipatingHospital(id: 'h09', name: 'Apollo Ideal Hospital', type: 'hospital', area: 'Abids'),
  ParticipatingHospital(id: 'h10', name: 'Sudha Hospital', type: 'hospital', area: 'Koti'),
  ParticipatingHospital(id: 'h11', name: 'Niims Hospital', type: 'hospital', area: 'Uppal'),
  ParticipatingHospital(id: 'h12', name: 'Regenix Super Speciality Hospital', type: 'hospital', area: 'Miyapur'),
  ParticipatingHospital(id: 'bb01', name: 'City Care Blood Centre', type: 'bloodbank', area: 'Kukatpally'),
  ParticipatingHospital(id: 'bb02', name: 'Vamsi Blood Bank', type: 'bloodbank', area: 'Miyapur'),
  ParticipatingHospital(id: 'bb03', name: 'Life Blood Bank', type: 'bloodbank', area: 'Secunderabad'),
  ParticipatingHospital(id: 'bb04', name: 'Aadhya Blood Bank', type: 'bloodbank', area: 'Dilsukhnagar'),
  ParticipatingHospital(id: 'bb05', name: 'Shreeya Blood Bank', type: 'bloodbank', area: 'Gachibowli'),
  ParticipatingHospital(id: 'bb06', name: 'Dhanush Blood Bank', type: 'bloodbank', area: 'Banjara Hills'),
  ParticipatingHospital(id: 'bb07', name: 'Sudha Blood Bank', type: 'bloodbank', area: 'Koti'),
  ParticipatingHospital(id: 'bb08', name: 'Prasanna Blood Bank', type: 'bloodbank', area: 'Kukatpally'),
];

/// Terms & conditions text shown in the benefits brochure.
const String kBenefitsTerms = '''
By using a donor benefit or coupon, you agree to the following terms:

1. All benefits are available only to verified donors of RaktaSetu.
2. A valid donor certificate or verified donor badge must be shown at the
   participating hospital / blood bank to avail the benefit.
3. Discount benefits cannot be combined with other offers unless stated.
4. Each coupon is single-use and is valid only on the date of issue until
   the expiry date shown on the coupon.
5. Coupons are non-transferable and cannot be exchanged for cash.
6. Participating hospitals reserve the right to verify donor identity before
   honouring a benefit or coupon.
7. RaktaSetu reserves the right to modify or withdraw benefits and coupons
   with prior notice to registered donors.
8. This brochure is for general guidance only. Please contact the specific
   hospital for exact service availability and timings.
''';
