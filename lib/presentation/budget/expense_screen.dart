import 'package:flutter/material.dart';
import 'package:tourism_app/presentation/budget/add_expense_screen.dart';
import 'package:tourism_app/presentation/theme/theme.dart';
import 'package:tourism_app/presentation/budget/widget/budget_card.dart'; 
class ExpenseScreen extends StatefulWidget {
  final String totalBudget;
  final String dailyBudget;
  final String selectedCurrency;

  const ExpenseScreen({
    super.key,
    required this.totalBudget,
    required this.dailyBudget,
    required this.selectedCurrency,
  });

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<Map<String, dynamic>> expenses = [];
  late double remainingBudget;
  late double dailyBudget;

  @override
  void initState() {
    super.initState();
    remainingBudget = double.tryParse(widget.totalBudget) ?? 0.0;
    dailyBudget = double.tryParse(widget.dailyBudget) ?? 0.0;
  }

  void _navigateToAddExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          selectedCurrency: widget.selectedCurrency,
          remainingBudget: remainingBudget,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        expenses.add({
          'amount': result['amount'],
          'description': result['description'],
          'category': result['category'],
          'date': result['date'] ?? DateTime.now().toString(), // Capture date
        });

        remainingBudget -= double.tryParse(
                result['amount'].toString().replaceAll(widget.selectedCurrency, '').trim()) ??
            0;
      });
    }
  }

  double get totalSpent {
    return expenses.fold(0.0, (sum, expense) {
      double amount = double.tryParse(
              expense['amount'].toString().replaceAll(widget.selectedCurrency, '').trim()) ??
          0;
      return sum + amount;
    });
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.fastfood;
      case 'transport':
        return Icons.directions_bus;
      case 'shopping':
        return Icons.shopping_cart;
      case 'entertainment':
        return Icons.movie;
      default:
        return Icons.receipt_long;
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalBudgetValue = double.tryParse(widget.totalBudget) ?? 0.0;
    return Scaffold(
      backgroundColor: DertamColors.white,
      appBar: AppBar(
        backgroundColor: DertamColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: DertamColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BudgetCard(
                  title: 'Total', 
                  spent: totalSpent, 
                  budget: totalBudgetValue,
                  currency : widget.selectedCurrency,
                ),
                SizedBox(width: DertamSpacings.s),
                BudgetCard(
                  title: 'Daily Budget', 
                  spent:totalSpent, 
                  budget: dailyBudget,
                  currency: widget.selectedCurrency,
                ),
              ],
            ),
          ),
          SizedBox(height: DertamSpacings.l),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Expense list',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: expenses.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: expenses.length,
                    padding: EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: DertamColors.primary.withOpacity(0.2),
                            child: Icon(
                              _getCategoryIcon(expenses[index]["category"] ?? "other"),
                              color: DertamColors.primary,
                            ),
                          ),
                          title: Text(expenses[index]["amount"], style: DertamTextStyles.body),
                          subtitle: Text(
                            expenses[index]["description"] ?? "No description",
                            style: DertamTextStyles.label,
                          ),
                          trailing: Text(
                            _formatDate(DateTime.parse(expenses[index]["date"])),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _navigateToAddExpense,
                backgroundColor: Colors.blue,
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }

 
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("It's pretty empty here...", style: TextStyle(color: Colors.grey, fontSize: 16)),
          SizedBox(height: 8),
          Text("Enter your\n1st expense", textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";
}
