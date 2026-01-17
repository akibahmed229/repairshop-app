import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:repair_shop/core/common/cubits/app_wide_user/app_wide_user_cubit.dart';
import 'package:repair_shop/core/services/notification_service.dart';
import 'package:repair_shop/core/theme/theme.dart';
import 'package:repair_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:repair_shop/features/auth/presentation/pages/login_page.dart';
import 'package:repair_shop/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:repair_shop/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:repair_shop/features/techNotes/presentation/bloc/tech_note_bloc.dart';
import 'package:repair_shop/features/techNotes/presentation/pages/tech_note_page.dart';
import 'package:repair_shop/features/users/presentation/bloc/user_bloc.dart';
import 'package:repair_shop/firebase_options.dart';
import 'package:repair_shop/init_dependencies.dart';

// 1. Define the Global Key here
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initDependencies();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<AppWideUserCubit>()),
        BlocProvider(create: (_) => serviceLocator<TechNoteBloc>()),
        BlocProvider(create: (_) => serviceLocator<UserBloc>()),
        BlocProvider(create: (_) => serviceLocator<NotificationBloc>()),
        BlocProvider(create: (_) => serviceLocator<ChatBloc>()),
      ],
      child: const RepairShop(),
    ),
  );
}

class RepairShop extends StatefulWidget {
  const RepairShop({super.key});

  @override
  State<RepairShop> createState() => _RepairShopState();
}

class _RepairShopState extends State<RepairShop> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedInEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: "Repair Shop",
      theme: AppTheme.darkThemeMode,
      home: BlocBuilder<AppWideUserCubit, AppWideUserState>(
        // buildWhen ensures the UI only rebuilds if the login status actually CHANGED
        buildWhen: (previous, current) {
          return (previous is AppWideUserLoggedIn) !=
              (current is AppWideUserLoggedIn);
        },
        builder: (context, state) {
          if (state is AppWideUserLoggedIn) {
              // Grab the bloc instance immediately
              final authBloc = context.read<AuthBloc>();

              // Initialize service only when logged in
              // Use Future.microtask to ensure the UI transition finishes first
              Future.microtask(() {
                NotificationService.initNotifications(authBloc);
                NotificationService.setupForegroundListeners();
              });

            return const TechNotePage();
          }
          return const LoginPage();
        },
      ),
    );
  }
}
