# Fix Windows Plugin Registrations
# This script fixes the MissingPluginException for camera_windows and other non-endorsed plugins

Write-Host "🔧 Fixing Windows plugin registrations..." -ForegroundColor Yellow

# 1. Fix generated_plugin_registrant.cc
$registrantFile = "windows\flutter\generated_plugin_registrant.cc"
$registrantContent = @"
//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <camera_windows/camera_windows_plugin.h>
#include <path_provider_windows/path_provider_windows.h>
#include <permission_handler_windows/permission_handler_windows_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  CameraWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CameraWindowsPlugin"));
  PathProviderWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PathProviderWindows"));
  PermissionHandlerWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("PermissionHandlerWindowsPlugin"));
}
"@

Write-Host "📝 Updating $registrantFile..." -ForegroundColor Cyan
$registrantContent | Out-File -FilePath $registrantFile -Encoding utf8

# 2. Add missing plugins to .flutter-plugins if they're not there
$flutterPluginsFile = ".flutter-plugins"
if (Test-Path $flutterPluginsFile) {
    $pluginsContent = Get-Content $flutterPluginsFile
    
    $missingPlugins = @()
    if (-not ($pluginsContent | Select-String "camera_windows=")) {
        $missingPlugins += "camera_windows=C:\Users\PierreGancel\AppData\Local\Pub\Cache\hosted\pub.dev\camera_windows-0.2.6+2\"
    }
    if (-not ($pluginsContent | Select-String "path_provider_windows=")) {
        $missingPlugins += "path_provider_windows=C:\Users\PierreGancel\AppData\Local\Pub\Cache\hosted\pub.dev\path_provider_windows-2.3.0\"
    }
    if (-not ($pluginsContent | Select-String "permission_handler_windows=")) {
        $missingPlugins += "permission_handler_windows=C:\Users\PierreGancel\AppData\Local\Pub\Cache\hosted\pub.dev\permission_handler_windows-0.2.1\"
    }
    
    if ($missingPlugins.Count -gt 0) {
        Write-Host "📝 Adding missing Windows plugins to .flutter-plugins..." -ForegroundColor Cyan
        $missingPlugins | Add-Content $flutterPluginsFile
    }
}

Write-Host "✅ Windows plugin registrations fixed!" -ForegroundColor Green
Write-Host "💡 You can now run: flutter run -d windows" -ForegroundColor Blue 