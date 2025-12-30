import 'package:get/get.dart';

import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/ble_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/database_service.dart';
import '../../data/services/storage_service.dart'; // ← ADD THIS
import '../../data/services/sync_service.dart';
import '../../data/services/websocket_service.dart';
import '../../data/repositories/animal_repository.dart';
import '../../data/repositories/annotation_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/collar_repository.dart';
import '../../data/repositories/session_repository.dart';
import '../../database/sqlite_service.dart';
import '../../services/dual_upload_service.dart';
import '../../services/surgery_data_router.dart';
import '../../services/calibration_service.dart';
import '../../services/bcg_processor_service.dart';
import '../../services/network_queue_manager.dart';
import '../../services/ble_service.dart';

/// Initial binding - registers global services at app startup
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (permanent - never disposed)
    // ORDER MATTERS! StorageService must be first (others depend on it)
    Get.put(StorageService(), permanent: true); // ← ADD THIS FIRST
    Get.put(ConnectivityService(), permanent: true);
    Get.put(ApiService(), permanent: true);
    Get.put(DatabaseService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(BleService(), permanent: true);
    Get.put(WebSocketService(), permanent: true);
    Get.put(SyncService(), permanent: true);

    // V3.2.0 Services
    Get.put(SQLiteService(), permanent: true);
    Get.put(DualUploadService(), permanent: true);
    Get.put(SurgeryDataRouter(), permanent: true);
    Get.put(CalibrationService(), permanent: true);
    Get.put(BCGProcessorService(), permanent: true);
    Get.put(NetworkQueueManager(), permanent: true);
    Get.put(
      BLEService(),
      permanent: true,
    ); // Different from BleService (legacy)

    // Repositories (lazy - created on first access)
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => AnimalRepository(), fenix: true);
    Get.lazyPut(() => CollarRepository(), fenix: true);
    Get.lazyPut(() => SessionRepository(), fenix: true);
    Get.lazyPut(() => AnnotationRepository(), fenix: true);
  }
}
