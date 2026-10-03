import 'package:flutter/foundation.dart';

import '../models/user.dart';

/// Phase 1 mock authentication service.
///
/// Keeps registered users in memory and persists only the *current*
/// session user so the splash screen can restore it while the app
/// process is alive. Swap this class for a real backend in Phase 2+.
class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  final Map<String, ({String password, AppUser user})> _accounts = {};
  AppUser? _currentUser;

  static const String _sessionKey = 'raktasetu_session_user';

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  /// Registers a new account. Returns an error message or null on success.
  String? register({
    required String fullName,
    required String email,
    required String phone,
    required String bloodGroup,
    required String area,
    required String password,
    int? age,
    UserRole role = UserRole.donor,
    String? managedFacilityId,
  }) {
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      return 'An account with this email already exists.';
    }
    if (role != UserRole.donor && managedFacilityId == null) {
      return 'Admin accounts must be linked to a facility.';
    }
    final user = AppUser(
      id: 'u${_accounts.length + 1}',
      fullName: fullName.trim(),
      email: key,
      phone: phone.trim(),
      bloodGroup: bloodGroup,
      area: area,
      age: age,
      role: role,
      managedFacilityId: managedFacilityId,
    );
    _accounts[key] = (password: password, user: user);
    _currentUser = user;
    _persistSession(user);
    notifyListeners();
    return null;
  }

  /// Logs in with email + password. Returns an error message or null.
  String? login({required String email, required String password}) {
    final key = email.trim().toLowerCase();
    final account = _accounts[key];
    if (account == null) {
      // Mock convenience accounts so every role is demoable:
      //   demo@raktasetu.in  / demo123      → donor
      //   hospital@raktasetu.in / demo123   → hospital admin (h01)
      //   bloodbank@raktasetu.in / demo123  → blood bank admin (bb01)
      const demoAccounts = <String, AppUser>{
        'demo@raktasetu.in': _demoUser,
        'hospital@raktasetu.in': _demoHospitalAdmin,
        'bloodbank@raktasetu.in': _demoBloodBankAdmin,
      };
      final demoUser = demoAccounts[key];
      if (demoUser != null && password == 'demo123') {
        _currentUser = demoUser;
        _persistSession(demoUser);
        notifyListeners();
        return null;
      }
      return 'No account found for this email. Please register.';
    }
    if (account.password != password) {
      return 'Incorrect password. Please try again.';
    }
    _currentUser = account.user;
    _persistSession(account.user);
    notifyListeners();
    return null;
  }

  /// Marks a reset link as "sent" (mock). Returns error message or null.
  String? sendPasswordReset(String email) {
    final key = email.trim().toLowerCase();
    if (key == 'demo@raktasetu.in') return null;
    if (!_accounts.containsKey(key)) {
      return 'No account found for this email.';
    }
    return null;
  }

  /// Updates the logged-in user's profile fields.
  void updateProfile({
    String? fullName,
    String? phone,
    String? bloodGroup,
    String? area,
    int? age,
  }) {
    final user = _currentUser;
    if (user == null) return;
    final updated = user.copyWith(
      fullName: fullName,
      phone: phone,
      bloodGroup: bloodGroup,
      area: area,
      age: age,
      kycRecordId: user.kycRecordId,
    );
    _currentUser = updated;
    // Keep the stored account in sync too.
    final account = _accounts[updated.email];
    if (account != null) {
      _accounts[updated.email] = (password: account.password, user: updated);
    }
    _persistSession(updated);
    notifyListeners();
  }

  /// Phase 4: attaches a KYC record id to the current user.
  void attachKYCRecord(String recordId) {
    final user = _currentUser;
    if (user == null) return;
    final updated = user.copyWith(
      kycRecordId: recordId,
      fullName: user.fullName,
      phone: user.phone,
      bloodGroup: user.bloodGroup,
      area: user.area,
      age: user.age,
    );
    _currentUser = updated;
    final account = _accounts[updated.email];
    if (account != null) {
      _accounts[updated.email] = (password: account.password, user: updated);
    }
    _persistSession(updated);
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _sessionBox.remove(_sessionKey);
    notifyListeners();
  }

  // ---- Tiny in-memory "storage" so the session survives within the
  // app process even if widgets are rebuilt from scratch (Phase 1 mock). ----
  static final Map<String, String> _sessionBox = {};

  void _persistSession(AppUser user) {
    // In Phase 2 this becomes secure storage / backend session.
    _sessionBox[_sessionKey] = user.email;
  }

  // ---- Internal accessors (for cross-service lookups in mock services) ----
  Map<String, ({String password, AppUser user})> get accounts => _accounts;

  static const AppUser _demoUser = AppUser(
    id: 'u0',
    fullName: 'Demo Donor',
    email: 'demo@raktasetu.in',
    phone: '+91 90000 00000',
    bloodGroup: 'O+',
    area: 'Kukatpally',
    age: 28,
    // Phase 4: demo donor comes pre-verified so benefits/coupons are
    // immediately visible on first run.
    kycRecordId: 'kyc_demo_0',
  );

  static const AppUser _demoHospitalAdmin = AppUser(
    id: 'ua1',
    fullName: 'City Care Admin',
    email: 'hospital@raktasetu.in',
    phone: '+91 98765 43001',
    bloodGroup: 'B+',
    area: 'Kukatpally',
    role: UserRole.hospitalAdmin,
    managedFacilityId: 'h01',
  );

  static const AppUser _demoBloodBankAdmin = AppUser(
    id: 'ua2',
    fullName: 'City Care BB Admin',
    email: 'bloodbank@raktasetu.in',
    phone: '+91 98765 44001',
    bloodGroup: 'A+',
    area: 'Kukatpally',
    role: UserRole.bloodBankAdmin,
    managedFacilityId: 'bb01',
  );

  AppUser get demoUser => _demoUser;
  AppUser get demoHospitalAdmin => _demoHospitalAdmin;
  AppUser get demoBloodBankAdmin => _demoBloodBankAdmin;

  /// Every known account, including the three built-in demo accounts.
  List<AppUser> get allUsers => [
        ..._accounts.values.map((a) => a.user),
        if (!_accounts.values.any((a) => a.user.id == _demoUser.id)) _demoUser,
        if (!_accounts.values.any((a) => a.user.id == _demoHospitalAdmin.id))
          _demoHospitalAdmin,
        if (!_accounts.values.any((a) => a.user.id == _demoBloodBankAdmin.id))
          _demoBloodBankAdmin,
      ];

  /// Looks up a user by id across registered and demo accounts.
  AppUser? userById(String id) {
    for (final a in _accounts.values) {
      if (a.user.id == id) return a.user;
    }
    for (final u in [_demoUser, _demoHospitalAdmin, _demoBloodBankAdmin]) {
      if (u.id == id) return u;
    }
    return null;
  }
}
