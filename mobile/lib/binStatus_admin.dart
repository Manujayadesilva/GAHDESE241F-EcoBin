import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class BinStatusPage extends StatefulWidget {
  @override
  _BinStatusPageState createState() => _BinStatusPageState();
}

class _BinStatusPageState extends State<BinStatusPage> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance
      .ref()
      .child('wasteBins');
  List<BinData> _binsList = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBinStatus();
  }

  void _fetchBinStatus() {
    try {
      _databaseReference.onValue.listen(
        (event) {
          if (event.snapshot.value != null) {
            final Map<dynamic, dynamic> bins =
                event.snapshot.value as Map<dynamic, dynamic>;

            setState(() {
              _binsList =
                  bins.entries.map((entry) {
                    return BinData(
                      id: entry.key,
                      location: entry.value['location'] ?? 'Unknown Location',
                      status: entry.value['status'] ?? 'Unknown',
                      wasteLevel: (entry.value['wasteLevel'] ?? 0).toDouble(),
                      nfcAccess: entry.value['nfcAccess'] ?? 'No Access',
                      lat: (entry.value['lat'] ?? 0.0).toDouble(),
                      lng: (entry.value['lng'] ?? 0.0).toDouble(),
                    );
                  }).toList();

              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
              _errorMessage = 'No bins found';
            });
          }
        },
        onError: (error) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Error fetching bin data: ${error.toString()}';
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An unexpected error occurred';
      });
    }
  }

  Color get _primaryColor => Colors.green.shade600;
  Color get _backgroundColor => Colors.white;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Bin Monitoring', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: _primaryColor, // Using the green color defined earlier
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(color: Colors.teal.shade300),
              )
              : _errorMessage.isNotEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.teal.shade300,
                      size: 80,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : _binsList.isEmpty
              ? Center(
                child: Text(
                  'No Waste Bins Available',
                  style: TextStyle(color: Colors.black54, fontSize: 18),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  children: [
                    // Pie Chart for Bin Fill Levels
                    _buildFillLevelsPieChart(),

                    // Bar Chart for Waste Levels by Location
                    _buildWasteLevelsByLocationChart(),

                    // Existing ListView of Bin Status Cards
                    ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      itemCount: _binsList.length,
                      separatorBuilder:
                          (context, index) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _BinStatusCard(bin: _binsList[index]);
                      },
                    ),
                  ],
                ),
              ),
    );
  }

  // Pie Chart for Fill Levels
  Widget _buildFillLevelsPieChart() {
    // Categorize bins by fill level
    int lowCount = _binsList.where((bin) => bin.wasteLevel <= 39).length;
    int mediumCount =
        _binsList
            .where((bin) => bin.wasteLevel > 39 && bin.wasteLevel <= 74)
            .length;
    int highCount = _binsList.where((bin) => bin.wasteLevel > 74).length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Bin Fill Levels',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SfCircularChart(
                series: <CircularSeries>[
                  PieSeries<Map<String, dynamic>, String>(
                    dataSource: [
                      {
                        'category': 'Low',
                        'count': lowCount,
                        'color': Colors.green,
                      },
                      {
                        'category': 'Medium',
                        'count': mediumCount,
                        'color': Colors.orange,
                      },
                      {
                        'category': 'High',
                        'count': highCount,
                        'color': Colors.red,
                      },
                    ],
                    pointColorMapper: (datum, _) => datum['color'],
                    xValueMapper: (datum, _) => datum['category'],
                    yValueMapper: (datum, _) => datum['count'],
                    dataLabelSettings: DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                  ),
                ],
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Bar Chart for Waste Levels by Location
  Widget _buildWasteLevelsByLocationChart() {
    // Group waste levels by location
    Map<String, double> locationWasteLevels = {};
    for (var bin in _binsList) {
      locationWasteLevels[bin.location] = bin.wasteLevel;
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Waste Levels by Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                series: <CartesianSeries>[
                  BarSeries<MapEntry<String, double>, String>(
                    dataSource: locationWasteLevels.entries.toList(),
                    xValueMapper: (entry, _) => entry.key,
                    yValueMapper: (entry, _) => entry.value,
                    color: Colors.blue.shade600,
                    dataLabelMapper:
                        (entry, _) => '${entry.value.toStringAsFixed(1)}%',
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
                tooltipBehavior: TooltipBehavior(enable: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Existing BinData and _BinStatusCard classes remain the same
class BinData {
  final String id;
  final String location;
  final String status;
  final double wasteLevel;
  final String nfcAccess;
  final double lat;
  final double lng;

  BinData({
    required this.id,
    required this.location,
    required this.status,
    required this.wasteLevel,
    required this.nfcAccess,
    required this.lat,
    required this.lng,
  });
}

class _BinStatusCard extends StatelessWidget {
  final BinData bin;

  const _BinStatusCard({required this.bin});

  Color _getStatusColor() {
    switch (bin.status.toLowerCase()) {
      case 'low':
        return Colors.green.shade500;
      case 'medium':
        return Colors.orange.shade500;
      case 'high':
        return Colors.red.shade500;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          bin.id,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bin.location, style: TextStyle(color: Colors.black54)),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Waste Level: ${bin.wasteLevel.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Status: ${bin.status}',
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'NFC: ${bin.nfcAccess}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Text(
              'Lat: ${bin.lat.toStringAsFixed(5)}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
            Text(
              'Lng: ${bin.lng.toStringAsFixed(5)}',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
