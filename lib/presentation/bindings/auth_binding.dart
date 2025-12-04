import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

/// Binding for authentication screens
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(() => AuthController());
  }
}
