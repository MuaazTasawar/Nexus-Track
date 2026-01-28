import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Subscription {
  final String id;
  final String name;
  final double amount;
  final String cycle;
  final DateTime createdAt;
  final String? category;

  Subscription({
    required this.id,
    required this.name,
    required this.amount,
    required this.cycle,
    required this.createdAt,
    this.category = 'Other',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'cycle': cycle,
      'createdAt': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory Subscription.fromMap(Map<String, dynamic> map) {
    return Subscription(
      id: map['id'],
      name: map['name'],
      amount: map['amount']?.toDouble() ?? 0.0,
      cycle: map['cycle'] ?? 'Monthly',
      createdAt: DateTime.parse(map['createdAt']),
      category: map['category'] ?? 'Other',
    );
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

class SubscriptionTab extends StatefulWidget {
  const SubscriptionTab({Key? key}) : super(key: key);

  @override
  State<SubscriptionTab> createState() => _SubscriptionTabState();
}

class _SubscriptionTabState extends State<SubscriptionTab>
    with SingleTickerProviderStateMixin {
  List<Subscription> _subscriptions = [];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCycle = 'Monthly';
  String _selectedCategory = 'Entertainment';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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
    _loadSubscriptions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionsJson = prefs.getString('subscriptions');
    if (subscriptionsJson != null) {
      final List<dynamic> subscriptionsMap = json.decode(subscriptionsJson);
      setState(() {
        _subscriptions = subscriptionsMap.map((item) => Subscription.fromMap(item)).toList();
      });
    }
  }

  Future<void> _saveSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final subscriptionsMap = _subscriptions.map((sub) => sub.toMap()).toList();
    await prefs.setString('subscriptions', json.encode(subscriptionsMap));
  }

  void _addSubscription() {
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
                          "ADD SUBSCRIPTION",
                          style: GoogleFonts.orbitron(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.tealAccent,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Subscription Name
                        Text(
                          "SERVICE NAME",
                          style: GoogleFonts.exo2(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Netflix, Spotify, etc.",
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

                        // Category
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
                          items: [
                            'Entertainment',
                            'Software',
                            'Utilities',
                            'Fitness',
                            'Education',
                            'Other'
                          ].map((category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                _getCategoryIcon(category),
                                const SizedBox(width: 10),
                                Text(category),
                              ],
                            ),
                          )).toList(),
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedCategory = val!);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Amount
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
                        const SizedBox(height: 16),

                        // Billing Cycle
                        Text(
                          "BILLING CYCLE",
                          style: GoogleFonts.exo2(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedCycle,
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
                          items: ['Monthly', 'Quarterly', 'Yearly']
                              .map((cycle) => DropdownMenuItem(
                            value: cycle,
                            child: Row(
                              children: [
                                _getCycleIcon(cycle),
                                const SizedBox(width: 10),
                                Text(cycle),
                              ],
                            ),
                          ))
                              .toList(),
                          onChanged: (val) {
                            HapticFeedback.lightImpact();
                            setState(() => _selectedCycle = val!);
                          },
                        ),
                        const SizedBox(height: 30),

                        // Action Buttons
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
                                  final newSubscription = Subscription(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    name: _nameController.text,
                                    amount: double.tryParse(_amountController.text) ?? 0,
                                    cycle: _selectedCycle,
                                    createdAt: DateTime.now(),
                                    category: _selectedCategory,
                                  );
                                  setState(() {
                                    _subscriptions.add(newSubscription);
                                  });
                                  await _saveSubscriptions();
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
                                "ADD SUBSCRIPTION",
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
      case 'Entertainment':
        return const FaIcon(FontAwesomeIcons.film, size: 16);
      case 'Software':
        return const FaIcon(FontAwesomeIcons.laptopCode, size: 16);
      case 'Utilities':
        return const FaIcon(FontAwesomeIcons.lightbulb, size: 16);
      case 'Fitness':
        return const FaIcon(FontAwesomeIcons.dumbbell, size: 16);
      case 'Education':
        return const FaIcon(FontAwesomeIcons.graduationCap, size: 16);
      default:
        return const FaIcon(FontAwesomeIcons.circleDot, size: 16);
    }
  }

  Widget _getCycleIcon(String cycle) {
    switch (cycle) {
      case 'Monthly':
        return const FaIcon(FontAwesomeIcons.calendarAlt, size: 16);
      case 'Quarterly':
        return const FaIcon(FontAwesomeIcons.calendarCheck, size: 16);
      case 'Yearly':
        return const FaIcon(FontAwesomeIcons.calendarDay, size: 16);
      default:
        return const FaIcon(FontAwesomeIcons.calendar, size: 16);
    }
  }

  Future<void> _deleteSubscription(int index) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _subscriptions.removeAt(index);
    });
    await _saveSubscriptions();
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
              child: _subscriptions.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const FaIcon(
                      FontAwesomeIcons.circleNotch,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "NO SUBSCRIPTIONS",
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add your first subscription to get started",
                      style: GoogleFonts.exo2(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _addSubscription,
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
                        "ADD SUBSCRIPTION",
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
                itemCount: _subscriptions.length,
                itemBuilder: (ctx, i) {
                  final sub = _subscriptions[i];
                  return Padding(
                    key: ValueKey(sub.id),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Dismissible(
                      key: Key(sub.id),
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
                                "Delete Subscription?",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                "Are you sure you want to delete this subscription?",
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
                          _subscriptions.removeAt(i);
                        });
                        await _saveSubscriptions();
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
                                  _getCategoryIcon(sub.category ?? 'Other'),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sub.name,
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${sub.category} • \$${sub.amount.toStringAsFixed(2)}/${sub.cycle}",
                                          style: GoogleFonts.exo2(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "Added on ${sub.formattedDate}",
                                          style: GoogleFonts.exo2(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  _getCycleIcon(sub.cycle),
                                  const SizedBox(width: 8),
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
                  onPressed: _addSubscription,
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