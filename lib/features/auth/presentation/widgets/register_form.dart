import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skyshare_frontend_mobile/core/i18n/app_localizations.dart';
import 'auth_buttons.dart';
import '../../providers/auth_provider.dart';

class RegisterForm extends StatefulWidget {
  final VoidCallback onLoginTap;
  const RegisterForm({required this.onLoginTap, super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        await Provider.of<AuthProvider>(context, listen: false).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          username: _nameController.text.trim(),
        );
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)
                        ?.t('error_generic')
                        .replaceAll('{err}', e.toString()) ??
                    'Error: ${e.toString()}',
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            const SizedBox(height: 12),
            Text(AppLocalizations.of(context)?.t('auth.register') ?? 'Register', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 18),
          Form(
            key: _formKey,
            child: Column(
              children: [
                _buildNameInput(),
                const SizedBox(height: 12),
                _buildEmailInput(),
                const SizedBox(height: 12),
                _buildPasswordInput(),
                const SizedBox(height: 16),
                PrimaryButton(
                  label: AppLocalizations.of(context)?.t('auth.register') ?? 'Register',
                  onPressed: _isLoading ? null : _submit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 12),
                Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)?.t('auth.already_have_account_prefix') ?? 'Already have an account? ', style: const TextStyle(color: Colors.white70)),
                      GestureDetector(
                        onTap: _isLoading ? null : widget.onLoginTap,
                        child: Text(AppLocalizations.of(context)?.t('auth.login') ?? 'Login', style: const TextStyle(decoration: TextDecoration.underline, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Center(child: Text(AppLocalizations.of(context)?.t('auth.or') ?? 'Or', style: const TextStyle(color: Colors.white54))),
                const SizedBox(height: 12),
                GoogleButton(
                  label: AppLocalizations.of(context)?.t('auth.continue_with_google') ?? 'Continue with Google',
                  onPressed: _isLoading ? null : _signInWithGoogle,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInput() {
    return TextFormField(
      controller: _nameController,
      keyboardType: TextInputType.name,
      enabled: !_isLoading,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)?.t('auth.name_hint') ?? 'Name',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withAlpha((0.03 * 255).round()),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: const BorderSide(color: Colors.white24)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: const BorderSide(color: Colors.white54)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)?.t('auth.name_required') ?? 'Name is required';
        }
        if (value.length < 2) {
          return AppLocalizations.of(context)?.t('auth.name_min_length') ?? 'Name must be at least 2 characters';
        }
        if (value.length > 50) {
          return AppLocalizations.of(context)?.t('auth.name_max_length') ?? 'Name must be less than 50 characters';
        }
        return null;
      },
    );
  }

  Widget _buildEmailInput() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      enabled: !_isLoading,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
  hintText: AppLocalizations.of(context)?.t('auth.email_hint') ?? 'Email',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withAlpha((0.03 * 255).round()),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: const BorderSide(color: Colors.white24)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: const BorderSide(color: Colors.white54)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)?.t('auth.email_required') ?? 'Email is required';
        }
        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
        if (!emailRegex.hasMatch(value)) {
          return AppLocalizations.of(context)?.t('auth.invalid_email') ?? 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordInput() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      enabled: !_isLoading,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
  hintText: AppLocalizations.of(context)?.t('auth.password_hint') ?? 'Password',
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withAlpha((0.03 * 255).round()),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: const BorderSide(color: Colors.white24)
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10), 
          borderSide: const BorderSide(color: Colors.white54)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)?.t('auth.password_required') ?? 'Password is required';
        }
        if (value.length < 6) {
          return AppLocalizations.of(context)?.t('auth.password_min_length') ?? 'Password must be at least 6 characters';
        }
        if (value.length > 128) {
          return AppLocalizations.of(context)?.t('auth.password_max_length') ?? 'Password must be less than 128 characters';
        }
        return null;
      },
    );
  }
}