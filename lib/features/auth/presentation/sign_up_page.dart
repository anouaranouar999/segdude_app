import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_branding_panel.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_page_background.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:segdude_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final firstNameC = TextEditingController();
  final lastNameC = TextEditingController();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final confirmC = TextEditingController();
  final phoneC = TextEditingController();
  final instC = TextEditingController();

  String? selectedRole;
  bool isLoading = false;
  String message = "";
  bool isPasswordVisible = false;
  @override
  void dispose() {
    firstNameC.dispose();
    lastNameC.dispose();
    emailC.dispose();
    passC.dispose();
    confirmC.dispose();
    phoneC.dispose();
    instC.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    // Guard against rapid double-taps before the button has a chance to
    // rebuild as disabled.
    if (isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    // Note: no separate `selectedRole == null` check is needed here — the
    // role dropdown has its own validator, so Form.validate() above already
    // returns false (and shows the inline error) when no role is selected.

    setState(() {
      isLoading = true;
      message = "";
    });

    FocusScope.of(context).unfocus();

    try {
      final authActions = ref.read(authRepositoryProvider);

      final result = await authActions
          .signUp(
            email: emailC.text.trim(),
            password: passC.text,
            name: firstNameC.text.trim(),
            lastName: lastNameC.text.trim(),
            role: selectedRole!,
            phone: phoneC.text.trim(),
            institution: instC.text.trim(),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (result == 'success') {
        context.pushReplacement('/login');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result)));
      }
    } catch (e) {
      debugPrint('Sign-up error: $e');
      if (mounted) {
        setState(() {
          message = e is TimeoutException
              ? AppLocalizations.of(context)!.requestTimedOut
              : AppLocalizations.of(context)!.unexpectedError;
        });
      }
    } finally {
      // Always executes, even after the early `return` above, so the
      // spinner can never get stuck on — as long as the widget is still
      // mounted.
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AuthPageBackground(child: webLayout(context)));
  }

  // ---------------------------------------------------------------------
  // Responsive, no-scale layout: on wide (web) viewports the branding panel
  // and card sit side by side at their natural size. On narrow (mobile)
  // viewports they stack, and the whole column is wrapped in a
  // SingleChildScrollView so content that's taller than the viewport
  // scrolls instead of overflowing or being squeezed by a FittedBox.
  // Same strategy as SignInPage.webLayout, kept in sync with it.
  // ---------------------------------------------------------------------
  Widget webLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 1040;
        final card = _authCard();

        final content = isWeb
            ? SingleChildScrollView(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 500, child: AuthBrandingPanel()),
                    const SizedBox(width: 10),
                    SizedBox(width: 460, child: card),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 600, child: card),
                    const SizedBox(height: 28),
                    const SizedBox(width: 380, child: AuthBrandingPanel()),
                  ],
                ),
              );

        return Center(
          child: Padding(padding: const EdgeInsets.all(20), child: content),
        );
      },
    );
  }

  Widget _authCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppLocalizations.of(context)!.signUp,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF16213E),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppLocalizations.of(context)!.signUpSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF5A6A85)),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                // -------------------------------------------First Name
                Expanded(
                  child: AuthTextField(
                    controller: firstNameC,
                    label: AppLocalizations.of(context)!.firstName,
                    icon: Icons.person_outline_rounded,
                    validator: (val) => (val == null || val.isEmpty)
                        ? AppLocalizations.of(context)!.emptyFirstName
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                // -------------------------------------------Last Name
                Expanded(
                  child: AuthTextField(
                    controller: lastNameC,
                    label: AppLocalizations.of(context)!.lastName,
                    icon: Icons.person_outline_rounded,
                    validator: (val) => (val == null || val.isEmpty)
                        ? AppLocalizations.of(context)!.emptyLastName
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // -------------------------------------------Email
            AuthTextField(
              controller: emailC,
              label: AppLocalizations.of(context)!.email,
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return AppLocalizations.of(context)!.fillAllFields;
                }
                final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,}$");
                if (!emailRegex.hasMatch(val)) {
                  return AppLocalizations.of(context)!.invalidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                // -------------------------------------------Password
                Expanded(
                  child: AuthTextField(
                    controller: passC,
                    label: AppLocalizations.of(context)!.password,
                    icon: Icons.lock_outline_rounded,
                    obscureText: !isPasswordVisible,
                    suffixIcon: IconButton(
                      onPressed: () => setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      }),
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: const Color(0xFF8792A6),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppLocalizations.of(context)!.fillAllFields;
                      }
                      if (val.length < 6) {
                        return AppLocalizations.of(context)!.shortPassword;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // -------------------------------------------Confirm Password
                Expanded(
                  child: AuthTextField(
                    controller: confirmC,
                    label: AppLocalizations.of(context)!.confirmPassword,
                    icon: Icons.lock_outline_rounded,
                    obscureText: !isPasswordVisible,
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return AppLocalizations.of(context)!.fillAllFields;
                      }
                      if (val != passC.text) {
                        return AppLocalizations.of(context)!.passwordNotMatch;
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // -------------------------------------------Role
            buildRoleDropdown(),
            const SizedBox(height: 12),

            // -------------------------------------------Phone
            AuthTextField(
              controller: phoneC,
              label: AppLocalizations.of(context)!.phone,
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (val) => null,
            ),
            const SizedBox(height: 12),

            // -------------------------------------------Institution
            AuthTextField(
              controller: instC,
              label: AppLocalizations.of(context)!.institution,
              icon: Icons.apartment_outlined,
              validator: (val) => null,
            ),
            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2A6FDB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: isLoading ? null : signup,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        AppLocalizations.of(context)!.signUp,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            if (message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent, fontSize: 13),
              ),
            ],
            const SizedBox(height: 18),
            signInRow(),
          ],
        ),
      ),
    );
  }

  Widget buildRoleDropdown() {
    final Map<String, String> roleMap = {
      'director': AppLocalizations.of(context)!.roleDirector,
      'supervisor': AppLocalizations.of(context)!.roleSupervisor,
      'teacher': AppLocalizations.of(context)!.roleTeacher,
      'student': AppLocalizations.of(context)!.roleStudent,
    };

    return DropdownButtonFormField<String>(
      initialValue: selectedRole,
      validator: (value) => (value == null || value.isEmpty)
          ? AppLocalizations.of(context)!.pleaseSelectRole
          : null,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.roleLabel,
        prefixIcon: const Icon(
          Icons.badge_outlined,
          size: 20,
          color: Color(0xFF8792A6),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        filled: true,
        fillColor: const Color(0xFFF7F9FC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A6FDB), width: 1.4),
        ),
      ),
      items: roleMap.entries.map((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Text(entry.value, style: const TextStyle(fontSize: 14.5)),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          selectedRole = value;
        });
      },
    );
  }

  Widget signInRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context)!.alreadyHave,
          style: const TextStyle(color: Color(0xFF5A6A85), fontSize: 14),
        ),
        const SizedBox(width: 4),
        InkWell(
          onTap: () => context.pushReplacement('/login'),
          child: Text(
            AppLocalizations.of(context)!.signInLabel,
            style: const TextStyle(
              color: Color(0xFF2A6FDB),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
