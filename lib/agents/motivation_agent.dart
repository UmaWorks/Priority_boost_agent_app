import '../services/llm_service.dart';
import '../models/task.dart';
import '../models/user_profile.dart';

class MotivationAgent {
  final LLMService llmService;
  
  MotivationAgent(this.llmService);
  
  Future<String> generateMotivation(Task task, UserProfile profile) async {
    final prompt = '''
    Generate personalized motivation for this task:
    Task: ${task.title}
    User type: ${profile.motivationStyle}
    Current streak: ${profile.streak}
    
    Create:
    1. Energizing encouragement
    2. Dopamine-triggering milestone
    3. Quick win suggestion
    
    Keep it brief and exciting!
    ''';
    
    return await llmService.generateResponse(prompt);
  }
}