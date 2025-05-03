// lib/services/llm_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class LLMService {
  final String apiKey;
  final String baseUrl = 'https://api.openai.com/v1/chat/completions';

  LLMService({required this.apiKey});

  Future<String> generateResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {'role': 'system', 'content': 'You are a helpful assistant.'},
          {'role': 'user', 'content': prompt}
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get LLM response: ${response.body}');
    }
  }
}
