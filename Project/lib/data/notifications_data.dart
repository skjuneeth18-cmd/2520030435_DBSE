import '../models/app_notification.dart';

/// Phase 1 mock notifications covering every required category.
const List<AppNotification> kNotifications = [
  AppNotification(
    id: 'n01',
    title: 'Critical: O- needed at Gachibowli',
    body:
        'Sunshine Institute of Medical Sciences urgently needs 2 units of O- for a surgery. Please donate today if eligible.',
    category: NotificationCategory.emergency,
    timeAgo: '20 min ago',
    area: 'Gachibowli',
  ),
  AppNotification(
    id: 'n02',
    title: 'Fresh stock of A+ at City Care',
    body:
        'City Care Blood Centre, Kukatpally received 12 new units of A+ after yesterday\'s camp. Walk-ins welcome.',
    category: NotificationCategory.availability,
    timeAgo: '1 hr ago',
    area: 'Kukatpally',
  ),
  AppNotification(
    id: 'n03',
    title: 'Shortage alert in Koti area',
    body:
        'B- and AB- stocks are running low across Koti blood banks. Donors of these groups are requested to come forward.',
    category: NotificationCategory.areaAlert,
    timeAgo: '2 hrs ago',
    area: 'Koti',
  ),
  AppNotification(
    id: 'n04',
    title: 'Donation camp: Sunday at Madhapur',
    body:
        'Cyber Blood Hub is hosting a donation camp this Sunday, 9 AM – 4 PM at Kavuri Hills community hall. Free health check for all donors.',
    category: NotificationCategory.donationCamp,
    timeAgo: '4 hrs ago',
    area: 'Madhapur',
  ),
  AppNotification(
    id: 'n05',
    title: 'Emergency: B+ units needed in Kukatpally',
    body:
        'City Care Multispeciality Hospital requires 4 units of B+ for a thalassemia patient. Contact the hospital blood centre directly.',
    category: NotificationCategory.emergency,
    timeAgo: '5 hrs ago',
    area: 'Kukatpally',
  ),
  AppNotification(
    id: 'n06',
    title: 'O+ availability restored at St. Mary',
    body:
        'St. Mary Rotary Blood Bank, Secunderabad has restocked O+ and now reports Available status for all components.',
    category: NotificationCategory.availability,
    timeAgo: '7 hrs ago',
    area: 'Secunderabad',
  ),
  AppNotification(
    id: 'n07',
    title: 'Camp announcement: Mehdipatnam',
    body:
        'Hope Blood Bank Mehdipatnam will run a weekend camp at Pillar No. 145 this Saturday. Registration on arrival.',
    category: NotificationCategory.donationCamp,
    timeAgo: '9 hrs ago',
    area: 'Mehdipatnam',
  ),
  AppNotification(
    id: 'n08',
    title: 'Platelet demand rising this week',
    body:
        'Hospitals across the city report higher platelet demand during the dengue season. Eligible donors are urged to donate platelets too.',
    category: NotificationCategory.news,
    timeAgo: '12 hrs ago',
    area: '',
  ),
  AppNotification(
    id: 'n09',
    title: 'Area alert: L B Nagar stocks low',
    body:
        'Sagar Blood Resource Centre reports Limited status for most groups. Planned surgeries may be deferred — donors needed.',
    category: NotificationCategory.areaAlert,
    timeAgo: '1 day ago',
    area: 'L B Nagar',
  ),
  AppNotification(
    id: 'n10',
    title: 'New: Kondapur LifeLine extends to 11 PM',
    body:
        'Kondapur LifeLine Blood Bank will now stay open until 11 PM daily to serve evening donors and emergencies.',
    category: NotificationCategory.news,
    timeAgo: '1 day ago',
    area: 'Kondapur',
  ),
  AppNotification(
    id: 'n11',
    title: 'Urgent: AB- for cancer patient',
    body:
        'Mehdipatnam Hope Blood Bank needs 2 units of AB- for an ongoing oncology procedure. Rare group — please share widely.',
    category: NotificationCategory.emergency,
    timeAgo: '1 day ago',
    area: 'Mehdipatnam',
  ),
  AppNotification(
    id: 'n12',
    title: 'Thank you, donors!',
    body:
        'Over 400 units were collected across city camps last week. Your single donation can save up to three lives.',
    category: NotificationCategory.news,
    timeAgo: '2 days ago',
    area: '',
  ),
];
