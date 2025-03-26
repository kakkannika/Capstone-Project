import 'package:flutter/material.dart';
import 'package:tourism_app/data/repository/api/chatbot_api_repository.dart';

class ChatbotProvider extends ChangeNotifier {
  final ChatbotApiRepository _chatbotRepository;

  // Constructor to initialize the provider with the repository
  ChatbotProvider({
    required String apiUrl,
  }) : _chatbotRepository = ChatbotApiRepository(apiUrl: apiUrl);

  // State variables
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _response;
  String? get response => _response;

  // Method to send a message to the chatbot
  Future<void> sendMessage(String message) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _response = await _chatbotRepository.sendMessage(message);
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Method to send a message with retry logic
  Future<void> sendMessageWithRetry(String message,
      {int maxRetries = 3}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _response = await _chatbotRepository.sendMessageWithRetry(message,
          maxRetries: maxRetries);
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
