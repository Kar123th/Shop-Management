import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shop_management_app/core/constants/route_constants.dart';
import 'package:shop_management_app/presentation/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final authService = ref.read(authServiceProvider);
    final isBiometricEnabled = await authService.isBiometricEnabled();
    final isPinSet = await authService.isPinSet();

    if (isBiometricEnabled && isPinSet) {
      _authenticateWithBiometric();
    }
  }

  Future<void> _authenticateWithBiometric() async {
    final authService = ref.read(authServiceProvider);
    final authenticated = await authService.authenticateWithBiometrics();

    if (authenticated) {
      await authService.setAuthenticated(true);
      if (mounted) {
        context.go(RouteConstants.dashboard);
      }
    }
  }

  Future<void> _loginWithPin() async {
    if (_pinController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter PIN';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final authService = ref.read(authServiceProvider);
    final isPinSet = await authService.isPinSet();

    if (!isPinSet) {
      // First time setup - save PIN
      await authService.savePin(_pinController.text);
      await authService.setAuthenticated(true);
      if (mounted) {
        context.go(RouteConstants.setup);
      }
    } else {
      // Verify PIN
      final isValid = await authService.verifyPin(_pinController.text);
      if (isValid) {
        await authService.setAuthenticated(true);
        if (mounted) {
          context.go(RouteConstants.dashboard);
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid PIN';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPinSetAsync = ref.watch(isPinSetProvider);
    final isBiometricAvailableAsync = ref.watch(isBiometricAvailableProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: AssetImage('assets/images/logo.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Jaikrishna Traders',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      isPinSetAsync.when(
                        data: (isPinSet) => Text(
                          isPinSet ? 'Welcome Back!' : 'Setup Your Account',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                        ),
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: InputDecoration(
                          labelText: isPinSetAsync.value == true ? 'Enter PIN' : 'Create PIN',
                          hintText: 'Enter 4-6 digit PIN',
                          prefixIcon: const Icon(Icons.lock),
                          errorText: _errorMessage.isEmpty ? null : _errorMessage,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onSubmitted: (_) => _loginWithPin(),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _loginWithPin,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  isPinSetAsync.value == true ? 'Login' : 'Setup',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      isBiometricAvailableAsync.when(
                        data: (isAvailable) {
                          if (isAvailable && isPinSetAsync.value == true) {
                            return TextButton.icon(
                              onPressed: _authenticateWithBiometric,
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('Use Biometric'),
                            );
                          }
                          return const SizedBox();
                        },
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }
}
