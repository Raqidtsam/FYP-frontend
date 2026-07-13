import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/search_history_service.dart';
import 'map_screen.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final SearchHistoryService _historyService = SearchHistoryService();
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _results = [];
  List<SearchHistoryItem> _history = [];
  bool _loading = false;
  bool _searched = false;
  bool _showHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty && !_showHistory) {
        setState(() => _showHistory = true);
      }
    });
  }

  Future<void> _loadHistory() async {
    final history = await _historyService.getHistory();
    setState(() => _history = history);
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _searched = true;
      _showHistory = false;
      _results = [];
    });

    final geoResult = await _apiService.geocodeLocation(query);

    if (geoResult != null) {
      final lat = double.parse(geoResult['lat']);
      final lng = double.parse(geoResult['lon']);
      final displayName = geoResult['display_name'] ?? query;

      final nearestDistrict = await _apiService.findNearestDistrict(lat, lng);

      setState(() {
        _results = [
          {
            'name': displayName,
            'type': 'location',
            'lat': lat.toString(),
            'lng': lng.toString(),
            'district': nearestDistrict?.name ?? 'Unknown',
            'districtId': nearestDistrict?.id.toString() ?? '0',
          }
        ];
        _loading = false;
      });
    } else {
      try {
        final districts = await _apiService.getDistricts();
        final filtered = districts
            .where((d) => d.name.toLowerCase().contains(query.toLowerCase()))
            .toList();

        setState(() {
          _results = filtered.map((d) => {
            'name': d.name,
            'type': 'district',
            'lat': d.latitude.toString(),
            'lng': d.longitude.toString(),
            'district': d.name,
            'districtId': d.id.toString(),
          }).toList();
          _loading = false;
        });
      } catch (e) {
        setState(() => _loading = false);
      }
    }
  }

  void _navigateToMap(Map<String, String> result) async {
    // Save to history
    await _historyService.addSearch(SearchHistoryItem(
      query: _searchController.text.trim(),
      locationName: result['name']!,
      latitude: double.parse(result['lat']!),
      longitude: double.parse(result['lng']!),
      districtName: result['district']!,
      districtId: int.parse(result['districtId']!),
      timestamp: DateTime.now(),
    ));

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          targetLat: double.parse(result['lat']!),
          targetLng: double.parse(result['lng']!),
          targetName: result['name']!,
          districtId: int.parse(result['districtId']!),
          districtName: result['district']!,
        ),
      ),
    );
  }

  void _navigateFromHistory(SearchHistoryItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapScreen(
          targetLat: item.latitude,
          targetLng: item.longitude,
          targetName: item.locationName,
          districtId: item.districtId,
          districtName: item.districtName,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Location'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search any place in Zanzibar...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _results = [];
                                  _searched = false;
                                  _showHistory = true;
                                });
                              },
                            )
                          : null,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.green),
                  onPressed: _search,
                ),
              ],
            ),
          ),

          // Search Results
          if (_loading)
            const Center(child: CircularProgressIndicator()),

          if (_results.isNotEmpty && !_loading)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Results',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  ..._results.map((result) => ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.red),
                        title: Text(result['name']!),
                        subtitle: Text('District: ${result['district']}'),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: () => _navigateToMap(result),
                      )),
                ],
              ),
            ),

          if (_searched && _results.isEmpty && !_loading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text('No results found. Try another name.'),
            ),

          // Search History
          if (_showHistory && _history.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Searches',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white70 : Colors.grey.shade700,
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _historyService.clearHistory();
                            _loadHistory();
                          },
                          child: const Text('Clear All'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final item = _history[index];
                        return Dismissible(
                          key: Key(item.timestamp.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) async {
                            await _historyService.deleteItem(index);
                            _loadHistory();
                          },
                          child: ListTile(
                            leading: const Icon(Icons.history, color: Colors.grey),
                            title: Text(item.locationName),
                            subtitle: Text('${item.districtName} • ${_formatDate(item.timestamp)}'),
                            trailing: const Icon(Icons.north_west, size: 16),
                            onTap: () => _navigateFromHistory(item),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}