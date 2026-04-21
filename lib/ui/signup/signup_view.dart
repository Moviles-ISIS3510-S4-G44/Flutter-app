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
        SnackBar(
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(milliseconds: 2000),
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                '¡Cuenta creada! Ya puedes iniciar sesión.',
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
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
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
            if (!connectivityModel.isOnline) const ConnectivityView(),

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

                      // Logo
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

                      // Title
                      const Text(
                        'Únete a la comunidad',
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
                        'Crear cuenta',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: textPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 26),

                      // Name
                      _sectionLabel('NOMBRE COMPLETO'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        enabled: connectivityModel.isOnline,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.words,
                        maxLength: _maxNameLength,
                        onChanged: (_) {
                          if (_nameError != null) {
                            setState(() => _nameError = null);
                          }
                          if (viewModel.errorMessage != null) {
                            context.read<SignUpViewModel>().clearError();
                          }
                        },
                        onSubmitted: (_) =>
                            FocusScope.of(context).requestFocus(_emailFocusNode),
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(
                          hint: 'Juan Pérez',
                          hasError: _nameError != null,
                          suffixIcon: const Icon(
                            Icons.person,
                            size: 18,
                            color: Color(0xFF9A9A9A),
                          ),
                        ),
                      ),
                      if (_nameError != null) _fieldError(_nameError!),

                      const SizedBox(height: 20),

                      // Email
                      _sectionLabel('CORREO UNIVERSITARIO'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        enabled: connectivityModel.isOnline,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        maxLength: _maxEmailLength,
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        onChanged: (_) {
                          if (_emailError != null) {
                            setState(() => _emailError = null);
                          }
                          if (viewModel.errorMessage != null) {
                            context.read<SignUpViewModel>().clearError();
                          }
                        },
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_passwordFocusNode),
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(
                          hint: 'usuario@uniandes.edu.co',
                          hasError: _emailError != null,
                          suffixIcon: const Icon(
                            Icons.alternate_email,
                            size: 18,
                            color: Color(0xFF9A9A9A),
                          ),
                        ),
                      ),
                      if (_emailError != null) _fieldError(_emailError!),

                      const SizedBox(height: 20),

                      // Password
                      _sectionLabel('CONTRASEÑA'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: obscurePassword,
                        enabled: connectivityModel.isOnline,
                        textInputAction: TextInputAction.next,
                        maxLength: _maxPasswordLength,
                        onChanged: (_) {
                          if (_passwordError != null) {
                            setState(() => _passwordError = null);
                          }
                          // Re-validar confirm si ya tenía error
                          if (_confirmError != null) {
                            setState(() {
                              _confirmError = _validateConfirm(
                                  _confirmPasswordController.text);
                            });
                          }
                        },
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_confirmFocusNode),
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
                            onPressed: () =>
                                setState(() => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                      if (_passwordError != null) _fieldError(_passwordError!),

                      const SizedBox(height: 20),

                      // Confirm password
                      _sectionLabel('CONFIRMAR CONTRASEÑA'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _confirmPasswordController,
                        focusNode: _confirmFocusNode,
                        obscureText: obscureConfirm,
                        enabled: connectivityModel.isOnline,
                        textInputAction: TextInputAction.done,
                        maxLength: _maxPasswordLength,
                        onChanged: (_) {
                          if (_confirmError != null) {
                            setState(() => _confirmError = null);
                          }
                        },
                        onSubmitted: (_) {
                          if (canSubmit) _handleSignUp(context);
                        },
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          color: textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: _inputDecoration(
                          hint: '••••••••',
                          hasError: _confirmError != null,
                          suffixIcon: IconButton(
                            splashRadius: 18,
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 18,
                              color: const Color(0xFF9A9A9A),
                            ),
                            onPressed: () =>
                                setState(() => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                      ),
                      if (_confirmError != null) _fieldError(_confirmError!),

                      const SizedBox(height: 22),

                      // Backend error banner
                      if (viewModel.errorMessage != null) ...[
                        _errorBanner(_friendlyError(viewModel.errorMessage!)),
                        const SizedBox(height: 16),
                      ],

                      // Register button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              canSubmit ? () => _handleSignUp(context) : null,
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: primaryYellow,
                            foregroundColor: textPrimary,
                            disabledBackgroundColor:
                                primaryYellow.withOpacity(0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: viewModel.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: textPrimary,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'REGISTRARSE',
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

                      // Login link
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
                                TextSpan(text: '¿Ya tienes cuenta? '),
                                TextSpan(
                                  text: 'Inicia sesión',
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
                  top: BorderSide(color: Color(0xFFE4E4E4), width: 1),
                ),
              ),
              child: Column(
                children: const [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'POLÍTICA DE PRIVACIDAD',
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
                        'TÉRMINOS DE USO',
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