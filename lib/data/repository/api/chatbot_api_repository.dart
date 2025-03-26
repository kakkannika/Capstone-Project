// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tourism_app/data/repository/chatbot_repository.dart';

class ChatbotApiRepository extends ChatbotRepository {
  final String apiUrl; // URL of the chatbot API endpoint

  ChatbotApiRepository({
    required this.apiUrl,
  });

  @override
  Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'messages': [message]
        }),
      );

      print('API Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['responses'] is List && data['responses'].isNotEmpty) {
          data['responses'].sort((a, b) =>
              (b['confidence'] as double).compareTo(a['confidence'] as double));
          return data['responses'].first['response'];
        }
        return 'No relevant response found.';
      } else {
        return 'Error: Failed to get response.';
      }
    } catch (e) {
      return 'Error communicating with chatbot: $e';
    }
  }

  @override
  Future<String> sendMessageWithRetry(String message,
      {int maxRetries = 3}) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await sendMessage(message);
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
    throw Exception('Failed after $maxRetries attempts');
  }
}
