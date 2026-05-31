import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/password_reset_service.dart';

enum _PasswordResetStep { requestCode, resetPassword, completed }

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _service = const PasswordResetService();

  _PasswordResetStep _step = _PasswordResetStep.requestCode;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _requestCode({bool validateForm = true}) async {
    FocusScope.of(context).unfocus();

    if (validateForm && !_formKey.currentState!.validate()) {
      return;
    }

    if (!validateForm && _validateEmail(_emailController.text) != null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final result = await _service.requestCode(_emailController.text.trim());

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isError = !result.success;
      _message = result.message;
      if (result.success) {
        _step = _PasswordResetStep.resetPassword;
      }
    });
  }

  Future<void> _resetPassword() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _message = null;
    });

    final result = await _service.resetPassword(
      email: _emailController.text.trim(),
      code: _codeController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _isError = !result.success;
      _message = result.message;
      if (result.success) {
        _step = _PasswordResetStep.completed;
      }
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email wajib diisi';
    if (!email.contains('@')) return 'Format email belum valid';
    return null;
  }

  String? _validateCode(String? value) {
    final code = value?.trim() ?? '';
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return 'Masukkan kode verifikasi 6 digit';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Password baru wajib diisi';
    if (password.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  String? _validatePasswordConfirmation(String? value) {
    if (value != _passwordController.text) {
      return 'Konfirmasi password belum sama';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (_step == _PasswordResetStep.resetPassword) {
              setState(() {
                _step = _PasswordResetStep.requestCode;
                _message = null;
              });
              return;
            }

            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Kembali',
        ),
        title: const Text('Lupa Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 82,
                          height: 82,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _title,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.h1.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _description,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodySecondary.copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 26),
                    if (_step == _PasswordResetStep.requestCode)
                      CustomTextField(
                        controller: _emailController,
                        hintText: 'Email akun Pluffy',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: _validateEmail,
                        onFieldSubmitted: (_) =>
                            _isLoading ? null : _requestCode(),
                      ),
                    if (_step == _PasswordResetStep.resetPassword) ...[
                      CustomTextField(
                        controller: _codeController,
                        hintText: 'Kode verifikasi 6 digit',
                        prefixIcon: Icons.pin_outlined,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(6),
                        ],
                        validator: _validateCode,
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Password baru',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        textInputAction: TextInputAction.next,
                        validator: _validatePassword,
                        suffixIcon: _visibilityButton(
                          isObscured: _obscurePassword,
                          onPressed: () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomTextField(
                        controller: _passwordConfirmationController,
                        hintText: 'Ulangi password baru',
                        prefixIcon: Icons.lock_reset_outlined,
                        obscureText: _obscureConfirmation,
                        textInputAction: TextInputAction.done,
                        validator: _validatePasswordConfirmation,
                        onFieldSubmitted: (_) =>
                            _isLoading ? null : _resetPassword(),
                        suffixIcon: _visibilityButton(
                          isObscured: _obscureConfirmation,
                          onPressed: () {
                            setState(
                              () =>
                                  _obscureConfirmation = !_obscureConfirmation,
                            );
                          },
                        ),
                      ),
                    ],
                    if (_message != null) ...[
                      const SizedBox(height: 14),
                      _MessageBox(message: _message!, isError: _isError),
                    ],
                    const SizedBox(height: 22),
                    if (_step == _PasswordResetStep.requestCode)
                      CustomButton(
                        text: 'Kirim Kode Verifikasi',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _requestCode,
                      ),
                    if (_step == _PasswordResetStep.resetPassword) ...[
                      CustomButton(
                        text: 'Simpan Password Baru',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _resetPassword,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () => _requestCode(validateForm: false),
                        child: const Text('Kirim ulang kode'),
                      ),
                    ],
                    if (_step == _PasswordResetStep.completed)
                      CustomButton(
                        text: 'Kembali ke Login',
                        onPressed: () => context.go('/auth'),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String get _title {
    switch (_step) {
      case _PasswordResetStep.requestCode:
        return 'Atur Ulang Password';
      case _PasswordResetStep.resetPassword:
        return 'Masukkan Kode Verifikasi';
      case _PasswordResetStep.completed:
        return 'Password Berhasil Diubah';
    }
  }

  String get _description {
    switch (_step) {
      case _PasswordResetStep.requestCode:
        return 'Masukkan email akunmu. Kami akan mengirim kode verifikasi untuk membuat password baru.';
      case _PasswordResetStep.resetPassword:
        return 'Periksa email ${_emailController.text.trim()} dan masukkan kode yang berlaku selama 15 menit.';
      case _PasswordResetStep.completed:
        return 'Silakan masuk kembali menggunakan password baru kamu.';
    }
  }

  Widget _visibilityButton({
    required bool isObscured,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: AppColors.textSecondary,
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final bool isError;

  const _MessageBox({required this.message, required this.isError});

  @override
  Widget build(BuildContext context) {
    final color = isError ? AppColors.error : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        message,
        style: AppTextStyles.bodySecondaryMedium.copyWith(color: color),
      ),
    );
  }
}
