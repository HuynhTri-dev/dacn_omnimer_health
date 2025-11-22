import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_bloc.dart';
import 'package:omnihealthmobileflutter/presentation/common/blocs/auth/authentication_event.dart';
import 'package:omnihealthmobileflutter/presentation/common/cubits/theme_cubit.dart';
import '../injection_container.dart';
import 'app_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      // Pixel 9 Pro specifications: 427x952 dp
      designSize: const Size(427, 952),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiBlocProvider(
          providers: [
            // Authentication Bloc - global
            BlocProvider(
              create: (_) =>
                  sl<AuthenticationBloc>()..add(AuthenticationStarted()),
            ),
            // Theme Cubit - global
            BlocProvider(create: (_) => sl<ThemeCubit>()),
          ],
          child: const AppView(),
        );
      },
    );
  }
}
