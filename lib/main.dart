import 'package:flutter/material.dart';
import 'app/routes.dart';
import 'app/theme.dart';
import 'core/services/game_engine.dart';
import 'core/services/storage_service.dart';
import 'core/services/task_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Инициализация хранилища (Hive)
  final storage = StorageService();
  await storage.init();

  // Инициализация игровой экономики
  await GameEngine().init();

  // Инициализация трекинга заданий
  await TaskService().init();

  runApp(const FinnyPetApp());
}

class FinnyPetApp extends StatelessWidget {
  const FinnyPetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Питомец Финни',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: AppRoutes.router,
    );
  }
}
