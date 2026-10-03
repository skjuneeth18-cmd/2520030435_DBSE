/// A donor in a facility's registry (Phase 3 admin view).
class DonorRegistryEntry {
  const DonorRegistryEntry({
    required this.name,
    required this.bloodGroup,
    required this.lastDonation,
    required this.donations,
    this.hasUpcomingSlot = false,
  });

  final String name;
  final String bloodGroup;
  final DateTime? lastDonation;
  final int donations;
  final bool hasUpcomingSlot;
}
