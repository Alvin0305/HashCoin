part of 'transaction_bloc.dart';

class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final Map<String, MonthlySummary> groupedTransactions;

  const TransactionLoaded({required this.groupedTransactions});

  @override
  List<Object> get props => [groupedTransactions];
}

class TransactionError extends TransactionState {
  final String message;
  const TransactionError(this.message);
}
