import 'package:flutter/material.dart';

import 'models.dart';

const sopivaInk = Color(0xFF161A22);
const sopivaPaper = Color(0xFFF3F1EC);
const sopivaPanel = Color(0xFFE9E6DF);
const sopivaIndigo = Color(0xFF4F5DFF);
const sopivaCoral = Color(0xFFFF6B57);
const sopivaMint = Color(0xFF3CBF9B);
const sopivaGold = Color(0xFFE8B34F);
const sopivaSlate = Color(0xFF707786);
const sopivaDarkPanel = Color(0xFF202630);

ThemeData sopivaTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  final scheme = ColorScheme.fromSeed(
    seedColor: sopivaIndigo,
    brightness: brightness,
    primary: sopivaIndigo,
    secondary: sopivaCoral,
    surface: dark ? sopivaDarkPanel : Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? const Color(0xFF11151C) : sopivaPaper,
    fontFamily: null,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: dark ? const Color(0xFF1C222C) : Colors.white,
      hintStyle: TextStyle(
        color: dark ? Colors.white54 : sopivaSlate,
      ),
      labelStyle: TextStyle(
        color: dark ? Colors.white70 : sopivaSlate,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: dark ? Colors.white12 : const Color(0xFFD7D3CA),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: dark ? Colors.white12 : const Color(0xFFD7D3CA),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(
          color: sopivaIndigo,
          width: 1.5,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: sopivaInk,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    ),
  );
}

IconData categoryIcon(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.operations:
      return Icons.precision_manufacturing_outlined;
    case ProcedureCategory.admin:
      return Icons.inventory_2_outlined;
    case ProcedureCategory.client:
      return Icons.groups_2_outlined;
    case ProcedureCategory.quality:
      return Icons.fact_check_outlined;
    case ProcedureCategory.finance:
      return Icons.account_balance_wallet_outlined;
    case ProcedureCategory.safety:
      return Icons.shield_outlined;
    case ProcedureCategory.other:
      return Icons.widgets_outlined;
  }
}

Color categoryColor(ProcedureCategory category) {
  switch (category) {
    case ProcedureCategory.operations:
      return sopivaIndigo;
    case ProcedureCategory.admin:
      return const Color(0xFF6D70C7);
    case ProcedureCategory.client:
      return sopivaCoral;
    case ProcedureCategory.quality:
      return sopivaMint;
    case ProcedureCategory.finance:
      return sopivaGold;
    case ProcedureCategory.safety:
      return const Color(0xFFCF4D64);
    case ProcedureCategory.other:
      return sopivaSlate;
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

class SopivaMark extends StatelessWidget {
  final double size;
  final bool compact;

  const SopivaMark({
    super.key,
    this.size = 56,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = size * .28;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: sopivaInk,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: size * .18,
            top: size * .18,
            child: Container(
              width: size * .22,
              height: size * .22,
              decoration: const BoxDecoration(
                color: sopivaCoral,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: size * .14,
            bottom: size * .17,
            child: Container(
              width: size * .34,
              height: size * .34,
              decoration: BoxDecoration(
                color: sopivaIndigo,
                borderRadius: BorderRadius.circular(size * .11),
              ),
            ),
          ),
          Icon(
            Icons.alt_route_rounded,
            size: compact ? size * .40 : size * .46,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String kicker;
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionTitle({
    super.key,
    required this.kicker,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kicker.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: sopivaCoral,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            child: Text(action!),
          ),
      ],
    );
  }
}

class MetricStrip extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const MetricStrip({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: dark ? sopivaDarkPanel : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: dark ? Colors.white10 : const Color(0xFFDEDBD3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .8,
                    color: dark ? Colors.white54 : sopivaSlate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Pill extends StatelessWidget {
  final String text;
  final Color color;
  final IconData? icon;

  const Pill({
    super.key,
    required this.text,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class NumberBadge extends StatelessWidget {
  final int number;
  final Color color;
  final bool done;

  const NumberBadge({
    super.key,
    required this.number,
    required this.color,
    this.done = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: done ? color : color.withOpacity(.10),
        borderRadius: BorderRadius.circular(11),
      ),
      child: done
          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
          : Text(
              '$number',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
              ),
            ),
    );
  }
}

class ProgressTrack extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const ProgressTrack({
    super.key,
    required this.value,
    required this.color,
    this.height = 7,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0).toDouble(),
        minHeight: height,
        color: color,
        backgroundColor: color.withOpacity(.10),
      ),
    );
  }
}
