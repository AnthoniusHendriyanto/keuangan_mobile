import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../domain/providers/transaction_provider.dart';
import '../../data/models/transaction.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final trueLiability = ref.watch(trueLiabilityProvider);
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    String fmtIDR(int amount) =>
        formatter.format(amount).replaceAll(',', '_').replaceAll('.', ',').replaceAll('_', '.');

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _AddTransactionFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: transactionsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, color: AppColors.secondary, size: 56),
                const SizedBox(height: 16),
                Text(
                  'Unable to sync',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => ref.refresh(transactionsProvider),
                  icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                  label: const Text('Retry', style: TextStyle(color: AppColors.primary)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primary, width: 1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
        data: (transactions) {
          // Derived data
          final pendingTx = transactions.where((t) => t.status == 'PENDING').toList();
          final totalSpend = transactions.fold<int>(0, (s, t) => s + t.amountIdr.abs());
          final recent = transactions.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(transactionsProvider),
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceContainerHigh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // === Top Header ===
                SliverToBoxAdapter(
                  child: _DashboardHeader(context: context),
                ),

                // === Hero: Safe to Spend ===
                SliverToBoxAdapter(
                  child: _HeroBalance(
                    label: 'SAFE TO SPEND',
                    amount: fmtIDR(totalSpend > trueLiability ? totalSpend - trueLiability : 0),
                    sublabel: 'After all pending liabilities',
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // === Current Liabilities Card ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _LiabilityCard(
                      liability: trueLiability,
                      pendingCount: pendingTx.length,
                      fmtIDR: fmtIDR,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // === Quick Stats Row ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Monthly Burn',
                            value: fmtIDR(totalSpend),
                            valueColor: AppColors.secondary,
                            icon: Icons.local_fire_department_rounded,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'Total Records',
                            value: '${transactions.length}',
                            valueColor: AppColors.tertiary,
                            icon: Icons.receipt_long_rounded,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 28)),

                // === Recent Activity Header ===
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Activity',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Text(
                          '${recent.length} of ${transactions.length}',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // === Transaction List ===
                if (recent.isEmpty)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(color: AppColors.onSurfaceVariant),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _TransactionTile(tx: recent[i], fmtIDR: fmtIDR),
                        childCount: recent.length,
                      ),
                    ),
                  ),

                // Space for FAB + bottom nav
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _DashboardHeader extends StatelessWidget {
  final BuildContext context;
  const _DashboardHeader({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final top = MediaQuery.of(ctx).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHigh,
              border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1.5),
            ),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 22),
          ),
          // Title
          const Text(
            'True Liability',
            style: TextStyle(
              color: AppColors.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
          // Notification Bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                padding: EdgeInsets.zero,
                onPressed: () {},
                icon: const Icon(Icons.notifications_none_rounded,
                    color: AppColors.onSurfaceVariant, size: 26),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Hero Balance ─────────────────────────────────────────────────────────────
class _HeroBalance extends StatelessWidget {
  final String label;
  final String amount;
  final String sublabel;
  const _HeroBalance({required this.label, required this.amount, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.primaryDim,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 6),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryContainer],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            sublabel,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Liability Card ───────────────────────────────────────────────────────────
class _LiabilityCard extends StatelessWidget {
  final int liability;
  final int pendingCount;
  final String Function(int) fmtIDR;
  const _LiabilityCard({required this.liability, required this.pendingCount, required this.fmtIDR});

  @override
  Widget build(BuildContext context) {
    const totalBudget = 20000000; // Mock budget for progress bar
    final progress = (liability / totalBudget).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.08),
            blurRadius: 40,
            spreadRadius: -8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Liabilities',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '$pendingCount PENDING',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            fmtIDR(liability),
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of monthly budget',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  const _StatCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: valueColor, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Tile ─────────────────────────────────────────────────────────
class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  final String Function(int) fmtIDR;
  const _TransactionTile({required this.tx, required this.fmtIDR});

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'food':
      case 'dining':
        return Icons.restaurant_rounded;
      case 'transport':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'subscription':
      case 'subscriptions':
        return Icons.subscriptions_rounded;
      case 'salary':
        return Icons.account_balance_wallet_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == 'CREDIT';
    final amountColor = isCredit ? AppColors.primary : AppColors.secondary;
    final prefix = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.04),
          highlightColor: Colors.transparent,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: amountColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconForCategory(tx.category), color: amountColor, size: 20),
                ),
                const SizedBox(width: 12),
                // Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.description,
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        DateFormat('MMM d · HH:mm').format(tx.transactionDate),
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$prefix ${fmtIDR(tx.amountIdr.abs())}',
                      style: TextStyle(
                        color: amountColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    _StatusChip(status: tx.status),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    Color textColor;
    switch (status.toUpperCase()) {
      case 'PENDING':
        chipColor = AppColors.secondary.withOpacity(0.15);
        textColor = AppColors.secondary;
        break;
      case 'VERIFIED':
        chipColor = AppColors.primary.withOpacity(0.15);
        textColor = AppColors.primary;
        break;
      default:
        chipColor = AppColors.onSurfaceVariant.withOpacity(0.15);
        textColor = AppColors.onSurfaceVariant;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _AddTransactionFAB extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          borderRadius: BorderRadius.circular(100),
          splashColor: Colors.white.withOpacity(0.1),
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, color: AppColors.onPrimary, size: 20),
                SizedBox(width: 8),
                Text(
                  '+ Add Transaction',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
