import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

class BinHistoryPage extends StatefulWidget {
  const BinHistoryPage({Key? key}) : super(key: key);

  @override
  _BinHistoryPageState createState() => _BinHistoryPageState();
}

class _BinHistoryPageState extends State<BinHistoryPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _binHistoryRecords = [];
  String _selectedBinId = 'All';
  List<String> _availableBinIds = ['All'];
  String _selectedTimeRange = 'All';
  final List<String> _timeRanges = ['All', 'Today', 'Last Week', 'Last Month'];

  @override
  void initState() {
    super.initState();
    _fetchBinIds();
    _fetchBinHistory();
  }

  Future<void> _fetchBinIds() async {
    try {
      final QuerySnapshot binsSnapshot =
          await FirebaseFirestore.instance.collection('bins').get();

      final List<String> binIds = ['All'];
      for (var doc in binsSnapshot.docs) {
        binIds.add(doc.id);
      }

      setState(() {
        _availableBinIds = binIds;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load bin IDs: $e');
    }
  }

  Future<void> _fetchBinHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Map<String, dynamic>> allHistory = [];

      // Determine the filter date based on time range
      DateTime? filterDate;
      if (_selectedTimeRange == 'Today') {
        filterDate = DateTime.now().subtract(const Duration(days: 1));
      } else if (_selectedTimeRange == 'Last Week') {
        filterDate = DateTime.now().subtract(const Duration(days: 7));
      } else if (_selectedTimeRange == 'Last Month') {
        filterDate = DateTime.now().subtract(const Duration(days: 30));
      }

      if (_selectedBinId == 'All') {
        // Get all bins
        final QuerySnapshot binsSnapshot =
            await FirebaseFirestore.instance.collection('bins').get();

        // Fetch history for each bin
        for (var bin in binsSnapshot.docs) {
          Query historyQuery = FirebaseFirestore.instance
              .collection('bins')
              .doc(bin.id)
              .collection('history');

          // Apply time filter if needed
          if (filterDate != null) {
            historyQuery = historyQuery.where(
              'timestamp',
              isGreaterThan: filterDate,
            );
          }

          // Sort by timestamp (newest first)
          historyQuery = historyQuery.orderBy('timestamp', descending: true);

          final QuerySnapshot historySnapshot = await historyQuery.get();

          for (var historyDoc in historySnapshot.docs) {
            Map<String, dynamic> data =
                historyDoc.data() as Map<String, dynamic>;
            data['binId'] = bin.id;
            data['historyId'] = historyDoc.id;
            allHistory.add(data);
          }
        }
      } else {
        // Get history for specific bin
        Query historyQuery = FirebaseFirestore.instance
            .collection('bins')
            .doc(_selectedBinId)
            .collection('history');

        // Apply time filter if needed
        if (filterDate != null) {
          historyQuery = historyQuery.where(
            'timestamp',
            isGreaterThan: filterDate,
          );
        }

        // Sort by timestamp (newest first)
        historyQuery = historyQuery.orderBy('timestamp', descending: true);

        final QuerySnapshot historySnapshot = await historyQuery.get();

        for (var historyDoc in historySnapshot.docs) {
          Map<String, dynamic> data = historyDoc.data() as Map<String, dynamic>;
          data['binId'] = _selectedBinId;
          data['historyId'] = historyDoc.id;
          allHistory.add(data);
        }
      }

      // Apply final sorting by timestamp (newest first)
      allHistory.sort((a, b) {
        if (a['timestamp'] != null && b['timestamp'] != null) {
          return (b['timestamp'] as Timestamp).compareTo(
            a['timestamp'] as Timestamp,
          );
        }
        return 0;
      });

      setState(() {
        _binHistoryRecords = allHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load bin history: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('MMM d, yyyy HH:mm').format(timestamp.toDate());
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'full':
        return '🔴';
      case 'half-full':
        return '🟠';
      case 'empty':
        return '🟢';
      default:
        return '⚪';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bin History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 1,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter History Records',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Bin ID',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            value: _selectedBinId,
                            items:
                                _availableBinIds.map((String id) {
                                  return DropdownMenuItem<String>(
                                    value: id,
                                    child: Text(id),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedBinId = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Time Range',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            value: _selectedTimeRange,
                            items:
                                _timeRanges.map((String range) {
                                  return DropdownMenuItem<String>(
                                    value: range,
                                    child: Text(range),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTimeRange = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _fetchBinHistory,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    )
                    : _binHistoryRecords.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No history records found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _binHistoryRecords.length,
                      itemBuilder: (context, index) {
                        final record = _binHistoryRecords[index];
                        final status = record['status'] ?? 'Unknown';
                        final timestamp = record['timestamp'] as Timestamp?;
                        final fillLevel =
                            record['fillLevel']?.toString() ?? 'N/A';
                        final binId = record['binId'] ?? 'Unknown';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Bin ID: $binId',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                    Text(
                                      _formatTimestamp(timestamp),
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildInfoCard(
                                        'Status',
                                        '${_getStatusIcon(status)} $status',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildInfoCard(
                                        'Fill Level',
                                        '$fillLevel%',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                record['notes'] != null
                                    ? Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Notes:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(record['notes']),
                                        ],
                                      ),
                                    )
                                    : const SizedBox(),
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

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
