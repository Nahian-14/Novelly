import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/app_user.dart';

/// Talks to our own backend server (the Node/Express + MongoDB server in
/// the `backend/` folder at the root of this repo). The Flutter app never
/// talks to MongoDB directly — it only ever goes through this server, and
/// every request carries the signed-in user's Firebase ID token so the
/// server can verify who's asking before it touches the database.
class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  /// Grabs a fresh Firebase ID token for whoever is currently signed in.
  /// Throws a [StateError] if nobody is signed in — every call below should
  /// only ever run after Firebase sign-in has already succeeded.
 
Future<String> _idToken() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw StateError('No signed-in Firebase user to get a token for.');
  }

  final token = await user.getIdToken();

  if (token == null) {
    throw StateError('Failed to get Firebase ID token.');
  }

  return token;
}


  Future<Map<String, String>> _authHeaders() async {
    final token = await _idToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Call this right after a successful Firebase sign-in or registration.
  /// It tells our backend "this Firebase user exists, make sure MongoDB has
  /// a matching profile" — creating the profile the first time, and simply
  /// returning it on every later sign-in. [role] is only used the first
  /// time (on creation); it's ignored on later syncs.
  Future<AppUser> syncUser({
    required String name,
    required String email,
    required UserRole role,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/api/users/sync'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'name': name,
        'email': email,
        'role': userRoleToLabel(role),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Could not sync profile with the server '
        '(${response.statusCode}): ${response.body}',
      );
    }

    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Fetches the signed-in user's MongoDB-backed profile (name, email,
  /// role, and anything else the backend later adds).
  Future<AppUser> fetchCurrentUser() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/api/users/me'),
      headers: await _authHeaders(),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Could not load profile from the server '
        '(${response.statusCode}): ${response.body}',
      );
    }

    return AppUser.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
