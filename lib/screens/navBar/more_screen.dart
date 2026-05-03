import 'package:bag_flow/providers/auth_provider.dart';
import 'package:bag_flow/providers/expense_provider.dart';
import 'package:bag_flow/screens/credentials/forgotPassword.dart';
import 'package:bag_flow/utils/bottom_nav_handler.dart';
import 'package:bag_flow/widgets/layouts/fixed_appBar.dart';
import 'package:bag_flow/widgets/layouts/fixed_bottomNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MoreScreen extends ConsumerStatefulWidget {
  const MoreScreen({super.key});

  @override
  ConsumerState<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends ConsumerState<MoreScreen> {
  int _currentIndex = 4;
  bool _keepSignedIn = true;
  bool _loadingPrefs = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = ref.read(preferencesServiceProvider);
    final keepSignedIn = await prefs.getKeepSignedIn();

    if (!mounted) return;

    setState(() {
      _keepSignedIn = keepSignedIn;
      _loadingPrefs = false;
    });
  }

  // Keep signed me in if turned on
  Future<void> _updateKeepSignedIn(bool value) async {
    setState(() => _keepSignedIn = value);
    await ref.read(preferencesServiceProvider).setKeepSignedIn(value);
  }

  // Logout pop up button
  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out of Bag Flow?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    // For false and null cases
    if (confirm != true) return;

    await ref.read(authServiceProvider).signOut();
  }

  Future<void> _exportData() async {
    final user = ref.read(authServiceProvider).currentUser;

    if (user == null) {
      _showMessage('Please log in first');
      return;
    }

    final expenses = await ref.read(expenseServiceProvider).getAllExpenses(user.uid);

    if (!mounted) return;

    _showMessage('Found ${expenses.length} expenses to export. CSV export comes next.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _comingSoon(String feature) {
    _showMessage('$feature coming soon');
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final user = ref.watch(authServiceProvider).currentUser;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: GradientAppBar(
        title: 'More',
        onMenuTap: () {},
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User profile coming from Firestore
              profileAsync.when(
                // When data is successfully loaded, run the following
                data: (profile) {
                  // Get full name and email from Firestore
                  final name = profile?['fullName'] ?? 'User';
                  final email = profile?['email'] ?? user?.email ?? 'No email found';

                  return _profileCard(
                    name: name.toString(),
                    email: email.toString(),
                  );
                },

                // Loading state of profile card
                loading: () => _profileCard(
                  name: 'Loading...',
                  email: 'Fetching profile',
                ),

                // Error state of profile card
                error: (_, __) => _profileCard(
                  name: 'Invalid User',
                  email: user?.email ?? 'Profile unavailable',
                ),
              ),

              const SizedBox(height: 22),

              // Account section
              _sectionTitle('Account'),
              _settingsCard([
                _settingsTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update your name and account details',
                  onTap: () => _comingSoon('Edit profile'),
                ),
                _settingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Reset Password',
                  subtitle: 'Send yourself a password reset link',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgotPassword(),
                      ),
                    );
                  },
                ),
              ]),

              const SizedBox(height: 18),

              // Preferences Section
              _sectionTitle('Preferences'),
              _settingsCard([
                _switchTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Keep me signed in',
                  subtitle: 'Stay logged in on this device',
                  value: _keepSignedIn,
                  loading: _loadingPrefs,
                  onChanged: _updateKeepSignedIn,
                ),
                _settingsTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Budget reminders and spending alerts',
                  onTap: () => _comingSoon('Notifications'),
                ),
              ]),

              const SizedBox(height: 18),

              // Data section
              _sectionTitle('Data'),
              _settingsCard([
                _settingsTile(
                  icon: Icons.file_download_outlined,
                  title: 'Export Data',
                  subtitle: 'Download your expenses later',
                  onTap: _exportData,
                ),
                _settingsTile(
                  icon: Icons.delete_outline_rounded,
                  title: 'Clear Data',
                  subtitle: 'Remove all saved expenses',
                  danger: true,
                  onTap: () => _comingSoon('Clear data'),
                ),
              ]),

              const SizedBox(height: 18),

              // Support Section
              _sectionTitle('Support'),
              _settingsCard([
                _settingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & FAQ',
                  subtitle: 'Get answers and support',
                  onTap: () => _comingSoon('Help'),
                ),
                _settingsTile(
                  icon: Icons.info_outline_rounded,
                  title: 'About Bag Flow',
                  subtitle: 'Version 1.0.0',
                  onTap: () => _comingSoon('About'),
                ),
              ]),

              const SizedBox(height: 22),

              _logoutButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          await handleBottomNavTap(
            context: context,
            index: index,
            currentIndex: _currentIndex,
            setIndex: (i) => setState(() => _currentIndex = i),
          );
        },
      ),
    );
  }

  Widget _profileCard({
    required String name,
    required String email,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.12),
            blurRadius: 24,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF3B82F6).withOpacity(0.18),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF93C5FD),
              size: 34,
            ),
          ),
          const SizedBox(width: 16),

          // Name and email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,

                  // If name is too long, truncate and show "..." instead of wrapping
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Format section title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // Format settings card to contain children
  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool danger = false,
  }) {
    final color = danger ? const Color(0xFFFF6B6B) : Colors.white;

    return ListTile(
      onTap: onTap,
      leading: _iconBubble(
        icon,
        danger ? const Color(0xFFFF6B6B) : const Color(0xFF3B82F6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white60),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Colors.white38,
      ),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,

    // Current ON/OFF state of the switch
    required bool value,

    // Whether the setting is still being loaded
    required bool loading,

    // Callback when user toggles switch
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      // Left-side icon wrapped in custom styled container
      leading: _iconBubble(icon, const Color(0xFF8B5CF6)),

      // Main title text (primary label for the setting)
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),

      // Secondary description text (explains what the setting does)
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white60),
      ),

      // Right-side widget: shows loading spinner OR switch
      trailing: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Switch(
              value: value,
              onChanged: onChanged,
              activeColor: const Color(0xFF3B82F6),
            ),
    );
  }

  // Formats icons that are displayed
  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 43,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }

  // Formats log out button
  Widget _logoutButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        label: const Text(
          'Log Out',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFFF6B6B),
          side: const BorderSide(color: Color(0xFFFF6B6B)),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}