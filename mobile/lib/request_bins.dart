import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// Import this at the top of your file
import 'payment.dart'; // Ensure this points to your PaymentPage file

class BinRequestPage extends StatefulWidget {
  const BinRequestPage({Key? key}) : super(key: key);

  @override
  _BinRequestPageState createState() => _BinRequestPageState();
}

class _BinRequestPageState extends State<BinRequestPage> {
  // Selected bin types (multiple selection)
  Set<String> _selectedBinTypes = {};

  // Bin types with prices and descriptions
  final List<Map<String, dynamic>> _binTypes = [
    {
      'id': 'recycling',
      'name': 'Recycling Bin',
      'price': 25.00,
      'description': 'For paper, plastic, and recyclable materials',
      'color': Colors.blue.shade500,
      'icon': Icons.delete_outline,
    },
    {
      'id': 'general',
      'name': 'General Waste Bin',
      'price': 30.00,
      'description': 'For general household waste',
      'color': Colors.grey.shade700,
      'icon': Icons.delete,
    },
    {
      'id': 'compost',
      'name': 'Compost Bin',
      'price': 20.00,
      'description': 'For organic and compostable waste',
      'color': Colors.green.shade600,
      'icon': Icons.eco,
    },
    {
      'id': 'hazardous',
      'name': 'Hazardous Waste Bin',
      'price': 40.00,
      'description': 'For batteries, chemicals, and hazardous materials',
      'color': Colors.red.shade600,
      'icon': Icons.warning_amber,
    },
  ];

  // Calculate total based on selections
  double calculateTotal() {
    double total = 0.0;
    for (String binId in _selectedBinTypes) {
      final selectedBin = _binTypes.firstWhere(
        (bin) => bin['id'] == binId,
        orElse: () => {'price': 0.0},
      );
      total += selectedBin['price'];
    }
    return total;
  }

  // Navigate to payment page
  void _navigateToPayment() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentPage(selectedBinTypes: _selectedBinTypes),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double total = calculateTotal();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.green.shade600,
        leading: CupertinoNavigationBarBackButton(
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Request Bins',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header

            // Bin Type Selection
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Choose bin types:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Select multiple',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  // Bin Options
                  ..._binTypes.map((bin) => _buildBinOption(bin)),

                  const SizedBox(height: 30),

                  // Order Summary
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Order Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Selected Bins
                        if (_selectedBinTypes.isEmpty) ...[
                          const Center(
                            child: Text(
                              'No bins selected',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Selected Bins:',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),

                          // List of selected bins
                          ..._selectedBinTypes.map((binId) {
                            final bin = _binTypes.firstWhere(
                              (b) => b['id'] == binId,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '• ${bin['name']}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    '\$${bin['price'].toStringAsFixed(2)}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],

                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Submit Request Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed:
                          _selectedBinTypes.isEmpty ? null : _navigateToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Proceed to Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

  Widget _buildBinOption(Map<String, dynamic> bin) {
    final bool isSelected = _selectedBinTypes.contains(bin['id']);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedBinTypes.remove(bin['id']);
          } else {
            _selectedBinTypes.add(bin['id']);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? bin['color'] : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: bin['color'].withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                  : [],
        ),
        child: Row(
          children: [
            // Colored icon section
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                color: bin['color'].withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
              child: Icon(bin['icon'], color: bin['color'], size: 30),
            ),

            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          bin['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${bin['price'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      bin['description'],
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Selection indicator
            Padding(
              padding: const EdgeInsets.all(15),
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? bin['color'] : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bin['color'],
                          ),
                        )
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
