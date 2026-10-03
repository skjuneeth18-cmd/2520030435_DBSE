import '../models/app_notification.dart';
import '../models/booking.dart';
import '../models/donation_record.dart';
import '../models/donor_certificate.dart';

/// Phase 2 demo seed data for the built-in demo account
/// (demo@raktasetu.in) so the donor dashboard, history and certificates
/// screens have content on first run.
const String kDemoDonorEmail = 'demo@raktasetu.in';

/// Past donations: 2 completed + 1 deferred (shows status variety).
final List<DonationRecord> kDemoDonationHistory = [
  DonationRecord(
    id: 'dr01',
    userEmail: kDemoDonorEmail,
    date: DateTime(2026, 8, 15),
    facilityId: 'bb01',
    facilityName: 'City Care Blood Centre',
    facilityType: 'Blood Bank',
    bloodGroup: 'O+',
    status: DonationRecordStatus.completed,
    units: 1,
    certificateId: 'RS-CERT-2026-0042',
  ),
  DonationRecord(
    id: 'dr02',
    userEmail: kDemoDonorEmail,
    date: DateTime(2026, 5, 10),
    facilityId: 'h02',
    facilityName: 'Sunshine Institute of Medical Sciences',
    facilityType: 'Hospital',
    bloodGroup: 'O+',
    status: DonationRecordStatus.completed,
    units: 1,
    certificateId: 'RS-CERT-2026-0031',
  ),
  DonationRecord(
    id: 'dr03',
    userEmail: kDemoDonorEmail,
    date: DateTime(2026, 2, 22),
    facilityId: 'bb05',
    facilityName: 'St. Mary Rotary Blood Bank',
    facilityType: 'Blood Bank',
    bloodGroup: 'O+',
    status: DonationRecordStatus.deferred,
    units: 0,
    notes: 'Haemoglobin below cut-off at screening.',
  ),
];

/// One upcoming confirmed booking for the demo donor.
final List<DonationBooking> kDemoBookings = [
  DonationBooking(
    id: 'bk01',
    userEmail: kDemoDonorEmail,
    venueId: 'bb01',
    venueName: 'City Care Blood Centre',
    venueType: 'Blood Bank',
    venueArea: 'Kukatpally',
    date: DateTime(2026, 10, 10),
    time: '10:00 AM',
    status: BookingStatus.confirmed,
    bloodGroup: 'O+',
  ),
];

/// Certificates matching the 2 completed donations.
final List<DonorCertificate> kDemoCertificates = [
  DonorCertificate(
    id: 'cert-0042',
    certificateId: 'RS-CERT-2026-0042',
    donorName: 'Demo Donor',
    bloodGroup: 'O+',
    donationDate: DateTime(2026, 8, 15),
    facilityName: 'City Care Blood Centre',
    facilityType: 'Blood Bank',
    issuedAt: DateTime(2026, 8, 15, 18, 30),
    userEmail: kDemoDonorEmail,
  ),
  DonorCertificate(
    id: 'cert-0031',
    certificateId: 'RS-CERT-2026-0031',
    donorName: 'Demo Donor',
    bloodGroup: 'O+',
    donationDate: DateTime(2026, 5, 10),
    facilityName: 'Sunshine Institute of Medical Sciences',
    facilityType: 'Hospital',
    issuedAt: DateTime(2026, 5, 10, 17, 0),
    userEmail: kDemoDonorEmail,
  ),
];

/// Donor-specific notifications (slot confirmation / reminder / update).
const List<AppNotification> kDemoDonorNotifications = [
  AppNotification(
    id: 'dn01',
    title: 'Slot confirmed at City Care Blood Centre',
    body:
        'Your donation slot on 10 Oct 2026 (Saturday) at 10:00 AM is confirmed. Please carry a photo ID and stay hydrated.',
    category: NotificationCategory.slotConfirmation,
    timeAgo: '35 min ago',
    area: 'Kukatpally',
  ),
  AppNotification(
    id: 'dn02',
    title: 'Reminder: donation tomorrow at 10:00 AM',
    body:
        'You have a confirmed slot tomorrow at City Care Blood Centre, Kukatpally. Eat iron-rich food and drink plenty of water.',
    category: NotificationCategory.slotReminder,
    timeAgo: '3 hrs ago',
    area: 'Kukatpally',
  ),
  AppNotification(
    id: 'dn03',
    title: 'Your donation saved up to 3 lives ❤️',
    body:
        'The O+ unit you donated on 15 Aug 2026 was issued to City Care Multispeciality Hospital. Thank you for donating!',
    category: NotificationCategory.donationUpdate,
    timeAgo: '2 weeks ago',
    area: 'Kukatpally',
  ),
  AppNotification(
    id: 'dn04',
    title: 'New camp near you: KPHB Donor Drive',
    body:
        'City Care Blood Centre is hosting a donation camp on 18 Oct 2026 at KPHB Phase 3. Registrations are open.',
    category: NotificationCategory.donationCamp,
    timeAgo: '1 day ago',
    area: 'Kukatpally',
  ),
];
