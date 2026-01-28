import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';

class Transaction {
  final String id;
  final String description;
  final double amount;
  final String type;
  final String category;
  final DateTime date;

  Transaction({
    required this.id,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'amount': amount,
    'type': type,
    'category': category,
    'date': date.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    description: json['description'],
    amount: json['amount'],
    type: json['type'],
    category: json['category'] ?? 'Other',
    date: DateTime.parse(json['date']),
  );
}

class TransactionTab extends StatefulWidget {
  const TransactionTab({super.key});

  @override
  State<TransactionTab> createState() => _TransactionTabState();
}

class _TransactionTabState extends State<TransactionTab> {
  final List<Transaction> _transactions = [];
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedType = 'Expense';
  String _selectedCategory = 'Other';

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<String> get _localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/transactions.json');
  }

  Future<void> _saveTransactions() async {
    final file = await _localFile;
    final jsonList = _transactions.map((tx) => tx.toJson()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<void> _loadTransactions() async {
    try {
      final file = await _localFile;
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> data = jsonDecode(contents);
        setState(() {
          _transactions.clear();
          _transactions.addAll(data.map((e) => Transaction.fromJson(e)).toList());
        });
      }
    } catch (e) {
      debugPrint("Error loading transactions: $e");
    }
  }

  void _addTransaction() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
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
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(4, 4), blurRadius: 8),
                    BoxShadow(color: Colors.tealAccent.withOpacity(0.1), offset: Offset(-4, -4), blurRadius: 8),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add Transaction',
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.tealAccent,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _descController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) => value?.isEmpty ?? true ? "Required" : null,
                      ),
                      SizedBox(height: 12),
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.cyanAccent, width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.white),
                        validator: (value) => value?.isEmpty ?? true ? "Required" : null,
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        items: ['Expense', 'Income']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                      SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          labelStyle: TextStyle(color: Colors.tealAccent),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        items: ['Food', 'Transport', 'Entertainment', 'Other']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val!),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _transactions.add(Transaction(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    description: _descController.text,
                                    amount: double.tryParse(_amountController.text) ?? 0,
                                    type: _selectedType,
                                    category: _selectedCategory,
                                    date: DateTime.now(),
                                  ));
                                  _descController.clear();
                                  _amountController.clear();
                                });
                                _saveTransactions();
                                Navigator.pop(context);
                              }
                            },
                            child: Text("Add", style: GoogleFonts.orbitron()),
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
        body: _transactions.isEmpty
            ? Center(
          child: Text(
            "No transactions yet",
            style: GoogleFonts.exo2(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        )
            : ListView.builder(
          itemCount: _transactions.length,
          itemBuilder: (ctx, i) {
            final tx = _transactions[i];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: AnimatedOpacity(
                opacity: 1.0,
                duration: Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), offset: Offset(4, 4), blurRadius: 8),
                      BoxShadow(color: Colors.tealAccent.withOpacity(0.1), offset: Offset(-4, -4), blurRadius: 8),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Icon(
                      tx.type == 'Expense' ? Icons.arrow_upward : Icons.arrow_downward,
                      color: tx.type == 'Expense' ? Colors.redAccent : Colors.greenAccent,
                      size: 28,
                    ),
                    title: Text(
                      tx.description,
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "${tx.date.toString().substring(0, 10)} • ${tx.type} • ${tx.category}",
                      style: GoogleFonts.exo2(color: Colors.white70),
                    ),
                    trailing: Text(
                      "\$${tx.amount.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: tx.type == 'Expense' ? Colors.redAccent : Colors.greenAccent,
                      ),
                    ),
                    onLongPress: () {
                      HapticFeedback.mediumImpact();
                      setState(() {
                        _transactions.removeAt(i);
                      });
                      _saveTransactions();
                    },
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTransaction,
          backgroundColor: Colors.tealAccent,
          child: Icon(Icons.add, color: Colors.black),
        ),
      ),
    );
  }
}