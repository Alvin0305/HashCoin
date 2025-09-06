import 'package:hashcoin/database/database.dart';

class MonthlySummary {
  final List<Transaction> transactions;
  double income;
  double expense;
  double balance;

  MonthlySummary({
    required this.transactions,
    required this.income,
    required this.expense,
    required this.balance,
  });
}
