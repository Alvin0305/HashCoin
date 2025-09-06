import 'package:flutter/material.dart';
import 'package:hashcoin/bloc/monthly_summary.dart';
import 'package:hashcoin/presentation/widgets/empty_state_widget.dart';
import 'package:hashcoin/presentation/widgets/summary_tile.dart';

class TransactionListScreen extends StatelessWidget {
  final Map<String, MonthlySummary> groupedTransactions;
  const TransactionListScreen({super.key, required this.groupedTransactions});

  @override
  Widget build(BuildContext context) {
    final months = groupedTransactions.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Transaction")),
      body: groupedTransactions.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.receipt_long_outlined,
              title: "No Transactions Yet",
              message:
                  "Tap the '+' button below to add your first expense or income",
            )
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  final String month = months[index];
                  final MonthlySummary monthlySummary =
                      groupedTransactions[month]!;

                  return SummaryTile(summary: monthlySummary);
                },
              ),
            ),
    );
  }
}
