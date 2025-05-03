// test/agent_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Prioritizer Agent Tests', () {
    test('prioritizes tasks correctly', () async {
      final llm = MockLLMService();
      final agent = PrioritizerAgent(llm);
      
      final tasks = [
        Task(title: 'Urgent Report'),
        Task(title: 'Meeting Prep'),
      ];
      
      final result = await agent.prioritizeTasks(tasks);
      expect(result.length).toBe(2);
      expect(result[0].priority).toBeGreaterThan(result[1].priority);
    });
  });
}