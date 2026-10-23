import 'package:flutter/material.dart';

import 'models.dart';

const sopivaNavy = Color(0xFF152238);
const sopivaTeal = Color(0xFF1F9D8B);
const sopivaAmber = Color(0xFFF4B942);
const sopivaBlue = Color(0xFF4A78D0);
const sopivaRed = Color(0xFFE46464);
const sopivaGreen = Color(0xFF3EA66B);
const sopivaBg = Color(0xFFF5F7FA);

ThemeData sopivaTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: sopivaTeal,
      brightness: brightness,
      primary: sopivaTeal,
      secondary: sopivaAmber,
    ),
    scaffoldBackgroundColor:
        dark ? const Color(0xFF0E1725) : sopivaBg,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

IconData categoryIcon(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.operations:
      return Icons.settings_suggest_outlined;
    case ProcedureCategory.admin:
      return Icons.badge_outlined;
    case ProcedureCategory.client:
      return Icons.handshake_outlined;
    case ProcedureCategory.quality:
      return Icons.verified_outlined;
    case ProcedureCategory.finance:
      return Icons.account_balance_wallet_outlined;
    case ProcedureCategory.safety:
      return Icons.health_and_safety_outlined;
    case ProcedureCategory.other:
      return Icons.checklist_rounded;
  }
}

Color categoryColor(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.operations:
      return sopivaBlue;
    case ProcedureCategory.admin:
      return sopivaTeal;
    case ProcedureCategory.client:
      return sopivaAmber;
    case ProcedureCategory.quality:
      return sopivaGreen;
    case ProcedureCategory.finance:
      return const Color(0xFF8B6CD6);
    case ProcedureCategory.safety:
      return sopivaRed;
    case ProcedureCategory.other:
      return const Color(0xFF6E7C91);
  }
}

String formatDuration(int totalSeconds) {
  if (totalSeconds < 60) return '${totalSeconds}s';

  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;

  if (minutes < 60) {
    return seconds == 0 ? '${minutes}m' : '${minutes}m ${seconds}s';
  }

  final hours = minutes ~/ 60;
  final restMinutes = minutes % 60;
  return restMinutes == 0 ? '${hours}h' : '${hours}h ${restMinutes}m';
}

String shortDate(DateTime value) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}

class SopivaLogo extends StatelessWidget {
  final double size;

  const SopivaLogo({
    super.key,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [sopivaNavy, sopivaTeal],
        ),
        borderRadius: BorderRadius.circular(size * .27),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.rule_rounded,
            size: size * .52,
            color: Colors.white,
          ),
          Positioned(
            right: size * .09,
            bottom: size * .09,
            child: Container(
              width: size * .25,
              height: size * .25,
              decoration: const BoxDecoration(
                color: sopivaAmber,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: size * .16,
                color: sopivaNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const MetricCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressLine extends StatelessWidget {
  final double value;
  final Color color;

  const ProgressLine({
    super.key,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final safe = value.clamp(0.0, 1.0).toDouble();

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: safe,
        minHeight: 8,
        color: color,
        backgroundColor: color.withOpacity(.10),
      ),
    );
  }
}
