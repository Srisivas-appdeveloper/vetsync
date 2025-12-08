import 'package:get/get.dart';

import '../../presentation/bindings/auth_binding.dart';
import '../../presentation/bindings/dashboard_binding.dart';
import '../../presentation/bindings/session_binding.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/splash_page.dart';
import '../../presentation/pages/dashboard/dashboard_page.dart';
import '../../presentation/pages/session/add_pet_page.dart';
import '../../presentation/pages/session/baseline_collection_page.dart';
import '../../presentation/pages/session/baseline_complete_page.dart';
import '../../presentation/pages/session/calibration_page.dart';
import '../../presentation/pages/session/collar_scan_page.dart';
import '../../presentation/pages/session/end_session_page.dart';
import '../../presentation/pages/session/pet_selection_page.dart';
import '../../presentation/pages/session/pre_surgery_page.dart';
import '../../presentation/pages/session/recovery_page.dart';
import '../../presentation/pages/session/session_complete_page.dart';
import '../../presentation/pages/session/session_setup_page.dart';
import '../../presentation/pages/session/start_surgery_page.dart';
import '../../presentation/pages/session/surgery_page.dart';
import '../../presentation/pages/settings/settings_page.dart';

part 'app_routes.dart';

/// Application pages and routing configuration
class AppPages {
  AppPages._();

  /// Initial route
  static const initial = Routes.splash;

  /// All application routes
  static final routes = [
    // Splash
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      transition: Transition.fade,
    ),

    // Auth
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
      transition: Transition.fadeIn,
    ),

    // Dashboard
    GetPage(
      name: Routes.dashboard,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
      transition: Transition.fadeIn,
    ),

    // Session Flow
    GetPage(
      name: Routes.petSelection,
      page: () => const PetSelectionPage(),
      binding: SessionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.addPet,
      page: () => const AddPetPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.collarScan,
      page: () => const CollarScanPage(),
      binding: SessionBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.sessionSetup,
      page: () => const SessionSetupPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.baselineCollection,
      page: () => const BaselineCollectionPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.baselineComplete,
      page: () => const BaselineCompletePage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.preSurgery,
      page: () => const PreSurgeryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.startSurgery,
      page: () => const StartSurgeryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.surgery,
      page: () => const SurgeryPage(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: Routes.calibration,
      page: () => const CalibrationPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.recovery,
      page: () => const RecoveryPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.endSession,
      page: () => const EndSessionPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: Routes.sessionComplete,
      page: () => const SessionCompletePage(),
      transition: Transition.fadeIn,
    ),

    // Settings
    GetPage(
      name: Routes.settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeft,
    ),
  ];
}
