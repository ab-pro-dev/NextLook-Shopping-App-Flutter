import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/success_toast.dart';
import '../application/settings_providers.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isClearingCache = false;

  Future<void> _handleClearCache() async {
    setState(() => _isClearingCache = true);
    await Future.delayed(const Duration(milliseconds: 600));
    await ref.read(cacheServiceProvider).clearImageCache();
    if (mounted) {
      setState(() => _isClearingCache = false);
      AppToast.show(
        context,
        title: 'Cache Cleared',
        subtitle: 'Image cache and temporary storage freed up successfully.',
      );
    }
  }

  void _showInfoSheet({required String title, required String content}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.dark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                content,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? const Color(0xFFCBD5E1) : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final notifSettings = ref.watch(notificationSettingsProvider);
    final biometric = ref.watch(biometricSettingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FC);
    final cardColor = isDark ? const Color(0xFF1E1E2D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2D2D3F) : const Color(0xFFEEEEEE);
    final textColor = isDark ? Colors.white : AppColors.dark;
    final subtitleColor = isDark ? const Color(0xFF94A3B8) : Colors.grey[600];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: cardColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const Key('settings_back_button'),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 20),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. APPEARANCE (Dark / Light Mode)
              _buildSectionTitle('Appearance & Theme', subtitleColor),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose Theme Mode',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select between light, dark, or system preference',
                      style: GoogleFonts.poppins(fontSize: 12, color: subtitleColor),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildThemeOptionCard(
                            key: const Key('settings_theme_light'),
                            icon: Icons.light_mode_rounded,
                            label: 'Light',
                            isSelected: themeMode == ThemeMode.light,
                            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
                            cardColor: cardColor,
                            textColor: textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildThemeOptionCard(
                            key: const Key('settings_theme_dark'),
                            icon: Icons.dark_mode_rounded,
                            label: 'Dark',
                            isSelected: themeMode == ThemeMode.dark,
                            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
                            cardColor: cardColor,
                            textColor: textColor,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildThemeOptionCard(
                            key: const Key('settings_theme_system'),
                            icon: Icons.brightness_auto_rounded,
                            label: 'System',
                            isSelected: themeMode == ThemeMode.system,
                            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
                            cardColor: cardColor,
                            textColor: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 2. NOTIFICATIONS
              _buildSectionTitle('Notifications', subtitleColor),
              const SizedBox(height: 10),
              Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        key: const Key('settings_order_updates_switch'),
                        icon: Icons.local_shipping_outlined,
                        title: 'Order Status & Tracking',
                        subtitle: 'Notifications for order confirmation and shipping milestones',
                        value: notifSettings.orderUpdates,
                        onChanged: (val) =>
                            ref.read(notificationSettingsProvider.notifier).toggleOrderUpdates(val),
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      Divider(height: 1, indent: 56, endIndent: 16, color: borderColor),
                      _buildSwitchTile(
                        key: const Key('settings_promo_switch'),
                        icon: Icons.local_offer_outlined,
                        title: 'Flash Sales & Deals',
                        subtitle: 'Promotional discount alerts and seasonal drops',
                        value: notifSettings.promotions,
                        onChanged: (val) =>
                            ref.read(notificationSettingsProvider.notifier).togglePromotions(val),
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      Divider(height: 1, indent: 56, endIndent: 16, color: borderColor),
                      _buildSwitchTile(
                        key: const Key('settings_new_arrivals_switch'),
                        icon: Icons.new_releases_outlined,
                        title: 'New Arrivals',
                        subtitle: 'Alerts when new curated items arrive in stock',
                        value: notifSettings.newArrivals,
                        onChanged: (val) =>
                            ref.read(notificationSettingsProvider.notifier).toggleNewArrivals(val),
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 3. SECURITY & PRIVACY
              _buildSectionTitle('Security & Preferences', subtitleColor),
              const SizedBox(height: 10),
              Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildSwitchTile(
                        key: const Key('settings_biometric_switch'),
                        icon: Icons.fingerprint_rounded,
                        title: 'Biometric Fast Checkout',
                        subtitle: 'Enable fingerprint or face unlock before payment',
                        value: biometric,
                        onChanged: (val) =>
                            ref.read(biometricSettingProvider.notifier).setBiometricEnabled(val),
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      Divider(height: 1, indent: 56, endIndent: 16, color: borderColor),
                      _buildNavTile(
                        icon: Icons.monetization_on_outlined,
                        title: 'Currency Display',
                        trailingText: 'ETB (Birr)',
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        onTap: () {
                          _showInfoSheet(
                            title: 'Currency Setting',
                            content:
                                'NextLook currently displays prices in Ethiopian Birr (ETB) with automatic formatting and thousands separators across all product and checkout screens.',
                          );
                        },
                      ),
                      Divider(height: 1, indent: 56, endIndent: 16, color: borderColor),
                      _buildNavTile(
                        icon: Icons.language_rounded,
                        title: 'App Language',
                        trailingText: 'English',
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        onTap: () {
                          _showInfoSheet(
                            title: 'Language Preference',
                            content: 'English is currently set as the primary language.',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 4. DATA & STORAGE
              _buildSectionTitle('Data & Storage', subtitleColor),
              const SizedBox(height: 10),
              Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        key: const Key('settings_clear_cache_tile'),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.cleaning_services_rounded,
                              color: AppColors.primary, size: 20),
                        ),
                        title: Text(
                          'Clear Image Cache',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        subtitle: Text(
                          'Frees temporary memory and thumbnail images',
                          style: GoogleFonts.poppins(fontSize: 12, color: subtitleColor),
                        ),
                        trailing: _isClearingCache
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.delete_outline_rounded,
                                color: Colors.redAccent, size: 22),
                        onTap: _isClearingCache ? null : _handleClearCache,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 5. LEGAL & ABOUT
              _buildSectionTitle('Legal & About', subtitleColor),
              const SizedBox(height: 10),
              Material(
                color: cardColor,
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _buildNavTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        onTap: () {
                          _showInfoSheet(
                            title: 'Privacy Policy',
                            content:
                                'NextLook values your privacy. We collect only essential information required for order fulfillment and authentication. Your data is encrypted and securely maintained in accordance with industry security standards.',
                          );
                        },
                      ),
                      Divider(height: 1, indent: 56, endIndent: 16, color: borderColor),
                      _buildNavTile(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                        onTap: () {
                          _showInfoSheet(
                            title: 'Terms of Service',
                            content:
                                'By using NextLook, you agree to our standard terms governing product orders, shipping timelines, returns, and digital customer support.',
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // 6. APP VERSION FOOTER
              Center(
                child: Column(
                  children: [
                    Text(
                      'NextLook Shopping App',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version 1.2.0 (Build 42)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: subtitleColor?.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, Color? color) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: color,
        letterSpacing: 0.4,
      ),
    );
  }

  Widget _buildThemeOptionCard({
    required Key key,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardColor,
    required Color textColor,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color textColor,
    required Color? subtitleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(fontSize: 12, color: subtitleColor),
      ),
      trailing: Switch.adaptive(
        key: key,
        value: value,
        activeColor: AppColors.primary,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
    required Color textColor,
    required Color? subtitleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: subtitleColor,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_right_rounded, color: subtitleColor, size: 22),
        ],
      ),
      onTap: onTap,
    );
  }
}
