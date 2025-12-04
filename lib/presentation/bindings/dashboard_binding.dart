import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

/// Binding for dashboard screen
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}
