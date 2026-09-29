import 'package:http/http.dart' as http;

class AppHttpClient {
  AppHttpClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    return _client.get(url, headers: headers);
  }

  void close() {
    _client.close();
  }
}
