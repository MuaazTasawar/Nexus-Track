import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/models/payment_method.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PaymentMethodTab extends StatefulWidget {
  const PaymentMethodTab({super.key});

  @override
  State<PaymentMethodTab> createState() => _PaymentMethodTabState();
}

class _PaymentMethodTabState extends State<PaymentMethodTab> with SingleTickerProviderStateMixin {
  final List<PaymentMethod> _paymentMethods = [];
  String _selectedCardType = 'Visa';
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
    _loadPaymentMethods();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('payment_methods') ?? [];
    setState(() {
      _paymentMethods.clear();
      _paymentMethods.addAll(data.map((e) => PaymentMethod.fromMap(jsonDecode(e))));
    });
  }

  Future<void> _savePaymentMethods() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _paymentMethods.map((e) => jsonEncode(e.toMap())).toList();
    await prefs.setStringList('payment_methods', encoded);
  }

  Future<void> _addPaymentMethod() async {
    final nameController = TextEditingController();
    final cardNumberController = TextEditingController();
    final expiryController = TextEditingController();

    await showDialog(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "ADD PAYMENT METHOD",
                        style: GoogleFonts.orbitron(
                          fontSize: 20,
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card Preview
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: _getCardGradient(_selectedCardType),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              top: 20,
                              right: 20,
                              child: _getCardIcon(_selectedCardType),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cardNumberController.text.isEmpty
                                        ? "•••• •••• •••• ••••"
                                        : cardNumberController.text,
                                    style: GoogleFonts.orbitron(
                                      color: Colors.white,
                                      fontSize: 16,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    nameController.text.isEmpty
                                        ? "CARD HOLDER"
                                        : nameController.text.toUpperCase(),
                                    style: GoogleFonts.exo2(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    expiryController.text.isEmpty
                                        ? "MM/YY"
                                        : expiryController.text,
                                    style: GoogleFonts.exo2(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Fields
                      Text(
                        "CARD TYPE",
                        style: GoogleFonts.exo2(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _selectedCardType,
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
                        items: ['Visa', 'Mastercard', 'Amex', 'Discover', 'PayPal']
                            .map((type) => DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              _getCardIcon(type, size: 20),
                              const SizedBox(width: 10),
                              Text(type),
                            ],
                          ),
                        ))
                            .toList(),
                        onChanged: (val) {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedCardType = val!);
                        },
                      ),
                      const SizedBox(height: 16),

                      Text(
                        "CARD NUMBER",
                        style: GoogleFonts.exo2(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: cardNumberController,
                        keyboardType: TextInputType.number,
                        style: GoogleFonts.orbitron(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "1234 5678 9012 3456",
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
                        onChanged: (value) => setState(() {}),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "EXPIRY DATE",
                                  style: GoogleFonts.exo2(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: expiryController,
                                  keyboardType: TextInputType.datetime,
                                  style: GoogleFonts.orbitron(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "MM/YY",
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
                                  onChanged: (value) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "CARD HOLDER",
                                  style: GoogleFonts.exo2(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextField(
                                  controller: nameController,
                                  style: GoogleFonts.exo2(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: "John Doe",
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
                                  onChanged: (value) => setState(() {}),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                              HapticFeedback.mediumImpact();
                              final name = nameController.text.trim();
                              final cardNumber = cardNumberController.text.trim();
                              if (name.isNotEmpty && cardNumber.isNotEmpty) {
                                final newMethod = PaymentMethod(
                                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                                  name: "$_selectedCardType •••• ${cardNumber.length > 4 ? cardNumber.substring(cardNumber.length - 4) : cardNumber}",
                                  cardType: _selectedCardType,
                                  lastFour: cardNumber.length > 4
                                      ? cardNumber.substring(cardNumber.length - 4)
                                      : cardNumber,
                                );
                                setState(() {
                                  _paymentMethods.add(newMethod);
                                });
                                await _savePaymentMethods();
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
                              "ADD CARD",
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

  List<Color> _getCardGradient(String cardType) {
    switch (cardType) {
      case 'Visa':
        return [const Color(0xFF4364F7), const Color(0xFF6FB1FC)];
      case 'Mastercard':
        return [const Color(0xFFEB6D09), const Color(0xFFF5AF19)];
      case 'Amex':
        return [const Color(0xFF0070BA), const Color(0xFF154284)];
      case 'Discover':
        return [const Color(0xFFEA5B0C), const Color(0xFFEBB417)];
      case 'PayPal':
        return [const Color(0xFF003087), const Color(0xFF009CDE)];
      default:
        return [const Color(0xFF1A1A2E), const Color(0xFF16213E)];
    }
  }

  Widget _getCardIcon(String cardType, {double size = 32}) {
    switch (cardType) {
      case 'Visa':
        return const FaIcon(FontAwesomeIcons.ccVisa, color: Colors.white, size: 32);
      case 'Mastercard':
        return const FaIcon(FontAwesomeIcons.ccMastercard, color: Colors.white, size: 32);
      case 'Amex':
        return const FaIcon(FontAwesomeIcons.ccAmex, color: Colors.white, size: 32);
      case 'Discover':
        return const FaIcon(FontAwesomeIcons.ccDiscover, color: Colors.white, size: 32);
      case 'PayPal':
        return const FaIcon(FontAwesomeIcons.paypal, color: Colors.white, size: 32);
      default:
        return const Icon(Icons.credit_card, color: Colors.white, size: 32);
    }
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
              child: _paymentMethods.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.credit_card_off,
                      size: 64,
                      color: Colors.white54,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "NO PAYMENT METHODS",
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add your first payment method to get started",
                      style: GoogleFonts.exo2(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _addPaymentMethod,
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
                        "ADD PAYMENT METHOD",
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
                itemCount: _paymentMethods.length,
                itemBuilder: (ctx, i) {
                  final method = _paymentMethods[i];
                  return Padding(
                    key: ValueKey(method.id),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Dismissible(
                      key: Key(method.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 30),
                        child: const Icon(Icons.delete, color: Colors.red),
                      ),
                      confirmDismiss: (direction) async {
                        HapticFeedback.mediumImpact();
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: const Color(0xFF1A1A2E),
                              title: Text(
                                "Delete Payment Method?",
                                style: TextStyle(color: Colors.white),
                              ),
                              content: Text(
                                "Are you sure you want to delete this payment method?",
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
                          _paymentMethods.removeAt(i);
                        });
                        await _savePaymentMethods();
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
                                gradient: LinearGradient(
                                  colors: _getCardGradient(method.cardType ?? 'Visa'),
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
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
                                  _getCardIcon(method.cardType ?? 'Visa', size: 24),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          method.name,
                                          style: GoogleFonts.orbitron(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.1,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          method.lastFour != null
                                              ? "•••• ${method.lastFour}"
                                              : "",
                                          style: GoogleFonts.exo2(
                                            color: Colors.white.withOpacity(0.8),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios,
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
                  onPressed: _addPaymentMethod,
                  backgroundColor: Colors.tealAccent,
                  child: const Icon(Icons.add, color: Colors.black, size: 28),
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