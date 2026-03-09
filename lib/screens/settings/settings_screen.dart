import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Text(
                  'Settings',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              // Profile section
              Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final user = authProvider.user;
                  final profile = authProvider.userProfile;
                  final isVerified = authProvider.isEmailVerified;

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppTheme.dividerColor.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              (profile?.displayName ?? user?.email ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          profile?.displayName ??
                              user?.displayName ??
                              'User',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isVerified
                                    ? AppTheme.successGreen.withOpacity(0.15)
                                    : AppTheme.accentGold.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isVerified
                                        ? Icons.verified
                                        : Icons.warning_amber_rounded,
                                    color: isVerified
                                        ? AppTheme.successGreen
                                        : AppTheme.accentGold,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isVerified ? 'Verified account' : 'Not verified',
                                    style: TextStyle(
                                      color: isVerified
                                          ? AppTheme.successGreen
                                          : AppTheme.accentGold,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Settings list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferences',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Notification toggle
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        return _buildSettingTile(
                          icon: Icons.notifications_outlined,
                          title: 'Location Notifications',
                          subtitle:
                              'Get notified about nearby services',
                          trailing: Switch(
                            value: settings.locationNotifications,
                            onChanged: (value) {
                              settings
                                  .setLocationNotifications(value);
                              // Also update in Firestore
                              context
                                  .read<AuthProvider>()
                                  .updateNotificationPreference(
                                      value);
                            },
                            activeColor: AppTheme.accentGold,
                            activeTrackColor:
                                AppTheme.accentGold.withOpacity(0.3),
                            inactiveThumbColor: AppTheme.textMuted,
                            inactiveTrackColor:
                                AppTheme.dividerColor,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Bookmarks toggle (UI matching the screenshot)
                    Consumer<SettingsProvider>(
                      builder: (context, settings, _) {
                        return _buildSettingTile(
                          icon: Icons.bookmark_outline,
                          title: 'Bookmarks',
                          subtitle: 'Save places for quick access',
                          trailing: Switch(
                            value: true,
                            onChanged: (value) {},
                            activeColor: AppTheme.accentGold,
                            activeTrackColor:
                                AppTheme.accentGold.withOpacity(0.3),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Account',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Privacy
                    _buildSettingTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      subtitle: 'Manage your data',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textMuted,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),

                    // Help
                    _buildSettingTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      subtitle: 'FAQs and contact us',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textMuted,
                      ),
                      onTap: () {},
                    ),
                    const SizedBox(height: 8),

                    // About
                    _buildSettingTile(
                      icon: Icons.info_outline,
                      title: 'About',
                      subtitle: 'Version 1.0.0',
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: AppTheme.textMuted,
                      ),
                      onTap: () {},
                    ),

                    const SizedBox(height: 32),

                    // Sign out button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showSignOutDialog(context),
                        icon: const Icon(
                          Icons.logout,
                          size: 20,
                          color: AppTheme.errorRed,
                        ),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                            color: AppTheme.errorRed,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppTheme.errorRed,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.dividerColor.withOpacity(0.5),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.accentGold, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
