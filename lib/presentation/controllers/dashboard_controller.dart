import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_pages.dart';
import '../../data/models/models.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/sync_service.dart';
import '../../data/repositories/session_repository.dart';
import '../../data/repositories/collar_repository.dart';

/// Controller for dashboard screen
class DashboardController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final ConnectivityService _connectivity = Get.find<ConnectivityService>();
  final SyncService _syncService = Get.find<SyncService>();
  final SessionRepository _sessionRepo = Get.find<SessionRepository>();
  final CollarRepository _collarRepo = Get.find<CollarRepository>();

  // Observer info
  Observer? get observer => _authService.currentObserver.value;
  String get observerName => observer?.firstName ?? 'Observer';
  String get clinicName => observer?.clinicName ?? '';

  // Connectivity
  bool get isOnline => _connectivity.isOnline.value;
  String get connectivityStatus => _connectivity.statusString;

  // Sync status
  int get pendingUploads => _syncService.pendingCount.value;
  bool get isSyncing => _syncService.isSyncing.value;

  // Dashboard data
  final RxBool isLoading = false.obs;
  final RxList<Session> todaySessions = <Session>[].obs;
  final RxList<Collar> availableCollars = <Collar>[].obs;
  final Rx<DashboardStats?> stats = Rx<DashboardStats?>(null);

  @override
  void onInit() {
    super.onInit();
    loadDashboard();

    // Listen for connectivity changes
    ever(_connectivity.isOnline, (_) {
      if (_connectivity.isOnline.value) {
        _syncService.syncPending();
      }
    });
  }

  /// Load dashboard data
  Future<void> loadDashboard() async {
    isLoading.value = true;

    try {
      // Load in parallel
      await Future.wait([
        _loadTodaySessions(),
        _loadAvailableCollars(),
        _loadStats(),
      ]);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load dashboard data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadTodaySessions() async {
    try {
      final sessions = await _sessionRepo.getTodaySessions();
      todaySessions.value = sessions;
    } catch (e) {
      // Use cached data if offline
    }
  }

  Future<void> _loadAvailableCollars() async {
    try {
      final collars = await _collarRepo.getAvailableCollars();
      availableCollars.value = collars;
    } catch (e) {
      // Use cached data if offline
    }
  }

  Future<void> _loadStats() async {
    try {
      final dashboardStatsMap = await _sessionRepo.getDashboardStats();
      stats.value = DashboardStats.fromJson(dashboardStatsMap);
    } catch (e) {
      // Ignore stats errors
    }
  }

  /// Start new session
  void startNewSession() {
    print('[Dashboard] ========================================');
    print('[Dashboard] 🆕 START NEW SESSION BUTTON PRESSED');
    print('[Dashboard] ========================================');
    print('[Dashboard] Target Route: ${Routes.petSelection}');

    try {
      print('[Dashboard] 🚀 Attempting navigation to pet selection...');
      Get.toNamed(Routes.petSelection);
      print('[Dashboard] ✅ Navigation successful');
      print('[Dashboard] ========================================');
    } catch (e, stackTrace) {
      print('[Dashboard] ========================================');
      print('[Dashboard] ❌ NAVIGATION ERROR');
      print('[Dashboard] ========================================');
      print('[Dashboard] Error Type: ${e.runtimeType}');
      print('[Dashboard] Error Message: $e');
      print('[Dashboard] Attempted Route: ${Routes.petSelection}');
      print('[Dashboard] Stack Trace:');
      print(stackTrace);
      print('[Dashboard] ========================================');

      Get.snackbar(
        'Navigation Error',
        'Failed to start new session. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Resume active session
  void resumeSession(Session session) {
    print('[Dashboard] ========================================');
    print('[Dashboard] 🔄 RESUME SESSION BUTTON PRESSED');
    print('[Dashboard] ========================================');
    print('[Dashboard] Session ID: ${session.id}');
    print('[Dashboard] Session Phase: ${session.currentPhase.displayName}');
    print('[Dashboard] Animal: ${session.animalId}');

    try {
      // Navigate to appropriate screen based on session phase
      switch (session.currentPhase) {
        case SessionPhase.preSurgery:
          print('[Dashboard] 🚀 Attempting navigation to pre-surgery...');
          Get.toNamed(Routes.preSurgery, arguments: session);
          break;
        case SessionPhase.surgery:
          print('[Dashboard] 🚀 Attempting navigation to surgery...');
          Get.toNamed(Routes.surgery, arguments: session);
          break;
        case SessionPhase.calibration:
          print('[Dashboard] 🚀 Attempting navigation to calibration...');
          Get.toNamed(Routes.calibration, arguments: session);
          break;
        case SessionPhase.recovery:
          print('[Dashboard] 🚀 Attempting navigation to recovery...');
          Get.toNamed(Routes.recovery, arguments: session);
          break;
        case SessionPhase.completed:
          print('[Dashboard] 🚀 Attempting navigation to session complete...');
          Get.toNamed(Routes.sessionComplete, arguments: session);
          break;
      }

      print('[Dashboard] ✅ Navigation successful');
      print('[Dashboard] ========================================');
    } catch (e, stackTrace) {
      print('[Dashboard] ========================================');
      print('[Dashboard] ❌ NAVIGATION ERROR');
      print('[Dashboard] ========================================');
      print('[Dashboard] Error Type: ${e.runtimeType}');
      print('[Dashboard] Error Message: $e');
      print('[Dashboard] Session ID: ${session.id}');
      print('[Dashboard] Session Phase: ${session.currentPhase.displayName}');
      print('[Dashboard] Stack Trace:');
      print(stackTrace);
      print('[Dashboard] ========================================');

      Get.snackbar(
        'Navigation Error',
        'Failed to resume session. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Open settings
  void openSettings() {
    print('[Dashboard] ========================================');
    print('[Dashboard] ⚙️ SETTINGS BUTTON PRESSED');
    print('[Dashboard] ========================================');
    print('[Dashboard] Target Route: ${Routes.settings}');

    try {
      print('[Dashboard] 🚀 Attempting navigation to settings...');
      Get.toNamed(Routes.settings);
      print('[Dashboard] ✅ Navigation successful');
      print('[Dashboard] ========================================');
    } catch (e, stackTrace) {
      print('[Dashboard] ========================================');
      print('[Dashboard] ❌ NAVIGATION ERROR');
      print('[Dashboard] ========================================');
      print('[Dashboard] Error Type: ${e.runtimeType}');
      print('[Dashboard] Error Message: $e');
      print('[Dashboard] Attempted Route: ${Routes.settings}');
      print('[Dashboard] Stack Trace:');
      print(stackTrace);
      print('[Dashboard] ========================================');

      Get.snackbar(
        'Navigation Error',
        'Failed to open settings. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Manual sync
  Future<void> syncNow() async {
    if (!isOnline) {
      Get.snackbar(
        'Offline',
        'Cannot sync while offline',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _syncService.syncPending();
    await loadDashboard();
  }

  /// Logout
  Future<void> logout() async {
    print('[Dashboard] ========================================');
    print('[Dashboard] 🚪 LOGOUT BUTTON PRESSED');
    print('[Dashboard] ========================================');

    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                print('[Dashboard] 📱 Logout cancelled by user');
                Get.back(result: false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                print('[Dashboard] ✅ Logout confirmed by user');
                Get.back(result: true);
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        print('[Dashboard] 🔄 Performing logout...');
        await _authService.logout();
        print('[Dashboard] ✅ Auth service logout successful');

        print('[Dashboard] 🚀 Attempting navigation to login...');
        Get.offAllNamed(Routes.login);
        print('[Dashboard] ✅ Navigation to login successful');
      } else {
        print('[Dashboard] ℹ️ Logout cancelled - user chose not to logout');
      }
      print('[Dashboard] ========================================');
    } catch (e, stackTrace) {
      print('[Dashboard] ========================================');
      print('[Dashboard] ❌ LOGOUT ERROR');
      print('[Dashboard] ========================================');
      print('[Dashboard] Error Type: ${e.runtimeType}');
      print('[Dashboard] Error Message: $e');
      print('[Dashboard] Stack Trace:');
      print(stackTrace);
      print('[Dashboard] ========================================');

      Get.snackbar(
        'Logout Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
        duration: const Duration(seconds: 5),
      );
    }
  }

  /// Get greeting based on time of day
  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

/// Dashboard statistics model
class DashboardStats {
  final int todaySessionCount;
  final int weekSessionCount;
  final int monthSessionCount;
  final int totalAnnotations;
  final double avgSessionDuration;
  final int calibratedSessions;

  DashboardStats({
    required this.todaySessionCount,
    required this.weekSessionCount,
    required this.monthSessionCount,
    required this.totalAnnotations,
    required this.avgSessionDuration,
    required this.calibratedSessions,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      todaySessionCount: json['today_session_count'] as int? ?? 0,
      weekSessionCount: json['week_session_count'] as int? ?? 0,
      monthSessionCount: json['month_session_count'] as int? ?? 0,
      totalAnnotations: json['total_annotations'] as int? ?? 0,
      avgSessionDuration:
          (json['avg_session_duration'] as num?)?.toDouble() ?? 0,
      calibratedSessions: json['calibrated_sessions'] as int? ?? 0,
    );
  }
}
