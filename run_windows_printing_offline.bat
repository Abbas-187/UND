@echo off
echo Running Flutter Windows app with printing package offline workaround...

:: Set environment variable to skip PDFium download
set ENABLE_PDFIUM_DOWNLOAD=0

:: Run Flutter in offline mode
flutter run -d windows --no-pub

:: Reset environment variable
set ENABLE_PDFIUM_DOWNLOAD=

pause