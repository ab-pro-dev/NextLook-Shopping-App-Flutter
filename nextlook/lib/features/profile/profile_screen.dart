import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/sign_in_required_view.dart';
import '../auth/application/auth_providers.dart';
import '../auth/data/user_model.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const backgroundColor = Color(0xFFF8F9FC);
    final authState = ref.watch(authControllerProvider);

    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SignInRequiredView(
            title: 'Sign In Required',
            message: 'Sign in to manage your profile, addresses, and account settings.',
            icon: Icons.person_outline_rounded,
          ),
        ),
      );
    }

    final user = authState.user;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title
              Text(
                'Profile',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 20),

              // User Info Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEEEEEE)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildAvatar(user),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Account Options Header
              Text(
                'Account Options',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),

              // Options Card
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    children: [
                      _buildOptionRow(
                        key: const Key('profile_edit_profile_tile'),
                        icon: Icons.person_outline_rounded,
                        label: 'Edit Profile',
                        onTap: () => context.push('/profile/edit'),
                      ),
                      _buildOptionRow(
                        key: const Key('profile_my_addresses_tile'),
                        icon: Icons.location_on_outlined,
                        label: 'My Addresses',
                        onTap: () => context.push('/addresses'),
                      ),
                      _buildOptionRow(
                        key: const Key('profile_my_orders_tile'),
                        icon: Icons.local_shipping_outlined,
                        label: 'My Orders',
                        onTap: () => context.push('/orders'),
                      ),
                      _buildOptionRow(
                        key: const Key('profile_wishlist_tile'),
                        icon: Icons.favorite_outline_rounded,
                        label: 'Wishlist',
                        onTap: () => context.push('/wishlist'),
                      ),
                      _buildOptionRow(
                        key: const Key('profile_notifications_tile'),
                        icon: Icons.notifications_none_rounded,
                        label: 'Notifications',
                        onTap: () => context.push('/notifications'),
                      ),
                      _buildOptionRow(
                        key: const Key('profile_settings_tile'),
                        icon: Icons.settings_outlined,
                        label: 'Settings',
                        onTap: () => context.push('/settings-mobile'),
                        isLast: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  key: const Key('profile_logout_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withValues(alpha: 0.1),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: Text(
                    'Log Out',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(User user) {
    final hasAvatar = user.avatarUrl != null && user.avatarUrl!.trim().isNotEmpty;
    if (hasAvatar) {
      return CircleAvatar(
        radius: 30,
        backgroundColor: AppColors.primary.withValues(alpha: 0.1),
        backgroundImage: NetworkImage(user.avatarUrl!),
        onBackgroundImageError: (_, __) {},
      );
    }
    return CircleAvatar(
      radius: 30,
      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      child: Text(
        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildOptionRow({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          key: key,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          title: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.dark,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey,
            size: 22,
          ),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, indent: 64, endIndent: 16, color: Color(0xFFEEEEEE)),
      ],
    );
  }
}
