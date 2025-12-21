import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:martfury/src/service/currency_service.dart';
import 'package:martfury/src/service/language_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:martfury/core/app_config.dart';
import 'package:martfury/src/service/token_service.dart';
import 'package:martfury/src/view/screen/splash_screen.dart';
import 'package:martfury/src/view/screen/maintenance_screen.dart';
import 'package:martfury/src/view/screen/server_error_screen.dart';
import 'package:martfury/src/view/screen/no_internet_screen.dart';
import 'package:get/get.dart';

class MaintenanceException implements Exception {
  final String message;
  MaintenanceException(this.message);

  @override
  String toString() => message;
}

class NoInternetException implements Exception {
  final String message;
  NoInternetException(this.message);

  @override
  String toString() => message;
}

class ServerErrorException implements Exception {
  final String message;
  ServerErrorException(this.message);

  @override
  String toString() => message;
}

class BaseService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  void _handleNoInternet() {
    Get.offAll(
      () => NoInternetScreen(
        onRetry: () {
          Get.offAll(() => const SplashScreen());
        },
      ),
    );
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final currency = json.decode(
      prefs.getString(CurrencyService.selectedCurrencyKey) ?? '{}',
    );
    final language = json.decode(
      prefs.getString(LanguageService.selectedLanguageKey) ?? '{}',
    );

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-CURRENCY': (currency?['title'] ?? '').toString(),
      'X-LANGUAGE': (language?['lang_locale'] ?? '').toString(),
      'X-API-KEY': AppConfig.apiKey,
    };

    if (includeAuth) {
      headers['Authorization'] =
          'Bearer ${await TokenService.getToken() ?? ''}';
    }

    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode == 401) {
      await TokenService.deleteToken();
      Get.offAll(() => const SplashScreen());
      throw Exception('Unauthorized');
    }

    if (response.statusCode == 502) {
      Get.offAll(
        () => ServerErrorScreen(
          onRetry: () {
            Get.offAll(() => const SplashScreen());
          },
        ),
      );
      throw ServerErrorException('Bad Gateway - Server Error');
    }

    if (response.statusCode == 503) {
      Get.offAll(
        () => MaintenanceScreen(
          onRetry: () {
            Get.offAll(() => const SplashScreen());
          },
        ),
      );
      throw MaintenanceException('Service Unavailable - Maintenance Mode');
    }

    if (response.statusCode == 404) {
      throw Exception('Not Found - Resource Not Available');
    }

    if (response.statusCode == 500) {
      String errorMessage = 'Internal Server Error';
      try {
        final errorBody = json.decode(response.body);
        errorMessage =
            errorBody['message'] ?? errorBody['error'] ?? errorMessage;
      } catch (e) {
        if (response.body.length < 200) {
          errorMessage = response.body;
        }
      }

      throw Exception('Server Error: $errorMessage');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final decoded = json.decode(response.body);

        if (decoded is bool && decoded == true) {
          throw Exception('API returned error flag: true');
        }

        return decoded;
      } catch (e) {
        if (e is FormatException) {
          return response.body;
        }
        rethrow;
      }
    } else {
      try {
        final errorBody = json.decode(response.body);
        final errorMessage =
            errorBody['message'] ??
            errorBody['error'] ??
            errorBody['errors']?.toString() ??
            'An error occurred';
        throw Exception(errorMessage);
      } on FormatException {
        throw Exception('An error occurred (${response.statusCode})');
      }
    }
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();

      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      );

      return _handleResponse(response);
    } on SocketException {
      _handleNoInternet();
      throw NoInternetException('No internet connection');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, Object> body) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl$endpoint';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      _handleNoInternet();
      throw NoInternetException('No internet connection');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, Object> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      _handleNoInternet();
      throw NoInternetException('No internet connection');
    }
  }

  Future<dynamic> delete(String endpoint, Map<String, Object> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      _handleNoInternet();
      throw NoInternetException('No internet connection');
    }
  }

  Future<dynamic> postAuth(String endpoint, Map<String, Object> body) async {
    try {
      final headers = await _getHeaders(includeAuth: false);
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } on SocketException {
      _handleNoInternet();
      throw NoInternetException('No internet connection');
    }
  }
}
