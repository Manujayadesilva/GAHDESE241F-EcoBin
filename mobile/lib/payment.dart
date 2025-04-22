import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
  final Set<String> selectedBinTypes;

  // Add constructor to receive selected bins
  const PaymentPage({Key? key, required this.selectedBinTypes})
    : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  // Payment method
  String _paymentMethod = 'Credit Card';

  // Success dialog visibility
  bool _showSuccessDialog = false;

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

  // Payment methods
  final List<String> _paymentMethods = ['Credit Card', 'Cash'];

  // Calculate total based on selections
  double calculateTotal() {
    double total = 0.0;
    for (String binId in widget.selectedBinTypes) {
      final selectedBin = _binTypes.firstWhere(
        (bin) => bin['id'] == binId,
        orElse: () => {'price': 0.0},
      );
      total += selectedBin['price'];
    }
    return total;
  }

  // Show success message
  void _showSuccessMessage() {
    setState(() {
      _showSuccessDialog = true;
    });

    // Auto-close after 3 seconds and navigate back
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    double total = calculateTotal();
    bool isCashPayment = _paymentMethod == 'Cash';

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.grey.shade50,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.green.shade600,
            title: const Text('Payment', style: TextStyle(color: Colors.white)),
            leading: CupertinoNavigationBarBackButton(
              color: Colors.white,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment details section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Payment Method Section
                      const Text(
                        'Payment Method:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Payment Method Toggle
                      Row(
                        children:
                            _paymentMethods.map((method) {
                              bool isSelected = _paymentMethod == method;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _paymentMethod = method;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      right: method == 'Credit Card' ? 10 : 0,
                                      left: method == 'Cash' ? 10 : 0,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          isSelected
                                              ? Colors.green.shade50
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            isSelected
                                                ? Colors.green.shade600
                                                : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          method == 'Credit Card'
                                              ? Icons.credit_card
                                              : Icons.money,
                                          color:
                                              isSelected
                                                  ? Colors.green.shade600
                                                  : Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          method,
                                          style: TextStyle(
                                            fontWeight:
                                                isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                            color:
                                                isSelected
                                                    ? Colors.green.shade700
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 30),

                      // Payment Details Form - Only show for Credit Card
                      if (!isCashPayment) ...[
                        const Text(
                          'Payment Details:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Card Details
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            children: [
                              // Card Number
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Card Number',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 15),

                              // Row for expiry and CVV
                              Row(
                                children: [
                                  // Expiry Date
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'Expiry Date',
                                        hintText: 'MM/YY',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 15,
                                            ),
                                      ),
                                      keyboardType: TextInputType.datetime,
                                    ),
                                  ),
                                  const SizedBox(width: 15),

                                  // CVV
                                  Expanded(
                                    child: TextField(
                                      decoration: InputDecoration(
                                        labelText: 'CVV',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 15,
                                              vertical: 15,
                                            ),
                                      ),
                                      keyboardType: TextInputType.number,
                                      obscureText: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),

                              // Name on Card
                              TextField(
                                decoration: InputDecoration(
                                  labelText: 'Name on Card',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        // Cash payment message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.green.shade700,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You will need to pay when the bins are delivered to your location',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

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
                            if (widget.selectedBinTypes.isEmpty) ...[
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
                              ...widget.selectedBinTypes.map((binId) {
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

                      // Payment Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed:
                              widget.selectedBinTypes.isEmpty
                                  ? null
                                  : _showSuccessMessage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isCashPayment ? 'Confirm Order' : 'Pay Now',
                            style: const TextStyle(
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
        ),

        // Success Dialog
        if (_showSuccessDialog)
          Container(
            color: Colors.black54,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.green.shade700,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isCashPayment
                          ? 'Order Confirmed!'
                          : 'Payment Successful!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "Let's make our world greener one bin at a time!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      isCashPayment
                          ? 'Please prepare \$${total.toStringAsFixed(2)} for when your bins are delivered.'
                          : 'Your order has been processed and your bins will be delivered soon.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
