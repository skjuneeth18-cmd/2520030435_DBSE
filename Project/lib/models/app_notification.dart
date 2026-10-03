/// Category of an in-app notification.
enum NotificationCategory {
  emergency,
  availability,
  areaAlert,
  donationCamp,
  news,
  slotConfirmation,
  slotReminder,
  donationUpdate,
}

extension NotificationCategoryX on NotificationCategory {
  String get label => switch (this) {
        NotificationCategory.emergency => 'Emergency',
        NotificationCategory.availability => 'Availability Update',
        NotificationCategory.areaAlert => 'Area Alert',
        NotificationCategory.donationCamp => 'Donation Camp',
        NotificationCategory.news => 'Important News',
        NotificationCategory.slotConfirmation => 'Slot Confirmation',
        NotificationCategory.slotReminder => 'Slot Reminder',
        NotificationCategory.donationUpdate => 'Donation Update',
      };

  String get emoji => switch (this) {
        NotificationCategory.emergency => '🚨',
        NotificationCategory.availability => '🩸',
        NotificationCategory.areaAlert => '📍',
        NotificationCategory.donationCamp => '📢',
        NotificationCategory.news => '📰',
        NotificationCategory.slotConfirmation => '✅',
        NotificationCategory.slotReminder => '⏰',
        NotificationCategory.donationUpdate => '❤️',
      };
}

/// In-app notification model.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.timeAgo,
    required this.area,
    this.isRead = false,
  });

  final String id;
  final String title;
  final String body;
  final NotificationCategory category;
  final String timeAgo;
  final String area; // '' for global notifications
  final bool isRead;
}
