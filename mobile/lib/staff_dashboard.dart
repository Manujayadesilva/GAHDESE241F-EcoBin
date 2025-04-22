import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

// Models
class BinOrder {
  final String id;
  final String customerName;
  final String address;
  final bool isPaid;
  final double price;
  final DateTime orderDate;
  final OrderStatus status;

  BinOrder({
    required this.id,
    required this.customerName,
    required this.address,
    required this.isPaid,
    required this.price,
    required this.orderDate,
    this.status = OrderStatus.pending,
  });
}

enum OrderStatus { pending, inProgress, completed, cancelled }

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({Key? key}) : super(key: key);

  @override
  _StaffDashboardState createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const BinOrdersPage(),
    const StaffActivitiesPage(),
    const SalaryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staff Dashboard'),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.delete_outline),
            label: 'Bin Orders',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Activities'),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on),
            label: 'Salary',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF2E7D32),
        onTap: _onItemTapped,
      ),
    );
  }
}

class BinOrdersPage extends StatefulWidget {
  const BinOrdersPage({Key? key}) : super(key: key);

  @override
  _BinOrdersPageState createState() => _BinOrdersPageState();
}

class _BinOrdersPageState extends State<BinOrdersPage> {
  final List<BinOrder> _binOrders = [
    BinOrder(
      id: 'BO001',
      customerName: 'John Doe',
      address: '123 Green Street',
      isPaid: true,
      price: 150.00,
      orderDate: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.pending,
    ),
    BinOrder(
      id: 'BO002',
      customerName: 'Jane Smith',
      address: '456 Eco Avenue',
      isPaid: false,
      price: 200.00,
      orderDate: DateTime.now().subtract(const Duration(days: 3)),
      status: OrderStatus.inProgress,
    ),
    BinOrder(
      id: 'BO003',
      customerName: 'Mike Johnson',
      address: '789 Recycle Lane',
      isPaid: true,
      price: 175.50,
      orderDate: DateTime.now().subtract(const Duration(days: 7)),
      status: OrderStatus.completed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            labelColor: const Color(0xFF2E7D32),
            tabs: [
              Tab(text: 'All Orders'),
              Tab(text: 'Paid'),
              Tab(text: 'Unpaid'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOrderList(_binOrders),
                _buildOrderList(
                  _binOrders.where((order) => order.isPaid).toList(),
                ),
                _buildOrderList(
                  _binOrders.where((order) => !order.isPaid).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<BinOrder> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              order.customerName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(order.address),
                Text(
                  'Order Date: ${DateFormat('dd MMM yyyy').format(order.orderDate)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${order.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: order.isPaid ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.isPaid ? 'Paid' : 'Unpaid',
                  style: TextStyle(
                    color: order.isPaid ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            onTap: () => _showOrderDetails(order),
          ),
        );
      },
    );
  }

  void _showOrderDetails(BinOrder order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Details - ${order.id}'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Customer: ${order.customerName}'),
              Text('Address: ${order.address}'),
              Text(
                'Order Date: ${DateFormat('dd MMM yyyy').format(order.orderDate)}',
              ),
              Text('Price: \$${order.price.toStringAsFixed(2)}'),
              Text('Payment Status: ${order.isPaid ? 'Paid' : 'Unpaid'}'),
              Text(
                'Current Status: ${order.status.toString().split('.').last}',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

class StaffActivitiesPage extends StatefulWidget {
  const StaffActivitiesPage({Key? key}) : super(key: key);

  @override
  _StaffActivitiesPageState createState() => _StaffActivitiesPageState();
}

class _StaffActivitiesPageState extends State<StaffActivitiesPage> {
  final List<Map<String, dynamic>> _activities = [
    {
      'title': 'Weekly Route Planning',
      'description': 'Plan bin collection routes for the upcoming week',
      'status': 'Pending',
      'dueDate': DateTime.now().add(const Duration(days: 3)),
    },
    {
      'title': 'Customer Bin Delivery',
      'description': 'Deliver 10 new recycling bins to residential area',
      'status': 'In Progress',
      'dueDate': DateTime.now().add(const Duration(days: 1)),
    },
    {
      'title': 'Monthly Reporting',
      'description': 'Compile recycling statistics for management',
      'status': 'Completed',
      'dueDate': DateTime.now().subtract(const Duration(days: 5)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _activities.length,
      itemBuilder: (context, index) {
        final activity = _activities[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            title: Text(
              activity['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(activity['description']),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Due: ${DateFormat('dd MMM yyyy').format(activity['dueDate'])}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  activity['status'],
                  style: TextStyle(
                    color: _getStatusColor(activity['status']),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

class SalaryPage extends StatelessWidget {
  const SalaryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSalaryCard(),
            const SizedBox(height: 20),
            _buildSalaryBreakdown(),
            const SizedBox(height: 20),
            _buildPaymentHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildSalaryCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Monthly Salary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '\$4,500.00',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip('Base Salary', '\$4,000'),
                _buildInfoChip('Bonus', '\$500'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Chip(
      label: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
      backgroundColor: Colors.green.shade50,
    );
  }

  Widget _buildSalaryBreakdown() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Salary Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            _buildBreakdownRow('Base Salary', '\$4,000'),
            _buildBreakdownRow('Performance Bonus', '\$500'),
            _buildBreakdownRow('Tax Deduction', '-\$600'),
            const Divider(),
            _buildBreakdownRow('Net Salary', '\$3,900', isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(
    String label,
    String amount, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.green : Colors.black,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            _buildPaymentRow('January 2024', '\$3,900', true),
            _buildPaymentRow('December 2023', '\$3,900', true),
            _buildPaymentRow('November 2023', '\$3,900', true),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String month, String amount, bool isPaid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(month, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(
                amount,
                style: TextStyle(color: isPaid ? Colors.green : Colors.red),
              ),
              const SizedBox(width: 10),
              Icon(
                isPaid ? Icons.check_circle : Icons.cancel,
                color: isPaid ? Colors.green : Colors.red,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
