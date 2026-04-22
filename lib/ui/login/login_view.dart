import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../login/login_viewmodel.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_model.dart';
import 'package:marketplace_flutter_application/ui/connectivity/connectivity_view.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const LoginPage();
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool obscurePassword = true;
  bool stayLoggedIn = false;

  String? _emailError;
  String? _passwordError;

  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color background = Color(0xFFF7F7F5);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color borderColor = Color(0xFFBDBDBD);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color errorRedLight = Color(0xFFFFEBEE);
  static const Color errorRedBorder = Color(0xFFEF9A9A);

  static const int _maxEmailLength = 80;
  static const int _maxPasswordLength = 64;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmailFormat(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email.trim());
  }

  String? _validateEmail(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'El correo es requerido';
    if (!_isValidEmailFormat(trimmed)) return 'Ingresa un correo válido';
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

  bool _validateForm() {
    final emailErr = _validateEmail(_emailController.text);
    final passErr = _validatePassword(_passwordController.text);

    setState(() {
      _emailError = emailErr;
      _passwordError = passErr;
    });

    return emailErr == null && passErr == null;
  }

  String _friendlyError(String raw) {
    final msg = raw.replaceAll('Exception: ', '').toLowerCase();

    if (msg.contains('incorrect') ||
        msg.contains('invalid') ||
        msg.contains('unauthorized') ||
        msg.contains('401') ||
        msg.contains('wrong')) {
      return 'Correo o contraseña incorrectos. Verifica tus datos.';
    }
    if (msg.contains('not found') || msg.contains('404')) {
      return 'No encontramos una cuenta con ese correo.';
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

    return 'Algo salió mal. Intenta de nuevo.';
  }

  Future<void> _handleLogin(BuildContext context) async {
    FocusScope.of(context).unfocus();

    if (!_validateForm()) return;

    final viewModel = context.read<LoginViewModel>();
    if (viewModel.isLoading) return;

    await viewModel.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (viewModel.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(milliseconds: 1400),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                '¡Bienvenido! Iniciando sesión…',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 900));
      if (!mounted) return;
      context.go('/Home');
    }
  }

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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
      ),
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

  Widget _fieldError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: errorRed),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: errorRed,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorBanner(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: errorRedLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: errorRedBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 18, color: errorRed),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: errorRed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _partnerButton({
    required IconData icon,
    required String text,
  }) {
    return Expanded(
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textPrimary),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 13,
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
    final connectivityModel = context.watch<ConnectivityModel>();
    final viewModel = context.watch<LoginViewModel>();

    final backendError = viewModel.errorMessage == null
        ? null
        : _friendlyError(viewModel.errorMessage!);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            if (!connectivityModel.isOnline) const ConnectivityView(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        const Row(
                          children: [
                            Icon(
                              Icons.account_balance,
                              size: 18,
                              color: Color(0xFF6A5A00),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'University Marketplace',
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
                          'Login',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Access your academic marketplace\ndashboard.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color.fromARGB(255, 8, 8, 8),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 26),

                        _sectionLabel('UNIVERSITY EMAIL'),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          enabled: connectivityModel.isOnline && !viewModel.isLoading,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          maxLength: _maxEmailLength,
                          onChanged: (_) {
                            if (_emailError != null) {
                              setState(() => _emailError = null);
                            }
                          },
                          onSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_passwordFocusNode);
                          },
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _inputDecoration(
                            hint: 'student@uniandes.edu.co',
                            hasError: _emailError != null,
                            suffixIcon: const Icon(
                              Icons.alternate_email,
                              size: 18,
                              color: Color(0xFF9A9A9A),
                            ),
                          ),
                        ),
                        if (_emailError != null) _fieldError(_emailError!),

                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _sectionLabel('PASSWORD'),
                          ],
                        ),
                        TextField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          obscureText: obscurePassword,
                          enabled: connectivityModel.isOnline && !viewModel.isLoading,
                          textInputAction: TextInputAction.done,
                          maxLength: _maxPasswordLength,
                          onChanged: (_) {
                            if (_passwordError != null) {
                              setState(() => _passwordError = null);
                            }
                          },
                          onSubmitted: (_) => _handleLogin(context),
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 14,
                            color: textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: _inputDecoration(
                            hint: '••••••••',
                            hasError: _passwordError != null,
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
                        if (_passwordError != null) _fieldError(_passwordError!),



                        if (backendError != null) ...[
                          const SizedBox(height: 16),
                          _errorBanner(backendError),
                        ],

                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: (viewModel.isLoading || !connectivityModel.isOnline)
                                ? null
                                : () => _handleLogin(context),
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Color(0xFFFFE600),
                              foregroundColor: textPrimary,
                              disabledBackgroundColor: const Color(0xFFE6E6E6),
                              disabledForegroundColor: const Color(0xFF9E9E9E),
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
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'LOGIN',
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

                        const SizedBox(height: 30),
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: Color(0xFFE0E0E0),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(height: 28),
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go('/signup'),
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  color: textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(text: "Don't have an account? "),
                                  TextSpan(
                                    text: 'Register',
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
              child: const Column(
                children: [
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
                    '© 20226 Uniandes ISIS3510',
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