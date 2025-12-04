part of 'app_pages.dart';

/// Route name constants
abstract class Routes {
  Routes._();
  
  // Auth
  static const splash = '/splash';
  static const login = '/login';
  
  // Dashboard
  static const dashboard = '/dashboard';
  
  // Session Flow
  static const petSelection = '/pet-selection';
  static const addPet = '/add-pet';
  static const collarScan = '/collar-scan';
  static const sessionSetup = '/session-setup';
  static const baselineCollection = '/baseline-collection';
  static const baselineComplete = '/baseline-complete';
  static const preSurgery = '/pre-surgery';
  static const startSurgery = '/start-surgery';
  static const surgery = '/surgery';
  static const calibration = '/calibration';
  static const recovery = '/recovery';
  static const endSession = '/end-session';
  static const sessionComplete = '/session-complete';
  
  // Settings
  static const settings = '/settings';
  
  // Multi-observer
  static const joinSession = '/join-session';
  
  // Collar management
  static const collarSwap = '/collar-swap';
}
