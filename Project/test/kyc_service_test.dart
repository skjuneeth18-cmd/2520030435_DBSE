import 'package:flutter_test/flutter_test.dart';
import 'package:raktasetu/models/benefit.dart';
import 'package:raktasetu/models/coupon.dart';
import 'package:raktasetu/models/donor_verification.dart';
import 'package:raktasetu/models/kyc.dart';
import 'package:raktasetu/services/auth_service.dart';
import 'package:raktasetu/services/kyc_service.dart';

/// Unit tests for the Phase 4 KYC / donor verification / coupons /
/// benefits mock backend.
void main() {
  late AuthService auth;
  late KYCService kyc;

  setUp(() {
    auth = AuthService.instance;
    kyc = KYCService.instance;
    auth.logout();
  });

  group('seed data', () {
    test('demo donor arrives pre-verified with coupons', () {
      expect(kyc.getDonorVerification('u0'),
          DonorVerificationStatus.verified);
      expect(kyc.isDonorFullyVerified('u0'), isTrue);

      final coupons = kyc.getCouponsForUser('u0');
      expect(coupons.length, greaterThanOrEqualTo(2));
      expect(coupons.any((c) => c.status == CouponStatus.active), isTrue);
      expect(coupons.any((c) => c.status == CouponStatus.used), isTrue);
    });

    test('benefits and participating hospitals are readable', () {
      expect(kyc.getBenefits(), isNotEmpty);
      expect(kyc.getActiveBenefits(), isNotEmpty);
      expect(kyc.getParticipatingHospitals(), isNotEmpty);
    });
  });

  group('KYC submission', () {
    test('rejects invalid masked Aadhaar formats', () {
      auth.register(
        fullName: 'KYC Tester',
        email: 'kyc1@example.com',
        phone: '9000000011',
        bloodGroup: 'O+',
        area: 'Kukatpally',
        password: 'secret1',
      );

      expect(kyc.submitKYC(aadhaarLast4Masked: '1234'), isNotNull);
      expect(kyc.submitKYC(aadhaarLast4Masked: 'XXXX-12'), isNotNull);
      expect(kyc.submitKYC(aadhaarLast4Masked: ''), isNotNull);
      expect(kyc.getKYCRecord(auth.currentUser!.id), isNull);
    });

    test('accepts a valid masked Aadhaar and stores only the suffix',
        () {
      auth.register(
        fullName: 'KYC Tester',
        email: 'kyc2@example.com',
        phone: '9000000012',
        bloodGroup: 'A+',
        area: 'Koti',
        password: 'secret1',
      );

      final error = kyc.submitKYC(aadhaarLast4Masked: 'XXXX-4321');
      expect(error, isNull);

      final record = kyc.getKYCRecord(auth.currentUser!.id);
      expect(record, isNotNull);
      expect(record!.aadhaarLast4Masked, 'XXXX-4321');
      expect(record.status, KYCStatus.pending);
      expect(record.secureRef, startsWith('ID-'));
      // Raw identity number is never retained anywhere on the record.
      expect(record.toMap().values.join(), isNot(contains('rawAadhaar')));
    });

    test('requires a logged-in user', () {
      expect(kyc.submitKYC(aadhaarLast4Masked: 'XXXX-1234'), isNotNull);
    });

    test('cancel removes a pending record but not a verified one', () {
      auth.login(email: 'demo@raktasetu.in', password: 'demo123');
      // Verified seeded record cannot be cancelled.
      expect(kyc.cancelKYC(), isFalse);
      expect(kyc.getKYCRecord('u0'), isNotNull);

      auth.logout();
      auth.register(
        fullName: 'Cancel Tester',
        email: 'cancel@example.com',
        phone: '9000000013',
        bloodGroup: 'B+',
        area: 'Abids',
        password: 'secret1',
      );
      kyc.submitKYC(aadhaarLast4Masked: 'XXXX-9999');
      expect(kyc.cancelKYC(), isTrue);
      expect(kyc.getKYCRecord(auth.currentUser!.id), isNull);
    });
  });

  group('admin KYC review', () {
    test('verify then full donor verification requires donor verification',
        () {
      final error = auth.register(
        fullName: 'Review Tester',
        email: 'review@example.com',
        phone: '9000000014',
        bloodGroup: 'O-',
        area: 'Secunderabad',
        password: 'secret1',
      );
      expect(error, isNull);
      final id = auth.currentUser!.id;

      kyc.submitKYC(aadhaarLast4Masked: 'XXXX-5555');
      expect(kyc.reviewKYC(id, KYCStatus.verified, 'ok'), isNull);
      expect(kyc.getKYCRecord(id)!.status, KYCStatus.verified);

      // KYC alone is not enough: donor verification is separate.
      expect(kyc.isDonorFullyVerified(id), isFalse);
      expect(kyc.verifyDonor(id, DonorVerificationStatus.verified), isNull);
      expect(kyc.isDonorFullyVerified(id), isTrue);
    });

    test('rejects unknown users and illegal transitions', () {
      expect(kyc.reviewKYC('nope', KYCStatus.verified, null), isNotNull);
      expect(kyc.verifyDonor('nope', DonorVerificationStatus.verified),
          isNotNull);
      expect(kyc.verifyDonor('u0', DonorVerificationStatus.pending),
          isNotNull);
      // Verified KYC cannot be pushed back to pending.
      expect(kyc.reviewKYC('u0', KYCStatus.rejected, null), isNotNull);
    });

    test('pending queue only counts pending records', () {
      final pendingBefore = kyc.pendingKYCCount;
      auth.register(
        fullName: 'Queue Tester',
        email: 'queue@example.com',
        phone: '9000000015',
        bloodGroup: 'A-',
        area: 'Gachibowli',
        password: 'secret1',
      );
      kyc.submitKYC(aadhaarLast4Masked: 'XXXX-1111');
      expect(kyc.pendingKYCCount, pendingBefore + 1);
      expect(kyc.getKYCRecords().first.userId, auth.currentUser!.id);
      kyc.cancelKYC();
      expect(kyc.pendingKYCCount, pendingBefore);
    });
  });

  group('coupons', () {
    test('can only be generated for fully verified donors', () {
      final result = kyc.generateCoupon(
        userId: 'does-not-exist',
        participatingHospitalId: 'h01',
        benefitType: BenefitType.freeCheckup,
        discountPercent: 100,
      );
      expect(result, isA<String>());

      auth.logout();
      auth.register(
        fullName: 'Unverified Donor',
        email: 'unverified@example.com',
        phone: '9000000016',
        bloodGroup: 'O+',
        area: 'Uppal',
        password: 'secret1',
      );
      final unverified = kyc.generateCoupon(
        userId: auth.currentUser!.id,
        participatingHospitalId: 'h01',
        benefitType: BenefitType.freeCheckup,
        discountPercent: 100,
      );
      expect(unverified, isA<String>());
    });

    test('generates, uses and blocks re-use of a coupon', () {
      final result = kyc.generateCoupon(
        userId: 'u0',
        participatingHospitalId: 'h01',
        benefitType: BenefitType.diagnosticDiscount,
        discountPercent: 30,
        maxDiscount: 500,
      );
      expect(result, isA<Coupon>());
      final coupon = result as Coupon;
      expect(coupon.code, startsWith('RAKTA-'));
      expect(coupon.status, CouponStatus.active);
      expect(coupon.isActive, isTrue);

      // Wrong hospital cannot redeem.
      expect(kyc.useCoupon(coupon.id, 'h02'), isNotNull);
      // Correct hospital redeems once.
      expect(kyc.useCoupon(coupon.id, 'h01'), isNull);
      expect(kyc.getCoupon(coupon.id)!.status, CouponStatus.used);
      expect(kyc.useCoupon(coupon.id, 'h01'), isNotNull);
    });

    test('validates discount range and coupon existence', () {
      expect(
        kyc.generateCoupon(
          userId: 'u0',
          participatingHospitalId: 'h01',
          benefitType: BenefitType.consultationDiscount,
          discountPercent: 150,
        ),
        isA<String>(),
      );
      expect(kyc.useCoupon('cp_missing', 'h01'), isNotNull);
      expect(kyc.revokeCoupon('cp_missing'), isNotNull);
    });

    test('used coupons cannot be revoked', () {
      final used = kyc
          .getCouponsForUser('u0')
          .firstWhere((c) => c.status == CouponStatus.used);
      expect(kyc.revokeCoupon(used.id), isNotNull);
    });

    test('revoking an active coupon marks it revoked', () {
      final result = kyc.generateCoupon(
        userId: 'u0',
        participatingHospitalId: 'h01',
        benefitType: BenefitType.partnerHospitalBenefit,
        discountPercent: 10,
      ) as Coupon;
      expect(kyc.revokeCoupon(result.id), isNull);
      expect(kyc.getCoupon(result.id)!.status, CouponStatus.revoked);
    });
  });

  group('benefits', () {
    test('hospital filters only return benefits for that hospital', () {
      final forH01 = kyc.getBenefitsForHospital('h01');
      expect(forH01, isNotEmpty);
      expect(forH01.every((b) => b.participatingHospitalIds.contains('h01')),
          isTrue);

      expect(kyc.getBenefitsForHospital('zz99'), isEmpty);
    });

    test('add / update / delete a custom benefit', () {
      const id = 'b_test_1';
      const created = Benefit(
        id: id,
        title: 'Test Benefit',
        description: 'Created by the unit test.',
        benefitType: BenefitType.freeCheckup,
        participatingHospitalIds: ['h01'],
      );

      expect(kyc.addBenefit(created), isNull);
      expect(kyc.addBenefit(created), isNotNull); // duplicate id
      expect(kyc.getBenefits().any((b) => b.id == id), isTrue);

      expect(kyc.updateBenefit(id, created.copyWith(title: 'Updated')),
          isNull);
      expect(
        kyc.getBenefits().firstWhere((b) => b.id == id).title,
        'Updated',
      );

      expect(kyc.updateBenefit('b_missing', created), isNotNull);
      expect(kyc.deleteBenefit('b_missing'), isNotNull);

      expect(kyc.deleteBenefit(id), isNull);
      expect(kyc.getBenefits().any((b) => b.id == id), isFalse);
    });

    test('deleting a seeded benefit retires it instead of removing it', () {
      final seeded = kyc.getBenefits().firstWhere((b) => b.id == 'b01');
      expect(kyc.deleteBenefit('b01'), isNull);

      final after = kyc.getBenefits().firstWhere((b) => b.id == 'b01');
      expect(after.isActive, isFalse);
      expect(kyc.getActiveBenefits().any((b) => b.id == seeded.id), isFalse);

      // Restore for later tests in this file.
      kyc.updateBenefit('b01', seeded);
    });
  });

  group('permissions', () {
    test('only a hospital admin can manage KYC', () {
      auth.logout();
      expect(kyc.canManageKYC, isFalse);

      auth.login(email: 'hospital@raktasetu.in', password: 'demo123');
      expect(kyc.canManageKYC, isTrue);

      auth.logout();
      auth.login(email: 'bloodbank@raktasetu.in', password: 'demo123');
      expect(kyc.canManageKYC, isFalse);
      auth.logout();
    });
  });
}