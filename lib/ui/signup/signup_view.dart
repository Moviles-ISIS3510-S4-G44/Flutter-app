import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'signup_viewmodel.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SignUpPage();
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool obscurePassword = true;

  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color background = Color(0xFFF7F7F5);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFBDBDBD);
  static const Color lightGray = Color(0xFFEAEAEA);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty) {
      _showMessage('Please enter your full name');
      return;
    }

    if (email.isEmpty) {
      _showMessage('Please enter your university email');
      return;
    }

    if (password.isEmpty) {
      _showMessage('Please enter a password');
      return;
    }

    if (password.length < 8) {
      _showMessage('Password must be at least 8 characters');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match');
      return;
    }

    final viewModel = context.read<SignUpViewModel>();

    await viewModel.signup(
      name: name,
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (viewModel.signupSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please log in.'),
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        color: Color(0xFFB4B4B4),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: background,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: borderColor,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: textPrimary,
          width: 1.2,
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: Color(0xFF4F4F4F),
      ),
    );
  }

  Widget _partnerButton({
    required IconData icon,
    required String text,
  }) {
    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: textSecondary),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    
    final viewModel = context.watch<SignUpViewModel>();

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          Row(
                            children: const [
                              Icon(
                                Icons.account_balance,
                                size: 18,
                                color: Color(0xFF6A5A00),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'SCHOLASTIC',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 74),
                          const Text(
                            'Join the community',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF6A5A00),
                              height: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 26),
                          _sectionLabel('FULL NAME'),
                          const SizedBox(height: 8),
                          TextField(
                            // FIX #1: era _usernameController
                            controller: _nameController,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _inputDecoration(
                              hint: 'John Doe',
                              suffixIcon: const Icon(
                                Icons.person,
                                size: 18,
                                color: Color(0xFF9A9A9A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 26),
                          _sectionLabel('UNIVERSITY EMAIL'),
                          const SizedBox(height: 8),
                          TextField(
                            // FIX #1: era _usernameController
                            controller: _emailController,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _inputDecoration(
                              hint: 'student@university.edu.co',
                              suffixIcon: const Icon(
                                Icons.alternate_email,
                                size: 18,
                                color: Color(0xFF9A9A9A),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _sectionLabel('PASSWORD'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: obscurePassword,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              suffixIcon: IconButton(
                                splashRadius: 18,
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: const Color(0xFF9A9A9A),
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _sectionLabel('CONFIRM'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            // FIX #2: era _passwordController
                            controller: _confirmPasswordController,
                            obscureText: obscurePassword,
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 14,
                              color: textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: _inputDecoration(
                              hint: '••••••••',
                              suffixIcon: IconButton(
                                splashRadius: 18,
                                icon: Icon(
                                  obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 18,
                                  color: const Color(0xFF9A9A9A),
                                ),
                                onPressed: () {
                                  setState(() {
                                    obscurePassword = !obscurePassword;
                                  });
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              // FIX #3: era doble coma ,,
                              onPressed: viewModel.isLoading ? null : _handleSignUp,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: primaryYellow,
                                foregroundColor: textPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text(
                                    'REGISTER',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(text: "Already have an account? "),
                                  TextSpan(
                                    text: 'Login',
                                    style: TextStyle(
                                      color: textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 36),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFE4E4E4),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: const [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'PRIVACY POLICY',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Color(0xFF9C9C9C),
                            ),
                          ),
                          SizedBox(width: 18),
                          Text(
                            'TERMS OF SERVICE',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                              color: Color(0xFF9C9C9C),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        '© 2024 SCHOLASTIC MEDIA GROUP',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: Color(0xFF9C9C9C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}