/// Static safety content for the Basic Safety section.
class SafetyInfo {
  const SafetyInfo({
    required this.title,
    required this.icon,
    required this.points,
  });

  final String title;
  final String icon; // emoji shown in the section header
  final List<String> points;

  static const List<SafetyInfo> all = [
    SafetyInfo(
      title: 'Blood Donation Eligibility',
      icon: '✅',
      points: [
        'Age between 18 and 65 years.',
        'Body weight should be at least 50 kg.',
        'Haemoglobin level of at least 12.5 g/dL.',
        'Minimum 3 months (12 weeks) gap since your last whole-blood donation.',
        'You must be free of fever, cold, flu or infection on donation day.',
        'Not pregnant or breastfeeding at the time of donation.',
        'No antibiotics or dental procedures in the last 72 hours (for minor work).',
        'No history of jaundice/hepatitis B or C, HIV, or other transmissible infections.',
        'Normal blood pressure and pulse at the screening check.',
      ],
    ),
    SafetyInfo(
      title: 'Pre-Donation Precautions',
      icon: '🧾',
      points: [
        'Eat a healthy full meal 2–3 hours before donating; never donate on an empty stomach.',
        'Drink plenty of water or juice before donation.',
        'Sleep well (at least 6–7 hours) the night before.',
        'Avoid smoking for at least 1 hour before donating.',
        'Avoid alcohol for at least 24 hours before donation.',
        'Wear clothing that lets you roll your sleeves above the elbow.',
        'Carry a photo ID and mention all medicines you are currently taking.',
        'Inform staff immediately if you fainted during an earlier donation.',
      ],
    ),
    SafetyInfo(
      title: 'Post-Donation Precautions',
      icon: '🩹',
      points: [
        'Keep the bandage on for at least 4–5 hours.',
        'Drink extra fluids (4+ glasses) over the next 24 hours.',
        'Avoid heavy lifting, running or intense exercise for the rest of the day.',
        'Avoid smoking and alcohol for at least 4–6 hours after donating.',
        'If you feel dizzy, lie down with your legs slightly raised until it passes.',
        'Eat iron-rich foods (spinach, dates, jaggery, eggs, beans) for the next few days.',
        'If bleeding resumes at the needle site, press firmly and raise your arm.',
        'Contact the blood bank if you develop fever, unusual bruising, or persistent pain.',
      ],
    ),
    SafetyInfo(
      title: 'Medical Screening Information',
      icon: '🩺',
      points: [
        'Haemoglobin is checked with a finger-prick test before every donation.',
        'Blood pressure, pulse and body temperature are measured at the camp.',
        'Weight is recorded to confirm the 50 kg minimum.',
        'Donated blood is tested for HIV, Hepatitis B & C, syphilis and malaria.',
        'Donor identity and questionnaire answers are verified by trained staff.',
        'Only a licensed medical officer can finally clear you to donate.',
        'Your confidential donor record is kept by the blood bank for future reference.',
      ],
    ),
  ];
}
