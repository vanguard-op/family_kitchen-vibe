import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';
import '../widgets/input_field.dart';
import '../widgets/loading_button.dart';

/// Signup screen for user registration
class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;
  String _passwordStrengthMessage = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _passwordController.addListener(_updatePasswordStrength);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _updatePasswordStrength() {
    if (_passwordController.text.isEmpty) {
      setState(() => _passwordStrengthMessage = '');
      return;
    }

    final strength = FormValidators.getPasswordStrength(_passwordController.text);
    setState(() {
      _passwordStrengthMessage = strength['message'] as String;
    });
  }

  Color _getStrengthColor(String message) {
    switch (message) {
      case 'Weak':
        return Colors.red;
      case 'Fair':
        return Colors.orange;
      case 'Good':
        return Colors.yellow[700]!;
      case 'Strong':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final matchError = FormValidators.validatePasswordMatch(
      _passwordController.text,
      _confirmPasswordController.text,
    );
    if (matchError != null) {
      setState(() => _errorMessage = matchError);
      return;
    }

    try {
      setState(() => _errorMessage = null);
      final authProvider = context.read<AuthProvider>();
      await authProvider.signup(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/kingdom-setup');
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(UIConstants.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(
              Icons.restaurant,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Create Your Kingdom',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 32),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(UIConstants.paddingMedium),
                margin: const EdgeInsets.only(bottom: UIConstants.paddingMedium),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
                  border: Border.all(color: Colors.red[400]!),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red[900]),
                ),
              ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  InputField(
                    controller: _emailController,
                    labelText: 'Email',
                    hintText: 'user@example.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: FormValidators.validateEmail,
                  ),
                  const SizedBox(height: UIConstants.paddingMedium),
                  InputField(
                    controller: _passwordController,
                    labelText: 'Password',
                    hintText: 'SecurePass123!',
                    obscureText: _obscurePassword,
                    validator: FormValidators.validatePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  if (_passwordStrengthMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: UIConstants.paddingSmall),
                      child: Text(
                        'Strength: $_passwordStrengthMessage',
                        style: TextStyle(
                          color: _getStrengthColor(_passwordStrengthMessage),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: UIConstants.paddingMedium),
                  InputField(
                    controller: _confirmPasswordController,
                    labelText: 'Confirm Password',
                    hintText: 'SecurePass123!',
                    obscureText: _obscureConfirm,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscureConfirm = !_obscureConfirm);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.paddingLarge),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return LoadingButton(
                  isLoading: authProvider.isLoading,
                  onPressed: _handleSignup,
                  label: 'Sign Up',
                );
              },
            ),
            const SizedBox(height: UIConstants.paddingMedium),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/login'),
                  child: Text(
                    'Login',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
