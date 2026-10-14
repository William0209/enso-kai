<#
.SYNOPSIS
  Install or uninstall this Enso system into Claude Code (Windows PowerShell 5.1+ or PowerShell 7+).

.DESCRIPTION
  - Links each folder in system/skills into <ClaudeHome>/skills (directory junctions on Windows, no admin needed).
  - Adds an @import of system/CLAUDE.md to <ClaudeHome>/CLAUDE.md.
  - Merges autoMemoryDirectory, env.ENSO_HOME and secret-file deny rules into <ClaudeHome>/settings.json.
  Non-destructive: anything it would replace is moved to <ClaudeHome>/.enso-backup/<timestamp>/ first.

.EXAMPLE
  ./scripts/install.ps1             # install
  ./scripts/install.ps1 -DryRun     # show what would happen
  ./scripts/install.ps1 -Uninstall  # remove links, import and settings keys
#>
param(
    [string]$ClaudeHome = (Join-Path $HOME '.claude'),
    [switch]$Uninstall,
    [switch]$DryRun
)
$ErrorActionPreference = 'Stop'

$Repo      = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$System    = Join-Path $Repo 'system'
$Skills    = Join-Path $System 'skills'
$OnWindows = ($PSVersionTable.PSEdition -eq 'Desktop') -or $IsWindows
$Backup    = Join-Path $ClaudeHome (".enso-backup/" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$Marker    = '<!-- enso: system instructions -->'
$DenyRules = @('Read(**/.env)', 'Read(**/.env.local)', 'Read(**/*.pem)', 'Read(**/*.key)', 'Read(**/secrets/*.dec.*)')

# Claude Code accepts absolute paths or ~/ paths; prefer ~/ so the value reads the same on every device.
function ConvertTo-ClaudePath([string]$path) {
    $p = $path -replace '\\', '/'
    $h = ($HOME -replace '\\', '/').TrimEnd('/')
    if ($p.StartsWith("$h/", [StringComparison]::OrdinalIgnoreCase)) { $p = '~/' + $p.Substring($h.Length + 1) }
    return $p
}
$MemoryDir  = ConvertTo-ClaudePath (Join-Path $System 'memory')
$EnsoHome   = $Repo -replace '\\', '/'
$ImportLine = '@' + ((ConvertTo-ClaudePath (Join-Path $System 'CLAUDE.md')) -replace ' ', '\ ')

function Say([string]$msg) { Write-Host "  $msg" }
function Step([string]$msg, [scriptblock]$action) {
    if ($DryRun) { Say "[dry-run] $msg" } else { & $action; Say $msg }
}
function Get-LinkTarget([string]$path) {
    $item = Get-Item -LiteralPath $path -Force -ErrorAction SilentlyContinue
    if ($item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { return [string]($item.Target | Select-Object -First 1) }
    return $null
}
function Move-ToBackup([string]$path) {
    New-Item -ItemType Directory -Force -Path $Backup | Out-Null
    Move-Item -LiteralPath $path -Destination (Join-Path $Backup (Split-Path $path -Leaf))
}
function Write-Utf8([string]$path, [string]$text) {
    [IO.File]::WriteAllText($path, $text, (New-Object Text.UTF8Encoding $false))  # no BOM
}
function Set-Prop($obj, [string]$name, $value) {
    if ($obj.PSObject.Properties[$name]) { $obj.$name = $value }
    else { $obj | Add-Member -NotePropertyName $name -NotePropertyValue $value }
}
function Read-Settings([string]$path) {
    if ((Test-Path $path) -and (Get-Content -Raw $path).Trim()) { return (Get-Content -Raw $path | ConvertFrom-Json) }
    return [pscustomobject]@{}
}

$SkillsDir    = Join-Path $ClaudeHome 'skills'
$ClaudeMd     = Join-Path $ClaudeHome 'CLAUDE.md'
$SettingsPath = Join-Path $ClaudeHome 'settings.json'

Write-Host "Enso $(if ($Uninstall) {'uninstall'} else {'install'}): $Repo -> $ClaudeHome"

# ---------------------------------------------------------------- skills
Write-Host 'Skills'
if (-not $Uninstall) { New-Item -ItemType Directory -Force -Path $SkillsDir | Out-Null }
foreach ($src in Get-ChildItem -Directory $Skills) {
    $dest   = Join-Path $SkillsDir $src.Name
    $target = Get-LinkTarget $dest
    $ours   = $target -and ((($target -replace '\\', '/').TrimEnd('/')) -ieq (($src.FullName -replace '\\', '/').TrimEnd('/')))
    if ($Uninstall) {
        if ($ours) { Step "unlinked $($src.Name)" { [IO.Directory]::Delete($dest, $false) } }
        continue
    }
    if ($ours) { Say "ok        $($src.Name)"; continue }
    if (Test-Path -LiteralPath $dest) { Step "backed up existing $($src.Name)" { Move-ToBackup $dest } }
    $type = if ($OnWindows) { 'Junction' } else { 'SymbolicLink' }
    Step "linked    $($src.Name)" { New-Item -ItemType $type -Path $dest -Target $src.FullName | Out-Null }
}

# ---------------------------------------------------------------- CLAUDE.md import
Write-Host 'CLAUDE.md'
$lines = if (Test-Path $ClaudeMd) { @(Get-Content $ClaudeMd) } else { @() }
$has   = $lines -contains $ImportLine
if ($Uninstall) {
    if ($has) { Step 'removed Enso import' { Write-Utf8 $ClaudeMd ((($lines | Where-Object { $_ -ne $Marker -and $_ -ne $ImportLine }) -join "`n").TrimEnd() + "`n") } }
} elseif ($has) {
    Say 'ok        import present'
} else {
    $block = "$Marker`n$ImportLine`n"
    $text  = if ($lines.Count) { (($lines -join "`n").TrimEnd()) + "`n`n" + $block } else { $block }
    Step "added     $ImportLine" { Write-Utf8 $ClaudeMd $text }
}

# ---------------------------------------------------------------- settings.json
Write-Host 'settings.json'
$settings = Read-Settings $SettingsPath
$before   = $settings | ConvertTo-Json -Depth 32 -Compress

if (-not $settings.PSObject.Properties['env'])         { Set-Prop $settings 'env' ([pscustomobject]@{}) }
if (-not $settings.PSObject.Properties['permissions']) { Set-Prop $settings 'permissions' ([pscustomobject]@{}) }
$deny = @($settings.permissions.deny | Where-Object { $_ })

if ($Uninstall) {
    if ($settings.autoMemoryDirectory -eq $MemoryDir) { $settings.PSObject.Properties.Remove('autoMemoryDirectory') }
    if ($settings.env.ENSO_HOME -eq $EnsoHome)       { $settings.env.PSObject.Properties.Remove('ENSO_HOME') }
    $deny = @($deny | Where-Object { $DenyRules -notcontains $_ })
} else {
    if ($settings.autoMemoryDirectory -and $settings.autoMemoryDirectory -ne $MemoryDir) {
        Say "note: replacing autoMemoryDirectory '$($settings.autoMemoryDirectory)' (old value kept in backup)"
    }
    Set-Prop $settings 'autoMemoryDirectory' $MemoryDir
    Set-Prop $settings.env 'ENSO_HOME' $EnsoHome
    $deny = @($deny + ($DenyRules | Where-Object { $deny -notcontains $_ }))
}
if ($deny.Count) { Set-Prop $settings.permissions 'deny' $deny } else { $settings.permissions.PSObject.Properties.Remove('deny') }
if (-not @($settings.env.PSObject.Properties).Count)         { $settings.PSObject.Properties.Remove('env') }
if (-not @($settings.permissions.PSObject.Properties).Count) { $settings.PSObject.Properties.Remove('permissions') }

if (($settings | ConvertTo-Json -Depth 32 -Compress) -eq $before) {
    Say 'ok        no changes'
} else {
    Step "autoMemoryDirectory, ENSO_HOME, deny rules $(if ($Uninstall) {'removed'} else {'set'})" {
        New-Item -ItemType Directory -Force -Path $ClaudeHome | Out-Null
        if (Test-Path $SettingsPath) { New-Item -ItemType Directory -Force -Path $Backup | Out-Null; Copy-Item $SettingsPath (Join-Path $Backup 'settings.json') }
        Write-Utf8 $SettingsPath (($settings | ConvertTo-Json -Depth 32) + "`n")
    }
}

if (-not $Uninstall) {
    Write-Host "`nDone. Restart Claude Code, then run /onboard."
    if (Test-Path $Backup) { Write-Host "Backups: $Backup" }
}
