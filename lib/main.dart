import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/screens/landing/landing_page.dart';
import 'package:ez_queue/screens/theme_customizer/theme_customizer_page.dart';
import 'package:ez_queue/screens/department_selection/department_selection_page.dart';
import 'package:ez_queue/screens/user_type_selection/user_type_selection_page.dart';
import 'package:ez_queue/screens/personal_information/personal_information_page.dart';
import 'package:ez_queue/screens/confirmation/confirmation_page.dart';
import 'package:ez_queue/screens/ticket_preview/ticket_preview_page.dart';
import 'package:ez_queue/screens/queue_display/queue_display_page.dart';
import 'package:ez_queue/screens/cancel_queue/cancel_queue_page.dart';

void main() {
  runApp(const ProviderScope(child: EZQueueApp()));
}

/// GoRouter configuration.
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LandingPage()),
    GoRoute(
      path: '/theme-customizer',
      builder: (context, state) => const ThemeCustomizerPage(),
    ),
    GoRoute(
      path: '/department-selection',
      builder: (context, state) => const DepartmentSelectionPage(),
    ),
    GoRoute(
      path: '/user-type-selection',
      builder: (context, state) => const UserTypeSelectionPage(),
    ),
    GoRoute(
      path: '/personal-information',
      builder: (context, state) => const PersonalInformationPage(),
    ),
    GoRoute(
      path: '/confirmation',
      builder: (context, state) => const ConfirmationPage(),
    ),
    GoRoute(
      path: '/ticket-preview',
      builder: (context, state) => const TicketPreviewPage(),
    ),
    GoRoute(
      path: '/queue-display',
      builder: (context, state) => const QueueDisplayPage(),
    ),
    GoRoute(
      path: '/cancel-queue',
      builder: (context, state) => const CancelQueuePage(),
    ),
  ],
);

/// Main app widget with theme and navigation setup.
class EZQueueApp extends ConsumerWidget {
  const EZQueueApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appThemeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'EZQueue',
      theme: theme,
      darkTheme: theme,
      themeMode: themeMode,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}
