class Scheme {
  final String id;
  final String title;
  final String category; // subsidy, insurance, loan, training
  final String state;
  final String description;
  final List<String> eligibilityTags; // e.g., small, sc_st, crop_wheat
  final List<String> steps;

  Scheme({
    required this.id,
    required this.title,
    required this.category,
    required this.state,
    required this.description,
    required this.eligibilityTags,
    required this.steps,
  });

  static Scheme fromMap(Map<String, dynamic> map) {
    return Scheme(
      id: map['id'] ?? map['title'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: (map['category'] ?? 'training').toString(),
      state: map['state'] ?? '',
      eligibilityTags: (map['eligibilityTags'] as List<dynamic>? ?? const [])
          .map((x) => x.toString()).toList(),
      steps: (map['steps'] as List<dynamic>? ?? const [])
          .map((x) => x.toString()).toList(),
    );
}
}

