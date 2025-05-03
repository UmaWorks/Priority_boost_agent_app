import '../services/llm_service.dart';
import '../agents/prioritizer_agent.dart';
import '../agents/motivation_agent.dart';
import '../agents/accountability_agent.dart';
import '../models/task.dart';
import '../models/user_profile.dart';

class AgentCoordinator {
  final LLMService llmService;
  late final PrioritizerAgent prioritizer;
  late final MotivationAgent motivator;
  late final AccountabilityAgent accountability;
  final UserProfile userProfile;

  AgentCoordinator(this.llmService, this.userProfile) {
    prioritizer = PrioritizerAgent(llmService);
    motivator = MotivationAgent(llmService);
    accountability = AccountabilityAgent(llmService);
  }

  Future<Map<String, dynamic>> orchestrateTaskCompletion(Task task) async {
    final motivation = await motivator.generateMotivation(task, userProfile);
    final reward = calculateReward(task);
    final checkIn = await accountability.checkInWithUser(task, userProfile);
    
    return {
      'motivation': motivation,
      'reward': reward,
      'checkIn': checkIn,
    };
  }
  
  Map<String, dynamic> calculateReward(Task task) {
    final basePoints = task.priority * 10;
    final difficultyMultiplier = task.difficulty ?? 1;
    
    return {
      'points': basePoints * difficultyMultiplier,
      'badges': [],
      'achievements': [],
    };
  }
}