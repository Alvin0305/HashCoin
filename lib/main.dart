import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hashcoin/bloc/transaction_bloc.dart';
import 'package:hashcoin/database/database.dart';
import 'package:hashcoin/presentation/home_screen.dart';
import 'package:hashcoin/presentation/theme/app_theme.dart';

final AppDatabase database = AppDatabase();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          TransactionBloc(database: database)..add(LoadTransactions()),
      child: MaterialApp(
        title: "HashCoin",
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: HomeScreen(),
      ),
    );
  }
}
