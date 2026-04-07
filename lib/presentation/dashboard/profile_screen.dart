import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/network/api_client.dart';
import '../../presentation/auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _ProfileHeader(context: context)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: _ProfileCard(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                'Account & Security',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsSection(items: const [
                _SettingItem(icon: Icons.security_rounded, label: 'Account Security', trailing: null),
                _SettingItem(icon: Icons.download_rounded, label: 'Export Data', trailing: null),
              ]),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Text(
                'Preferences',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SettingsSection(items: const [
                _SettingItem(icon: Icons.notifications_rounded, label: 'Billing Reminders', trailing: null),
                _SettingItem(icon: Icons.campaign_rounded, label: 'Notification Settings', trailing: null),
                _SettingItem(icon: Icons.dark_mode_rounded, label: 'Dark Mode', trailing: 'toggle'),
              ]),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _LogoutButton(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'VERSION 1.0.0 (ENTERPRISE OBSIDIAN)',
                  style: TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final BuildContext context;
  const _ProfileHeader({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final top = MediaQuery.of(ctx).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: const Text(
        'Profile & Settings',
        style: TextStyle(
          color: AppColors.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}

// ─── Profile Card ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHighest,
                  border: Border.all(color: AppColors.primary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 16,
                      spreadRadius: -4,
                    ),
                  ],
                ),
                child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 32),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enterprise User',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'user@company.com',
                  style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Text(
                    'PRO TRACKER',
                    style: TextStyle(
                      color: AppColors.onPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Section ─────────────────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final List<_SettingItem> items;
  const _SettingsSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          return Column(
            children: [
              _SettingRow(item: items[i]),
              if (i < items.length - 1)
                Divider(
                  height: 1,
                  indent: 52,
                  color: AppColors.outlineVariant.withOpacity(0.3),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  final String? trailing;
  const _SettingItem({required this.icon, required this.label, required this.trailing});
}

class _SettingRow extends StatefulWidget {
  final _SettingItem item;
  const _SettingRow({required this.item});

  @override
  State<_SettingRow> createState() => _SettingRowState();
}

class _SettingRowState extends State<_SettingRow> {
  bool _toggle = true;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        splashColor: AppColors.primary.withOpacity(0.04),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(widget.item.icon, color: AppColors.onSurfaceVariant, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (widget.item.trailing == 'toggle')
                Transform.scale(
                  scale: 0.85,
                  child: Switch(
                    value: _toggle,
                    onChanged: (v) => setState(() => _toggle = v),
                    activeColor: AppColors.primary,
                    activeTrackColor: AppColors.primaryDim.withOpacity(0.4),
                    inactiveTrackColor: AppColors.surfaceContainerHighest,
                    inactiveThumbColor: AppColors.onSurfaceVariant,
                  ),
                )
              else
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.errorContainer.withOpacity(0.15),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.secondary.withOpacity(0.08),
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          final navigator = Navigator.of(context);
          await ApiClient().clearToken();
          messenger.showSnackBar(
            SnackBar(
              content: const Text('Signed out successfully'),
              backgroundColor: AppColors.surfaceContainerHigh,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
          navigator.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout_rounded, color: AppColors.secondary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
