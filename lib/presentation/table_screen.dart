import 'package:flutter/material.dart';
import 'package:hashcoin/bloc/monthly_summary.dart';
import 'package:hashcoin/database/database.dart';
import 'package:intl/intl.dart';

class TableScreen extends StatefulWidget {
  final Map<String, MonthlySummary> groupedTransactions;
  const TableScreen({super.key, required this.groupedTransactions});

  @override
  State<TableScreen> createState() => _TableScreenState();
}

class _TableScreenState extends State<TableScreen> {
  late List<MapEntry<String, MonthlySummary>> _sortedEntries;
  int? _sortColumnIndex;
  bool _isAscending = true;
  String? selectedMonth;

  late List<Transaction> _sortedTransactions;
  int? _transactionSortColumnIndex;
  bool _isTransactionSortAscending = true;

  @override
  void initState() {
    super.initState();
    _sortedEntries = widget.groupedTransactions.entries.toList();
    _sortedTransactions = [];
  }

  @override
  void didUpdateWidget(covariant TableScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.groupedTransactions != oldWidget.groupedTransactions) {
      setState(() {
        _sortedEntries = widget.groupedTransactions.entries.toList();
        if (_sortColumnIndex != null) {
          _onSort(_sortColumnIndex!, _isAscending);
        }

        if (selectedMonth != null) {
          if (widget.groupedTransactions.containsKey(selectedMonth)) {
            final updatedSummary = widget.groupedTransactions[selectedMonth]!;
            _sortedTransactions = List.from(updatedSummary.transactions);

            if (_transactionSortColumnIndex != null) {
              _onTransactionSort(
                _transactionSortColumnIndex!,
                _isTransactionSortAscending,
              );
            }
          } else {
            selectedMonth = null;
            _sortedTransactions = [];
          }
        }
      });
    }
  }

  void _onSort(int columnIndex, bool isAscending) {
    _sortColumnIndex = columnIndex;
    _isAscending = isAscending;
    _sortedEntries.sort((a, b) {
      int compareResult = 0;
      switch (columnIndex) {
        case 0:
          final dateA = DateFormat('MMMM yyyy').parse(a.key);
          final dateB = DateFormat('MMMM yyyy').parse(b.key);
          compareResult = dateA.compareTo(dateB);
          break;
        case 1:
          compareResult = a.value.income.compareTo(b.value.income);
          break;
        case 2:
          compareResult = a.value.expense.compareTo(b.value.expense);
          break;
        case 3:
          compareResult = a.value.balance.compareTo(b.value.balance);
          break;
      }
      return isAscending ? compareResult : -compareResult;
    });

    if (mounted) {
      setState(() {});
    }
  }

  void _onTransactionSort(int columnIndex, bool isAscending) {
    _transactionSortColumnIndex = columnIndex;
    _isTransactionSortAscending = isAscending;

    _sortedTransactions.sort((a, b) {
      int compareResult = 0;
      switch (columnIndex) {
        case 0:
          compareResult = a.date.compareTo(b.date);
          break;
        case 1:
          compareResult = a.amount.compareTo(b.amount);
          break;
        case 2:
          compareResult = a.description.compareTo(b.description);
          break;
      }
      return isAscending ? compareResult : -compareResult;
    });

    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildHeader(String label, {IconData? icon, Color? iconColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (icon != null) const SizedBox(width: 8),
        if (icon != null)
          CircleAvatar(
            backgroundColor: iconColor!.withValues(alpha: 0.15),
            child: Icon(icon, color: iconColor, size: 18),
          ),
      ],
    );
  }

  Widget _buildAmountCell(double amount, Color color) {
    return Text(
      '₹${amount.toStringAsFixed(2)}',
      style: TextStyle(color: color, fontWeight: FontWeight.w600),
      textAlign: TextAlign.end,
    );
  }

  Widget _buildTableForMonth() {
    if (selectedMonth != null) {
      final textTheme = Theme.of(context).textTheme;
      final colorScheme = Theme.of(context).colorScheme;

      final incomeColor = Colors.green.shade600;
      final expenseColor = colorScheme.error;

      return Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            sortColumnIndex: _transactionSortColumnIndex,
            sortAscending: _isTransactionSortAscending,
            headingTextStyle: textTheme.titleMedium,
            columnSpacing: 32.0,
            columns: <DataColumn>[
              DataColumn(
                label: _buildHeader("Day"),
                onSort: _onTransactionSort,
              ),
              DataColumn(
                label: _buildHeader(
                  "Transaction",
                  icon: Icons.money,
                  iconColor: colorScheme.primary,
                ),
                numeric: true,
                onSort: _onTransactionSort,
              ),
              DataColumn(
                label: _buildHeader(
                  "Description",
                  icon: Icons.file_copy,
                  iconColor: expenseColor,
                ),
                onSort: _onTransactionSort,
              ),
            ],
            rows: _sortedTransactions.map((Transaction tx) {
              bool isDebit = tx.type == 'debit';
              double amount = isDebit ? -tx.amount : tx.amount;
              Color color = isDebit ? expenseColor : incomeColor;
              return DataRow(
                cells: <DataCell>[
                  DataCell(
                    Text(
                      DateFormat.yMMMd().format(tx.date),
                      style: textTheme.bodyMedium,
                    ),
                  ),
                  DataCell(_buildAmountCell(amount, color)),
                  DataCell(Text(tx.description, style: textTheme.bodyMedium)),
                ],
              );
            }).toList(),
          ),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(24.0),
      alignment: Alignment.center,
      child: Text(
        "Tap a month above to view its transactions",
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildMonthlyTable() {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final incomeColor = Colors.green.shade600;
    final expenseColor = colorScheme.error;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _isAscending,
          headingTextStyle: textTheme.titleMedium,
          columnSpacing: 32.0,
          columns: <DataColumn>[
            DataColumn(label: _buildHeader("Month"), onSort: _onSort),
            DataColumn(
              label: _buildHeader(
                "Income",
                icon: Icons.arrow_upward,
                iconColor: incomeColor,
              ),
              numeric: true,
              onSort: _onSort,
            ),
            DataColumn(
              label: _buildHeader(
                "Expense",
                icon: Icons.arrow_downward,
                iconColor: expenseColor,
              ),
              numeric: true,
              onSort: _onSort,
            ),
            DataColumn(
              label: _buildHeader(
                "Balance",
                icon: Icons.account_balance_wallet_outlined,
                iconColor: colorScheme.primary,
              ),
              numeric: true,
              onSort: _onSort,
            ),
          ],
          rows: _sortedEntries.map((MapEntry<String, MonthlySummary> entry) {
            final summary = entry.value;
            final balanceColor = summary.balance >= 0
                ? colorScheme.primary
                : Colors.orange.shade700;

            return DataRow(
              selected: selectedMonth == entry.key,
              onSelectChanged: (isSelected) {
                setState(() {
                  if (selectedMonth == entry.key) {
                    selectedMonth = null;
                    _sortedTransactions = [];
                  } else {
                    selectedMonth = entry.key;
                    _sortedTransactions = List.from(summary.transactions);
                    _transactionSortColumnIndex = 0;
                    _isTransactionSortAscending = false;
                    _onTransactionSort(
                      _transactionSortColumnIndex!,
                      _isTransactionSortAscending,
                    );
                  }
                });
              },
              cells: <DataCell>[
                DataCell(Text(entry.key, style: textTheme.bodyMedium)),
                DataCell(_buildAmountCell(summary.income, incomeColor)),
                DataCell(_buildAmountCell(-summary.expense, expenseColor)),
                DataCell(_buildAmountCell(summary.balance, balanceColor)),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Monthly Summary Table")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildMonthlyTable(),
            const SizedBox(height: 16),
            _buildTableForMonth(),
          ],
        ),
      ),
    );
  }
}
