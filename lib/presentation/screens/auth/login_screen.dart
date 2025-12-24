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

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 24.0)
        .chain(CurveTween(curve: Curves.elasticIn))
        .animate(_shakeController);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _pinController.dispose();
    super.dispose();
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
      _shakeController.forward(from: 0.0);
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
      if (_pinController.text.length < 4) {
         setState(() {
          _errorMessage = 'PIN must be 4-6 digits';
          _isLoading = false;
        });
        _shakeController.forward(from: 0.0);
        return;
      }
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
        _shakeController.forward(from: 0.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPinSetAsync = ref.watch(isPinSetProvider);
    final isBiometricAvailableAsync = ref.watch(isBiometricAvailableProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedBuilder(
                animation: _shakeController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_shakeAnimation.value * (_shakeController.value <= 0.5 ? 1 : -1), 0), // Simple shake
                    child: child,
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 150,
                        height: 150,
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
}

