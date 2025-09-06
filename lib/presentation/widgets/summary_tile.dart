import 'package:flutter/material.dart';
import 'package:hashcoin/bloc/monthly_summary.dart';
import 'package:hashcoin/presentation/widgets/transaction_tile.dart';
import 'package:intl/intl.dart';

class SummaryTile extends StatelessWidget {
  final MonthlySummary summary;
  const SummaryTile({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final String month = DateFormat(
      'MMMM yyyy',
    ).format(summary.transactions.first.date);

    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final balanceColor = summary.balance >= 0
        ? colorScheme.primary
        : Colors.orange.shade700;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: ExpansionTile(
        title: Text(
          month,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          '₹${summary.balance.toStringAsFixed(2)}',
          style: textTheme.titleMedium?.copyWith(
            color: balanceColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        initiallyExpanded: false,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(
                  context: context,
                  icon: Icons.arrow_upward,
                  label: 'Income',
                  amount: summary.income,
                  color: Colors.green.shade600,
                ),
                _buildSummaryItem(
                  context: context,
                  icon: Icons.arrow_downward,
                  label: 'Expense',
                  amount: summary.expense,
                  color: colorScheme.error,
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ...summary.transactions.map(
            (transaction) => TransactionTile(transaction: transaction),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required double amount,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: textTheme.bodySmall),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
