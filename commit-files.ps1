# Get all modified files
lib/core/layout/main_layout.dart lib/core/routes/app_router.dart lib/features/inventory/data/models/inventory_item_model.dart lib/features/inventory/data/repositories/inventory_repository.dart lib/features/inventory/domain/entities/inventory_item.dart lib/features/inventory/domain/providers/batch_operations_provider.dart lib/features/inventory/domain/providers/inventory_provider.dart lib/features/inventory/domain/services/module_integration_service.dart lib/features/inventory/presentation/screens/create_movement_page.dart lib/features/inventory/presentation/screens/inventory_dashboard_page.dart lib/features/inventory/presentation/screens/inventory_item_details_screen.dart lib/features/inventory/presentation/screens/inventory_movement_history_screen.dart lib/features/inventory/presentation/screens/inventory_screen.dart lib/features/inventory/presentation/screens/movement_details_page.dart lib/features/inventory/presentation/widgets/dashboard/inventory_dashboard_widgets.dart lib/features/inventory/presentation/widgets/movements/movement_approval_dialog.dart lib/features/milk_reception/domain/models/milk_reception_model.dart lib/features/milk_reception/presentation/screens/milk_reception_details_screen.dart lib/features/procurement/domain/integration/procurement_inventory_integration.dart lib/features/procurement/presentation/screens/reports/procurement_dashboard_screen.dart lib/l10n/app_localizations.dart lib/main.dart pubspec.lock pubspec.yaml = git status -s | Where-Object {  -match '^\s*M\s+(.*)' } | ForEach-Object { System.Collections.Hashtable[1].Trim() }

# Commit each modified file separately
foreach ( in lib/core/layout/main_layout.dart lib/core/routes/app_router.dart lib/features/inventory/data/models/inventory_item_model.dart lib/features/inventory/data/repositories/inventory_repository.dart lib/features/inventory/domain/entities/inventory_item.dart lib/features/inventory/domain/providers/batch_operations_provider.dart lib/features/inventory/domain/providers/inventory_provider.dart lib/features/inventory/domain/services/module_integration_service.dart lib/features/inventory/presentation/screens/create_movement_page.dart lib/features/inventory/presentation/screens/inventory_dashboard_page.dart lib/features/inventory/presentation/screens/inventory_item_details_screen.dart lib/features/inventory/presentation/screens/inventory_movement_history_screen.dart lib/features/inventory/presentation/screens/inventory_screen.dart lib/features/inventory/presentation/screens/movement_details_page.dart lib/features/inventory/presentation/widgets/dashboard/inventory_dashboard_widgets.dart lib/features/inventory/presentation/widgets/movements/movement_approval_dialog.dart lib/features/milk_reception/domain/models/milk_reception_model.dart lib/features/milk_reception/presentation/screens/milk_reception_details_screen.dart lib/features/procurement/domain/integration/procurement_inventory_integration.dart lib/features/procurement/presentation/screens/reports/procurement_dashboard_screen.dart lib/l10n/app_localizations.dart lib/main.dart pubspec.lock pubspec.yaml) {
    Write-Host  Adding and committing:  -ForegroundColor Cyan
    git add "
 git commit -m Update: 
}

# Get all untracked files
 = git status -s | Where-Object { -match '^\s*\?\?\s+(.*)' } | ForEach-Object { System.Collections.Hashtable[1].Trim() }

# Commit each untracked file separately
foreach ( in ) {
 Write-Host Adding and committing new file:  -ForegroundColor Green
 git add 
 git commit -m Add: 
}

# Push all commits to remote
Write-Host Pushing all commits to remote... -ForegroundColor Yellow
git push

Write-Host Completed! -ForegroundColor Magenta
