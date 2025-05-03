import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../services/agent_coordinator.dart';
import 'task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Task> _sampleTasks = [
    Task(
      id: '1',
      title: 'Complete Project Report',
      description: 'Finish the Q4 project report for the team',
      priority: 5,
      estimatedMinutes: 60,
      deadline: DateTime.now().add(const Duration(days: 2)),
      difficulty: 3,
    ),
    Task(
      id: '2',
      title: 'Call Client',
      description: 'Follow up with client about new features',
      priority: 4,
      estimatedMinutes: 30,
      deadline: DateTime.now().add(const Duration(days: 1)),
      difficulty: 2,
    ),
    Task(
      id: '3',
      title: 'Review Code',
      description: 'Review team\'s pull requests',
      priority: 3,
      estimatedMinutes: 45,
      deadline: DateTime.now().add(const Duration(hours: 6)),
      difficulty: 2,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final userProfile = Provider.of<UserProfile>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Priority Boost'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text('Streak: ${userProfile.streak}'),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _sampleTasks.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(_sampleTasks[index]);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(task.description ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text('Priority: ${task.priority}'),
                  backgroundColor: _getPriorityColor(task.priority),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text('${task.estimatedMinutes} min'),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskScreen(task: task),
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red.withOpacity(0.7);
      case 4:
        return Colors.orange.withOpacity(0.7);
      case 3:
        return Colors.yellow.withOpacity(0.7);
      case 2:
        return Colors.blue.withOpacity(0.7);
      case 1:
        return Colors.green.withOpacity(0.7);
      default:
        return Colors.grey.withOpacity(0.7);
    }
  }
}