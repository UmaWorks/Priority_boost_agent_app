import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/user_profile.dart';
import '../services/agent_coordinator.dart';
import '../widgets/progress_ring.dart';
import '../widgets/motivation_card.dart';
import '../widgets/timer_widget.dart';
import '../widgets/dopamine_animation.dart';

class TaskScreen extends StatefulWidget {
  final Task task;

  const TaskScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with SingleTickerProviderStateMixin {
  late AgentCoordinator _coordinator;
  late UserProfile _profile;
  String? _currentMotivation;
  bool _isTaskRunning = false;
  int _timeSpent = 0;
  int _progress = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _coordinator = Provider.of<AgentCoordinator>(context, listen: false);
    _profile = Provider.of<UserProfile>(context, listen: false);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _loadInitialMotivation();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialMotivation() async {
    final motivation = await _coordinator.motivator.generateMotivation(
      widget.task,
      _profile,
    );
    setState(() {
      _currentMotivation = motivation;
    });
  }

  void _startTask() {
    setState(() {
      _isTaskRunning = true;
    });
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (!_isTaskRunning) return false;
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _timeSpent++;
        _progress = (_timeSpent / (widget.task.estimatedMinutes * 60) * 100).round();
      });
      
      // Trigger motivational check every 5 minutes
      if (_timeSpent % 300 == 0) {
        _refreshMotivation();
      }
      
      return true;
    });
  }

  Future<void> _refreshMotivation() async {
    final motivation = await _coordinator.motivator.generateMotivation(
      widget.task,
      _profile,
    );
    setState(() {
      _currentMotivation = motivation;
    });
  }

  Future<void> _completeTask() async {
    setState(() {
      _isTaskRunning = false;
      _progress = 100;
    });

    // Trigger dopamine celebration
    _animationController.forward();

    // Get completion rewards and feedback
    final result = await _coordinator.orchestrateTaskCompletion(widget.task);
    
    // Show celebration dialog
    _showCompletionDialog(result);
  }

  void _showCompletionDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Task Completed!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DopamineAnimation(controller: _animationController),
            const SizedBox(height: 16),
            Text(result['motivation'] ?? 'Great job!', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Points earned: ${result['reward']['points']}'),
            if (result['reward']['badge'] != null)
              Chip(
                label: Text(result['reward']['badge']),
                backgroundColor: Colors.amber,
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true); // Return to home screen
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.title),
        actions: [
          if (_isTaskRunning)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshMotivation,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Task Details Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(widget.task.description ?? 'No description'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Chip(
                          label: Text('Priority: ${widget.task.priority}'),
                          backgroundColor: _getPriorityColor(widget.task.priority),
                        ),
                        const SizedBox(width: 8),
                        Chip(
                          label: Text('Est. ${widget.task.estimatedMinutes} min'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Progress Ring
            ProgressRing(
              progress: _progress,
              size: 150,
              strokeWidth: 15,
              centerChild: Text(
                '$_progress%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Timer Display
            TimerWidget(timeSpent: _timeSpent),
            const SizedBox(height: 24),

            // Motivation Card
            if (_currentMotivation != null)
              MotivationCard(
                message: _currentMotivation!,
                onRefresh: _refreshMotivation,
              ),
            const SizedBox(height: 24),

            // Action Buttons
            if (!_isTaskRunning)
              ElevatedButton(
                onPressed: _startTask,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Start Task',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: _completeTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      'Complete Task',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isTaskRunning = false;
                      });
                    },
                    child: const Text('Pause'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 5:
        return Colors.red;
      case 4:
        return Colors.orange;
      case 3:
        return Colors.amber;
      case 2:
        return Colors.blue;
      case 1:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}