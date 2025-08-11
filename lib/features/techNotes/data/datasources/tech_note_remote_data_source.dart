import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:repair_shop/core/error/other_execptions.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/techNotes/data/models/tech_note_model.dart';
import 'package:http/http.dart' as http;
import 'package:repair_shop/features/techNotes/data/models/tech_note_user_model.dart';

abstract interface class TechNoteRemoteDataSource {
  Future<List<TechNoteModel>> getAllTechNotes();

  Future<TechNoteModel> createTechNote({
    required String userId,
    required String title,
    required String content,
  });

  Future<String> updateTechNote({
    required String id,
    required String userId,
    required String title,
    required String content,
    required bool completed,
  });

  Future<String> deleteTechNote({required String id});

  Future<List<TechNoteUserModel>> getAllTechNoteUsers();
}

class TechNoteRemoteDataSourceImpl implements TechNoteRemoteDataSource {
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
  Future<List<TechNoteModel>> getAllTechNotes() async {
    try {
      final response = await http.get(
        Uri.parse('${AppSecrets.backendUri}/api/techNotes'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)["message"] ??
            'Unknown error occurred on the server.';
      }

      final List<dynamic> decodedBody = jsonDecode(response.body);

      return decodedBody
          .map((noteJson) => TechNoteModel.fromJson(noteJson))
          .toList();
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  @override
  Future<TechNoteModel> createTechNote({
    required String userId,
    required String title,
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppSecrets.backendUri}/api/techNotes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "userId": userId,
          "title": title,
          "content": content,
        }),
      );

      if (response.statusCode != 201) {
        throw jsonDecode(response.body)['message'];
      }

      return TechNoteModel.fromJson(jsonDecode(response.body));
    } catch (e) {
      throw OtherExecptions("Failed to create note: ${e.toString()}");
    }
  }

  @override
  Future<String> updateTechNote({
    required String id,
    required String userId,
    required String title,
    required String content,
    required bool completed,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${AppSecrets.backendUri}/api/techNotes'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": id,
          "userId": userId,
          "title": title,
          "content": content,
          "completed": completed,
        }),
      );

      if (response.statusCode != 200) {
        throw jsonDecode(response.body)['message'];
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw OtherExecptions("Failed to create note: ${e.toString()}");
    }
  }

  @override
  Future<String> deleteTechNote({required String id}) async {
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
      throw OtherExecptions("Failed to create note: ${e.toString()}");
    }
  }

  @override
  Future<List<TechNoteUserModel>> getAllTechNoteUsers() async {
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

      return decodedBody
          .map((noteJson) => TechNoteUserModel.formJson(noteJson))
          .toList();
    } catch (e) {
      _handleNetworkError(e);
    }
  }
}
