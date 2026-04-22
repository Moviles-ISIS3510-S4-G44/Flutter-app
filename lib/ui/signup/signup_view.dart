import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'signup_viewmodel.dart';

import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';

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

  final _nameFocusNode = FocusNode();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  // Field-level errors
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;

  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color background = Color(0xFFF7F7F5);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFBDBDBD);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color errorRedLight = Color(0xFFFFEBEE);
  static const Color errorRedBorder = Color(0xFFEF9A9A);

  static const int _maxNameLength = 60;
  static const int _maxEmailLength = 80;
  static const int _maxPasswordLength = 64;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  // Validation 

  String? _validateName(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'El nombre es requerido';
    if (trimmed.length < 2) return 'Ingresa tu nombre completo';
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'\-]+$").hasMatch(trimmed)) {
      return 'El nombre solo puede contener letras';
    }
    return null;
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'El correo es requerido';
    if (!RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$')
        .hasMatch(trimmed)) {
      return 'Ingresa un correo válido';
    }
    if (!trimmed.toLowerCase().endsWith('@uniandes.edu.co')) {
      return 'Debe ser un correo @uniandes.edu.co';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 8) return 'Mínimo 8 caracteres';
    return null;
  }

  String? _validateConfirm(String value) {
    if (value.isEmpty) return 'Confirma tu contraseña';
    if (value != _passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  bool _validateForm() {
    final nameErr = _validateName(_nameController.text);
    final emailErr = _validateEmail(_emailController.text);
    final passErr = _validatePassword(_passwordController.text);
    final confirmErr = _validateConfirm(_confirmPasswordController.text);
    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _passwordError = passErr;
      _confirmError = confirmErr;
    });
    return nameErr == null &&
        emailErr == null &&
        passErr == null &&
        confirmErr == null;
  }

  // Errores backend a mensajes amigables

  String _friendlyError(String raw) {
    final msg = raw.replaceAll('Exception: ', '').toLowerCase();

    if (msg.contains('already') ||
        msg.contains('exists') ||
        msg.contains('409') ||
        msg.contains('duplicate')) {
      return 'Ya existe una cuenta con ese correo. Intenta iniciar sesión.';
    }
    if (msg.contains('invalid') || msg.contains('400')) {
      return 'Los datos ingresados no son válidos. Revísalos e intenta de nuevo.';
    }
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'La conexión tardó demasiado. Intenta de nuevo.';
    }
    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return 'Sin conexión. Revisa tu internet e intenta de nuevo.';
    }
    if (msg.contains('500') || msg.contains('server')) {
      return 'Error en el servidor. Intenta más tarde.';
    }
    return 'No se pudo crear la cuenta. Intenta de nuevo.';
  }

  // Signup

  Future<void> _handleSignUp(BuildContext context) async {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) return;

    final viewModel = context.read<SignUpViewModel>();
    if (viewModel.isLoading) return; // guard contra double-tap

    await viewModel.signup(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (context.read<SignUpViewModel>().signupSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please log in.'),
        ),
      );

      context.go('/login');
    }
  }

  // Builders

  InputDecoration _inputDecoration({
    required String hint,
    Widget? suffixIcon,
    bool hasError = false,
  }) {
    final activeBorder = hasError ? errorRed : textPrimary;
    final idleBorder = hasError ? errorRed : borderColor;

    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'PlusJakartaSans',
        fontSize: 14,
        color: Color(0xFFB4B4B4),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: hasError ? errorRedLight : background,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: idleBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide(color: activeBorder, width: 1.6),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
      counterText: '',
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

  @override
  Widget build(BuildContext context) {
    final connectivityModel = context.watch<ConnectivityModel>();
    final viewModel = context.watch<SignUpViewModel>();

    final bool canSubmit = !viewModel.isLoading && connectivityModel.isOnline;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            // Banner de conectividad al tope
            if (!connectivityModel.isOnline)
              const ConnectivityView(),

            // Contenido principal
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
                        controller: _nameController,
                        enabled: connectivityModel.isOnline,
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
                        controller: _emailController,
                        enabled: connectivityModel.isOnline,
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
                      _sectionLabel('PASSWORD'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        obscureText: obscurePassword,
                        enabled: connectivityModel.isOnline,
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
                      _sectionLabel('CONFIRM'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: obscurePassword,
                        enabled: connectivityModel.isOnline,
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
                          onPressed: (viewModel.isLoading || !connectivityModel.isOnline)
                              ? null
                              : () => _handleSignUp(context),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: primaryYellow,
                            foregroundColor: textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Row(
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
                        child: GestureDetector(
                          onTap: () => context.go('/login'),
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
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
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
      ),
    );
  }
}