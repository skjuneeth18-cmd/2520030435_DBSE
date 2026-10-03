/// KYC verification status for a donor (Phase 4).
enum KYCStatus { pending, verified, rejected }

extension KYCStatusX on KYCStatus {
  String get label => switch (this) {
        KYCStatus.pending => 'Pending',
        KYCStatus.verified => 'Verified',
        KYCStatus.rejected => 'Rejected',
      };

  String get emoji => switch (this) {
        KYCStatus.pending => '⏳',
        KYCStatus.verified => '✅',
        KYCStatus.rejected => '❌',
      };
}

/// Secure representation of Aadhaar-linked identity data.
///
/// In a real app this would live in a compliant store with encryption at
/// rest and masked display. Here we keep only a hashed reference + masked
/// number for mock development, and never expose the raw value to the UI.
class IdentityProof {
  const IdentityProof({
    required this.aadhaarLast4Masked,
    required this.submissionDate,
    this.notes,
  });

  /// Masked Aadhaar suffix shown in the UI, e.g. 'XXXX-1234'.
  final String aadhaarLast4Masked;

  /// When the donor submitted the KYC proof.
  final DateTime submissionDate;

  /// Internal reviewer notes (not shown to the donor).
  final String? notes;

  /// A deterministic hash reference for the stored identity blob.
  ///
  /// This is a stand-in for a real encrypted blob reference. The raw
  /// Aadhaar number is never stored nor shown in this mock.
  String get secureRef =>
      'ID-${submissionDate.millisecondsSinceEpoch ~/ 1000}';

  IdentityProof copyWith({
    String? aadhaarLast4Masked,
    DateTime? submissionDate,
    String? notes,
  }) {
    return IdentityProof(
      aadhaarLast4Masked: aadhaarLast4Masked ?? this.aadhaarLast4Masked,
      submissionDate: submissionDate ?? this.submissionDate,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() => {
        'aadhaarLast4Masked': aadhaarLast4Masked,
        'submissionDate': submissionDate.toIso8601String(),
        'notes': notes,
      };

  factory IdentityProof.fromMap(Map<String, dynamic> map) {
    return IdentityProof(
      aadhaarLast4Masked: map['aadhaarLast4Masked'] as String,
      submissionDate:
          DateTime.parse(map['submissionDate'] as String),
      notes: map['notes'] as String?,
    );
  }
}
