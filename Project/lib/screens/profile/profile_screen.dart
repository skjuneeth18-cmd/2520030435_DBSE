import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../data/hospitals_data.dart';
import '../../models/blood_availability.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../services/blood_service.dart';
import '../../services/donor_service.dart';

import '../../widgets/custom_text_field.dart';
import '../../widgets/donor_badges.dart';
import '../auth/login_screen.dart';
import '../donate/certificates_screen.dart';
import '../donate/donation_history_screen.dart';
import '../donate/my_bookings_screen.dart';
import '../requirements/requirements_screen.dart';
import '../safety/safety_screen.dart';
import '../kyc/kyc_screen.dart';
import '../benefits/benefits_screen.dart';
import '../coupons/coupons_screen.dart';

/// Profile tab: user info, edit profile, links, logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _logout() {
    AuthService.instance.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _editProfile() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final nameCtrl = TextEditingController(text: user.fullName);
    final phoneCtrl = TextEditingController(text: user.phone);
    final ageCtrl =
        TextEditingController(text: user.age?.toString() ?? '');
    String bloodGroup = user.bloodGroup;
    String area = user.area;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Edit profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: nameCtrl,
                  label: 'Full name',
                  hint: 'Your name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: phoneCtrl,
                  label: 'Phone',
                  hint: 'Phone number',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: ageCtrl,
                  label: 'Age',
                  hint: '18–65 years',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: FacilityStock.allGroups
                      .map(
                        (g) => ChoiceChip(
                          label: Text(g),
                          selected: bloodGroup == g,
                          selectedColor: AppTheme.red,
                          labelStyle: TextStyle(
                            color: bloodGroup == g
                                ? Colors.white
                                : AppTheme.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                          onSelected: (_) => bloodGroup = g,
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: area,
                  decoration: const InputDecoration(labelText: 'Area'),
                  items: kAreas
                      .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                      .toList(),
                  onChanged: (v) => area = v ?? area,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save changes'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (saved == true) {
      AuthService.instance.updateProfile(
        fullName: nameCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        bloodGroup: bloodGroup,
        area: area,
        age: int.tryParse(ageCtrl.text.trim()),
      );
      if (mounted) setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    AuthService.instance.addListener(_refresh);
    DonorService.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    AuthService.instance.removeListener(_refresh);
    DonorService.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('You are not logged in'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                child: const Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: _editProfile,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- Avatar card ----
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.red, AppTheme.redDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.initials,
                    style: const TextStyle(
                      color: AppTheme.red,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user.fullName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _tag(Icons.bloodtype, user.bloodGroup),
                    const SizedBox(width: 10),
                    _tag(Icons.location_on_outlined, user.area),
                    const SizedBox(width: 10),
                    _tag(
                      user.isAdmin
                          ? (user.role == UserRole.hospitalAdmin
                              ? Icons.local_hospital
                              : Icons.water_drop)
                          : Icons.volunteer_activism,
                      user.role.label,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ---- Account details ----
          _row(Icons.badge_outlined, 'Full name', user.fullName),
          _row(Icons.email_outlined, 'Email', user.email),
          _row(Icons.phone_outlined, 'Phone', user.phone),
          _row(Icons.bloodtype_outlined, 'Blood group', user.bloodGroup),
          _row(Icons.location_on_outlined, 'Area', '${user.area}, ${user.city}'),
          if (user.age != null)
            _row(Icons.cake_outlined, 'Age', '${user.age} years'),
          _row(
            Icons.manage_accounts_outlined,
            'Account type',
            user.role.label,
          ),
          if (user.managedFacilityId != null)
            _row(
              Icons.business_outlined,
              'Manages',
              user.role == UserRole.hospitalAdmin
                  ? (BloodService.instance.hospitalById(user.managedFacilityId!)
                          ?.name ??
                      user.managedFacilityId!)
                  : (BloodService.instance.bloodBankById(user.managedFacilityId!)
                          ?.name ??
                      user.managedFacilityId!),
            ),

          const SizedBox(height: 12),

          // ---- Donor status card (Phase 2) ----
          Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.volunteer_activism,
                          size: 18, color: AppTheme.red),
                      SizedBox(width: 8),
                      Text(
                        'Donor status',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textGrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      EligibilityBadge(
                        status: DonorService.instance
                            .donorProfile()!
                            .computedStatus,
                        note: DonorService.instance.nextEligibleLabel,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '❤️ ${DonorService.instance.donorProfile()!.donationCount} donations',
                          style: const TextStyle(
                            color: AppTheme.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (DonorService.instance.nextEligibleLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Next donation possible after '
                          '${DonorService.instance.nextEligibleLabel}.',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textGrey),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ---- Quick links ----
          _linkTile(
            icon: Icons.event_available_outlined,
            title: 'My donation slots',
            subtitle: 'Upcoming & past bookings',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const MyBookingsScreen()),
            ),
          ),
          _linkTile(
            icon: Icons.history,
            title: 'Donation history',
            subtitle: 'Every donation you have made',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const DonationHistoryScreen()),
            ),
          ),
          _linkTile(
            icon: Icons.workspace_premium_outlined,
            title: 'My certificates',
            subtitle: 'Digital proofs of your donations',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const CertificatesScreen()),
            ),
          ),
          _linkTile(
            icon: Icons.campaign_outlined,
            title: 'Area-wise requirements',
            subtitle: 'Who needs blood right now',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RequirementsScreen()),
            ),
          ),
          _linkTile(
            icon: Icons.health_and_safety_outlined,
            title: 'Donation safety',
            subtitle: 'Eligibility, precautions & screening',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SafetyScreen()),
            ),
          ),
          if (!user.isAdmin) ...[
            _linkTile(
              icon: Icons.verified_user_outlined,
              title: 'KYC & Verification',
              subtitle: 'Aadhaar-linked identity verification',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KycScreen()),
              ),
            ),
            _linkTile(
              icon: Icons.card_giftcard_outlined,
              title: 'My Coupons',
              subtitle: 'Active, used & expired coupons',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CouponsScreen()),
              ),
            ),
            _linkTile(
              icon: Icons.card_giftcard,
              title: 'Donor Benefits',
              subtitle: 'Discounts & partner hospital offers',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BenefitsScreen()),
              ),
            ),
          ],

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.red,
                side: const BorderSide(color: AppTheme.red),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'RaktaSetu Phase 4 · KYC, benefits & coupons (mock build)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5, color: AppTheme.textGrey),
          ),
        ],
      ),
    );
  }

  Widget _tag(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.red, size: 22),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
            color: AppTheme.textGrey,
          ),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
      ),
    );
  }

  Widget _linkTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppTheme.red, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textGrey),
      ),
    );
  }
}
