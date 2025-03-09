import 'package:flutter/material.dart';
import 'package:tourism_app/models/budget/budget.dart';
import 'package:tourism_app/models/budget/expense.dart'; 
import 'package:tourism_app/presentation/screens/budget/widget/budget_card.dart';
import 'package:tourism_app/presentation/theme/theme.dart';
import 'add_expense_screen.dart';

class ExpenseScreen extends StatefulWidget {
  final Budget budget;

  const ExpenseScreen({super.key, required this.budget});

  @override
  _ExpenseScreenState createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  double remainingBudget = 0;
  List<Expense> expenses = [];

  @override
  void initState() {
    super.initState();
    remainingBudget = widget.budget.total;
  }

  void _navigateToAddExpense() async {
    // Navigate to AddExpenseScreen and wait for the result
    final newExpense = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(
          selectedCurrency: widget.budget.currency,
          remainingBudget: remainingBudget,
        ),
      ),
    );

    // If an expense was added, update the state
    if (newExpense != null) {
      setState(() {
        expenses.add(newExpense);
        remainingBudget -= newExpense.amount;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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

  @override
  Widget build(BuildContext context) {
    double totalBudgetValue = widget.budget.total;
    double totalSpent = totalBudgetValue - remainingBudget;
    double dailyBudget = widget.budget.dailyBudget; 

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
                  currency: widget.budget.currency,
                ),
                SizedBox(width: DertamSpacings.s),
                BudgetCard(
                  title: 'Daily Budget', 
                  spent: totalSpent, 
                  budget: dailyBudget,
                  currency: widget.budget.currency,
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
                      final expense = expenses[index];
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: DertamColors.primary.withOpacity(0.2),
                            child: Icon(
                              expense.category.icon, // Use the icon getter from ExpenseCategoryExtension
                              color: DertamColors.primary,
                            ),
                          ),
                          title: Text('${expense.amount} ${widget.budget.currency}', style: DertamTextStyles.body),
                          subtitle: Text(
                            expense.description,
                            style: DertamTextStyles.label,
                          ),
                          trailing: Text(
                            _formatDate(expense.date),
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddExpense,
        backgroundColor: DertamColors.primary,
        child: Icon(Icons.add, color: DertamColors.white),
      ),
    );
  }
}