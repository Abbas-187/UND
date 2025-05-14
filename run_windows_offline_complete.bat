@echo off
echo Running Flutter Windows app in complete offline mode...
flutter run -d windows --no-pub --no-android-skip-build-dependency-validation
pause