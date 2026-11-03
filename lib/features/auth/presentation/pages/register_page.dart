import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedRole = 'student';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignUpRequestedEvent(
              displayName: _nameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              role: _selectedRole,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          context.goNamed(AppRoutes.homeName);
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.pop(),
            ),
            title: const Text('Create Account'),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Join LearnHub',
                      style: theme.textTheme.displaySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Start learning or sharing knowledge today',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    // Role Selector
                    Text(
                      'I want to join as:',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                          value: 'student',
                          icon: Icon(Icons.school_outlined),
                          label: Text('Student / Learner'),
                        ),
                        ButtonSegment(
                          value: 'instructor',
                          icon: Icon(Icons.co_present_outlined),
                          label: Text('Instructor'),
                        ),
                      ],
                      selected: {_selectedRole},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          _selectedRole = newSelection.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Full Name Field
                    CustomTextField(
                      label: 'Full Name',
                      hint: 'e.g. Alex Johnson',
                      controller: _nameController,
                      prefixIcon: const Icon(Icons.person_outline),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    CustomTextField(
                      label: 'Email Address',
                      hint: 'name@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.email_outlined),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    CustomTextField(
                      label: 'Password',
                      hint: 'At least 6 characters',
                      controller: _passwordController,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    CustomTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _onRegisterPressed(),
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // Submit Button
                    CustomButton(
                      text: 'Create Account',
                      isLoading: isLoading,
                      onPressed: _onRegisterPressed,
                    ),
                    const SizedBox(height: 24),

                    // Already have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
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
        );
      },
    );
  }
}

