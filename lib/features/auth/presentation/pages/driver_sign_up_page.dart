import 'package:ebus/app/router/app_routes.dart';
import 'package:ebus/core/services/navigation_service.dart';
import 'package:ebus/features/auth/auth_locator.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:ebus/features/auth/presentation/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverSignUpPage extends StatefulWidget {
  const DriverSignUpPage({super.key});

  @override
  State<DriverSignUpPage> createState() => _DriverSignUpPageState();
}

class _DriverSignUpPageState extends State<DriverSignUpPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  UserRole _selectedRole = UserRole.passenger;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await AuthLocator.signUpUseCase(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        role: _selectedRole,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Signup successful. Please verify email, then login with selected role.',
          ),
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      await NavigationService.pushReplacementNamed<void, void>(
        AppRoutes.driverLogin,
      );
    } on AuthException catch (error) {
      messenger.showSnackBar(SnackBar(content: Text(error.message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Signup failed. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      icon: Icons.badge_rounded,
      title: 'Create Account',
      subtitle: 'Set up credentials, pick role, then verify from email link.',
      footer: TextButton(
        onPressed: _isLoading ? null : NavigationService.pop,
        child: const Text('Already have an account? Login'),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Role',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<UserRole>(
              showSelectedIcon: false,
              segments: const <ButtonSegment<UserRole>>[
                ButtonSegment<UserRole>(
                  value: UserRole.driver,
                  label: Text('Driver'),
                  icon: Icon(Icons.directions_bus_rounded),
                ),
                ButtonSegment<UserRole>(
                  value: UserRole.passenger,
                  label: Text('Passenger'),
                  icon: Icon(Icons.person_rounded),
                ),
              ],
              selected: <UserRole>{_selectedRole},
              onSelectionChanged: _isLoading
                  ? null
                  : (Set<UserRole> selection) {
                      if (selection.isNotEmpty) {
                        setState(() => _selectedRole = selection.first);
                      }
                    },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _fullNameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                hintText: 'Md. Rahim Uddin',
              ),
              validator: (String? value) {
                if ((value ?? '').trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'driver@ebus.com',
              ),
              validator: (String? value) {
                final String email = (value ?? '').trim();
                if (email.isEmpty) return 'Email is required';
                if (!email.contains('@')) return 'Enter a valid email';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'At least 6 characters',
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (String? value) {
                final String password = (value ?? '').trim();
                if (password.isEmpty) return 'Password is required';
                if (password.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                hintText: 'Re-enter password',
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _obscureConfirmPassword = !_obscureConfirmPassword,
                  ),
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                  ),
                ),
              ),
              validator: (String? value) {
                final String confirmPassword = (value ?? '').trim();
                if (confirmPassword.isEmpty) {
                  return 'Confirm password is required';
                }
                if (confirmPassword != _passwordController.text.trim()) {
                  return 'Passwords do not match';
                }
                return null;
              },
              onFieldSubmitted: (_) => _onSignUp(),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _isLoading ? null : _onSignUp,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }
}
