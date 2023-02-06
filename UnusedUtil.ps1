#Requires -Version 7 -Modules FXPSYaml

Import-Module FXPSYaml;

Add-Type -AssemblyName System.Windows.Forms;

# Tell me someone will get this one.
function Write-SickHeader() {
    $Intro = 
    "     _   _   __   _   _   _   _____   _____   _____   _   _   _____   _   _      
    | | | | |  \ | | | | | | /  ___/ | ____| |  _  \ | | | | |_   _| | | | |     
    | | | | |   \| | | | | | | |___  | |__   | | | | | | | |   | |   | | | |     
    | | | | | |\   | | | | | \___  \ |  __|  | | | | | | | |   | |   | | | |     
    | |_| | | | \  | | |_| |  ___| | | |___  | |_| | | |_| |   | |   | | | |___  
    \_____/ |_|  \_| \_____/ /_____/ |_____| |_____/ \_____/   |_|   |_| |_____| "

    $Quote = "They say I don't know how to use PowerShell.", 
             "And he lays down my server, your plugin is sucks.",
             "I spent three days getting this to work.";

    Write-Host $Intro -ForegroundColor Yellow;
    $Quote | Get-Random | Write-Host;
}

function Select-File([string] $Folder) {
    $Browser = New-Object System.Windows.Forms.OpenFileDialog;
    $Browser.Title = "Select the translation file";
    $Browser.InitialDirectory = $Folder
    $Result = $Browser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }));
    if ($Result -eq [Windows.Forms.DialogResult]::OK) {
        return $browser.FileName;
    } else { Exit; }
}

function Select-Folder() {
    $Browser = New-Object System.Windows.Forms.FolderBrowserDialog;
    $Browser.RootFolder = "MyComputer";
    $Browser.Description = "Select the folder the repository is located at";
    $Result = $Browser.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true }));
    if ($Result -eq [Windows.Forms.DialogResult]::OK) {
        return $Browser.SelectedPath;
    } else { Exit; }
}

Write-SickHeader;

$Folder = Select-Folder
$File = Select-File;

# This could be potentially improved

Write-Information "Parsing file $File";

$Yaml = [System.IO.File]::ReadAllText($File) | ConvertFrom-Yaml;

$KeyCount = $Yaml.Keys.Count
$Progress = 0;

# Create an "bucket" array for the 
$UnusedKeys = [System.Collections.ArrayList]@();

foreach ($Key in $Yaml.Keys) {
    $Progress = $Progress + 1;
    $Percent = [Math]::Floor(($Progress / $KeyCount) * 100);
    
    Write-Progress -Activity "Search in Progress" -Status "Processing $Key" -PercentComplete $Percent

    $Finds = Get-ChildItem -Recurse *.java | Select-String -Pattern "(`"$Key`")" | Select-Object -Unique Path
    
    if ($Finds.Count -eq 0) {
        $UnusedKeys.Add($Key);
    }
}

$($UnusedKeys -join [Environment]::NewLine) > "./results.txt";
Write-Output "Complete! Found $($UnusedKeys.Count) unused keys.";
