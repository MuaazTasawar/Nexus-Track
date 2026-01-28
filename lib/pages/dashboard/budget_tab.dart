import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:percent_indicator/linear_percent_indicator.dart';


class Budget {
  final String category;
  final double limit;
  double used;

  Budget({required this.category, required this.limit, this.used = 0});

  Map<String, dynamic> toMap() {
    return {
      'category': category,
      'limit': limit,
      'used': used,
    };
  }

  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      category: map['category'],
      limit: map['limit'],
      used: map['used'] ?? 0,
    );
  }
}

class BudgetTab extends StatefulWidget {
  const BudgetTab({super.key});

  @override
  State<BudgetTab> createState() => _BudgetTabState();
}

class _BudgetTabState extends State<BudgetTab> with SingleTickerProviderStateMixin {
  List<Budget> _budgets = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
    _animationController.forward();
    _loadBudgets();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsJson = prefs.getString('budgets');
    if (budgetsJson != null) {
      final List<dynamic> budgetsMap = json.decode(budgetsJson);
      setState(() {
        _budgets = budgetsMap.map((item) => Budget.fromMap(item)).toList();
      });
    }
  }

  Future<void> _saveBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final budgetsMap = _budgets.map((budget) => budget.toMap()).toList();
    await prefs.setString('budgets', json.encode(budgetsMap));
  }

  void _addBudget(BuildContext context) {
    final categoryController = TextEditingController();
    final limitController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF0A0A2A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, -5),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Create New Budget",
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Category Name",
                        style: GoogleFonts.exo2(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: categoryController,
                        style: GoogleFonts.exo2(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "e.g. Groceries, Entertainment",
                          hintStyle: TextStyle(color: Colors.white30),
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
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Budget Limit",
                        style: GoogleFonts.exo2(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: limitController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.exo2(color: Colors.white),
                        decoration: InputDecoration(
                          prefixText: "\$ ",
                          prefixStyle: TextStyle(color: Colors.tealAccent),
                          hintText: "0.00",
                          hintStyle: TextStyle(color: Colors.white30),
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
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.exo2(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              final category = categoryController.text.trim();
                              final limit = double.tryParse(limitController.text.trim()) ?? 0;
                              if (category.isNotEmpty && limit > 0) {
                                setState(() {
                                  _budgets.add(Budget(category: category, limit: limit));
                                });
                                await _saveBudgets();
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 5,
                              shadowColor: Colors.tealAccent.withOpacity(0.4),
                            ),
                            child: Text(
                              "Create Budget",
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
    );
  }

  Future<void> _deleteBudget(int index) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _budgets.removeAt(index);
    });
    await _saveBudgets();
  }

  Future<void> _editBudget(int index) async {
    final budget = _budgets[index];
    final categoryController = TextEditingController(text: budget.category);
    final limitController = TextEditingController(text: budget.limit.toString());
    final usedController = TextEditingController(text: budget.used.toString());

    await showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1A1A2E), Color(0xFF0A0A2A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.tealAccent.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: Offset(0, -5),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Edit Budget",
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(height: 24),
                      Text(
                        "Category Name",
                        style: GoogleFonts.exo2(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: categoryController,
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
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Budget Limit",
                        style: GoogleFonts.exo2(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: limitController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.exo2(color: Colors.white),
                        decoration: InputDecoration(
                          prefixText: "\$ ",
                          prefixStyle: TextStyle(color: Colors.tealAccent),
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
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        "Amount Used",
                        style: GoogleFonts.exo2(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: usedController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: GoogleFonts.exo2(color: Colors.white),
                        decoration: InputDecoration(
                          prefixText: "\$ ",
                          prefixStyle: TextStyle(color: Colors.tealAccent),
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
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                        ),
                      ),
                      SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            child: Text(
                              "Cancel",
                              style: GoogleFonts.exo2(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              HapticFeedback.lightImpact();
                              final category = categoryController.text.trim();
                              final limit = double.tryParse(limitController.text.trim()) ?? 0;
                              final used = double.tryParse(usedController.text.trim()) ?? 0;
                              if (category.isNotEmpty && limit > 0) {
                                setState(() {
                                  _budgets[index] = Budget(
                                    category: category,
                                    limit: limit,
                                    used: used,
                                  );
                                });
                                await _saveBudgets();
                                Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 5,
                              shadowColor: Colors.tealAccent.withOpacity(0.4),
                            ),
                            child: Text(
                              "Save Changes",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F0F1A), Color(0xFF1A1A2E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimatedSwitcher(
          duration: Duration(milliseconds: 500),
          child: _budgets.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 64,
                  color: Colors.white.withOpacity(0.3),
                ),
                SizedBox(height: 20),
                Text(
                  "No Budgets Yet",
                  style: GoogleFonts.orbitron(
                    fontSize: 22,
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Create your first budget to get started",
                  style: GoogleFonts.exo2(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _addBudget(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    elevation: 5,
                  ),
                  child: Text(
                    "Create Budget",
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
            padding: EdgeInsets.only(top: 16, bottom: 100),
            itemCount: _budgets.length,
            itemBuilder: (context, index) {
              final budget = _budgets[index];
              final percentage = budget.used / budget.limit;
              final isOverBudget = percentage > 1.0;

              return Padding(
                key: ValueKey(budget.category),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Dismissible(
                  key: Key(budget.category),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 30),
                    child: Icon(Icons.delete_forever, color: Colors.red),
                  ),
                  confirmDismiss: (direction) async {
                    HapticFeedback.mediumImpact();
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color(0xFF1A1A2E),
                          title: Text("Delete Budget?", style: TextStyle(color: Colors.white)),
                          content: Text("Are you sure you want to delete this budget?", style: TextStyle(color: Colors.white70)),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("Cancel", style: TextStyle(color: Colors.tealAccent)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) => _deleteBudget(index),
                  child: GestureDetector(
                    onTap: () => _editBudget(index),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: Offset(4, 4),
                            blurRadius: 8,
                          ),
                          BoxShadow(
                            color: Colors.tealAccent.withOpacity(0.05),
                            offset: Offset(-4, -4),
                            blurRadius: 8,
                          ),
                        ],
                        border: Border.all(
                          color: isOverBudget
                              ? Colors.red.withOpacity(0.3)
                              : Colors.tealAccent.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                budget.category,
                                style: GoogleFonts.orbitron(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              Icon(
                                Icons.edit,
                                color: Colors.white54,
                                size: 18,
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Limit",
                                    style: GoogleFonts.exo2(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "\$${budget.limit.toStringAsFixed(2)}",
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Used",
                                    style: GoogleFonts.exo2(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "\$${budget.used.toStringAsFixed(2)}",
                                    style: GoogleFonts.orbitron(
                                      color: isOverBudget ? Colors.redAccent : Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "Remaining",
                                    style: GoogleFonts.exo2(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    "\$${(budget.limit - budget.used).toStringAsFixed(2)}",
                                    style: GoogleFonts.orbitron(
                                      color: isOverBudget
                                          ? Colors.redAccent
                                          : Colors.tealAccent,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "${(percentage * 100).toStringAsFixed(1)}% ${isOverBudget ? 'Over' : 'Used'}",
                                  style: GoogleFonts.exo2(
                                    color: isOverBudget ? Colors.redAccent : Colors.tealAccent,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                isOverBudget
                                    ? "Over by \$${(budget.used - budget.limit).toStringAsFixed(2)}"
                                    : "On track",
                                style: GoogleFonts.exo2(
                                  color: isOverBudget ? Colors.redAccent : Colors.tealAccent,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Container(
                            height: 8,
                              child: LinearPercentIndicator(
                                lineHeight: 14.0,
                                percent: percentage > 1.0 ? 1.0 : percentage,
                                backgroundColor: Colors.grey.withOpacity(0.2),
                                progressColor: isOverBudget ? Colors.redAccent : Colors.tealAccent,
                                barRadius: const Radius.circular(4),
                                center: const Text(""),
                              )
                          ),
                        ],
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
          child: FloatingActionButton(
            backgroundColor: Colors.tealAccent,
            onPressed: () => _addBudget(context),
            child: Icon(Icons.add, color: Colors.black, size: 28),
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}