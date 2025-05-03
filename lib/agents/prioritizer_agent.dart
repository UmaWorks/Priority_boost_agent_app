import 'dart:convert';
import '../services/llm_service.dart';
import '../models/task.dart';

class PrioritizerAgent {
  final LLMService llmService;

  PrioritizerAgent(this.llmService);

  Future<List<Task>> prioritizeTasks(List<Task> tasks) async {
    final prompt = '''
    You are a task prioritization expert. Analyze these tasks and return the top 5 priorities:
    ${tasks.map((t) => '- ${t.title}: ${t.description}').join('\n')}
    
    Consider:
    1. Urgency and importance
    2. Time estimates
    3. Dependencies
    
    Return JSON format:
    [{"id": "1", "title": "...", "priority": 1, "timeEstimate": 60}]
    ''';

    final response = await llmService.generateResponse(prompt);
    return _parseTasks(response);
  }
  
  List<Task> _parseTasks(String response) {
    try {
      final List<dynamic> jsonList = jsonDecode(response);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      // Return empty list if parsing fails
      print('Error parsing tasks: $e');
      return [];
    }
  }
}