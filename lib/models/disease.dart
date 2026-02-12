class Remedy {
  final String type; // organic, chemical
  final String name;
  final String instruction;
  final String? marketplaceQuery; // for deep linking

  Remedy({
    required this.type,
    required this.name,
    required this.instruction,
    this.marketplaceQuery,
  });
}

class DiseaseDetectionResult {
  final String diseaseName;
  final double confidence; // 0..1
  final List<Remedy> remedies;

  DiseaseDetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.remedies,
  });
}


