class MonthlyRevenue {
  final String month;
  final double sales;
  final double credits;
  final double receipts;
  final double expenses;

  MonthlyRevenue({
    required this.month,
    required this.sales,
    required this.credits,
    required this.receipts,
    required this.expenses,
  });

  double get netRevenue => sales - expenses;
  double get margin => sales > 0 ? ((sales - expenses) / sales) * 100 : 0;
}
