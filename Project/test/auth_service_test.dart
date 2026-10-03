import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/services/auth_service.dart';

void main() {
  late AuthService auth;

  setUp(() {
    auth = AuthService.instance;
    auth.logout(); // start each test logged out
  });

  group('AuthService', () {
    test('register creates account and logs in', () {
      final error = auth.register(
        fullName: 'Test Donor',
        email: 'test@example.com',
        phone: '9000000001',
        bloodGroup: 'A+',
        area: 'Kukatpally',
        password: 'secret1',
      );
      expect(error, isNull);
      expect(auth.isLoggedIn, isTrue);
      expect(auth.currentUser!.email, 'test@example.com');
      expect(auth.currentUser!.bloodGroup, 'A+');
    });

    test('register rejects duplicate email (case-insensitive)', () {
      auth.register(
        fullName: 'First User',
        email: 'dup@example.com',
        phone: '9000000002',
        bloodGroup: 'O+',
        area: 'Koti',
        password: 'secret1',
      );
      auth.logout();
      final error = auth.register(
        fullName: 'Second User',
        email: 'DUP@example.com',
        phone: '9000000003',
        bloodGroup: 'B-',
        area: 'Abids',
        password: 'secret2',
      );
      expect(error, isNotNull);
      expect(auth.isLoggedIn, isFalse);
    });

    test('login works with correct credentials', () {
      auth.register(
        fullName: 'Login User',
        email: 'login@example.com',
        phone: '9000000004',
        bloodGroup: 'AB+',
        area: 'Gachibowli',
        password: 'secret9',
      );
      auth.logout();

      final wrong = auth.login(
          email: 'login@example.com', password: 'badpass');
      expect(wrong, isNotNull);
      expect(auth.isLoggedIn, isFalse);

      final ok = auth.login(
          email: 'login@example.com', password: 'secret9');
      expect(ok, isNull);
      expect(auth.currentUser!.fullName, 'Login User');
    });

    test('login fails for unknown email', () {
      final error = auth.login(
          email: 'ghost@example.com', password: 'whatever');
      expect(error, isNotNull);
    });

    test('demo account logs in', () {
      final error = auth.login(
          email: 'demo@raktasetu.in', password: 'demo123');
      expect(error, isNull);
      expect(auth.isLoggedIn, isTrue);
    });

    test('sendPasswordReset accepts known email, rejects unknown', () {
      auth.register(
        fullName: 'Reset User',
        email: 'reset@example.com',
        phone: '9000000005',
        bloodGroup: 'O-',
        area: 'Madhapur',
        password: 'secret3',
      );
      auth.logout();
      expect(auth.sendPasswordReset('reset@example.com'), isNull);
      expect(auth.sendPasswordReset('nope@example.com'), isNotNull);
    });

    test('updateProfile changes editable fields only', () {
      auth.register(
        fullName: 'Edit Me',
        email: 'edit@example.com',
        phone: '9000000006',
        bloodGroup: 'B+',
        area: 'Ameerpet',
        password: 'secret4',
      );
      auth.updateProfile(
        fullName: 'Edited Name',
        bloodGroup: 'AB-',
        area: 'Banjara Hills',
      );
      expect(auth.currentUser!.fullName, 'Edited Name');
      expect(auth.currentUser!.bloodGroup, 'AB-');
      expect(auth.currentUser!.area, 'Banjara Hills');
      // email must never change via profile edit
      expect(auth.currentUser!.email, 'edit@example.com');
    });

    test('logout clears the session', () {
      auth.login(email: 'demo@raktasetu.in', password: 'demo123');
      expect(auth.isLoggedIn, isTrue);
      auth.logout();
      expect(auth.isLoggedIn, isFalse);
      expect(auth.currentUser, isNull);
    });
  });
}
