part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object> get props => [];
}

class LoadTransactions extends TransactionEvent {}

class AddTransaction extends TransactionEvent {
  final TransactionsCompanion transaction;
  const AddTransaction(this.transaction);
}

class DeleteTransaction extends TransactionEvent {
  final int id;
  const DeleteTransaction(this.id);
}

class EditTransaction extends TransactionEvent {
  final TransactionsCompanion transaction;
  const EditTransaction(this.transaction);
}
