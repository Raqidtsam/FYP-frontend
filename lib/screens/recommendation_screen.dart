import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/recommendation.dart';

class RecommendationScreen extends StatefulWidget {
  final int districtId;
  final String districtName;

  const RecommendationScreen({
    super.key,
    required this.districtId,
    required this.districtName,
  });

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final ApiService _apiService = ApiService();
  List<Recommendation> _recommendations = [];
  bool _loading = true;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    setState(() => _loading = true);
    try {
      final recommendations =
          await _apiService.getRecommendations(widget.districtId);
      setState(() {
        _recommendations = recommendations;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  Future<void> _generateAIRecommendations() async {
    setState(() => _generating = true);
    try {
      final result = await _apiService.generateRecommendations(widget.districtId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Generated successfully')),
        );
      }
      await _loadRecommendations();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Generation failed: $e')),
        );
      }
    } finally {
      setState(() => _generating = false);
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  IconData _getScoreIcon(double score) {
    if (score >= 80) return Icons.trending_up;
    if (score >= 60) return Icons.trending_flat;
    return Icons.trending_down;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Highly Recommended';
    if (score >= 60) return 'Good Opportunity';
    return 'Moderate';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Investments in ${widget.districtName}'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: _generating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            tooltip: 'Generate AI Recommendations',
            onPressed: _generating ? null : _generateAIRecommendations,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadRecommendations,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _recommendations.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No recommendations yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the magic button to generate AI recommendations',
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _generateAIRecommendations,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Generate AI Recommendations'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header summary
                    Container(
                      width: double.infinity,
                      color: Colors.green.shade50,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.lightbulb, color: Colors.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${_recommendations.length} AI-Generated Recommendations',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Recommendations list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _recommendations.length,
                        itemBuilder: (context, index) {
                          final rec = _recommendations[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Score circle
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getScoreColor(rec.score)
                                          .withValues(alpha: 0.1),
                                      border: Border.all(
                                        color: _getScoreColor(rec.score),
                                        width: 3,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${rec.score.toInt()}%',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: _getScoreColor(rec.score),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                rec.sectorName ??
                                                    'Sector ${rec.sectorId}',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            Icon(
                                              _getScoreIcon(rec.score),
                                              color:
                                                  _getScoreColor(rec.score),
                                              size: 20,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getScoreColor(rec.score)
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getScoreLabel(rec.score),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color:
                                                  _getScoreColor(rec.score),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        if (rec.reason != null &&
                                            rec.reason!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            rec.reason!,
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey.shade700,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}