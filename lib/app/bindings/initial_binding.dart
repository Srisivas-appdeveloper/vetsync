import 'package:get/get.dart';

import '../../data/services/api_service.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/ble_service.dart';
import '../../data/services/connectivity_service.dart';
import '../../data/services/database_service.dart';
import '../../data/services/sync_service.dart';
import '../../data/services/websocket_service.dart';
import '../../data/repositories/animal_repository.dart';
import '../../data/repositories/annotation_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/collar_repository.dart';
import '../../data/repositories/session_repository.dart';

/// Initial binding - registers global services at app startup
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (permanent - never disposed)
    Get.put(ConnectivityService(), permanent: true);
    Get.put(ApiService(), permanent: true);
    Get.put(DatabaseService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(BleService(), permanent: true);
    Get.put(WebSocketService(), permanent: true);
    Get.put(SyncService(), permanent: true);
    
    // Repositories (lazy - created on first access)
    Get.lazyPut(() => AuthRepository(), fenix: true);
    Get.lazyPut(() => AnimalRepository(), fenix: true);
    Get.lazyPut(() => CollarRepository(), fenix: true);
    Get.lazyPut(() => SessionRepository(), fenix: true);
    Get.lazyPut(() => AnnotationRepository(), fenix: true);
  }
}
