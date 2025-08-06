import 'dart:convert';

import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/core/utils/sp_service.dart';
import 'package:repair_shop/features/auth/data/models/user_model.dart';
import 'package:http/http.dart' as http;

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  });

  Future<UserModel> logInWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel?> currentUserData(String? token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  @override
  Future<UserModel> signUpWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppSecrets.backendUri}/api/sginup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"name": name, "email": email, "password": password}),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['message'];
      }

      return UserModel.formJson(jsonDecode(res.body));
    } catch (e) {
      throw ServerExecptions('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> logInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppSecrets.backendUri}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      final Map<String, dynamic> data = jsonDecode(res.body);

      if (res.statusCode != 200) {
        throw data['message'] ?? 'Unknown login error';
      }

      return UserModel.formJson(data).copyWith(token: data['token']);
    } catch (e) {
      throw ServerExecptions('Login failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> currentUserData(String? token) async {
    try {
      if (token == null) {
        return null;
      }

      final res = await http.post(
        Uri.parse('${AppSecrets.backendUri}/api/jwt'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      final decoded = jsonDecode(res.body);
      final isValid = decoded == true || decoded == "true";

      if (res.statusCode != 200 || !isValid) {
        return null;
      }

      final userResponse = await http.get(
        Uri.parse('${AppSecrets.backendUri}/api/users'),
        headers: {'Content-Type': 'application/json', 'x-auth-token': token},
      );

      if (userResponse.statusCode != 200) {
        throw jsonDecode(res.body)["message"];
      }

      return UserModel.formJson(
        jsonDecode(userResponse.body),
      ).copyWith(token: token);
    } catch (e) {
      throw ServerExecptions('Failed to fetch current user data: $e');
    }
  }
}
