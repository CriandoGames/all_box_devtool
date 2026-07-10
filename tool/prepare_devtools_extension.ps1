$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$extensionApp = Join-Path $repoRoot 'extension\devtools'
$tempBuild = Join-Path $repoRoot '.dart_tool\devtools_extension_build'
$destBuild = Join-Path $extensionApp 'build'

Remove-Item -LiteralPath $tempBuild -Recurse -Force -ErrorAction SilentlyContinue

Push-Location $extensionApp
try {
  flutter pub get
  flutter build web --release --output $tempBuild

  Remove-Item -LiteralPath $destBuild -Recurse -Force -ErrorAction SilentlyContinue
  New-Item -ItemType Directory -Path $destBuild | Out-Null
  Copy-Item -Path (Join-Path $tempBuild '*') -Destination $destBuild -Recurse -Force

  dart run devtools_extensions validate --package=$repoRoot
} finally {
  Pop-Location
}
