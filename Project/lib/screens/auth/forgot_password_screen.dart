import 'package:flutter/material.dart';

import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Mock forgot-password flow: validates the email against accounts and
/// shows a success message (Phase 2 will send a real reset link).
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  static const String routeName = '/forgot-password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    await Future<void>.delayed(const Duration(milliseconds: 600)); // mock IO
    final error = AuthService.instance.sendPasswordReset(_emailCtrl.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (error != null) {
        _error = error;
      } else {
        _sent = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: _sent ? _buildSent() : _buildForm(),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.lock_reset, color: AppTheme.red, size: 56),
          const SizedBox(height: 12),
          const Text(
            'Reset your password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the email linked to your RaktaSetu account and we will '
            'send you a reset link.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: AppTheme.textGrey),
          ),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailCtrl,
            label: 'Email',
            hint: 'you@example.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Email is required';
              if (!v.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(
                color: AppTheme.red,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'Send reset link',
            icon: Icons.send_outlined,
            isLoading: _loading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildSent() {
    return Column(
      children: [
        const Icon(Icons.mark_email_read_outlined,
            color: AppTheme.available, size: 64),
        const SizedBox(height: 16),
        const Text(
          'Check your inbox!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'If an account exists for ${_emailCtrl.text.trim()}, a password '
          'reset link is on its way. (Mock flow in Phase 1.)',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13.5, color: AppTheme.textGrey),
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          label: 'Back to login',
          icon: Icons.arrow_back,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
