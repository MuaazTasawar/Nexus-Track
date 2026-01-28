import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:expense_tracker/pages/auth/login_page.dart';
import 'transaction_tab.dart';
import 'budget_tab.dart';
import 'subscription_tab.dart' hide TransactionTab;
import 'shared_expense_tab.dart';
import 'payment_method_tab.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _gradientAnimation;
  int _currentTabIndex = 0;

  final List<Color> _gradientColors = [
    const Color(0xFF0F0F1A),
    const Color(0xFF1A1A2E),
    const Color(0xFF2D2D44),
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _gradientAnimation = ColorTween(
      begin: _gradientColors[0],
      end: _gradientColors[1],
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _logout(BuildContext context) {
    HapticFeedback.heavyImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) =>  LoginPage(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    HapticFeedback.lightImpact();
  }

  Widget _buildTabBar() {
    return TabBar(
      isScrollable: true,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            Colors.tealAccent.withOpacity(0.6),
            Colors.cyanAccent.withOpacity(0.3),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.tealAccent.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      labelColor: Colors.tealAccent,
      unselectedLabelColor: Colors.white70,
      labelStyle: GoogleFonts.orbitron(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
      ),
      unselectedLabelStyle: GoogleFonts.orbitron(
        fontSize: 14,
        color: Colors.white70,
      ),
      onTap: _onTabChanged,
      tabs: const [
        Tab(icon: Icon(Icons.list_alt_rounded), text: "TRANSACTIONS"),
        Tab(icon: Icon(Icons.pie_chart_outline_rounded), text: "BUDGET"),
        Tab(icon: Icon(Icons.subscriptions_rounded), text: "SUBSCRIPTIONS"),
        Tab(icon: Icon(Icons.group_rounded), text: "SHARED"),
        Tab(icon: Icon(Icons.credit_card_rounded), text: "PAYMENTS"),
      ],
    );
  }

  Widget _buildAppBar() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1B1B2F).withOpacity(0.9),
                  const Color(0xFF0A0A2A).withOpacity(0.9)
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          title: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.chartLine,
                        color: Colors.tealAccent, size: 22),
                    const SizedBox(width: 12),
                    Text(
                      'NEXUS TRACK',
                      style: GoogleFonts.orbitron(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: IconButton(
                    icon: const FaIcon(FontAwesomeIcons.rightFromBracket,
                        color: Colors.tealAccent, size: 20),
                    onPressed: () => _logout(context),
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTabBar(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(140),
              child: _buildAppBar(),
            ),
            body: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.1, 0.5, 0.9],
                ),
              ),
              child: Stack(
                children: [
                  // Animated background elements
                  Positioned(
                    top: -50,
                    right: -50,
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 30),
                      curve: Curves.linear,
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.tealAccent.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -100,
                    left: -100,
                    child: AnimatedContainer(
                      duration: const Duration(seconds: 40),
                      curve: Curves.linear,
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.cyanAccent.withOpacity(0.03),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Main content
                  TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      const TransactionTab(),
                      const BudgetTab(),
                      const SubscriptionTab(),
                      const SharedExpenseTab(),
                      const PaymentMethodTab(),
                    ],
                  ),

                  // Interactive tab indicator
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.tealAccent.withOpacity(0.8),
                            Colors.cyanAccent.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}