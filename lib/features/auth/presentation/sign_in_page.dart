import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_branding_panel.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_page_background.dart';
import 'package:segdude_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:segdude_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:segdude_app/l10n/app_localizations.dart';

class SignInPage extends ConsumerStatefulWidget {
  final String? from;
  const SignInPage({super.key, this.from});

  @override
  ConsumerState<SignInPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final emailC = TextEditingController();
  final passC = TextEditingController();
  bool isLoading = false;
  bool isObscure = true;
  @override
  void dispose() {
    emailC.dispose();
    passC.dispose();
    super.dispose();
  }

  Future<void> login() async {
    // Guard against rapid double-taps before the button has a chance to
    // rebuild as disabled.
    if (isLoading) return;

    // Validate BEFORE entering the loading state. This was the root cause
    // of the "spinner never stops" bug: isLoading used to be set to true
    // unconditionally, before validation ran, with no path to reset it
    // back to false when validation failed.
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() {
      isLoading = true;
    });

    try {
      final res = await ref
          .read(authRepositoryProvider)
          .signIn(email: emailC.text, password: passC.text)
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (res == 'success') {
        //-------------------------- create user table for the new user if not exist
        // Fire-and-forget, but never let it become an unhandled Future
        // rejection if it fails after we've already moved on.
        ref.read(authRepositoryProvider).createUserTable().catchError((error) {
          debugPrint('createUserTable failed: $error');
          return Future.value('success');
        });
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(widget.from ?? '/', extra: widget.from);
        }
      } else if (res == 'Email not confirmed') {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.info),
              content: SizedBox(
                height: 50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${AppLocalizations.of(context)!.emailNotConfirmedError} ${AppLocalizations.of(context)!.pleaseConfirmEmail}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.emailWillBeSentTo} ${emailC.text}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text(AppLocalizations.of(context)!.ok),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            elevation: 100,
            content: Text(res),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      debugPrint('Sign-in error: $e');
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
        title: Text(AppLocalizations.of(context)!.signIn),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              if (widget.from == '/') {
                context.go('/');
              } else {
                context.go(widget.from ?? '/');
              }
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),
      body: AuthPageBackground(child: webLayout(context)),
    );
  }

  // ---------------------------------------------------------------------
  // Responsive, no-scroll layout: the branding panel + card are built at
  // their natural/ideal size, then scaled down uniformly (never up) with a
  // FittedBox so the page always fits the viewport with zero scrollbars,
  // on any window size.
  // ---------------------------------------------------------------------
  Widget webLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWeb = constraints.maxWidth >= 1000;
        final card = _authCard(width: isWeb ? 420 : 380);

        final content = isWeb
            ? Row(
                // mainAxisSize.max (default) + asymmetric Spacers instead of
                // Center(): the branding panel + card block was previously
                // dead-centered, but the card's solid white/shadowed block
                // reads as visually heavier than the looser branding
                // content next to it, so a perfectly centered block still
                // *looks* card-heavy/right-shifted. Giving the right side
                // slightly more flexible space than the left nudges the
                // whole composition — and the card — gently left, so the
                // two sections feel balanced rather than just measured
                // equally. Ratio is proportional, so it scales sensibly
                // across large-screen widths instead of being a fixed
                // pixel offset.
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(flex: 4),
                  const SizedBox(width: 500, child: AuthBrandingPanel()),
                  const SizedBox(width: 48),
                  SizedBox(width: 420, child: card),
                  const Spacer(flex: 5),
                ],
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 500, child: card),
                    const SizedBox(height: 28),
                    const SizedBox(width: 380, child: AuthBrandingPanel()),
                  ],
                ),
              );

        return Center(
          child: Padding(padding: const EdgeInsets.all(10), child: content),
        );
      },
    );
  }

  Widget _authCard({required double width}) {
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
      child: loginForm(),
    );
  }

  Widget loginForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppLocalizations.of(context)!.signIn,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF16213E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            AppLocalizations.of(context)!.signInSubtitle,
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
          const SizedBox(height: 14),

          //--------------------------------------------------Password Field
          AuthTextField(
            controller: passC,
            label: AppLocalizations.of(context)!.password,
            icon: Icons.lock_outline_rounded,
            obscureText: isObscure,
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  isObscure = !isObscure;
                });
              },
              icon: Icon(
                isObscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: const Color(0xFF8792A6),
              ),
            ),
            validator: (val) {
              if (val == null || val.isEmpty) {
                return AppLocalizations.of(context)!.pleaseEnterPassword;
              }
              if (val.length < 6) {
                return AppLocalizations.of(context)!.shortPassword;
              }
              return null;
            },
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => context.push('/login/reset_password'),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                AppLocalizations.of(context)!.forgotPassword,
                style: const TextStyle(
                  color: Color(0xFF2A6FDB),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),

          //--------------------------------------------------Login Button
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
              onPressed: isLoading ? null : login,
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
                      AppLocalizations.of(context)!.signIn,
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
                AppLocalizations.of(context)!.dontHaveAccount,
                style: const TextStyle(color: Color(0xFF5A6A85), fontSize: 14),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => context.pushReplacement('/sign_up'),
                child: Text(
                  AppLocalizations.of(context)!.signUp,
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
