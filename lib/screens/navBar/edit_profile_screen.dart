import 'package:bag_flow/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _photoController = TextEditingController();

  bool _isSaving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final user = ref.read(authServiceProvider).currentUser;

    if (user == null) return;

    final name = _nameController.text.trim();
    final photoUrl = _photoController.text.trim();

    if (name.isEmpty) {
      _showMessage('Name cannot be empty');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await ref.read(userServiceProvider).updateUserProfile(
            uid: user.uid,
            fullName: name,
            photoUrl: photoUrl.isEmpty ? null : photoUrl,
          );

      await user.updateDisplayName(name);

      if (photoUrl.isNotEmpty) {
        await user.updatePhotoURL(photoUrl);
      }

      if (!mounted) return;

      _showMessage('Profile updated');
      Navigator.pop(context);
    } catch (e) {
      _showMessage('Could not update profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (!_loaded) {
              _nameController.text =
                  (profile?['fullName'] ?? user?.displayName ?? '').toString();

              _photoController.text =
                  (profile?['photoUrl'] ?? user?.photoURL ?? '').toString();

              _loaded = true;
            }

            final photoUrl = _photoController.text.trim();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 54,
                      backgroundColor: const Color(0xFF3B82F6).withOpacity(0.25),
                      backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                      child: photoUrl.isEmpty
                          ? const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 58,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Profile Image URL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _photoController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Paste image URL',
                      hintStyle: TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.image_outlined),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Full Name',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: Colors.black54),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    enabled: false,
                    controller: TextEditingController(
                      text: user?.email ?? profile?['email'] ?? 'No email found',
                    ),
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white70,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              'Error: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}