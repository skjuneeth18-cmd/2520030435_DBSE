import '../models/camp.dart';

/// Phase 2 mock donation camps (monthly city camps + special drives).
/// Dates are set around the demo period; the UI filters upcoming ones.
/// (final, not const: DateTime constructors are not const in Dart.)
final List<DonationCamp> kCamps = [
  DonationCamp(
    id: 'c01',
    name: 'October City Mega Donation Camp',
    startsAt: DateTime(2026, 10, 11), // Sunday
    timeLabel: '9:00 AM – 4:00 PM',
    location: 'Kavuri Hills Community Hall, Madhapur',
    organizer: 'Cyber Blood Hub × Rotary Club Madhapur',
    area: 'Madhapur',
    city: 'Hyderabad',
    totalSlots: 120,
    slotsBooked: 84,
    bloodGroupsRequired: ['O+', 'O-', 'B+', 'A+'],
    contactPhone: '+91 98765 44011',
  ),
  DonationCamp(
    id: 'c02',
    name: 'Kukatpally Housing Board Donor Drive',
    startsAt: DateTime(2026, 10, 18), // Sunday
    timeLabel: '8:30 AM – 2:00 PM',
    location: 'KPHB Phase 3 Community Ground, Near Forum Mall',
    organizer: 'City Care Blood Centre',
    area: 'Kukatpally',
    city: 'Hyderabad',
    totalSlots: 80,
    slotsBooked: 31,
    bloodGroupsRequired: ['B+', 'B-', 'AB+'],
    contactPhone: '+91 98765 44001',
  ),
  DonationCamp(
    id: 'c03',
    name: 'Tech Parks Bloodthon — Gachibowli',
    startsAt: DateTime(2026, 10, 25), // Sunday
    timeLabel: '9:00 AM – 5:00 PM',
    location: 'IT Junction Event Lawn, Gachibowli',
    organizer: 'Sunshine Voluntary Blood Bank × TSIIC',
    area: 'Gachibowli',
    city: 'Hyderabad',
    totalSlots: 150,
    slotsBooked: 149,
    bloodGroupsRequired: ['O-', 'AB-', 'B-'],
    contactPhone: '+91 98765 44002',
  ),
  DonationCamp(
    id: 'c04',
    name: 'November Red Cross Camp — Secunderabad',
    startsAt: DateTime(2026, 11, 8), // Sunday
    timeLabel: '9:00 AM – 3:00 PM',
    location: 'SP Grounds, Near Clock Tower',
    organizer: 'St. Mary Rotary Blood Bank × Indian Red Cross',
    area: 'Secunderabad',
    city: 'Hyderabad',
    totalSlots: 100,
    slotsBooked: 22,
    bloodGroupsRequired: ['A+', 'A-', 'O+', 'AB+'],
    contactPhone: '+91 98765 44005',
  ),
  DonationCamp(
    id: 'c05',
    name: 'Student Donor Mela — Koti',
    startsAt: DateTime(2026, 11, 15), // Sunday
    timeLabel: '10:00 AM – 4:00 PM',
    location: 'Afzal Gunj Road College Quadrangle, Koti',
    organizer: 'Koti Red Crescent Blood Centre',
    area: 'Koti',
    city: 'Hyderabad',
    totalSlots: 90,
    slotsBooked: 45,
    bloodGroupsRequired: ['All groups welcome'],
    contactPhone: '+91 98765 44006',
  ),
  DonationCamp(
    id: 'c06',
    name: 'December Winter Camp — Mehdipatnam',
    startsAt: DateTime(2026, 12, 6), // Sunday
    timeLabel: '9:00 AM – 3:30 PM',
    location: 'Pillar No. 145 Open Ground, Mehdipatnam',
    organizer: 'Mehdipatnam Hope Blood Bank',
    area: 'Mehdipatnam',
    city: 'Hyderabad',
    totalSlots: 110,
    slotsBooked: 12,
    bloodGroupsRequired: ['O+', 'B+', 'A-'],
    contactPhone: '+91 98765 44009',
  ),
  DonationCamp(
    id: 'c07',
    name: 'Year-End Lifeline Drive — Kondapur',
    startsAt: DateTime(2026, 12, 20), // Sunday
    timeLabel: '8:00 AM – 2:00 PM',
    location: 'Botanical Garden Road Community Centre',
    organizer: 'Kondapur LifeLine Blood Bank',
    area: 'Kondapur',
    city: 'Hyderabad',
    totalSlots: 70,
    slotsBooked: 5,
    bloodGroupsRequired: ['All groups welcome'],
    contactPhone: '+91 98765 44010',
  ),
  // One past camp so "All camps" view has history too.
  DonationCamp(
    id: 'c08',
    name: 'Ganesh Chaturthi Special Camp — Ameerpet',
    startsAt: DateTime(2026, 9, 20), // past
    timeLabel: '9:00 AM – 4:00 PM',
    location: 'Sai Nagar Function Hall, Ameerpet',
    organizer: 'Ameerpet Jeevandhara Blood Bank',
    area: 'Ameerpet',
    city: 'Hyderabad',
    totalSlots: 85,
    slotsBooked: 85,
    bloodGroupsRequired: ['O+', 'B+'],
    contactPhone: '+91 98765 44004',
  ),
];
