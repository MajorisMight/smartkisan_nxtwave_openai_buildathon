class Remedy {
  final String type;
  final String name;
  final String instruction;
  final String marketplaceQuery;

  Remedy({
    required this.type,
    required this.name,
    required this.instruction,
    required this.marketplaceQuery,
  });
}

class DiseaseDetectionResult {
  final String diseaseName;
  final double confidence;
  final List<Remedy> remedies;

  DiseaseDetectionResult({
    required this.diseaseName,
    required this.confidence,
    required this.remedies,
  });
}
