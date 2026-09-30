import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/auth/providers/auth_provider.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_branding_panel.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_page_background.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailC.dispose();
    super.dispose();
  }

  Future<void> sendResetLink() async {
    // Guard against rapid double-taps before the button has a chance to
    // rebuild as disabled.
    if (isLoading) return;

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .resetPassword(email: emailC.text.trim())
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (result == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 100,
            content: Text(AppLocalizations.of(context)!.resetPasswordSuccess),
            duration: const Duration(seconds: 5),
          ),
        );
        emailC.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 100,
            content: Text(result),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('Reset password error: $e');
      if (mounted) {
        final friendlyMessage = e is TimeoutException
            ? AppLocalizations.of(context)!.requestTimedOut
            : AppLocalizations.of(context)!.unexpectedError;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 100,
            content: Text(
              '${AppLocalizations.of(context)!.errorPrefix} $friendlyMessage',
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Always executes, even after the early `return` above, so the
      // spinner can never get stuck on — as long as the widget is still
      // mounted.
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Blends into the AuthPageBackground gradient below it instead of
        // creating a hard, differently-colored strip at the top.
        backgroundColor: const Color(0xFFEFF3FA),
        elevation: 0,
        title: Text(AppLocalizations.of(context)!.resetPasswordTitle),
        centerTitle: true,
      ),
      body: AuthPageBackground(child: webLayout(context)),
    );
  }

  // ---------------------------------------------------------------------
  // Same responsive, no-scroll layout as the Sign In / Sign Up pages: the
  // branding panel + card are built at their natural/ideal size, then
  // scaled down uniformly (never up) with a FittedBox so the page always
  // fits the viewport with zero scrollbars, on any window size.
  // ---------------------------------------------------------------------
  Widget webLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 800;
        final card = _authCard();

        final content = isWeb
            ? Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 560, child: AuthBrandingPanel()),
                  const SizedBox(width: 48),
                  SizedBox(width: 420, child: card),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 380, child: AuthBrandingPanel()),
                  const SizedBox(height: 28),
                  SizedBox(width: 380, child: card),
                ],
              );

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.center,
              child: content,
            ),
          ),
        );
      },
    );
  }

  Widget _authCard() {
    return Container(
      padding: const EdgeInsets.all(36),
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
      child: resetForm(),
    );
  }

  Widget resetForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.resetPasswordTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF16213E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.resetPasswordDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, color: Color(0xFF5A6A85)),
          ),
          const SizedBox(height: 28),

          //--------------------------------------------------Email Field
          AuthTextField(
            controller: emailC,
            label: AppLocalizations.of(context)!.email,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterEmail;
              }
              if (!RegExp(
                r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
              ).hasMatch(val)) {
                return AppLocalizations.of(context)!.invalidEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 22),

          //--------------------------------------------------Send Button
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
              onPressed: isLoading ? null : sendResetLink,
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
                      AppLocalizations.of(context)!.send,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                AppLocalizations.of(context)!.alreadyHave,
                style: const TextStyle(color: Color(0xFF5A6A85), fontSize: 14),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/login');
                  }
                },
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
          ),
        ],
      ),
    );
  }
}
