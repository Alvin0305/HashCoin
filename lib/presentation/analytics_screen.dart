import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hashcoin/bloc/monthly_summary.dart';
import 'package:hashcoin/database/database.dart';
import 'package:hashcoin/presentation/widgets/empty_state_widget.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends StatefulWidget {
  final Map<String, MonthlySummary> groupedTransactions;
  const AnalyticsScreen({super.key, required this.groupedTransactions});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  MonthlySummary? _selectedMonthSummary;
  List<MonthlySummary> _sortedSummaries = [];
  List<String> _sortedMonthKeys = [];

  @override
  void initState() {
    super.initState();
    _prepareData();
  }

  @override
  void didUpdateWidget(covariant AnalyticsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.groupedTransactions != oldWidget.groupedTransactions) {
      _prepareData();
    }
  }

  void _prepareData() {
    _sortedMonthKeys = widget.groupedTransactions.keys
        .toList()
        .reversed
        .toList();

    _sortedSummaries = _sortedMonthKeys
        .map((key) => widget.groupedTransactions[key]!)
        .toList();

    setState(() {
      _selectedMonthSummary = null;
    });
  }

  String _formatYAxisLabel(double value, double maxY) {
    if (maxY < 1000) {
      return value.toInt().toString();
    } else {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
  }

  LineChartData _monthlyLineChartData() {
    double maxValue = 0;
    for (var summary in _sortedSummaries) {
      maxValue = max(summary.expense, max(maxValue, summary.income));
    }
    final paddedMaxValue = maxValue * 1.2;

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];
    final balanceSpots = <FlSpot>[];

    for (int i = 0; i < _sortedSummaries.length; i++) {
      final MonthlySummary summary = _sortedSummaries[i];
      incomeSpots.add(FlSpot(i.toDouble(), summary.income));
      expenseSpots.add(FlSpot(i.toDouble(), summary.expense));
      balanceSpots.add(FlSpot(i.toDouble(), summary.balance));
    }

    return LineChartData(
      maxY: paddedMaxValue > 0 ? paddedMaxValue : 1000,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(),
        touchCallback: (event, touchResponse) {
          if (event is FlTapUpEvent && touchResponse?.lineBarSpots != null) {
            final spotIndex = touchResponse!.lineBarSpots![0].spotIndex;
            setState(() {
              _selectedMonthSummary = _sortedSummaries[spotIndex];
            });
          }
        },
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index >= 0 && index < _sortedMonthKeys.length) {
                final date = DateFormat(
                  "MMMM yyyy",
                ).parse(_sortedMonthKeys[index]);
                return SideTitleWidget(
                  space: 8,
                  meta: meta,
                  child: Text(
                    DateFormat("MMM yy").format(date),
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              }
              return const Text("");
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == meta.max || value == meta.min) {
                return const Text("");
              }
              return Text(
                _formatYAxisLabel(value, paddedMaxValue),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _buildLineBarData(incomeSpots, Colors.green),
        _buildLineBarData(expenseSpots, Colors.red),
        _buildLineBarData(balanceSpots, Colors.blue),
      ],
    );
  }

  LineChartData _dailyLineChartData(MonthlySummary summary) {
    double maxValue = 0;
    final Map<int, ({double income, double expense})> dailyTotals = {};

    for (Transaction tx in summary.transactions) {
      final day = tx.date.day;
      final current = dailyTotals[day] ?? (income: 0.0, expense: 0.0);
      if (tx.type == 'debit') {
        dailyTotals[day] = (
          income: current.income,
          expense: current.expense + tx.amount,
        );
      } else {
        dailyTotals[day] = (
          income: current.income + tx.amount,
          expense: current.expense,
        );
      }
      maxValue = max(
        dailyTotals[day]!.expense,
        max(dailyTotals[day]!.income, maxValue),
      );
    }
    final paddedMaxValue = maxValue * 1.2;

    final date = summary.transactions.first.date;
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;

    final incomeSpots = <FlSpot>[];
    final expenseSpots = <FlSpot>[];

    for (int day = 1; day <= daysInMonth; day++) {
      final dayData = dailyTotals[day];
      final double income = dayData?.income ?? 0.0;
      final double expense = dayData?.expense ?? 0.0;

      incomeSpots.add(FlSpot(day.toDouble(), income));
      expenseSpots.add(FlSpot(day.toDouble(), expense));
    }

    return LineChartData(
      maxY: paddedMaxValue > 0 ? paddedMaxValue : 1000,

      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(),
        touchCallback: (event, touchResponse) {
          if (event is FlTapUpEvent && touchResponse?.lineBarSpots != null) {
            final spotIndex = touchResponse!.lineBarSpots![0].spotIndex;
            setState(() {
              _selectedMonthSummary = _sortedSummaries[spotIndex];
            });
          }
        },
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 5,
            getTitlesWidget: (value, meta) {
              return SideTitleWidget(
                meta: meta,
                child: Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              if (value == meta.max || value == meta.min) {
                return const Text("");
              }
              return Text(
                _formatYAxisLabel(value, paddedMaxValue),
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _buildLineBarData(incomeSpots, Colors.green),
        _buildLineBarData(expenseSpots, Colors.red),
      ],
    );
  }

  LineChartBarData _buildLineBarData(
    List<FlSpot> spots,
    Color color, {
    bool showDots = true,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(show: showDots),
      belowBarData: BarAreaData(
        show: true,
        color: color.withValues(alpha: 0.2),
      ),
    );
  }

  Widget _buildMonthlyGraph() {
    const double monthWidth = 45;
    final monthsCount = _sortedMonthKeys.length;
    final calculatedChartWidth = monthsCount * monthWidth;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Monthly Trends",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth = calculatedChartWidth > constraints.maxWidth
                    ? calculatedChartWidth
                    : constraints.maxWidth;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, right: 16.0),
                    child: SizedBox(
                      height: 200,
                      width: chartWidth,
                      child: LineChart(_monthlyLineChartData()),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGraph() {
    const double dayWidth = 22;
    final date = _selectedMonthSummary!.transactions.first.date;
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    final chartWidth = daysInMonth * dayWidth;
    final monthName = DateFormat("MMMM yyyy").format(date);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Daily Activity for $monthName",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                height: 200,
                width: chartWidth,
                child: LineChart(_dailyLineChartData(_selectedMonthSummary!)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Analytics")),
      body: widget.groupedTransactions.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.insights_outlined,
              title: "Analytics Await!",
              message:
                  "Start adding transactions to see your financial trends and insights here.",
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildMonthlyGraph(),
                  if (_selectedMonthSummary != null) _buildDailyGraph(),
                ],
              ),
            ),
    );
  }
}
