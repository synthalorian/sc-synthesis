import 'package:flutter/material.dart';

/// Category icon + color for each component type.
class ComponentStyle {
  final IconData icon;
  final Color primary;
  final Color secondary;
  final String label;

  const ComponentStyle({
    required this.icon,
    required this.primary,
    required this.secondary,
    required this.label,
  });

  static const Map<String, ComponentStyle> _categories = {
    'weapons': ComponentStyle(
      icon: Icons.gps_fixed,
      primary: Color(0xFFFF5555),
      secondary: Color(0xFF8B0000),
      label: 'Weapon',
    ),
    'shieldgenerator': ComponentStyle(
      icon: Icons.shield_outlined,
      primary: Color(0xFF4488FF),
      secondary: Color(0xFF0033AA),
      label: 'Shield',
    ),
    'armor': ComponentStyle(
      icon: Icons.security_outlined,
      primary: Color(0xFF999999),
      secondary: Color(0xFF444444),
      label: 'Armor',
    ),
    'powerplant': ComponentStyle(
      icon: Icons.bolt_outlined,
      primary: Color(0xFFFFD700),
      secondary: Color(0xFF8B6914),
      label: 'Power',
    ),
    'cooler': ComponentStyle(
      icon: Icons.ac_unit_outlined,
      primary: Color(0xFF55CCFF),
      secondary: Color(0xFF006688),
      label: 'Cooler',
    ),
    'quantumdrive': ComponentStyle(
      icon: Icons.speed_outlined,
      primary: Color(0xFFFF69B4),
      secondary: Color(0xFF8B0050),
      label: 'QT Drive',
    ),
    'radar': ComponentStyle(
      icon: Icons.radar_outlined,
      primary: Color(0xFF66FF99),
      secondary: Color(0xFF006633),
      label: 'Radar',
    ),
  };

  static const Map<String, ComponentStyle> _manufacturers = {
    'behring': ComponentStyle(
      icon: Icons.gps_fixed, primary: Color(0xFFCC3333), secondary: Color(0xFF660000), label: 'Behring',
    ),
    'klaus': ComponentStyle(
      icon: Icons.gps_fixed, primary: Color(0xFFFF8800), secondary: Color(0xFF884400), label: 'K&W',
    ),
    'lightning power': ComponentStyle(
      icon: Icons.bolt_outlined, primary: Color(0xFFFFDD00), secondary: Color(0xFF997700), label: 'Lightning',
    ),
    'juno': ComponentStyle(
      icon: Icons.bolt_outlined, primary: Color(0xFF00CCFF), secondary: Color(0xFF006688), label: 'Juno',
    ),
    'wen/cassel': ComponentStyle(
      icon: Icons.speed_outlined, primary: Color(0xFFFF44AA), secondary: Color(0xFF880044), label: 'Wen/Cassel',
    ),
    'chimera': ComponentStyle(
      icon: Icons.radar_outlined, primary: Color(0xFF44FF88), secondary: Color(0xFF008844), label: 'Chimera',
    ),
    'gorgon': ComponentStyle(
      icon: Icons.shield_outlined, primary: Color(0xFF6666FF), secondary: Color(0xFF222288), label: 'Gorgon',
    ),
    'amons': ComponentStyle(
      icon: Icons.ac_unit_outlined, primary: Color(0xFF66DDFF), secondary: Color(0xFF006688), label: 'Amon & Reese',
    ),
    'tyler': ComponentStyle(
      icon: Icons.gps_fixed, primary: Color(0xFF44AAFF), secondary: Color(0xFF004488), label: 'Tyler',
    ),
    'firestorm': ComponentStyle(
      icon: Icons.whatshot_outlined, primary: Color(0xFFFF6600), secondary: Color(0xFF883300), label: 'Firestorm',
    ),
    'apocalypse': ComponentStyle(
      icon: Icons.gps_fixed, primary: Color(0xFFCC0055), secondary: Color(0xFF660022), label: 'Apocalypse',
    ),
    'seal': ComponentStyle(
      icon: Icons.shield_outlined, primary: Color(0xFF88AACC), secondary: Color(0xFF445566), label: 'Seal',
    ),
    'wei-tek': ComponentStyle(
      icon: Icons.gps_fixed, primary: Color(0xFF44DD88), secondary: Color(0xFF006633), label: 'Wei-Tek',
    ),
    'willsop': ComponentStyle(
      icon: Icons.build_outlined, primary: Color(0xFFCC8844), secondary: Color(0xFF664422), label: 'WillsOp',
    ),
  };

  static ComponentStyle forCategory(String category) {
    return _categories[category.toLowerCase().replaceAll(' ', '')] ?? const ComponentStyle(
      icon: Icons.build_outlined,
      primary: Color(0xFF888888),
      secondary: Color(0xFF444444),
      label: 'Component',
    );
  }

  static ComponentStyle forManufacturer(String manufacturer) {
    final key = manufacturer.toLowerCase().trim();
    final match = _manufacturers.entries.where((e) => key.contains(e.key));
    return match.isNotEmpty ? match.first.value : const ComponentStyle(
      icon: Icons.build_outlined,
      primary: Color(0xFF888888),
      secondary: Color(0xFF444444),
      label: 'Generic',
    );
  }

  BoxDecoration decoration({double radius = 10}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight,
        colors: [primary.withValues(alpha: 0.15), secondary.withValues(alpha: 0.25)],
      ),
      border: Border.all(color: primary.withValues(alpha: 0.3), width: 1.5),
    );
  }
}

/// Avatar for a ship component — shows category icon + manufacturer color.
class ComponentAvatar extends StatelessWidget {
  final String category;
  final String manufacturer;
  final double size;

  const ComponentAvatar({
    super.key,
    required this.category,
    required this.manufacturer,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final mfrStyle = ComponentStyle.forManufacturer(manufacturer);
    final catStyle = ComponentStyle.forCategory(category);
    // Use manufacturer color if available, fall back to category color
    final primary = mfrStyle.primary;
    final icon = catStyle.icon;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [primary.withValues(alpha: 0.15), primary.withValues(alpha: 0.05)],
        ),
        border: Border.all(color: primary.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Icon(icon, size: size * 0.5, color: primary),
    );
  }
}
