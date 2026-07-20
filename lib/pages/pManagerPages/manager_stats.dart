// lib/pages/pManagerPages/manager_stats_page.dart
import 'dart:convert';
import 'package:brickapp/providers/user_provider.dart';
import 'package:brickapp/utils/app_colors.dart';
import 'package:brickapp/utils/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ManagerStatsPage extends ConsumerStatefulWidget {
  const ManagerStatsPage({super.key});

  @override
  ConsumerState<ManagerStatsPage> createState() => _ManagerStatsPageState();
}

class _ManagerStatsPageState extends ConsumerState<ManagerStatsPage> {
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  final formatter = NumberFormat('#,###');
  final dateFormatter = DateFormat('MMM dd');
  final monthFormatter = DateFormat('MMM yyyy');

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = ref.read(userProvider).token;
      if (token == null) {
        throw Exception('Not logged in');
      }

      final response = await http.get(
        Uri.parse('${AppUrls.baseUrl}/properties/manager/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Stats response: ${response.statusCode}');
      print('📊 Stats body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _stats = data['stats'];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load stats: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: _buildAppBar(),
        body:  Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.iconColor),
              SizedBox(height: 16),
              Text('Loading your statistics...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadStats,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iconColor,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_stats == null || _stats!['total_properties'] == 0) {
      return Scaffold(
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No Properties Yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Post your first property to start seeing statistics',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add-post');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.iconColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text('Post Property'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Overview Cards ─────────────────────────
              _buildOverviewCards(),
              const SizedBox(height: 24),

              // ─── Revenue Chart ──────────────────────────
              _buildRevenueChart(),
              const SizedBox(height: 24),

              // ─── Property Performance ──────────────────
              _buildPropertyPerformance(),
              const SizedBox(height: 24),

              // ─── Recent Activity ────────────────────────
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text(
        'My Statistics',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: AppColors.iconColor,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: _loadStats,
        ),
      ],
    );
  }

  Widget _buildOverviewCards() {
    final totalProps = _stats!['total_properties'] ?? 0;
    final totalViews = _stats!['total_views'] ?? 0;
    final totalBookings = _stats!['total_bookings'] ?? 0;
    final totalRevenue = _stats!['total_revenue'] ?? 0;
    final avgRating = _stats!['average_rating'] ?? 0;

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildOverviewCard(
          'Properties',
          totalProps.toString(),
          Icons.home_work,
          Colors.blue,
        ),
        _buildOverviewCard(
          'Views',
          totalViews.toString(),
          Icons.visibility,
          Colors.purple,
        ),
        _buildOverviewCard(
          'Bookings',
          totalBookings.toString(),
          Icons.calendar_today,
          Colors.orange,
        ),
        _buildOverviewCard(
          'Revenue',
          'UGX ${formatter.format(totalRevenue)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildOverviewCard(
          'Avg Rating',
          avgRating > 0 ? avgRating.toStringAsFixed(1) : '—',
          Icons.star,
          Colors.amber,
        ),
        _buildOverviewCard(
          'Conversion Rate',
          _getConversionRate(),
          Icons.trending_up,
          Colors.teal,
        ),
      ],
    );
  }

  String _getConversionRate() {
    final views = _stats!['total_views'] ?? 0;
    final bookings = _stats!['total_bookings'] ?? 0;
    if (views == 0) return '0%';
    return '${((bookings / views) * 100).toStringAsFixed(0)}%';
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Icon(Icons.more_vert, size: 16, color: Colors.grey),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              title,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    final properties = _stats!['properties'] as List? ?? [];
    if (properties.isEmpty) {
      return const SizedBox();
    }

    // Prepare chart data
    final chartData = properties.map((p) {
      return RevenueData(
        p['property_type'] ?? 'Property',
        (p['revenue'] ?? 0).toDouble(),
        p['booking_count'] ?? 0,
      );
    }).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.bar_chart, color: AppColors.iconColor),
                SizedBox(width: 8),
                Text(
                  'Revenue by Property',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(
                  labelRotation: -30,
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                primaryYAxis: NumericAxis(
                  numberFormat: NumberFormat.compact(),
                  labelFormat: '{value}',
                ),
                tooltipBehavior: TooltipBehavior(enable: true),
                series: <CartesianSeries<RevenueData, String>>[
                  ColumnSeries<RevenueData, String>(
                    dataSource: chartData,
                    xValueMapper: (RevenueData data, _) => data.label,
                    yValueMapper: (RevenueData data, _) => data.revenue,
                    name: 'Revenue',
                    color: Colors.orange,
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: false,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyPerformance() {
    final properties = _stats!['properties'] as List? ?? [];
    if (properties.isEmpty) {
      return const SizedBox();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Row(
              children: [
                Icon(Icons.assessment, color: AppColors.iconColor),
                SizedBox(width: 8),
                Text(
                  'Property Performance',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...properties.map((p) => _buildPropertyTile(p)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPropertyTile(Map<String, dynamic> property) {
    final views = property['view_count'] ?? 0;
    final bookings = property['booking_count'] ?? 0;
    final revenue = property['revenue'] ?? 0;
    final rating = property['avg_rating'] ?? 0;
    

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: property['thumbnail'] != null
                ? Image.network(
                    '${AppUrls.baseUrl}/${property['thumbnail']}',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 20),
                    ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey[200],
                    child: const Icon(Icons.home, size: 20, color: Colors.grey),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['address'] ?? 'Unknown Address',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  property['property_type'] ?? 'N/A',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildStatChip(Icons.visibility, '$views', Colors.purple),
                    const SizedBox(width: 6),
                    _buildStatChip(Icons.calendar_today, '$bookings', Colors.orange),
                    const SizedBox(width: 6),
                    if (rating > 0)
                      _buildStatChip(Icons.star, rating.toStringAsFixed(1), Colors.amber),
                    const SizedBox(width: 6),
                    _buildStatChip(Icons.attach_money, 'UGX ${formatter.format(revenue)}', Colors.green),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final properties = _stats!['properties'] as List? ?? [];
    if (properties.isEmpty) {
      return const SizedBox();
    }

    // Sort by revenue to show top properties
    final sorted = List<Map<String, dynamic>>.from(properties)
      ..sort((a, b) => (b['revenue'] ?? 0).compareTo(a['revenue'] ?? 0));

    final top3 = sorted.take(3).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Row(
              children: [
                Icon(Icons.trending_up, color: AppColors.iconColor),
                SizedBox(width: 8),
                Text(
                  'Top Performing Properties',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...top3.asMap().entries.map((entry) {
              final index = entry.key + 1;
              final p = entry.value;
              return _buildRankItem(index, p);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRankItem(int rank, Map<String, dynamic> property) {
    final colors = [Colors.amber, Colors.grey, Colors.brown];
    final color = rank <= 3 ? colors[rank - 1] : Colors.grey;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['address'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${property['booking_count'] ?? 0} bookings • UGX ${formatter.format(property['revenue'] ?? 0)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${property['view_count'] ?? 0} views',
              style: TextStyle(fontSize: 10, color: Colors.green[700]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chart Data Class ───────────────────────────────────────
class RevenueData {
  final String label;
  final double revenue;
  final int bookings;

  RevenueData(this.label, this.revenue, this.bookings);
}