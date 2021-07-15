
function Get-VsWhere {
    param (
        [Parameter(ParameterSetName = "1")][String] $component,
        [Parameter(ParameterSetName = "1")][String] $find,
        [Parameter(ParameterSetName = "2")][String] $property
    )
    $vswhere = "C:/Program Files (x86)/Microsoft Visual Studio/Installer/vswhere.exe"
    if ($find) {
        & $vswhere -latest -requires $component -find $find
    }
    elseif ($property) {
        & $vswhere -latest -property $property
    }
}

function Get-DevShell {
    if (-not $script:_devshell) {
        $script:_devshell = Get-VsWhere `
            -component 'Microsoft.Component.MSBuild' `
            -find 'Common7/Tools/Microsoft.VisualStudio.DevShell.dll'
    }
    $script:_devshell
}

function Get-VsInstallPath {
    if (-not $script:_vsinstall) {
        $script:_vsinstall = Get-VsWhere `
            -property installationPath
    }
    $script:_vsinstall
}

function Enter-DevShell {
    
    $module = Get-DevShell
    Import-module $module | Out-Null
    $vsinstall = Get-VsInstallPath
    
    Push-Location
    Enter-VsDevShell -VsInstallPath $vsinstall | Out-Null
    Pop-Location
}

$before = Get-Item env:
Enter-DevShell
$after = Get-Item env:

$diff = $after | Where-Object { $_ -notin $before } | Sort-Object { $_.Name }
$vars = ""
foreach($var in $diff) {
    $vars += "set(ENV{$($var.Name)} `"$($var.Value -Replace "\\", "\\")`")`n"
}
$vars | Out-File "env.cmake"
