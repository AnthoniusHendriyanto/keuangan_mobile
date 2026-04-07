import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';
import '../../core/network/api_client.dart';
import '../../presentation/auth/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/transaction_provider.dart';
import '../../data/models/transaction.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final trueLiability = ref.watch(trueLiabilityProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String formatIDR(int amount) {
      return currencyFormatter.format(amount).replaceAll(',', '_').replaceAll('.', ',').replaceAll('_', '.');
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.secondary, size: 48),
              const SizedBox(height: 16),
              Text('Failed to sync: $err', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(transactionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (transactions) {
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async => ref.refresh(transactionsProvider),
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceVariant,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: MediaQuery.of(context).padding.top + 32)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("True Liability", style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 8),
                            Text(
                              formatIDR(trueLiability),
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Verified transactions in PENDING state",
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    // Liability Cards
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildMetricCard(
                                context: context,
                                title: "Current Liabilities",
                                value: formatIDR(trueLiability),
                                valueColor: AppColors.secondary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: [
                                  _buildMetricCard(
                                    context: context,
                                    title: "Total Records",
                                    value: "${transactions.length}",
                                    valueColor: AppColors.onSurface,
                                  ),
                                  const SizedBox(height: 16),
                                  _buildMetricCard(
                                    context: context,
                                    title: "Status",
                                    value: "Live",
                                    subtitle: " Connected",
                                    subtitleColor: AppColors.primary,
                                    valueColor: AppColors.onSurface,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                    // Recent Activity
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Text(
                          "Recent Activity",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    if (transactions.isEmpty)
                      const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text("No transactions found.", style: TextStyle(color: AppColors.onSurfaceVariant)),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final tx = transactions[index];
                              return _buildTransactionItem(context, tx, formatIDR);
                            },
                            childCount: transactions.length,
                          ),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for bottom nav
                  ],
                ),
              ),
              // Bottom Nav Bar (Glassmorphic)
              Positioned(
                bottom: 32,
                left: 24,
                right: 24,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.0),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child: Container(
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavItem(Icons.dashboard_rounded, true, null),
                          _buildNavItem(Icons.receipt_long_rounded, false, null),
                          _buildNavItem(Icons.bar_chart_rounded, false, null),
                          _buildLogoutItem(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMetricCard({
    required BuildContext context,
    required String title,
    required String value,
    required Color valueColor,
    String? subtitle,
    Color? subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: valueColor, fontSize: 24),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(color: subtitleColor),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction tx, String Function(int) formatIDR) {
    final displayAmount = "- ${formatIDR(tx.amountIdr.abs())}"; // Mock as all debit/liability
    const amountColor = AppColors.secondary;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          highlightColor: AppColors.surfaceContainerHigh,
          splashColor: Colors.transparent,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tx.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM d, HH:mm').format(tx.transactionDate),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
                Text(
                  displayAmount,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, VoidCallback? onTap) {
    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
        size: 28,
      ),
      onPressed: onTap ?? () {},
    );
  }

  Widget _buildLogoutItem(BuildContext context) {
    return IconButton(
      tooltip: 'Logout',
      icon: const Icon(
        Icons.logout_rounded,
        color: AppColors.secondary,
        size: 26,
      ),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        await ApiClient().clearToken();

        messenger.showSnackBar(
          SnackBar(
            content: const Text('Signed out successfully.'),
            backgroundColor: AppColors.surfaceContainerHigh,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      },
    );
  }
}
