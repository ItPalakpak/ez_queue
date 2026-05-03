import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ez_queue/providers/theme_provider.dart';
import 'package:ez_queue/services/global_queue_alert_manager.dart';
import 'package:ez_queue/screens/landing/landing_page.dart';
import 'package:ez_queue/screens/theme_customizer/theme_customizer_page.dart';
import 'package:ez_queue/screens/department_selection/department_selection_page.dart';
import 'package:ez_queue/screens/service_selection/service_selection_page.dart';
import 'package:ez_queue/screens/department_queue/department_queue_page.dart';
import 'package:ez_queue/screens/user_type_selection/user_type_selection_page.dart';
import 'package:ez_queue/screens/identity_information/identity_information_page.dart';
import 'package:ez_queue/screens/contact_information/contact_information_page.dart';
import 'package:ez_queue/screens/details_information/details_information_page.dart';
import 'package:ez_queue/screens/confirmation/confirmation_page.dart';
import 'package:ez_queue/screens/ticket_preview/ticket_preview_page.dart';
import 'package:ez_queue/screens/queue_display/queue_display_page.dart';
import 'package:ez_queue/screens/cancel_queue/cancel_queue_page.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ez_queue/utils/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // CHANGED: Initialize Firebase before any Firestore calls
  await Firebase.initializeApp();
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint(".env file not found or could not be loaded: $e");
  }
  await ApiConfig.init();
  runApp(const ProviderScope(child: EZQueueApp()));
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// GoRouter configuration.
final _router = GoRouter(
  navigatorKey: rootNavigatorKey,
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
      path: '/service-selection',
      builder: (context, state) => const ServiceSelectionPage(),
    ),
    GoRoute(
      path: '/department-queue',
      builder: (context, state) {
        final dept = state.uri.queryParameters['dept'] ?? 'Unknown';
        return DepartmentQueuePage(initialDepartment: dept);
      },
    ),
    GoRoute(
      path: '/user-type-selection',
      builder: (context, state) => const UserTypeSelectionPage(),
    ),
    GoRoute(
      path: '/identity-information',
      builder: (context, state) => const IdentityInformationPage(),
    ),
    GoRoute(
      path: '/contact-information',
      builder: (context, state) => const ContactInformationPage(),
    ),
    GoRoute(
      path: '/details-information',
      builder: (context, state) => const DetailsInformationPage(),
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
      builder: (context, state) {
        final ticketNumber = state.uri.queryParameters['ticketNumber'];
        final departmentIdRaw = state.uri.queryParameters['departmentId'];
        final departmentName = state.uri.queryParameters['departmentName'];

        return QueueDisplayPage(
          trackedTicketNumber: ticketNumber,
          trackedDepartmentId: departmentIdRaw != null
              ? int.tryParse(departmentIdRaw)
              : null,
          trackedDepartmentName: departmentName,
        );
      },
    ),
    GoRoute(
      path: '/cancel-queue',
      builder: (context, state) => const CancelQueuePage(),
    ),
  ],
);

/// Main app widget with theme and navigation setup.
class EZQueueApp extends ConsumerStatefulWidget {
  const EZQueueApp({super.key});

  @override
  ConsumerState<EZQueueApp> createState() => _EZQueueAppState();
}

class _EZQueueAppState extends ConsumerState<EZQueueApp> {
  @override
  void initState() {
    super.initState();
    GlobalQueueAlertManager().initialize(rootNavigatorKey);
  }

  @override
  void dispose() {
    GlobalQueueAlertManager().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
