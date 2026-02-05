import 'package:petbacker/models/pet_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';

class PetRepository {
  Future<List<PetModel>> fetchPets() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://pbapi.forwen.com/v5/moments?refresh=1&type=0&auth=0',
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load items: ${response.statusCode}');
      }

      final List<dynamic> jsonList = jsonDecode(response.body);

      return jsonList.map((item) => PetModel.fromJson(item)).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ fetchPets error: $e');
      debugPrint('📌 stackTrace: $stackTrace');
      rethrow;
    }
  }
}
