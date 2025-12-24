import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_management_app/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final authService = ref.read(authServiceProvider);
    final enabled = await authService.isBiometricEnabled();
    setState(() {
      _biometricEnabled = enabled;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    final authService = ref.read(authServiceProvider);
    final isAvailable = await authService.isBiometricAvailable();

    if (!isAvailable) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biometric authentication not available on this device'),
          ),
        );
      }
      return;
    }

    await authService.setBiometricEnabled(value);
    setState(() {
      _biometricEnabled = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Biometric authentication enabled'
                : 'Biometric authentication disabled',
          ),
        ),
      );
    }
  }

  Future<void> _showBusinessInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final shopName = prefs.getString('shop_name') ?? 'Not set';
    final ownerName = prefs.getString('owner_name') ?? 'Not set';
    final phone = prefs.getString('phone') ?? 'Not set';

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Business Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Shop Name: $shopName'),
              const SizedBox(height: 8),
              Text('Owner: $ownerName'),
              const SizedBox(height: 8),
              Text('Phone: $phone'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text(
              'Business',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.store),
            title: const Text('Business Information'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: _showBusinessInfo,
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Security',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint),
            title: const Text('Biometric Authentication'),
            subtitle: const Text('Use fingerprint or face to login'),
            value: _biometricEnabled,
            onChanged: _toggleBiometric,
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change PIN'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Change PIN logic
            },
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Data',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('Backup Data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Backup logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.restore),
            title: const Text('Restore Data'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Restore logic
            },
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
