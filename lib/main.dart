import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:repair_shop/core/common/cubits/app_wide_user/app_wide_user_cubit.dart';
import 'package:repair_shop/core/theme/theme.dart';
import 'package:repair_shop/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:repair_shop/features/auth/presentation/pages/login_page.dart';
import 'package:repair_shop/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => serviceLocator<AuthBloc>()),
        BlocProvider(create: (_) => serviceLocator<AppWideUserCubit>()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    context.read<AuthBloc>().add(AuthIsUserLoggedInEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Repair Shop",
      theme: AppTheme.darkThemeMode,
      home: BlocSelector<AppWideUserCubit, AppWideUserState, bool>(
        selector: (state) => state is AppWideUserLoggedIn,
        builder: (context, isLoggedIn) {
          print(isLoggedIn);
          if (isLoggedIn) {
            return Scaffold(
              body: Center(child: Text("Welcome to the HomeScreen")),
            );
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
