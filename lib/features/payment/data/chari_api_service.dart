import 'dart:convert';
import 'package:segdude_app/core/config/app_env.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chariApiServiceProvider = Provider((ref) => ChariApiService());

class ChariApiService {
  final String _baseUrl =
      AppEnv.chariApiUrl.isNotEmpty ? AppEnv.chariApiUrl : 'https://sandbox.charimoney.com';
  final String _apiKey = AppEnv.chariApiKey;
  final _uuid = const Uuid();

  // Company Details for Premium Upgrade Destination
  // Default placeholders, meant to be replaced or pulled from .env
  final String _companyRib =
      AppEnv.companyRib.isNotEmpty ? AppEnv.companyRib : '827640000010000000000000';
  final String _companyBeneficiaryName =
      AppEnv.companyBeneficiaryName.isNotEmpty ? AppEnv.companyBeneficiaryName : 'Lkout Premium';

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Chari-Api-Key': _apiKey,
      'C-Request-Id': _uuid.v4(),
    };
  }

  /// 5.1 Bank Transfer Preview
  Future<Map<String, dynamic>> previewBankTransfer({
    required String customerPhoneNumber,
    required double amount,
  }) async {
    final url = Uri.parse('$_baseUrl/api/operations/bank-transfer/preview');
    final body = jsonEncode({
      "customerPhoneNumber": customerPhoneNumber,
      "amount": amount,
      "reason": "Upgrade to Premium",
      "rib": _companyRib,
      "beneficiaryName": _companyBeneficiaryName,
    });

    final response = await http.post(url, headers: _getHeaders(), body: body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception(
        'Failed to preview bank transfer: ${response.statusCode} - ${response.body}',
      );
    }
  }

  /// 5.2 Bank Transfer Execute
  Future<Map<String, dynamic>> executeBankTransfer({
    required String customerPhoneNumber,
    required double amount,
  }) async {
    final url = Uri.parse('$_baseUrl/api/operations/bank-transfer');
    final body = jsonEncode({
      "customerPhoneNumber": customerPhoneNumber,
      "amount": amount,
      "reason": "Upgrade to Premium",
      "rib": _companyRib,
      "beneficiaryName": _companyBeneficiaryName,
    });

    final response = await http.post(url, headers: _getHeaders(), body: body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    } else {
      throw Exception(
        'Failed to execute bank transfer: ${response.statusCode} - ${response.body}',
      );
    }
  }
}
