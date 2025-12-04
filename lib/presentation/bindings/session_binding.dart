import 'package:get/get.dart';
import '../controllers/session_controller.dart';
import '../controllers/pet_selection_controller.dart';
import '../controllers/collar_scan_controller.dart';
import '../controllers/baseline_controller.dart';

/// Binding for session flow screens
class SessionBinding extends Bindings {
  @override
  void dependencies() {
    // Main session controller - persists throughout session
    Get.put<SessionController>(SessionController(), permanent: true);
    
    // Lazy load sub-controllers
    Get.lazyPut<PetSelectionController>(() => PetSelectionController());
    Get.lazyPut<CollarScanController>(() => CollarScanController());
    Get.lazyPut<BaselineController>(() => BaselineController());
  }
}
