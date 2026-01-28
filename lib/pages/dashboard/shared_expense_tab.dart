import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/shared_expense.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SharedExpenseTab extends StatefulWidget {
  const SharedExpenseTab({Key? key}) : super(key: key);

  @override
  State<SharedExpenseTab> createState() => _SharedExpenseTabState();
}

class _SharedExpenseTabState extends State<SharedExpenseTab> with SingleTickerProviderStateMixin {
  final List<SharedExpense> _sharedExpenses = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  String _selectedCategory = 'Food';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
    _loadExpenses();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('shared_expenses') ?? [];
    setState(() {
      _sharedExpenses.clear();
      _sharedExpenses.addAll(data.map((e) => SharedExpense.fromMap(jsonDecode(e))));
    });
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedList = _sharedExpenses.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('shared_expenses', encodedList);
  }

  void _addSharedExpense() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1A1A2E).withOpacity(0.9),
                        const Color(0xFF0A0A2A).withOpacity(0.9)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, -5),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "ADD SHARED EXPENSE",
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          "WITH WHOM",
                          style: GoogleFonts.exo2(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Friend's name",
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.tealAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          style: GoogleFonts.exo2(color: Colors.white),
                          validator: (value) =>
                          value?.isEmpty ?? true ? "Required" : null,
                        ),
                        const SizedBox(height: 16),

                        Text(
                          "CATEGORY",
                          style: GoogleFonts.exo2(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          dropdownColor: const Color(0xFF1A1A2E),
                          style: GoogleFonts.exo2(color: Colors.white),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.tealAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          items: ['Food', 'Travel', 'Entertainment', 'Bills', 'Other']
                              .map((category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                _getCategoryIcon(category),
                                const SizedBox(width: 10),
                                Text(category),
                              ],
                            ),
                          ))
                              .toList(),
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedCategory = val!);
                          },
                        ),
                        const SizedBox(height: 16),

                        Text(
                          "AMOUNT",
                          style: GoogleFonts.exo2(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixText: "\$ ",
                            prefixStyle: TextStyle(color: Colors.tealAccent),
                            hintText: "0.00",
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.tealAccent,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                          style: GoogleFonts.orbitron(color: Colors.white),
                          validator: (value) =>
                          value?.isEmpty ?? true ? "Required" : null,
                        ),
                        const SizedBox(height: 30),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                              ),
                              child: Text(
                                "CANCEL",
                                style: GoogleFonts.exo2(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  HapticFeedback.mediumImpact();
                                  final newExpense = SharedExpense(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    name: _nameController.text,
                                    amount: double.tryParse(_amountController.text) ?? 0,
                                    category: _selectedCategory,
                                    date: DateTime.now(),
                                  );
                                  setState(() {
                                    _sharedExpenses.add(newExpense);
                                  });
                                  await _saveExpenses();
                                  _nameController.clear();
                                  _amountController.clear();
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.tealAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                elevation: 5,
                                shadowColor: Colors.tealAccent.withOpacity(0.4),
                              ),
                              child: Text(
                                "ADD EXPENSE",
                                style: GoogleFonts.orbitron(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return const FaIcon(FontAwesomeIcons.utensils, size: 16);
      case 'Travel':
        return const FaIcon(FontAwesomeIcons.plane, size: 16);
      case 'Entertainment':
        return const FaIcon(FontAwesomeIcons.film, size: 16);
      case 'Bills':
        return const FaIcon(FontAwesomeIcons.receipt, size: 16);
      default:
        return const FaIcon(FontAwesomeIcons.wallet, size: 16);
    }
  }

  Future<void> _deleteExpense(int index) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _sharedExpenses.removeAt(index);
    });
    await _saveExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F0F1A),
                Color(0xFF1A1A2E),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _sharedExpenses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.peopleGroup,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "NO SHARED EXPENSES",
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add your first shared expense to get started",
                      style: GoogleFonts.exo2(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _addSharedExpense,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 14),
                        elevation: 5,
                      ),
                      child: Text(
                        "ADD SHARED EXPENSE",
                        style: GoogleFonts.orbitron(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.only(top: 16, bottom: 100),
                itemCount: _sharedExpenses.length,
                itemBuilder: (ctx, i) {
                  final expense = _sharedExpenses[i];
                  return Padding(
                    key: ValueKey(expense.id),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Dismissible(
                      key: Key(expense.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 30),
                        child: const FaIcon(
                          FontAwesomeIcons.trash,
                          color: Colors.red,
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        HapticFeedback.mediumImpact();
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: const Color(0xFF1A1A2E),
                              title: Text(
                                "Delete Shared Expense?",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                "Are you sure you want to delete this expense?",
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: Text(
                                    "CANCEL",
                                    style: TextStyle(color: Colors.tealAccent),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(true),
                                  child: Text(
                                    "DELETE",
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onDismissed: (direction) async {
                        setState(() {
                          _sharedExpenses.removeAt(i);
                        });
                        await _saveExpenses();
                      },
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              // Add edit functionality here
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A2E),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  _getCategoryIcon(expense.category ?? 'Other'),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          expense.name,
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${expense.category} • \$${expense.amount.toStringAsFixed(2)}",
                                          style: GoogleFonts.exo2(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const FaIcon(
                                    FontAwesomeIcons.chevronRight,
                                    color: Colors.white70,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: FloatingActionButton(
                  onPressed: _addSharedExpense,
                  backgroundColor: Colors.tealAccent,
                  child: const FaIcon(
                    FontAwesomeIcons.plus,
                    color: Colors.black,
                    size: 24,
                  ),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}