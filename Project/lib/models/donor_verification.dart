/// Verified donor status (Phase 4).
///
/// Distinct from KYC: KYC validates identity; donor verification confirms
/// the donor profile is complete and donation-eligible.
enum DonorVerificationStatus { pending, verified, rejected }

extension DonorVerificationStatusX on DonorVerificationStatus {
  String get label => switch (this) {
        DonorVerificationStatus.pending => 'Pending',
        DonorVerificationStatus.verified => 'Verified',
        DonorVerificationStatus.rejected => 'Rejected',
      };

  String get emoji => switch (this) {
        DonorVerificationStatus.pending => '⏳',
        DonorVerificationStatus.verified => '🩸',
        DonorVerificationStatus.rejected => '❌',
      };
}
