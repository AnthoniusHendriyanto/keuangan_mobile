import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../domain/providers/transaction_provider.dart';
import '../../data/models/transaction.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String fmtIDR(int amount) =>
        formatter.format(amount).replaceAll(',', '_').replaceAll('.', ',').replaceAll('_', '.');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: transactionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (err, _) => Center(
          child: Text('Error: $err', style: const TextStyle(color: AppColors.onSurfaceVariant)),
        ),
        data: (transactions) {
          final totalSpend = transactions.fold<int>(0, (s, t) => s + t.amountIdr.abs());
          final pending = transactions.where((t) => t.status == 'PENDING').toList();
          final pendingTotal = pending.fold<int>(0, (s, t) => s + t.amountIdr.abs());
          final verified = transactions.where((t) => t.status == 'VERIFIED').toList();

          // Category breakdown
          final categoryMap = <String, int>{};
          for (final tx in transactions) {
            categoryMap[tx.category] = (categoryMap[tx.category] ?? 0) + tx.amountIdr.abs();
          }
          final sortedCategories = categoryMap.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Weekly data (last 4 weeks)
          final weeklyData = _computeWeeklyData(transactions);

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(child: _InsightsHeader(context: context)),

              // Hero: Total Spend
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _TotalSpendHero(
                    totalSpend: totalSpend,
                    fmtIDR: fmtIDR,
                    txCount: transactions.length,
                  ),
                ),
              ),

              // Spending chart
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: _SpendingChart(weeklyData: weeklyData, maxValue: totalSpend),
                ),
              ),

              // Stats row
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          label: 'Pending',
                          value: '${pending.length}',
                          sublabel: fmtIDR(pendingTotal),
                          color: AppColors.secondary,
                          icon: Icons.hourglass_empty_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          label: 'Verified',
                          value: '${verified.length}',
                          sublabel: 'transactions',
                          color: AppColors.primary,
                          icon: Icons.verified_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MiniStatCard(
                          label: 'Categories',
                          value: '${categoryMap.length}',
                          sublabel: 'total types',
                          color: AppColors.tertiary,
                          icon: Icons.category_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Spending categories
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    'Top Spending Categories',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final entry = sortedCategories[i];
                      final pct = totalSpend > 0 ? entry.value / totalSpend : 0.0;
                      return _CategoryRow(
                        category: entry.key,
                        amount: fmtIDR(entry.value),
                        percentage: pct,
                      );
                    },
                    childCount: sortedCategories.length,
                  ),
                ),
              ),

              // Smart Insights box
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: _SmartInsightCard(
                    pendingTotal: pendingTotal,
                    totalSpend: totalSpend,
                    fmtIDR: fmtIDR,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }

  List<double> _computeWeeklyData(List<Transaction> transactions) {
    final now = DateTime.now();
    final weeks = List.filled(4, 0.0);
    for (final tx in transactions) {
      final diff = now.difference(tx.transactionDate).inDays;
      final week = (diff / 7).floor();
      if (week < 4) {
        weeks[3 - week] += tx.amountIdr.abs().toDouble();
      }
    }
    return weeks;
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _InsightsHeader extends StatelessWidget {
  final BuildContext context;
  const _InsightsHeader({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final top = MediaQuery.of(ctx).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insights',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Spending Overview · ${DateFormat('MMMM yyyy').format(DateTime.now())}',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Spend ───────────────────────────────────────────────────────────────
class _TotalSpendHero extends StatelessWidget {
  final int totalSpend;
  final String Function(int) fmtIDR;
  final int txCount;
  const _TotalSpendHero(
      {required this.totalSpend, required this.fmtIDR, required this.txCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOTAL SPEND THIS MONTH',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.secondary, Color(0xFFFF9B8A)],
                ).createShader(bounds),
                child: Text(
                  fmtIDR(totalSpend),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Text(
                  '+4.2%',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Across $txCount transactions',
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ─── Spending Chart ───────────────────────────────────────────────────────────
class _SpendingChart extends StatelessWidget {
  final List<double> weeklyData;
  final int maxValue;
  const _SpendingChart({required this.weeklyData, required this.maxValue});

  @override
  Widget build(BuildContext context) {
    final maxBar = weeklyData.isEmpty ? 1.0 : weeklyData.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Weekly Trend',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Last 4 Weeks',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(4, (i) {
              final val = weeklyData.isNotEmpty ? weeklyData[i] : 0.0;
              final norm = maxBar > 0 ? val / maxBar : 0.0;
              final isMax = val == maxBar && maxBar > 0;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    children: [
                      // Glowing bar
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        height: 80 * norm.clamp(0.05, 1.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isMax
                                ? [AppColors.primary, AppColors.primaryContainer]
                                : [
                                    AppColors.tertiary.withOpacity(0.6),
                                    AppColors.tertiary.withOpacity(0.3),
                                  ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: isMax
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 12,
                                    spreadRadius: -2,
                                  )
                                ]
                              : [],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'WK 0${i + 1}',
                        style: TextStyle(
                          color: isMax ? AppColors.primary : AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: isMax ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Stat Card ───────────────────────────────────────────────────────────
class _MiniStatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sublabel;
  final Color color;
  final IconData icon;
  const _MiniStatCard({
    required this.label,
    required this.value,
    required this.sublabel,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Category Row ─────────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String category;
  final String amount;
  final double percentage;
  const _CategoryRow({
    required this.category,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    amount,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.4 ? AppColors.secondary : AppColors.tertiary,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Smart Insight Card ───────────────────────────────────────────────────────
class _SmartInsightCard extends StatelessWidget {
  final int pendingTotal;
  final int totalSpend;
  final String Function(int) fmtIDR;
  const _SmartInsightCard(
      {required this.pendingTotal, required this.totalSpend, required this.fmtIDR});

  @override
  Widget build(BuildContext context) {
    final pendingPct = totalSpend > 0 ? (pendingTotal / totalSpend * 100).toStringAsFixed(0) : '0';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tips_and_updates_rounded,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Insight',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pendingPct% of total spend (${fmtIDR(pendingTotal)}) is still in PENDING state. Verify transactions to clear your liability.',
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 13,
                    height: 1.45,
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
