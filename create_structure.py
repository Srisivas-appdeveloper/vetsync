import os

structure = [

    # ROOT
    "vetsync_clinical_mobile/pubspec.yaml",
    "vetsync_clinical_mobile/README.md",

    # lib/
    "vetsync_clinical_mobile/lib/main.dart",

    # app/
    "vetsync_clinical_mobile/lib/app/bindings/initial_binding.dart",
    "vetsync_clinical_mobile/lib/app/routes/app_pages.dart",
    "vetsync_clinical_mobile/lib/app/routes/app_routes.dart",
    "vetsync_clinical_mobile/lib/app/themes/app_colors.dart",
    "vetsync_clinical_mobile/lib/app/themes/app_theme.dart",
    "vetsync_clinical_mobile/lib/app/themes/app_typography.dart",

    # core/
    "vetsync_clinical_mobile/lib/core/algorithms/bcg_algorithm.dart",
    "vetsync_clinical_mobile/lib/core/constants/app_config.dart",

    # data/models
    "vetsync_clinical_mobile/lib/data/models/models.dart",
    "vetsync_clinical_mobile/lib/data/models/animal.dart",
    "vetsync_clinical_mobile/lib/data/models/annotation.dart",
    "vetsync_clinical_mobile/lib/data/models/baseline_data.dart",
    "vetsync_clinical_mobile/lib/data/models/collar.dart",
    "vetsync_clinical_mobile/lib/data/models/enums.dart",
    "vetsync_clinical_mobile/lib/data/models/session.dart",
    "vetsync_clinical_mobile/lib/data/models/user.dart",
    "vetsync_clinical_mobile/lib/data/models/vitals.dart",
    "vetsync_clinical_mobile/lib/data/models/vital_ranges.dart",

    # data/repositories
    "vetsync_clinical_mobile/lib/data/repositories/animal_repository.dart",
    "vetsync_clinical_mobile/lib/data/repositories/annotation_repository.dart",
    "vetsync_clinical_mobile/lib/data/repositories/auth_repository.dart",
    "vetsync_clinical_mobile/lib/data/repositories/collar_repository.dart",
    "vetsync_clinical_mobile/lib/data/repositories/session_repository.dart",

    # data/services
    "vetsync_clinical_mobile/lib/data/services/api_service.dart",
    "vetsync_clinical_mobile/lib/data/services/auth_service.dart",
    "vetsync_clinical_mobile/lib/data/services/ble_service.dart",
    "vetsync_clinical_mobile/lib/data/services/connectivity_service.dart",
    "vetsync_clinical_mobile/lib/data/services/database_service.dart",
    "vetsync_clinical_mobile/lib/data/services/storage_service.dart",
    "vetsync_clinical_mobile/lib/data/services/sync_service.dart",
    "vetsync_clinical_mobile/lib/data/services/websocket_service.dart",

    # presentation/bindings
    "vetsync_clinical_mobile/lib/presentation/bindings/auth_binding.dart",
    "vetsync_clinical_mobile/lib/presentation/bindings/dashboard_binding.dart",
    "vetsync_clinical_mobile/lib/presentation/bindings/session_binding.dart",

    # presentation/controllers
    "vetsync_clinical_mobile/lib/presentation/controllers/auth_controller.dart",
    "vetsync_clinical_mobile/lib/presentation/controllers/baseline_controller.dart",
    "vetsync_clinical_mobile/lib/presentation/controllers/collar_scan_controller.dart",
    "vetsync_clinical_mobile/lib/presentation/controllers/dashboard_controller.dart",
    "vetsync_clinical_mobile/lib/presentation/controllers/pet_selection_controller.dart",
    "vetsync_clinical_mobile/lib/presentation/controllers/session_controller.dart",
    "vetsync_clinical_mobile/lib/presentation/controllers/surgery_controller.dart",

    # presentation/pages/auth
    "vetsync_clinical_mobile/lib/presentation/pages/auth/splash_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/auth/login_page.dart",

    # presentation/pages/dashboard
    "vetsync_clinical_mobile/lib/presentation/pages/dashboard/dashboard_page.dart",

    # presentation/pages/session
    "vetsync_clinical_mobile/lib/presentation/pages/session/pet_selection_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/add_pet_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/collar_scan_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/session_setup_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/baseline_collection_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/baseline_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/baseline_complete_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/pre_surgery_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/start_surgery_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/surgery_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/calibration_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/recovery_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/end_session_page.dart",
    "vetsync_clinical_mobile/lib/presentation/pages/session/session_complete_page.dart",

    # presentation/pages/settings
    "vetsync_clinical_mobile/lib/presentation/pages/settings/settings_page.dart",

    # presentation/widgets
    "vetsync_clinical_mobile/lib/presentation/widgets/common_widgets.dart",
    "vetsync_clinical_mobile/lib/presentation/widgets/waveform_chart.dart",
]

for path in structure:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "w") as f:
        f.write("")  # Create empty file

print("🎉 Project structure created successfully!")
