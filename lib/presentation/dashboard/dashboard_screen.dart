import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/colors.dart';
import '../../data/repositories/mock_dashboard_repository.dart';
import '../../domain/entities/transaction.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repo = MockDashboardRepository();

  final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FutureBuilder(
        future: Future.wait([
          _repo.getNetBalance(),
          _repo.getCurrentLiabilities(),
          _repo.getMonthlyBurn(),
          _repo.getRecentTransactions(),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data as List<dynamic>;
          final int netBalance = data[0] as int;
          final int liabilities = data[1] as int;
          final int monthlyBurn = data[2] as int;
          final List<TransactionEntity> transactions = data[3] as List<TransactionEntity>;

          return Stack(
            children: [
              CustomScrollView(
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
                            currencyFormatter.format(netBalance).replaceAll(',','_').replaceAll('.',',').replaceAll('_','.'), // Simple format to Rp 15.000.000
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 40),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Verified by 3 linked accounts",
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
                              value: currencyFormatter.format(liabilities).replaceAll(',','_').replaceAll('.',',').replaceAll('_','.'),
                              valueColor: AppColors.secondary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                _buildMetricCard(
                                  context: context,
                                  title: "Monthly Burn",
                                  value: "Rp ${(monthlyBurn / 1000000).toStringAsFixed(1)}M",
                                  valueColor: AppColors.onSurface,
                                ),
                                const SizedBox(height: 16),
                                _buildMetricCard(
                                  context: context,
                                  title: "Credit Score",
                                  value: "782",
                                  subtitle: " +12",
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
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final tx = transactions[index];
                          return _buildTransactionItem(context, tx);
                        },
                        childCount: transactions.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for bottom nav
                ],
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
                          _buildNavItem(Icons.dashboard_rounded, true),
                          _buildNavItem(Icons.receipt_long_rounded, false),
                          _buildNavItem(Icons.bar_chart_rounded, false),
                          _buildNavItem(Icons.settings_rounded, false),
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

  Widget _buildTransactionItem(BuildContext context, TransactionEntity tx) {
    final isNegative = tx.amountIdr < 0;
    final displayAmount = (isNegative ? "- " : "+ ") + currencyFormatter.format(tx.amountIdr.abs()).replaceAll(',','_').replaceAll('.',',').replaceAll('_','.');
    final amountColor = isNegative ? AppColors.secondary : AppColors.primary;
    
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

  Widget _buildNavItem(IconData icon, bool isActive) {
    return IconButton(
      icon: Icon(
        icon,
        color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
        size: 28,
      ),
      onPressed: () {},
    );
  }
}
