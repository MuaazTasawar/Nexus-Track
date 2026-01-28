import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _storage = FlutterSecureStorage();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _formElevationAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1000),
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

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutQuart,
      ),
    );

    _formElevationAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      if (_passCtrl.text != _confirmPassCtrl.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Passwords don't match"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(20),
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      HapticFeedback.lightImpact();

      try {
        await Future.delayed(Duration(milliseconds: 800)); // Simulate network delay

        await _storage.write(key: 'email', value: _emailCtrl.text.trim());
        await _storage.write(key: 'password', value: _passCtrl.text);

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 800),
            pageBuilder: (_, __, ___) => LoginPage(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Account created successfully!"),
            backgroundColor: Colors.greenAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(20),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save credentials"),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: EdgeInsets.all(20),
          ),
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0F0F1A),
                Color(0xFF1A1A2E),
                Color(0xFF2D2D44),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.1, 0.5, 0.9],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated Logo
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Colors.tealAccent.withOpacity(0.2),
                              Colors.tealAccent.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.tealAccent.withOpacity(0.1),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_alt_1,
                          size: 60,
                          color: Colors.tealAccent,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Form Container
                  AnimatedBuilder(
                    animation: _formElevationAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_formElevationAnimation.value * 0.5),
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: Container(
                              width: size.width > 500 ? 500 : size.width * 0.9,
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A2E).withOpacity(0.8),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20 + _formElevationAnimation.value * 2,
                                    offset: Offset(0, 10 + _formElevationAnimation.value * 0.5),
                                  ),
                                  BoxShadow(
                                    color: Colors.tealAccent.withOpacity(0.05),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: Offset(0, -5),
                                  ),
                                ],
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.1),
                                  width: 1,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Padding(
                                    padding: EdgeInsets.all(30),
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Create Account',
                                            style: GoogleFonts.orbitron(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.tealAccent,
                                              letterSpacing: 1.5,
                                            ),
                                          ),

                                          SizedBox(height: 10),

                                          Text(
                                            'Join us to get started',
                                            style: GoogleFonts.exo2(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),

                                          SizedBox(height: 30),

                                          // Email Field
                                          TextFormField(
                                            controller: _emailCtrl,
                                            keyboardType: TextInputType.emailAddress,
                                            style: GoogleFonts.exo2(color: Colors.white),
                                            decoration: InputDecoration(
                                              labelText: 'Email',
                                              labelStyle: TextStyle(color: Colors.white70),
                                              prefixIcon: Icon(Icons.email, color: Colors.tealAccent),
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
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your email';
                                              }
                                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                                  .hasMatch(value)) {
                                                return 'Please enter a valid email';
                                              }
                                              return null;
                                            },
                                          ),

                                          SizedBox(height: 20),

                                          // Password Field
                                          TextFormField(
                                            controller: _passCtrl,
                                            obscureText: _obscurePassword,
                                            style: GoogleFonts.exo2(color: Colors.white),
                                            decoration: InputDecoration(
                                              labelText: 'Password',
                                              labelStyle: TextStyle(color: Colors.white70),
                                              prefixIcon: Icon(Icons.lock, color: Colors.tealAccent),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscurePassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.white70,
                                                ),
                                                onPressed: () {
                                                  setState(() => _obscurePassword = !_obscurePassword);
                                                },
                                              ),
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
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please enter your password';
                                              }
                                              if (value.length < 6) {
                                                return 'Password must be at least 6 characters';
                                              }
                                              return null;
                                            },
                                          ),

                                          SizedBox(height: 20),

                                          // Confirm Password Field
                                          TextFormField(
                                            controller: _confirmPassCtrl,
                                            obscureText: _obscureConfirmPassword,
                                            style: GoogleFonts.exo2(color: Colors.white),
                                            decoration: InputDecoration(
                                              labelText: 'Confirm Password',
                                              labelStyle: TextStyle(color: Colors.white70),
                                              prefixIcon: Icon(Icons.lock_outline, color: Colors.tealAccent),
                                              suffixIcon: IconButton(
                                                icon: Icon(
                                                  _obscureConfirmPassword
                                                      ? Icons.visibility_off
                                                      : Icons.visibility,
                                                  color: Colors.white70,
                                                ),
                                                onPressed: () {
                                                  setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                                },
                                              ),
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
                                            validator: (value) {
                                              if (value == null || value.isEmpty) {
                                                return 'Please confirm your password';
                                              }
                                              if (value != _passCtrl.text) {
                                                return 'Passwords do not match';
                                              }
                                              return null;
                                            },
                                          ),

                                          SizedBox(height: 25),

                                          // Sign Up Button
                                          SizedBox(
                                            width: double.infinity,
                                            height: 50,
                                            child: ElevatedButton(
                                              onPressed: _isLoading ? null : _register,
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.tealAccent,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 5,
                                                shadowColor: Colors.tealAccent.withOpacity(0.4),
                                              ),
                                              child: _isLoading
                                                  ? SizedBox(
                                                width: 20,
                                                height: 20,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                                ),
                                              )
                                                  : Text(
                                                'SIGN UP',
                                                style: GoogleFonts.orbitron(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 1.2,
                                                ),
                                              ),
                                            ),
                                          ),

                                          SizedBox(height: 25),

                                          // Divider
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white.withOpacity(0.2),
                                                  thickness: 1,
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 10),
                                                child: Text(
                                                  'OR',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Divider(
                                                  color: Colors.white.withOpacity(0.2),
                                                  thickness: 1,
                                                ),
                                              ),
                                            ],
                                          ),

                                          SizedBox(height: 25),

                                          // Login Button
                                          TextButton(
                                            onPressed: () => Navigator.pushReplacement(
                                              context,
                                              PageRouteBuilder(
                                                transitionDuration: Duration(milliseconds: 500),
                                                pageBuilder: (_, __, ___) => LoginPage(),
                                                transitionsBuilder: (_, animation, __, child) {
                                                  return SlideTransition(
                                                    position: Tween<Offset>(
                                                      begin: Offset(-1, 0),
                                                      end: Offset.zero,
                                                    ).animate(animation),
                                                    child: child,
                                                  );
                                                },
                                              ),
                                            ),
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: RichText(
                                              text: TextSpan(
                                                text: "Already have an account? ",
                                                style: GoogleFonts.exo2(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text: 'Login',
                                                    style: TextStyle(
                                                      color: Colors.tealAccent,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
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
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}