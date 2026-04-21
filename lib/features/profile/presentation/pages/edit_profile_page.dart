import 'package:ebus/features/auth/auth_locator.dart';
import 'package:ebus/features/auth/domain/entities/user_profile.dart';
import 'package:ebus/features/auth/domain/entities/user_role.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  late final Future<UserProfile?> _profileFuture;
  bool _didBindInitialValues = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _profileFuture = AuthLocator.getCurrentUserProfileUseCase();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _bindInitialValues(UserProfile profile) {
    if (_didBindInitialValues) {
      return;
    }
    _fullNameController.text = profile.fullName ?? '';
    _phoneController.text = profile.phone ?? '';
    _avatarUrlController.text = profile.avatarUrl ?? '';
    _bioController.text = profile.bio ?? '';
    _didBindInitialValues = true;
  }

  Future<void> _onSave() async {
    final bool valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    try {
      await AuthLocator.updateCurrentUserProfileUseCase(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        avatarUrl: _avatarUrlController.text,
        bio: _bioController.text,
      );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Profile update failed. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: FutureBuilder<UserProfile?>(
        future: _profileFuture,
        builder: (BuildContext context, AsyncSnapshot<UserProfile?> snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final UserProfile profile =
              snapshot.data ??
              const UserProfile(
                id: '',
                email: 'User',
                role: UserRole.passenger,
                fullName: null,
              );
          _bindInitialValues(profile);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Role: ${profile.role.label}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text('Email: ${profile.email}'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _fullNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'Enter full name',
                        ),
                        validator: (String? value) {
                          if ((value ?? '').trim().isEmpty) {
                            return 'Full name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Phone (Optional)',
                          hintText: '+8801XXXXXXXXX',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _avatarUrlController,
                        keyboardType: TextInputType.url,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Avatar URL (Optional)',
                          hintText: 'https://example.com/avatar.jpg',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _bioController,
                        minLines: 3,
                        maxLines: 5,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          labelText: 'Bio (Optional)',
                          hintText: 'Write short bio',
                        ),
                      ),
                      const SizedBox(height: 18),
                      FilledButton(
                        onPressed: _isSaving ? null : _onSave,
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Profile'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
