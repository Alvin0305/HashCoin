import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hashcoin/bloc/monthly_summary.dart';
import 'package:hashcoin/database/database.dart';
import 'package:intl/intl.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final AppDatabase database;

  TransactionBloc({required this.database}) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<EditTransaction>(_onEditTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
  }

  void _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      final transactions = await database.getAllTransaction();
      final processedData = _processTransactions(transactions);

      emit(TransactionLoaded(groupedTransactions: processedData));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    await database.insertTransaction(event.transaction);
    add(LoadTransactions());
  }

  void _onEditTransaction(
    EditTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    await database.updateTransaction(event.transaction);
    add(LoadTransactions());
  }

  void _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    await database.deleteTransaction(event.id);
    add(LoadTransactions());
  }

  Map<String, MonthlySummary> _processTransactions(
    List<Transaction> transactions,
  ) {
    final Map<String, MonthlySummary> grouped = {};
    transactions.sort((a, b) => b.date.compareTo(a.date));

    for (Transaction tx in transactions) {
      final String monthKey = DateFormat("MMMM yyyy").format(tx.date);

      grouped.putIfAbsent(
        monthKey,
        () => MonthlySummary(
          transactions: [],
          income: 0.0,
          expense: 0.0,
          balance: 0.0,
        ),
      );

      final MonthlySummary summary = grouped[monthKey]!;

      summary.transactions.add(tx);

      if (tx.type.toLowerCase() == 'debit') {
        summary.expense += tx.amount;
      } else {
        summary.income += tx.amount;
      }

      summary.balance = summary.income - summary.expense;
    }

    return grouped;
  }
}
