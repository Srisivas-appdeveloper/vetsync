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
    Get.toNamed(Routes.petSelection);
  }

  /// Resume active session
  void resumeSession(Session session) {
    // Navigate to appropriate screen based on session phase
    switch (session.currentPhase) {
      case SessionPhase.preSurgery:
        Get.toNamed(Routes.preSurgery, arguments: session);
        break;
      case SessionPhase.surgery:
        Get.toNamed(Routes.surgery, arguments: session);
        break;
      case SessionPhase.calibration:
        Get.toNamed(Routes.calibration, arguments: session);
        break;
      case SessionPhase.recovery:
        Get.toNamed(Routes.recovery, arguments: session);
        break;
      case SessionPhase.completed:
        Get.toNamed(Routes.sessionComplete, arguments: session);
        break;
    }
  }

  /// Open settings
  void openSettings() {
    Get.toNamed(Routes.settings);
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
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.logout();
      Get.offAllNamed(Routes.login);
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
