# PowerShell script to run the freezed code generator for the CRM models

# Run the code generator
Write-Host "Running freezed code generator for CRM models..."
flutter pub run build_runner build --delete-conflicting-outputs

Write-Host "Freezed model generation completed for CRM models." 