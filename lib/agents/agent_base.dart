import 'dart:convert';
import '../services/llm_service.dart';

abstract class AgentBase {
  final LLMService llmService;
  final String agentName;
  final String agentRole;
  
  AgentBase(this.llmService, this.agentName, this.agentRole);
  
  String buildBasePrompt() {
    return '''
    You are a $agentName agent specializing in $agentRole.
    Date: ${DateTime.now().toIso8601String()}
    
    Guidelines:
    - Be motivational and supportive
    - Keep responses concise and actionable  
    - Focus on dopamine-triggering suggestions
    - Maintain a positive, encouraging tone
    ''';
  }
  
  Future<String> execute(Map<String, dynamic> context) async {
    final prompt = buildPrompt(context);
    return await llmService.generateResponse(prompt);
  }
  
  String buildPrompt(Map<String, dynamic> context);
  
  Map<String, dynamic> parseResponse(String response) {
    try {
      return jsonDecode(response);
    } catch (e) {
      // Fallback to plain text response
      return {'text': response};
    }
  }
}