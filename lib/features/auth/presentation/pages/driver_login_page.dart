import 'package:ebus/app/router/app_routes.dart';
import 'package:ebus/core/services/navigation_service.dart';
import 'package:ebus/features/auth/auth_locator.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:ebus/features/auth/domain/errors/role_mismatch_exception.dart';
import 'package:ebus/features/auth/presentation/widgets/auth_shell.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DriverLoginPage extends StatefulWidget {
  const DriverLoginPage({super.key});

  @override
  State<DriverLoginPage> createState() => _DriverLoginPageState();
}

class _DriverLoginPageState extends State<DriverLoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  UserRole _selectedRole = UserRole.passenger;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    final bool isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid || _isLoading) {
      return;
    }

    setState(() => _isLoading = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await AuthLocator.loginWithRoleUseCase(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        selectedRole: _selectedRole,
      );

      if (!mounted) return;
      await NavigationService.pushNamedAndRemoveUntil<void>(AppRoutes.home);
    } on RoleMismatchException catch (error) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Role mismatch. Account role is ${error.actualRole.label}.',
          ),
        ),
      );
    } on AuthException catch (error) {
      final String message =
          error.message.toLowerCase().contains('email not confirmed')
          ? 'Email not confirmed. Please check your inbox for the confirmation link.'
          : error.message;
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Login failed. Please try again.')),
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
      icon: Icons.directions_bus_rounded,
      title: 'Login',
      subtitle: 'Choose role and sign in to continue.',
      footer: TextButton(
        onPressed: _isLoading
            ? null
            : () => NavigationService.pushNamed<void>(AppRoutes.driverSignUp),
        child: const Text("Don't have an account? Create one"),
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
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: 'Enter your password',
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
                if ((value ?? '').isEmpty) return 'Password is required';
                return null;
              },
              onFieldSubmitted: (_) => _onLogin(),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _isLoading ? null : _onLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.2),
                    )
                  : const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
