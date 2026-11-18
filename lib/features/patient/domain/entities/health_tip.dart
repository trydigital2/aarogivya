class HealthTip {
  const HealthTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String iconName;

  static const defaultTips = <HealthTip>[
    HealthTip(
      id: 'tip_1',
      title: 'Stay Hydrated',
      description: 'Drink at least 8 to 10 glasses of water daily to maintain cellular function and cognitive focus.',
      category: 'Wellness',
      iconName: 'water_drop',
    ),
    HealthTip(
      id: 'tip_2',
      title: 'Balanced Nutrition',
      description: 'Incorporate vibrant green leafy vegetables, dietary fiber, and healthy proteins into every meal.',
      category: 'Diet',
      iconName: 'restaurant',
    ),
    HealthTip(
      id: 'tip_3',
      title: 'Active Routine',
      description: 'A brisk 30-minute daily walk boosts cardiovascular endurance and significantly reduces stress.',
      category: 'Fitness',
      iconName: 'directions_walk',
    ),
  ];
}
