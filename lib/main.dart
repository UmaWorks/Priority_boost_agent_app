import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'services/agent_coordinator.dart';
import 'services/llm_service.dart';
import 'models/user_profile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfile()),
        Provider(
          create: (context) {
            final llmService = LLMService(apiKey: 'your-api-key');
            final userProfile = context.read<UserProfile>();
            return AgentCoordinator(llmService, userProfile);
          },
        ),
      ],
      child: MaterialApp(
        title: 'Priority Boost',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        home: HomeScreen(),
      ),
    );
  }
}