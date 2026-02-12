param(
  [Parameter(Mandatory=$true)]
  [string]$ApiKey
)

$envPath = Join-Path -Path $PSScriptRoot -ChildPath "..\.env"
if (!(Test-Path $envPath)) {
  New-Item -Path $envPath -ItemType File -Force | Out-Null
}

# Update or append GEMINI_API_KEY line
$content = Get-Content $envPath -Raw
if ($content -match "^GEMINI_API_KEY=.*" ) {
  $content = $content -replace "^GEMINI_API_KEY=.*", "GEMINI_API_KEY=$ApiKey"
} else {
  if ($content.Trim().Length -gt 0) { $content += "`n" }
  $content += "GEMINI_API_KEY=$ApiKey"
}
Set-Content -Path $envPath -Value $content
Write-Host "GEMINI_API_KEY set in .env"
