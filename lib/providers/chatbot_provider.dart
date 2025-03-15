// ignore_for_file: avoid_print

import 'dart:convert'; // For JSON encoding and decoding
import 'package:http/http.dart' as http; // For making HTTP requests

// CustomChatbotService class to manage communication with the chatbot API
class CustomChatbotService {
  final String apiUrl; // URL of the chatbot API endpoint
  // Constructor to initialize the service with the API URL
  CustomChatbotService({
    required this.apiUrl,
  });
  // Method to send a single message to the chatbot and get the response
  Future<String> sendMessage(String message) async {
    try {
      // Sending a POST request to the chatbot API
      final response = await http.post(
        Uri.parse(apiUrl), // Convert the API URL string to Uri
        headers: {
          'Content-Type': 'application/json'
        }, // Set the content type to JSON
        body: jsonEncode({
          'messages': [
            message
          ] // The message to be sent is wrapped in a 'messages' list
        }),
      );

      // Debug: Print the raw response from the API
      print('API Response: ${response.body}');

      // Check if the response status is 200 true
      if (response.statusCode == 200) {
        // Parse the JSON response from the chatbot
        final data = jsonDecode(response.body);
        // Check if the response contains a 'responses' field, which should be a list
        if (data['responses'] is List && data['responses'].isNotEmpty) {
          // Sort the responses by confidence level (highest first)
          data['responses'].sort((a, b) =>
              (b['confidence'] as double).compareTo(a['confidence'] as double));
          // Return the response with the highest confidence
          return data['responses'].first['response'];
        }
        // If there is no valid response, return a fallback message
        return 'No relevant response found.';
      } else {
        // If the response status is not 200, return an error message
        return 'Error: Failed to get response.';
      }
    } catch (e) {
      // Catch any errors (network issues, JSON parsing errors, etc.)
      return 'Error communicating with chatbot: $e';
    }
  }
  // Method to send a message with retry logic (in case of failure)
  Future<String> sendMessageWithRetry(String message,
      {int maxRetries = 3}) async {
    int attempts = 0;
    // Try sending the message up to 'maxRetries' times in case of failure
    while (attempts < maxRetries) {
      try {
        // Attempt to send the message
        return await sendMessage(message);
      } catch (e) {
        // Increment attempt counter if the request fails
        attempts++;
        // If the maximum retries are reached, rethrow the error
        if (attempts >= maxRetries) rethrow;
        // Wait for a backoff period before retrying (increasing delay each time)
        await Future.delayed(Duration(seconds: 2 * attempts));
      }
    }
    // If all retries fail, throw an exception
    throw Exception('Failed after $maxRetries attempts');
  }
}
