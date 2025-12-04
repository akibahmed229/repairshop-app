import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:repair_shop/core/common/models/user_model.dart';
import 'package:repair_shop/core/error/other_execptions.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';

abstract interface class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers();

  Future<UserModel> createNewUser({
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  });

  Future<UserModel> updateUser({
    required String id,
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  });

  Future<String> deleteUser({required String id});
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  // Reusable network error handler
  Never _handleNetworkError(Object e) {
    if (e is SocketException) {
      throw ServerExecptions('No internet connection or server unreachable');
    } else if (e is http.ClientException) {
      throw ServerExecptions('HTTP connection error — server unreachable');
    } else if (e is TimeoutException) {
      throw ServerExecptions('Request timed out — server not responding');
    } else {
      throw OtherExecptions('Unexpected error: ${e.toString()}');
    }
  }

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await http.get(
        Uri.parse('${AppSecrets.backendUri}/api/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      final List<dynamic> decodedBody = jsonDecode(response.body);

      return decodedBody.map((user) => UserModel.formJson(user)).toList();
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  @override
  Future<UserModel> createNewUser({
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppSecrets.backendUri}/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
          "roles": roles,
        }),
      );

      if (response.statusCode != 201) {
        throw jsonDecode(response.body)['message'];
      }

      return UserModel.formJson(jsonDecode(response.body));
    } catch (e) {
      throw OtherExecptions("Failed to create user: ${e.toString()}");
    }
  }

  @override
  Future<UserModel> updateUser({
    required String id,
    required String name,
    required String email,
    required String password,
    required List<String> roles,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppSecrets.backendUri}/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": id,
          "name": name,
          "email": email,
          "password": password,
          "roles": roles,
        }),
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['message'];
      }

      return UserModel.formJson(jsonDecode(response.body));
    } catch (e) {
      throw OtherExecptions("Failed to update user: ${e.toString()}");
    }
  }

  @override
  Future<String> deleteUser({required String id}) async {
    try {
      final response = await http.delete(
        Uri.parse('${AppSecrets.backendUri}/api/techNotes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"id": id}),
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['message'];
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw OtherExecptions("Failed to delete user: ${e.toString()}");
    }
  }
}
