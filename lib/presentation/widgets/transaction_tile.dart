import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hashcoin/bloc/transaction_bloc.dart';
import 'package:hashcoin/database/database.dart';
import 'package:hashcoin/presentation/widgets/edit_transaction_form.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  const TransactionTile({super.key, required this.transaction});

  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit Transaction'),
              onTap: () {
                Navigator.of(context).pop();
                _showEditForm(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete Transaction',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteConfirmationDialog(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: EditTransactionForm(transaction: transaction),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange.shade800,
            size: 48,
          ),
          title: const Text("Confirm Deletion"),
          content: Text(
            "Are you sure you want to permanently delete this transaction?\n\n\"${transaction.description}\"",
            textAlign: TextAlign.center,
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true && context.mounted) {
      context.read<TransactionBloc>().add(DeleteTransaction(transaction.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final isDebit = transaction.type == 'debit';
    final color = isDebit ? colorScheme.error : Colors.green.shade600;
    final icon = isDebit ? Icons.arrow_downward : Icons.arrow_upward;
    final sign = isDebit ? "-" : "+";

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(transaction.description, style: textTheme.bodyLarge),
      subtitle: Text(
        DateFormat.yMMMd().format(transaction.date),
        style: textTheme.bodySmall,
      ),
      trailing: Text(
        "$sign₹${transaction.amount.toStringAsFixed(2)}",
        style: textTheme.bodyLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
      onTap: () => _showOptionsSheet(context),
    );
  }
}
