enum BadgeRarity { common, rare, epic, legendary }

class BadgeUnlock {
  final String id;
  final String name;
  final String description;
  final String icon;
  final BadgeRarity rarity;

  const BadgeUnlock({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.rarity = BadgeRarity.legendary,
  });
}
