// lib/services/mongo_api_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb; // For kIsWeb
import 'dart:io' show Platform; // For Platform.isAndroid, Platform.isIOS etc.
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart'; // For getting ID token

// --- MAKE SURE THESE PACKAGE IMPORTS ARE CORRECT FOR YOUR PROJECT ---
// Replace 'YOUR_APP_PACKAGE_NAME' with your actual app name from pubspec.yaml
import '/screens/DoctorDirectory/DoctorDirectoryScreen.dart' show Doctor;
import '/screens/Resources/ResourceItem.dart';

class MongoApiService {
  static const String _defaultPort = '5000';
  static const String _apiPath = '/api';

  // Common base URLs
  static const String _localHostBase = 'http://localhost:$_defaultPort$_apiPath';
  static const String _androidEmulatorBase = 'http://10.0.2.2:$_defaultPort$_apiPath';

  // For physical device or if 10.0.2.2 emulator loopback has issues.
  // !!! YOU MUST MANUALLY UPDATE THIS IP IF YOUR COMPUTER'S LAN IP CHANGES !!!
  static const String _manualLanIpBase = 'http://192.168.100.96:$_defaultPort$_apiPath';
  // Example: static const String _manualLanIpBase = 'http://192.168.100.58:$_defaultPort$_apiPath';


  String get _baseUrl {
    String url;
    if (kIsWeb) {
      // Running in a web browser. If server is on same machine, localhost works.
      url = _localHostBase;
    } else if (Platform.isAndroid) {
      // For Android Emulator, 10.0.2.2 points to host's localhost.
      // If you consistently have issues with 10.0.2.2 (e.g. semaphore timeouts
      // that are not firewall related), you might switch to _manualLanIpBase here too,
      // but 10.0.2.2 is the standard.
      url = _androidEmulatorBase;
      // url = _manualLanIpBase; // Alternative for Android Emulator if 10.0.2.2 fails
    } else if (Platform.isIOS) {
      // For iOS Simulator, localhost typically works if server is on the same Mac.
      // For a physical iOS device on same WiFi, you'd use _manualLanIpBase.
      url = _localHostBase; // Assuming simulator and server on same Mac
      // url = _manualLanIpBase; // For physical iOS device
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // If the Flutter app itself is a desktop app running on the same machine as the server.
      url = _localHostBase;
    }
    else {
      // Fallback for other platforms or if you want to force LAN IP for specific cases.
      // This is primarily for physical devices on the same local network as the dev machine.
      print("Warning: Platform not explicitly handled for _baseUrl, defaulting to manual LAN IP. Check if this is intended.");
      url = _manualLanIpBase;
    }
    print("********** MongoApiService: Using Base URL: $url **********");
    return url;
  }

  Future<String?> _getIdToken() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken(true); // Force refresh
    } catch (e) {
      print("Error getting ID token: $e");
      return null;
    }
  }

  // --- Doctor Methods ---
  Future<List<Doctor>> getDoctors() async {
    final String apiUrl = '$_baseUrl/doctors';
    print('Fetching doctors from: $apiUrl');
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 20)); // Increased timeout
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Doctor.fromJson(item)).toList();
      } else {
        print('API Error fetching doctors: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load doctors (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Network/Parsing Error fetching doctors: $e');
      throw Exception('Error connecting/parsing for doctors: $e');
    }
  }

  Future<Doctor> createDoctor(Doctor doctorData) async {
    final token = await _getIdToken();
    if (token == null) {
      print('Authentication Error: User not logged in or token unavailable for createDoctor.');
      throw Exception('User not authenticated');
    }
    final String apiUrl = '$_baseUrl/doctors';
    print('Creating doctor at: $apiUrl');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(doctorData.toJsonForCreation()),
      ).timeout(const Duration(seconds: 20)); // Increased timeout

      if (response.statusCode == 201) {
        return Doctor.fromJson(jsonDecode(response.body));
      } else {
        print('API Error creating doctor: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create doctor (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Network/Parsing Error creating doctor: $e');
      throw Exception('Error connecting/parsing for doctor creation: $e');
    }
  }

  // --- Resource Methods ---
  Future<List<ResourceItem>> getResources() async {
    final String apiUrl = '$_baseUrl/resources';
    print('Fetching resources from: $apiUrl');
    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 20)); // Increased timeout
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => ResourceItem.fromJson(item)).toList();
      } else {
        print('API Error fetching resources: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load resources (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Network/Parsing Error fetching resources: $e');
      throw Exception('Error connecting/parsing for resources: $e');
    }
  }

  Future<ResourceItem> createResource(ResourceItem resourceData) async {
    final token = await _getIdToken();
    if (token == null) {
       print('Authentication Error: User not logged in or token unavailable for createResource.');
      throw Exception('User not authenticated');
    }
    final String apiUrl = '$_baseUrl/resources';
    print('Creating resource at: $apiUrl');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(resourceData.toJsonForCreation()),
      ).timeout(const Duration(seconds: 20)); // Increased timeout
      if (response.statusCode == 201) {
        return ResourceItem.fromJson(jsonDecode(response.body));
      } else {
        print('API Error creating resource: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to create resource (Status: ${response.statusCode})');
      }
    } catch (e) {
      print('Network/Parsing Error creating resource: $e');
      throw Exception('Error connecting/parsing for resource creation: $e');
    }
  }
}