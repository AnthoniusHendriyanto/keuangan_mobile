import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../domain/providers/transaction_provider.dart';
import '../../data/models/transaction.dart';

class ReceiptsScreen extends ConsumerWidget {
  const ReceiptsScreen({super.key});

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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.secondary, size: 48),
              const SizedBox(height: 16),
              Text('Failed to load: $err', textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.refresh(transactionsProvider),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                ),
                child: const Text('Retry', style: TextStyle(color: AppColors.primary)),
              )
            ],
          ),
        ),
        data: (transactions) {
          // Group by month
          final grouped = <String, List<Transaction>>{};
          for (final tx in transactions) {
            final key = DateFormat('MMMM yyyy').format(tx.transactionDate);
            grouped.putIfAbsent(key, () => []).add(tx);
          }
          final months = grouped.keys.toList();

          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(child: _ReceiptsHeader(context: context)),

              // Summary cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Transactions',
                          value: '${transactions.length}',
                          valueColor: AppColors.tertiary,
                          icon: Icons.receipt_long_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Volume',
                          value: fmtIDR(
                              transactions.fold<int>(0, (s, t) => s + t.amountIdr.abs())),
                          valueColor: AppColors.secondary,
                          icon: Icons.trending_up_rounded,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Filter chips
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: _FilterChips(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // Transaction list grouped by month
              if (transactions.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(60),
                    child: Center(
                      child: Text(
                        'No transactions found',
                        style: TextStyle(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ),
                )
              else
                for (final month in months) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        children: [
                          Text(
                            month,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              '${grouped[month]!.length}',
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) {
                          final tx = grouped[month]![i];
                          return _TransactionRow(tx: tx, fmtIDR: fmtIDR);
                        },
                        childCount: grouped[month]!.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 16)),
                ],

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          );
        },
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _ReceiptsHeader extends StatelessWidget {
  final BuildContext context;
  const _ReceiptsHeader({required this.context});

  @override
  Widget build(BuildContext ctx) {
    final top = MediaQuery.of(ctx).padding.top;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, top + 16, 20, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Billing Cycles',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMMM yyyy').format(DateTime.now()),
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded, color: AppColors.onSurfaceVariant),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              fixedSize: const Size(44, 44),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Summary Card ─────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  const _SummaryCard({
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
          Icon(icon, color: valueColor, size: 18),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ─── Filter Chips ─────────────────────────────────────────────────────────────
class _FilterChips extends StatefulWidget {
  @override
  State<_FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<_FilterChips> {
  int _selected = 0;
  final _labels = ['All', 'PENDING', 'VERIFIED', 'DEBIT', 'CREDIT'];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _labels.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final isActive = _selected == i;
        return GestureDetector(
          onTap: () => setState(() => _selected = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              _labels[i],
              style: TextStyle(
                color: isActive ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Transaction Row ──────────────────────────────────────────────────────────
class _TransactionRow extends StatelessWidget {
  final Transaction tx;
  final String Function(int) fmtIDR;
  const _TransactionRow({required this.tx, required this.fmtIDR});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == 'CREDIT';
    final amountColor = isCredit ? AppColors.primary : AppColors.secondary;
    final prefix = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.primary.withOpacity(0.04),
          highlightColor: Colors.transparent,
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
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
                      Row(
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(tx.transactionDate),
                            style: const TextStyle(
                                color: AppColors.onSurfaceVariant, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              tx.category,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                    const SizedBox(height: 4),
                    _StatusDot(status: tx.status),
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

class _StatusDot extends StatelessWidget {
  final String status;
  const _StatusDot({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toUpperCase()) {
      case 'PENDING':
        color = AppColors.secondary;
        break;
      case 'VERIFIED':
        color = AppColors.primary;
        break;
      default:
        color = AppColors.onSurfaceVariant;
    }
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          status,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
