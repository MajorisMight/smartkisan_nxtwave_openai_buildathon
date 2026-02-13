class AIAnalysisService {
  static Map<String, dynamic> getAIImpactData() {
    return {
      'total_yield_increase': 18.4,
      'cost_savings': 12450.0,
      'crops_saved_from_disease': 3,
      'total_investment_saved': 21300.0,
      'yield_improvements': [
        {
          'crop': 'Wheat',
          'improvement': 14.2,
          'previous_yield': '21 q/acre',
          'current_yield': '24 q/acre',
          'ai_recommendation': 'Stage-wise nitrogen split application',
        },
        {
          'crop': 'Mustard',
          'improvement': 11.0,
          'previous_yield': '8 q/acre',
          'current_yield': '8.9 q/acre',
          'ai_recommendation': 'Improved micronutrient schedule',
        },
      ],
      'disease_preventions': [
        {
          'disease': 'Leaf Blight',
          'potential_loss': 22,
          'ai_recommendation': 'Early warning + preventive spray timing',
        },
      ],
    };
  }

  static Map<String, dynamic> getFarmHealthAssessment() {
    return {
      'health_status': 'Good',
      'overall_score': 84.0,
      'soil_health': 79.0,
      'crop_health': 86.0,
      'pest_management': 81.0,
      'recommendations': [
        {
          'title': 'Increase potash in current cycle',
          'priority': 'Medium',
          'description': 'Soil balance indicates slightly low K levels.',
        },
        {
          'title': 'Weekly scout for stem borer',
          'priority': 'High',
          'description': 'Pest-pressure window is active for next 10 days.',
        },
      ],
    };
  }
}
