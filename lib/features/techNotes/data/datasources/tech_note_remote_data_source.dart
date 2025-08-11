import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:repair_shop/core/error/other_execptions.dart';
import 'package:repair_shop/core/error/server_execptions.dart';
import 'package:repair_shop/core/secrets/app_secrets.dart';
import 'package:repair_shop/features/techNotes/data/models/tech_note_model.dart';
import 'package:http/http.dart' as http;

abstract interface class TechNoteRemoteDataSource {
  Future<List<TechNoteModel>> getAllTechNotes();
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
}
