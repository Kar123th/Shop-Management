import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsHomeScreen extends ConsumerWidget {
  const ReportsHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: [
          _ReportCard(
            icon: Icons.trending_up,
            title: 'Sales Report',
            color: Colors.green,
            onTap: () {},
          ),
          _ReportCard(
            icon: Icons.shopping_cart,
            title: 'Purchase Report',
            color: Colors.orange,
            onTap: () {},
          ),
          _ReportCard(
            icon: Icons.account_balance_wallet,
            title: 'Profit & Loss',
            color: Colors.blue,
            onTap: () {},
          ),
          _ReportCard(
            icon: Icons.receipt_long,
            title: 'GST Report',
            color: Colors.purple,
            onTap: () {},
          ),
          _ReportCard(
            icon: Icons.inventory,
            title: 'Stock Report',
            color: Colors.teal,
            onTap: () {},
          ),
          _ReportCard(
            icon: Icons.people,
            title: 'Party Outstanding',
            color: Colors.red,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
