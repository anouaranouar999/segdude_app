import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:segdude_app/features/schedule/data/schedule_api.dart';

final currentScheduleProvider = StateProvider<ScheduleDecoder?>((ref) => null);

class UserLicenseState {
  final String? userId;
  final bool isPremium;
  final String? licenseType;
  final bool isLoading;

  UserLicenseState({
    this.userId,
    this.isPremium = false,
    this.licenseType,
    this.isLoading = false,
  });
}

class UserLicenseNotifier extends Notifier<UserLicenseState> {
  @override
  UserLicenseState build() {
    // Listen to auth state changes to check license on sign-in and reset on sign-out
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        checkLicense();
      } else if (event == AuthChangeEvent.signedOut) {
        state = UserLicenseState();
      }
    });
    return UserLicenseState();
  }

  Future<void> checkLicense() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      state = UserLicenseState();
      return;
    }

    if (state.userId == user.id && !state.isLoading) {
      return;
    }

    state = UserLicenseState(userId: user.id, isLoading: true);
    try {
      final api = ScheduleApi();
      final res = await api.checkUserLicense();
      if (res != null) {
        state = UserLicenseState(
          userId: user.id,
          isPremium: res['isPremium'] == true,
          licenseType: res['licenseType'] as String?,
          isLoading: false,
        );
      } else {
        state = UserLicenseState(
          userId: user.id,
          isPremium: false,
          isLoading: false,
        );
      }
    } catch (_) {
      state = UserLicenseState(
        userId: user.id,
        isPremium: false,
        isLoading: false,
      );
    }
  }
}

final userLicenseProvider =
    NotifierProvider<UserLicenseNotifier, UserLicenseState>(
      UserLicenseNotifier.new,
    );
