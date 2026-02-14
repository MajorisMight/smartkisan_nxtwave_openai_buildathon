import 'package:flutter/material.dart';

class FertilizerRecommendationCard extends StatelessWidget {
  final Map<String, dynamic> fertilizerJson;

  const FertilizerRecommendationCard({super.key, required this.fertilizerJson});

  @override
  Widget build(BuildContext context) {
    final targetCrop = fertilizerJson['target_crop'] ?? 'Unknown';
  final stage = fertilizerJson['stage'] ?? 'Unknown';
  final areaHa = fertilizerJson['area_ha'] ?? 0.0;
  final confidence = fertilizerJson['confidence'] ?? 'Low';
  final basis = fertilizerJson['basis'] ?? '';
  final whyRecommendation = fertilizerJson['why_this_recommendation'] ?? '';
  final caution = fertilizerJson['caution'] ?? '';
  
  final fertilizerItems = List<Map<String, dynamic>>.from(fertilizerJson['fertilizer_items'] ?? []);
  final splitSchedule = List<Map<String, dynamic>>.from(fertilizerJson['split_schedule'] ?? []);

  Color getConfidenceColor(String conf) {
    switch (conf.toLowerCase()) {
      case 'high': return Colors.green;
      case 'medium': return Colors.orange;
      case 'low': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData getFertilizerIcon(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('urea')) return Icons.grain;
    if (lowerName.contains('dap')) return Icons.scatter_plot;
    if (lowerName.contains('mop')) return Icons.settings_input_component;
    if (lowerName.contains('gypsum')) return Icons.terrain;
    return Icons.eco;
  }

  Color getFertilizerColor(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('urea')) return Colors.blue;
    if (lowerName.contains('dap')) return Colors.purple;
    if (lowerName.contains('mop')) return Colors.orange;
    if (lowerName.contains('gypsum')) return Colors.brown;
    return Colors.green;
  }

  String getNutrientInfo(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('urea')) return 'Nitrogen (N) - 46%';
    if (lowerName.contains('dap')) return 'Nitrogen (18%) + Phosphorus (46%)';
    if (lowerName.contains('mop')) return 'Potassium (K) - 60%';
    if (lowerName.contains('gypsum')) return 'Calcium + Sulfur';
    if (lowerName.contains('zn')) return 'Zinc micronutrient';
    return 'Multi-nutrient';
  }

  double calculateTotalCost(List<Map<String, dynamic>> items) {
    // Rough cost estimation in INR (you can update these prices)
    double total = 0;
    for (var item in items) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final kg = item['quantity_total_kg'] ?? 0.0;
      
      if (name.contains('urea')) total += kg * 6.5; // ₹6.5/kg
      if (name.contains('dap')) total += kg * 24; // ₹24/kg  
      if (name.contains('mop')) total += kg * 17; // ₹17/kg
      if (name.contains('gypsum')) total += kg * 8; // ₹8/kg
    }
    return total;
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Card
        Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.green[600]!, Colors.green[400]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.agriculture, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Fertilizer Prescription",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: getConfidenceColor(confidence).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          confidence.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip("🌾 $targetCrop", Colors.white24),
                      const SizedBox(width: 8),
                      _buildInfoChip("📈 $stage", Colors.white24),
                      const SizedBox(width: 8),
                      _buildInfoChip("📐 ${areaHa.toStringAsFixed(1)} ha", Colors.white24),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Quick Summary Card
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.summarize, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      "Quick Summary",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildSummaryStat("📦", "Products", "${fertilizerItems.length}"),
                          _buildSummaryStat("⏰", "Applications", "${splitSchedule.length}"),
                          _buildSummaryStat("💰", "Est. Cost", "₹${calculateTotalCost(fertilizerItems).toStringAsFixed(0)}"),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Fertilizer Items Detail
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.inventory, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      "Fertilizer Requirements",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...fertilizerItems.map((item) {
                  final name = item['name'] ?? '';
                  final quantity = item['quantity'] ?? '';
                  final perHa = item['quantity_kg_per_ha'] ?? 0.0;
                  final total = item['quantity_total_kg'] ?? 0.0;
                  final note = item['note'] ?? '';
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: getFertilizerColor(name).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: getFertilizerColor(name).withOpacity(0.3)),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: getFertilizerColor(name),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          getFertilizerIcon(name),
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getFertilizerColor(name),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              quantity,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(getNutrientInfo(name), 
                               style: const TextStyle(fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text("Rate: ${perHa.toStringAsFixed(1)} kg/ha • Purpose: $note"),
                          const SizedBox(height: 4),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Application Schedule
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.schedule, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Text(
                      "Application Timeline",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...splitSchedule.asMap().entries.map((entry) {
                  final index = entry.key;
                  final schedule = entry.value;
                  final product = schedule['product'] ?? '';
                  final when = schedule['when'] ?? '';
                  final amount = schedule['amount'] ?? '';
                  final notes = schedule['notes'] ?? '';
                  final isNow = when.toLowerCase().contains('now');
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline indicator
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: isNow ? Colors.red : Colors.indigo,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (index < splitSchedule.length - 1)
                              Container(
                                width: 2,
                                height: 40,
                                color: Colors.indigo[200],
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        // Content
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isNow ? Colors.red[50] : Colors.indigo[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border(
                                left: BorderSide(
                                  width: 4,
                                  color: isNow ? Colors.red : Colors.indigo,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      getFertilizerIcon(product),
                                      size: 16,
                                      color: isNow ? Colors.red : Colors.indigo,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "${product.toUpperCase()} - $amount",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isNow ? Colors.red[800] : Colors.indigo[800],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      isNow ? Icons.priority_high : Icons.schedule,
                                      size: 14,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      when,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: isNow ? Colors.red[700] : Colors.indigo[700],
                                      ),
                                    ),
                                  ],
                                ),
                                if (notes.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    notes,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Why This Recommendation
        if (whyRecommendation.isNotEmpty) ...[
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        "Why These Fertilizers?",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border(
                        left: BorderSide(width: 4, color: Colors.teal),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lightbulb, size: 16, color: Colors.teal),
                            const SizedBox(width: 8),
                            const Text(
                              "Scientific Reasoning:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(whyRecommendation),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.verified, size: 16, color: Colors.teal),
                            const SizedBox(width: 8),
                            // FIX: Wrap the long text in Expanded to avoid overflow
                            Expanded(
                              child: Text(
                                "Based on: $basis",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Application Instructions
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.integration_instructions, color: Colors.deepOrange),
                    const SizedBox(width: 8),
                    Text(
                      "How to Apply",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionItem(
                  "🌧️",
                  "Weather Check",
                  "Apply fertilizers when no rain is expected for 24-48 hours",
                ),
                _buildInstructionItem(
                  "💧",
                  "Soil Moisture",
                  "Ensure adequate soil moisture before application",
                ),
                _buildInstructionItem(
                  "🌅",
                  "Best Time",
                  "Apply early morning (6-8 AM) or evening (4-6 PM) to avoid heat stress",
                ),
                _buildInstructionItem(
                  "🚜",
                  "Method",
                  "Broadcast evenly and incorporate into soil or apply as side dressing",
                ),
                _buildInstructionItem(
                  "💧",
                  "After Application",
                  "Water lightly if possible to help nutrient absorption",
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Important Cautions
        if (caution.isNotEmpty) ...[
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: Colors.amber[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.amber),
                      const SizedBox(width: 8),
                      Text(
                        "Important Cautions",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        Expanded(child: Text(caution)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Cost Analysis
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      "Cost Analysis",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...fertilizerItems.map((item) {
                  final name = item['name'] ?? '';
                  final kg = item['quantity_total_kg'] ?? 0.0;
                  double costPerKg = 0;
                  
                  if (name.toLowerCase().contains('urea')) costPerKg = 6.5;
                  if (name.toLowerCase().contains('dap')) costPerKg = 24;
                  if (name.toLowerCase().contains('mop')) costPerKg = 17;
                  if (name.toLowerCase().contains('gypsum')) costPerKg = 8;
                  
                  final totalCost = kg * costPerKg;
                  final perHaCost = totalCost / areaHa;
                  
                  return ListTile(
                    leading: Icon(getFertilizerIcon(name), color: getFertilizerColor(name)),
                    title: Text(name.toUpperCase()),
                    subtitle: Text("${kg.toStringAsFixed(1)} kg @ ₹${costPerKg.toStringAsFixed(1)}/kg"),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("₹${totalCost.toStringAsFixed(0)}", 
                             style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("₹${perHaCost.toStringAsFixed(0)}/ha", 
                             style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  );
                }),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Investment:", 
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "₹${calculateTotalCost(fertilizerItems).toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          "₹${(calculateTotalCost(fertilizerItems) / areaHa).toStringAsFixed(0)}/ha",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Footer
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "This prescription is generated based on scientific analysis. Always consult your local agricultural officer for site-specific advice. Prices are approximate and may vary by location.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  }


  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSummaryStat(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInstructionItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  }