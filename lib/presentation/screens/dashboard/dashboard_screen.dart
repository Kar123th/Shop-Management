import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shop_management_app/core/constants/route_constants.dart';
import 'package:shop_management_app/presentation/providers/auth_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteConstants.settings),
          ),
        ],
      ),
      drawer: _buildDrawer(context, ref),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
          await Future.delayed(const Duration(seconds: 1));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Summary
              Text(
                'Today\'s Summary',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Sales',
                      value: currencyFormat.format(0),
                      icon: Icons.trending_up,
                      color: Colors.green,
                      onTap: () => context.push(RouteConstants.sales),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Purchases',
                      value: currencyFormat.format(0),
                      icon: Icons.shopping_cart,
                      color: Colors.orange,
                      onTap: () => context.push(RouteConstants.purchases),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Cash in Hand',
                      value: currencyFormat.format(0),
                      icon: Icons.account_balance_wallet,
                      color: Colors.blue,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Bank Balance',
                      value: currencyFormat.format(0),
                      icon: Icons.account_balance,
                      color: Colors.purple,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Outstanding
              Text(
                'Outstanding',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _OutstandingCard(
                      title: 'To Collect',
                      amount: currencyFormat.format(0),
                      subtitle: 'From Customers',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _OutstandingCard(
                      title: 'To Pay',
                      amount: currencyFormat.format(0),
                      subtitle: 'To Suppliers',
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _QuickActionCard(
                    icon: Icons.receipt_long,
                    label: 'New Sale',
                    color: Colors.green,
                    onTap: () => context.push(RouteConstants.newInvoice),
                  ),
                  _QuickActionCard(
                    icon: Icons.shopping_bag,
                    label: 'New Purchase',
                    color: Colors.orange,
                    onTap: () => context.push(RouteConstants.newPurchase),
                  ),
                  _QuickActionCard(
                    icon: Icons.inventory,
                    label: 'Products',
                    color: Colors.blue,
                    onTap: () => context.push(RouteConstants.products),
                  ),
                  _QuickActionCard(
                    icon: Icons.people,
                    label: 'Parties',
                    color: Colors.purple,
                    onTap: () => context.push(RouteConstants.parties),
                  ),
                  _QuickActionCard(
                    icon: Icons.money_off,
                    label: 'Expenses',
                    color: Colors.red,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    icon: Icons.bar_chart,
                    label: 'Reports',
                    color: Colors.teal,
                    onTap: () => context.push(RouteConstants.reports),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Low Stock Alert
              Card(
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: const Text('Low Stock Alert'),
                  subtitle: const Text('0 items running low'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => context.push(RouteConstants.lowStock),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                  backgroundColor: Colors.white,
                ),
                SizedBox(height: 8),
                Text(
                  'Jaikrishna Traders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.inventory),
            title: const Text('Products'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.products);
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: const Text('Sales'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.sales);
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Purchases'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.purchases);
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Parties'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.parties);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Reports'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.reports);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.push(RouteConstants.settings);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              final authService = ref.read(authServiceProvider);
              await authService.logout();
              if (context.mounted) {
                context.go(RouteConstants.login);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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

class _OutstandingCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final Color color;

  const _OutstandingCard({
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
