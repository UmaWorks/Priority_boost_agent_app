import 'dart:convert';
import 'agent_base.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../services/llm_service.dart';

class AccountabilityAgent extends AgentBase {
  AccountabilityAgent(LLMService llmService) 
    : super(llmService, 'Accountability Partner', 'supporting user commitments');
  
  @override
  String buildPrompt(Map<String, dynamic> context) {
    final task = context['task'] as Task?;
    final profile = context['profile'] as UserProfile?;
    final action = context['action'] as String;
    
    String prompt = buildBasePrompt();
    
    switch (action) {
      case 'checkIn':
        prompt += _buildCheckInPrompt(task, profile);
        break;
      case 'celebrate':
        prompt += _buildCelebrationPrompt(task, profile);
        break;
      case 'encourage':
        prompt += _buildEncouragementPrompt(task, profile);
        break;
      case 'recap':
        prompt += _buildRecapPrompt(context['completedTasks'], profile);
        break;
      default:
        prompt += 'Provide general accountability support.';
    }
    
    return prompt;
  }
  
  String _buildCheckInPrompt(Task? task, UserProfile? profile) {
    return '''
    Check in on the user's progress:
    
    Current task: ${task?.title ?? 'No active task'}
    Due: ${task?.deadline?.toString() ?? 'No deadline'}
    User streak: ${profile?.streak ?? 0} days
    Last completed: ${profile?.lastCompleted?.toString() ?? 'Never'}
    
    Create a check-in message that:
    1. Acknowledges their current status
    2. Provides gentle accountability
    3. Offers specific support if needed
    4. Ends with encouragement
    
    Tone: Supportive friend, not supervisor.
    ''';
  }
  
  String _buildCelebrationPrompt(Task? task, UserProfile? profile) {
    return '''
    Create a celebration message for completing:
    
    Task: ${task?.title}
    Completed on time: ${_wasOnTime(task)}
    Current streak: ${(profile?.streak ?? 0) + 1}
    
    Include:
    1. Enthusiastic congratulations
    2. Acknowledge specific achievement
    3. Highlight the impact of completion
    4. Tease next milestone
    
    Make it exciting and dopamine-triggering!
    ''';
  }
  
  String _buildEncouragementPrompt(Task? task, UserProfile? profile) {
    return '''
    The user is struggling with:
    
    Task: ${task?.title}
    Time remaining: ${_calculateTimeRemaining(task)}
    Difficulty level: ${task?.difficulty ?? 'Unknown'}
    User energy: ${profile?.currentEnergy ?? 'Unknown'}
    
    Provide:
    1. Empathetic understanding
    2. Reframe the challenge
    3. Offer a micro-action to restart
    4. Remind of their capability
    
    Keep it brief and re-energizing.
    ''';
  }
  
  String _buildRecapPrompt(List<Task>? completedTasks, UserProfile? profile) {
    return '''
    Generate a weekly recap for:
    
    Tasks completed: ${completedTasks?.length ?? 0}
    Current streak: ${profile?.streak ?? 0}
    Most productive day: ${_findMostProductiveDay(completedTasks)}
    
    Include:
    1. Overall progress celebration
    2. Highlight of biggest achievement
    3. Pattern recognition (what's working well)
    4. Gentle suggestion for improvement
    5. Inspiration for next week
    
    Format: Motivational summary
    ''';
  }
  
  bool _wasOnTime(Task? task) {
    if (task?.deadline == null || task?.completedAt == null) return false;
    return task!.completedAt!.isBefore(task.deadline!);
  }
  
  String _calculateTimeRemaining(Task? task) {
    if (task?.deadline == null) return 'No deadline set';
    final now = DateTime.now();
    final remaining = task!.deadline!.difference(now);
    
    if (remaining.isNegative) return 'Overdue';
    if (remaining.inHours < 1) return '${remaining.inMinutes} minutes';
    if (remaining.inDays < 1) return '${remaining.inHours} hours';
    return '${remaining.inDays} days';
  }
  
  String _findMostProductiveDay(List<Task>? tasks) {
    if (tasks == null || tasks.isEmpty) return 'No data available';
    
    final dayCount = <String, int>{};
    for (final task in tasks) {
      if (task.completedAt != null) {
        final day = _getDayName(task.completedAt!.weekday);
        dayCount[day] = (dayCount[day] ?? 0) + 1;
      }
    }
    
    if (dayCount.isEmpty) return 'No completed tasks';
    
    return dayCount.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
  
  String _getDayName(int weekday) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 
      'Friday', 'Saturday', 'Sunday'
    ];
    return days[weekday - 1];
  }
  
  // Specific methods for different accountability scenarios
  Future<Map<String, dynamic>> checkInWithUser(Task task, UserProfile profile) async {
    final response = await execute({
      'action': 'checkIn',
      'task': task,
      'profile': profile,
    });
    
    return {
      'message': response,
      'shouldPrompt': task.deadline?.difference(DateTime.now()).inDays == 1,
      'urgencyLevel': _calculateUrgencyLevel(task),
    };
  }
  
  Future<Map<String, dynamic>> celebrateCompletion(Task task, UserProfile profile) async {
    final response = await execute({
      'action': 'celebrate',
      'task': task,
      'profile': profile,
    });
    
    return {
      'celebration': response,
      'reward': _calculateReward(task, profile),
      'nextGoal': _suggestNextGoal(profile),
    };
  }
  
  int _calculateUrgencyLevel(Task task) {
    if (task.deadline == null) return 0;
    final timeLeft = task.deadline!.difference(DateTime.now());
    
    if (timeLeft.inHours < 6) return 3; // High urgency
    if (timeLeft.inDays < 2) return 2; // Medium urgency
    return 1; // Low urgency
  }
  
  Map<String, dynamic> _calculateReward(Task task, UserProfile profile) {
    final basePoints = task.priority * 10;
    final streakBonus = profile.streak * 5;
    final difficultyMultiplier = task.difficulty ?? 1;
    
    return {
      'points': basePoints * difficultyMultiplier + streakBonus,
      'badge': profile.streak % 7 == 0 ? 'Week Champion' : null,
      'achievement': _checkAchievements(task, profile),
    };
  }
  
  String _suggestNextGoal(UserProfile profile) {
    if (profile.streak < 3) return 'Build a 3-day streak';
    if (profile.streak < 7) return 'Reach a full week streak';
    if (profile.totalTasksCompleted < 50) return 'Complete 50 total tasks';
    return 'Maintain your momentum';
  }
  
  String? _checkAchievements(Task task, UserProfile profile) {
    if (profile.streak == 7) return 'Week Warrior';
    if (profile.totalTasksCompleted == 50) return 'Half Century Hero';
    if (task.priority == 5 && task.difficulty == 3) return 'Challenge Master';
    return null;
  }
}