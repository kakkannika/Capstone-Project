abstract class ChatbotRepository {
  Future<String> sendMessage(String message);
  Future<String> sendMessageWithRetry(String message, {int maxRetries = 3});
}
