# 🩸 RaktaSetu — Smart Blood Bank & Donor Locator

**Phase 1 + 2 + 3 + 4** (Flutter + Dart, mock data) · Tagline: *"Find Blood Fast. Save Lives."*

## Features (Phase 1 — find blood)

| Module | Where |
|---|---|
| Splash (logo, name, tagline) | `lib/screens/splash/splash_screen.dart` |
| Auth: register / login / logout / forgot password / profile | `lib/screens/auth/`, `lib/screens/profile/`, `lib/services/auth_service.dart` |
| Home dashboard (name + blood group, emergencies, nearby, notifications) | `lib/screens/home/home_screen.dart` |
| Find Blood (8 groups, area + facility filters, Available/Limited/Unavailable) | `lib/screens/find_blood/find_blood_screen.dart` |
| Top Hospitals (search, area, verified filter, detail + stock) | `lib/screens/hospitals/` |
| Blood Bank Centers (search, filters, detail + stock) | `lib/screens/blood_banks/` |
| Area-wise requirements (emergency level filter) | `lib/screens/requirements/requirements_screen.dart` |
| Notifications (8 categories with filter chips) | `lib/screens/notifications/notifications_screen.dart` |
| Basic Safety (eligibility, pre/post precautions, screening) | `lib/screens/safety/safety_screen.dart` |

## Features (Phase 2 — donate)

| Module | Where |
|---|---|
| Donor profile (age, eligibility status, donation count) | `lib/models/donor.dart`, `lib/services/donor_service.dart` |
| Slot booking (facility → date → time slot → confirm/cancel/reschedule) | `lib/screens/donate/book_slot_screen.dart`, `lib/screens/donate/my_bookings_screen.dart` |
| Donation history (dates, facility, blood group, status) | `lib/screens/donate/donation_history_screen.dart` |
| Monthly donation camps (list, detail, register) | `lib/screens/camps/camps_screen.dart`, `lib/data/camps_data.dart` |
| Donor certificate (auto-generated after completed donation, shareable text) | `lib/screens/donate/certificates_screen.dart`, `lib/models/donor_certificate.dart` |
| Donor notifications (slot confirmation, reminders, camp notices, updates) | `lib/services/donor_service.dart`, `lib/data/donor_seed_data.dart` |
| Donor dashboard (next appointment, history, upcoming camps, certificates) | `lib/screens/donate/donate_screen.dart` |

## Features (Phase 3 — hospitals, doctors & admin)

| Module | Where |
|---|---|
| Roles (donor / hospital admin / blood bank admin) + managed facility | `lib/models/user.dart`, demo logins below |
| Doctors tab (search, specialization filters, profiles, fees, status) | `lib/screens/doctors/`, `lib/data/doctors_data.dart` |
| Consultation booking (date picker, 30-min slots, consulting-day rules, cancel, history) | `lib/screens/doctors/doctor_profile_screen.dart`, `lib/screens/doctors/my_appointments_sheet.dart` |
| Hospital-wise doctor listing | `lib/screens/hospitals/hospital_detail_screen.dart` |
| Hospital Admin dashboard (info, doctors, inventory, appointments, camps, requests) | `lib/screens/admin/hospital_admin_screen.dart` |
| Blood Bank Admin dashboard (inventory updates, slots, donors, records, requests) | `lib/screens/admin/blood_bank_admin_screen.dart` |
| Blood requests (raise / fulfil with auto stock deduction / reject) | `lib/models/blood_request.dart`, `lib/services/admin_service.dart` |
| Blood inventory updates (per-group units, live status recompute) | `lib/services/admin_service.dart` |

## Features (Phase 4 — KYC, donor benefits & coupons)

| Module | Where |
|---|---|
| KYC screen (apply with masked Aadhaar, status card, withdraw pending KYC) | `lib/screens/kyc/kyc_screen.dart` |
| Donor verification (separate from KYC — profile complete + donation-eligible) | `lib/models/donor_verification.dart` |
| Donor Benefits (All Benefits / Hospital Offers / Brochure + terms) | `lib/screens/benefits/benefits_screen.dart`, `lib/data/benefits_data.dart` |
| My Coupons (Active / Used / Expired tabs, redeem at a participating hospital) | `lib/screens/coupons/coupons_screen.dart` |
| KYC & coupon/benefit backend (submit, review, generate, use, revoke, CRUD) | `lib/services/kyc_service.dart` |
| Admin KYC review queue (verify/reject, bulk approve, all-donors sheet, stats) | `lib/screens/admin/kyc_admin_screen.dart` |
| Admin benefits & coupons (benefits CRUD, coupon list/revoke, create coupon, hospitals) | `lib/screens/admin/benefits_coupons_admin_screen.dart` |
| Home quick actions + Profile links for KYC / Coupons / Benefits | `lib/screens/home/home_screen.dart`, `lib/screens/profile/profile_screen.dart` |

**KYC privacy:** the raw Aadhaar number is never stored. Only a masked
`XXXX-1234` suffix and a derived opaque `secureRef` (`ID-<epoch seconds>`)
are kept; a production build would hand this off to a compliant encrypted
KYC provider instead.

Quick actions: **KYC & Verification · My Coupons · Donor Benefits** on Home.
The hospital admin dashboard gains a **🪪 KYC & donor verification** section
(hospital admins only — `KYCService.canManageKYC`).

Bottom navigation: **Home | Find Blood | Hospitals | Doctors | Blood Banks | Profile**
(Donate dashboard, Camps, KYC, Coupons, Benefits and admin dashboards are
reachable from Home.)

Mock data: 12 hospitals, 12 blood banks, 12 requirements, 12 notifications,
8 camps, 18 doctors, demo donor history/bookings/certificates — in `lib/data/`.

**Demo logins** (password `demo123` for all):

| Role | Email |
|---|---|
| 👤 Donor (pre-seeded history, certificates, booking) | `demo@raktasetu.in` |
| 🏥 Hospital Admin (City Care Multispeciality, h01) | `hospital@raktasetu.in` |
| 🩸 Blood Bank Admin (City Care Blood Centre, bb01) | `bloodbank@raktasetu.in` |

New accounts can also pick a role + facility on the Register form.

## Project structure

```
lib/
├── main.dart            # entry point
├── app.dart             # MaterialApp + routes
├── core/app_theme.dart  # colors + Material 3 theme
├── models/              # plain Dart models (users, facilities,
│                        #   bookings, camps, doctors, appointments,
│                        #   certificates, blood requests, KYC, benefits,
│                        #   coupons, …)
├── data/                # mock datasets (Phases 1–4)
├── services/            # AuthService, BloodService, DonorService,
│                        #   DoctorService, AdminService, KYCService
│                        #   (singletons — swap internals for APIs later)
├── widgets/             # reusable UI components
└── screens/             # splash, auth, main, home, find_blood,
                         #   hospitals, blood_banks, doctors, requirements,
                         #   notifications, safety, profile,
                         #   donate (dashboard/booking/history/certificates),
                         #   camps, kyc, benefits, coupons,
                         #   admin (hospital & blood bank dashboards)
```

## Run the app

**1. Install Flutter** (Windows): download the SDK from
https://docs.flutter.dev/get-started/install/windows, extract to `C:\flutter`,
then add `C:\flutter\bin` to your PATH.

**2. Verify the toolchain:**

```bash
flutter doctor
```

**3. Get packages and run:**

```bash
flutter pub get
flutter run
```

Run on Windows desktop, an Android emulator, a connected phone, or Chrome
(`flutter run -d chrome`).

The demo donor comes pre-seeded with donation history, certificates, an
upcoming booking and donor notifications. New accounts can register too
(stored in memory; add your age on the Register form to get an eligibility
status, and pick Donor / Hospital / Blood bank as the account type).

## Phase 6 readiness (backend)

All data flows through `AuthService`, `BloodService`, `DonorService`,
`DoctorService`, `AdminService` and `KYCService` singletons. To connect a real
backend, replace the internals of these classes with API/database calls — no
screen or widget code needs to change. Models already have
`toMap()`/`fromMap()` for serialization.

Phase 4 notes for a real deployment: KYC document uploads and the Aadhaar
link must move to a compliant encrypted provider (see the privacy note above),
and coupon issuance/redemption needs a server-side audit trail.

Out of scope for Phase 1–2 (per spec): KYC, Aadhaar, police monitoring,
coupons, doctor consultancy, payments, admin panel — KYC, benefits and coupons
landed in Phase 4.
