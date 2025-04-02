# Configuration
$projectName = "und_app"
$projectRootPath = "C:\Users\morel\OneDrive\Documents\FlutterProjects\UNDAPP\und_app"
$featuresRootPath = "$projectRootPath\lib\features"
$reportDirPath = "$projectRootPath\ErrorReports"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$masterReportPath = Join-Path -Path $reportDirPath -ChildPath "Master_$projectName-$timestamp.html"

# Ensure report directory exists
if (-not (Test-Path -Path $reportDirPath)) {
    New-Item -Path $reportDirPath -ItemType Directory -Force | Out-Null
}

# Function to run dart analyze at the project level
function Run-DartAnalyze {
    Write-Host "Running dart analyze on the entire project..." -ForegroundColor Yellow
    
    try {
        # Run dart analyze from the project root and capture output
        $analysisOutput = & dart analyze --format=machine 2>&1
        return $analysisOutput
    }
    catch {
        Write-Host "Failed to run dart analyze: $_" -ForegroundColor Red
        return @()
    }
}

# Function to filter analysis results by feature directory
function Filter-AnalysisResultsByFeature {
    param (
        [Parameter(Mandatory)][array]$AnalysisOutput,
        [Parameter(Mandatory)][string]$FeaturePath,
        [Parameter(Mandatory)][string]$FeatureName
    )
    
    $filteredErrors = @()

    foreach ($line in $AnalysisOutput) {
        if ($line -match '(ERROR|WARNING|INFO)' -and $line -match [regex]::Escape($FeaturePath)) {
            # Parse output format: TYPE|FILE|LINE|COLUMN|CODE|MESSAGE
            $parts = $line -split '\|'
            
            if ($parts.Count -ge 6) {
                $severity = $parts[0]
                $file = $parts[1]
                $lineNumber = $parts[2]
                $column = $parts[3]
                $code = $parts[4]
                $message = $parts[5]
                
                # Add error details to the list of errors
                $filteredErrors += @{
                    Severity   = $severity
                    File       = $file
                    LineNumber = [int]$lineNumber
                    Column     = [int]$column
                    Code       = $code
                    Message    = $message
                }
            }
        }
    }

    return $filteredErrors
}

# Generate master HTML report summarizing all features' issues.
function Generate-MasterReport {
    param (
        [Parameter(Mandatory)][array]$MasterData,
        [Parameter(Mandatory)][string]$OutputFile
    )
    
    Write-Host "`nGenerating master report..." -ForegroundColor Cyan
    
    # Initialize HTML content for the master report
    $htmlContent = @"
<!DOCTYPE html>
<html>
<head>
<title>Master Error Report</title>
<style>
body { font-family: Arial, sans-serif; margin: 20px; }
h1, h2, h3 { color: #2c3e50; }
table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
th { background-color: #4472C4; color: white; }
tr:nth-child(even) { background-color: #f2f2f2; }
</style>
</head>
<body>
<h1>Master Error Report - $projectName</h1>
<h2>Generated on $(Get-Date)</h2>

<table>
<tr>
<th>Feature</th>
<th>Severity</th>
<th>File</th>
<th>Line</th>
<th>Column</th>
<th>Code</th>
<th>Message</th>
</tr>
"@

    # Add rows for each error in the master data
    foreach ($error in $MasterData) {
        $htmlContent += "<tr>"
        $htmlContent += "<td>$($error.Feature)</td>"
        $htmlContent += "<td>$($error.Severity)</td>"
        $htmlContent += "<td>$($error.File)</td>"
        $htmlContent += "<td>$($error.LineNumber)</td>"
        $htmlContent += "<td>$($error.Column)</td>"
        $htmlContent += "<td>$($error.Code)</td>"
        $htmlContent += "<td>$($error.Message)</td>"
        $htmlContent += "</tr>"
    }

    $htmlContent += @"
</table>
</body>
</html>
"@

    # Save the HTML content to the specified output file
    try {
        $htmlContent | Out-File -FilePath "$OutputFile" -Encoding utf8
        Write-Host "Master report saved successfully at: ${OutputFile}" -ForegroundColor Green
    }
    catch {
        Write-Host "Failed to save master report: $_" -ForegroundColor Red
    }
}

# Main Execution

# Define features with absolute paths based on your directory structure.
$features = @(
    @{ Name="auth"; Path="$featuresRootPath\auth" },
    @{ Name="factory"; Path="$featuresRootPath\factory" },
    @{ Name="forecasting"; Path="$featuresRootPath\forecasting" },
    @{ Name="inventory"; Path="$featuresRootPath\inventory" },
    @{ Name="logistics"; Path="$featuresRootPath\logistics" },
    @{ Name="quality_control"; Path="$featuresRootPath\quality_control" },
    @{ Name="sales"; Path="$featuresRootPath\sales" },
    @{ Name="warehouse"; Path="$featuresRootPath\warehouse" },
    @{ Name="warehouse_operations"; Path="$featuresRootPath\warehouse_operations" }
)

Write-Host "`nRunning dart analyze for the entire project..." -ForegroundColor Cyan

# Run dart analyze at project level and capture results
$analysisOutput = Run-DartAnalyze

if ($analysisOutput.Count -eq 0) {
    Write-Host "No analysis output found. Exiting..." -ForegroundColor Red
    exit 1
}

# Initialize master report data structure
$masterReportData = @()

foreach ($feature in $features) {
    Write-Host "`nAnalyzing feature: ${feature.Name}" -ForegroundColor Cyan
    
    # Filter analysis results for this feature
    $errors = Filter-AnalysisResultsByFeature `
              -AnalysisOutput $analysisOutput `
              -FeaturePath "$($feature.Path)" `
              -FeatureName "$($feature.Name)"
    
    if ($errors.Count -gt 0) {
        Write-Host "Found ${errors.Count} issues for feature: ${feature.Name}" -ForegroundColor Yellow
        
        # Append errors to master report data with feature name included
        foreach ($error in $errors) {
            $masterReportData += @{
                Feature     = "$($feature.Name)"
                Severity    = "$($error.Severity)"
                File        = "$($error.File)"
                LineNumber  = "$($error.LineNumber)"
                Column      = "$($error.Column)"
                Code        = "$($error.Code)"
                Message     = "$($error.Message)"
            }
        }
        
        # Save individual JSON report for this feature (optional)
        $jsonReportPath = Join-Path -Path "$reportDirPath" `
                           -ChildPath "$($feature.Name)-errors-$timestamp.json"
        ConvertTo-Json -InputObject @{ Errors=$errors } | Out-File `
                       -FilePath "$jsonReportPath" `
                       -Encoding utf8
        
        Write-Host "Saved JSON report for ${feature.Name} at ${jsonReportPath}" -ForegroundColor Green
    } else {
        Write-Host "No issues found for feature: ${feature.Name}" -ForegroundColor Green
    }
}

# Generate master HTML report summarizing all features' issues.
Generate-MasterReport `
-MasterData @{"Errors"=$masterReportData} `
-OutputFile "$masterReportPath"

Write-Host "`nAnalysis complete. Master report available at: ${masterReportPath}" -ForegroundColor Cyan
