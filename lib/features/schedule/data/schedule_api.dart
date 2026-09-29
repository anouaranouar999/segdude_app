import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:segdude_app/core/storage/shared_preferences_service.dart';
import 'package:segdude_app/features/schedule/domain/models_decoder.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Holds the result of [ScheduleApi.getLastGeneratedSchedule].
/// [schedule] is the decoded schedule, [inputData] is the raw input map
/// (rooms, teachers, subjects, etc.) that was used to generate it.
class ServerScheduleResult {
  final ScheduleDecoder schedule;
  final Map<String, dynamic> inputData;

  const ServerScheduleResult({required this.schedule, required this.inputData});
}

class ScheduleApi {
  final prefs = SharedPreferencesService();

  ScheduleApi._internal();
  static final ScheduleApi _instance = ScheduleApi._internal();

  factory ScheduleApi({http.Client? client}) {
    if (client != null) {
      _instance._client = client;
    }
    return _instance;
  }

  http.Client _client = http.Client();

  // Define your server list here
  final List<String> _servers = [
    'https://lkout.ghost-taipan.ts.net',
    'https://server2.ghost-taipan.ts.net',
    'https://madariss-back.fastapicloud.dev',
  ];

  /// Returns the URL of the first healthy server, or null if none are available.
  Future<String?> _getHealthyServer() async {
    for (final baseUrl in _servers) {
      try {
        final response = await _client
            .head(Uri.parse('$baseUrl/schedule/create'))
            .timeout(const Duration(seconds: 3));

        if (response.statusCode >= 200 && response.statusCode < 500) {
          debugPrint('used server: $baseUrl');
          return baseUrl;
        }
      } catch (e) {
        debugPrint('Error connecting to $baseUrl: $e');
        continue; // Try next server
      }
    }
    return null; // No servers available
  }

  /// Calls /schedule/estimate and returns the parsed response map,
  /// or null if the request fails or returns errors.
  Future<Map<String, dynamic>?> estimateSchedule(
    dynamic data,
    String lang,
  ) async {
    final baseUrl = await _getHealthyServer();
    if (baseUrl == null) return null;

    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      final response = await _client
          .post(
            Uri.parse('$baseUrl/schedule/estimate'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({...data as Map<String, dynamic>, 'lang': lang}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && !decoded.containsKey('detail')) {
          return decoded;
        }
      }
    } catch (e) {
      debugPrint('Estimate request failed: $e');
    }
    return null;
  }

  /// Calls /schedule/create with [data] and the UI locale [lang],
  /// persists the raw response, and returns a decoded [ScheduleDecoder].
  /// /////////////////////////////////////////////////////////////////////////////////////////////// ROOT FUNCTION
  Future<Map<String, dynamic>> fetchSchedule(dynamic data, String lang) async {
    // print('fetchSchedule data: $data');
    final baseUrl = await _getHealthyServer();
    if (baseUrl == null) {
      return {
        'error': ScheduleDecoder(
          error: {'error': 'No servers available. Please try again later.'},
          classes: [],
        ),
      };
    }

    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    final response = await _client.post(
      Uri.parse('$baseUrl/schedule/create'),
      headers: <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode({...data as Map<String, dynamic>, 'lang': lang}),
    );
    if (response.statusCode == 201) {
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      // Save the full server response so that ScheduleSerialization can
      // round-trip all three tab data sets (schedule, teacherSchedule,
      // teacherShiftGroups).
      await prefs.saveString('last_generated_schedule', response.body);
      final decoded = ScheduleDecoder.fromJson(responseJson);
      return {"schedule": decoded};
    }
    throw Exception('Failed to load data from server ${response.body}');
  }

  ///------------------------------------------------------ Get last Generated Schedule from Server------------------------------------------------------
  /// Fetches the last generated schedule for the current premium user.
  ///
  /// Strategy: **network-first, prefs-fallback**.
  /// - Always attempts to reach the server first.
  /// - On success, refreshes the local prefs cache with the server response.
  /// - If the server is unreachable, times out, or returns an unexpected
  ///   status, falls back to the last schedule stored in SharedPreferences
  ///   (key `'last_generated_schedule'`).  In offline mode [inputData] will
  ///   be an empty map because only the schedule JSON is cached locally.
  Future<ServerScheduleResult?> getLastGeneratedSchedule() async {
    // ── 1. Try the server ────────────────────────────────────────────────────
    final baseUrl = await _getHealthyServer();

    if (baseUrl != null) {
      try {
        final token = Supabase.instance.client.auth.currentSession?.accessToken;
        final response = await _client
            .post(
              Uri.parse('$baseUrl/schedule/last-generated'),
              headers: <String, String>{
                'Accept': 'application/json',
                'Content-Type': 'application/json; charset=UTF-8',
                if (token != null) 'Authorization': 'Bearer $token',
              },
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final scheduleJson = decoded['schedule'] as Map<String, dynamic>?;
          final inputData = decoded['input_data'] as Map<String, dynamic>?;

          if (scheduleJson == null || inputData == null) {
            debugPrint(
              'getLastGeneratedSchedule: missing schedule or input_data in response',
            );
          } else {
            // Keep the local cache fresh with the full server response so
            // that all three tab datasets survive an offline restart.
            await prefs.saveString(
              'last_generated_schedule',
              jsonEncode(decoded),
            );
            return ServerScheduleResult(
              schedule: ScheduleDecoder.fromJson(decoded),
              inputData: inputData,
            );
          }
        } else {
          debugPrint(
            'getLastGeneratedSchedule: unexpected status ${response.statusCode}',
          );
        }
      } catch (e) {
        debugPrint('getLastGeneratedSchedule server call failed: $e');
      }
    } else {
      debugPrint('getLastGeneratedSchedule: no healthy server — trying cache');
    }

    // ── 2. Offline fallback: read from SharedPreferences ────────────────────
    try {
      final cachedJson = await prefs.getString('last_generated_schedule');
      if (cachedJson != null && cachedJson.isNotEmpty && cachedJson != 'null') {
        debugPrint('getLastGeneratedSchedule: serving from local cache');
        return ServerScheduleResult(
          schedule: ScheduleDecoder.fromJson(
            jsonDecode(cachedJson) as Map<String, dynamic>,
          ),
          // input_data is not cached locally; callers that need it for
          // re-generation will handle the empty map gracefully — that path
          // requires a healthy server anyway.
          inputData: const {},
        );
      }
    } catch (e) {
      debugPrint('getLastGeneratedSchedule: cache read failed: $e');
    }

    return null;
  }

  /// Calls the license endpoint and returns a map with 'isPremium' (bool)
  /// and 'licenseType' (String), or null if the request fails / user is not
  /// authenticated.
  Future<Map<String, dynamic>?> checkUserLicense() async {
    final baseUrl = await _getHealthyServer();
    if (baseUrl == null) return null;

    try {
      final token = Supabase.instance.client.auth.currentSession?.accessToken;
      if (token == null) return null;

      final response = await _client
          .post(
            Uri.parse('$baseUrl/schedule/check-license'),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json; charset=UTF-8',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      }
    } catch (e) {
      debugPrint('checkUserLicense failed: $e');
    }
    return null;
  }

  /// Closes the current HTTP client and replaces it with a fresh one,
  /// effectively cancelling any in-flight requests.
  void dispose() {
    _client.close();
    _client = http.Client();
  }
}
