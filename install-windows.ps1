<#
.SYNOPSIS
    Устанавливает общие инструкции и навыки для Codex и Claude в Windows.
.DESCRIPTION
    Физически копирует файлы. Изменяемые существующие файлы сохраняет в
    <TargetProfile>/.artex-skills-backups/<дата-время>/ с прежними путями.
    Поддерживает -WhatIf. Junction и символические ссылки не изменяет.
.EXAMPLE
    .\install-windows.ps1 -WhatIf
.EXAMPLE
    .\install-windows.ps1 -Agents Codex,Claude
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('Codex', 'Claude')]
    [string[]]$Agents = @('Codex', 'Claude'),
    [ValidateNotNullOrEmpty()]
    [string]$TargetProfile = $env:USERPROFILE
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$encoding = New-Object System.Text.UTF8Encoding($false)
$profileRoot = [IO.Path]::GetFullPath($TargetProfile)
$skillsRoot = Join-Path $PSScriptRoot 'skills'
$operations = New-Object 'System.Collections.Generic.List[object]'

function Assert-NoLinks([string]$Path) {
    $cursor = [IO.Path]::GetFullPath($Path)
    while ($cursor) {
        # Get-Item проверяет в том числе ссылки на отсутствующие объекты.
        $item = Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
        if ($null -ne $item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
            throw "Обнаружена ссылка или junction: $cursor. Установщик её не изменяет. Используйте обычную папку профиля и навыков; см. docs/WINDOWS.md."
        }
        $parent = Split-Path -Path $cursor -Parent
        if ($parent -eq $cursor) { break }
        $cursor = $parent
    }
}

function Add-Operation([string]$RelativePath, [string]$Content) {
    $dest = [IO.Path]::GetFullPath((Join-Path $profileRoot $RelativePath))
    $prefix = $profileRoot.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
    if (-not $dest.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Путь назначения находится вне профиля: $dest"
    }
    $operations.Add([pscustomobject]@{ RelativePath = $RelativePath; Path = $dest; Content = $Content })
}

function Get-SkillBody([string]$Content) {
    return ([regex]::Replace($Content, '\A\uFEFF?---\r?\n.*?\r?\n---(?:\r?\n|\z)', '', [Text.RegularExpressions.RegexOptions]::Singleline)).Trim()
}

$skillDirs = @(Get-ChildItem -LiteralPath $skillsRoot -Directory | Sort-Object Name)
if ($skillDirs.Count -eq 0) { throw "Навыки не найдены: $skillsRoot" }
foreach ($dir in $skillDirs) {
    if (-not (Test-Path -LiteralPath (Join-Path $dir.FullName 'SKILL.md') -PathType Leaf)) {
        throw "Нет SKILL.md в $($dir.FullName)"
    }
}

if ($Agents -contains 'Codex') {
    $text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'instructions/codex/AGENTS.md'))
    Add-Operation '.codex/AGENTS.md' $text
    foreach ($dir in $skillDirs) {
        # Вместе с SKILL.md переносим метаданные и текстовые ресурсы навыка.
        foreach ($file in Get-ChildItem -LiteralPath $dir.FullName -File -Recurse -Force) {
            $relative = $file.FullName.Substring($skillsRoot.Length).TrimStart('\', '/')
            Add-Operation (Join-Path '.codex/skills' $relative) ([IO.File]::ReadAllText($file.FullName))
        }
    }
}
if ($Agents -contains 'Claude') {
    $text = [IO.File]::ReadAllText((Join-Path $PSScriptRoot 'instructions/claude/CLAUDE.md')).TrimEnd()
    foreach ($name in @('project-intake', 'plan-and-wait', 'docs-closeout')) {
        $body = Get-SkillBody ([IO.File]::ReadAllText((Join-Path $skillsRoot "$name/SKILL.md")))
        $text += "`n`n---`n`n$body"
    }
    Add-Operation '.claude/CLAUDE.md' ($text + "`n")
    foreach ($dir in $skillDirs) {
        $body = Get-SkillBody ([IO.File]::ReadAllText((Join-Path $dir.FullName 'SKILL.md')))
        Add-Operation ".claude/commands/$($dir.Name).md" ($body + "`n")
    }
}

# Полная предварительная проверка до первой записи.
Assert-NoLinks $profileRoot
foreach ($op in $operations) {
    Assert-NoLinks $op.Path
    if (Test-Path -LiteralPath $op.Path -PathType Container) { throw "Вместо файла существует папка: $($op.Path)" }
    $parent = Split-Path -Path $op.Path -Parent
    while ($parent -and -not (Test-Path -LiteralPath $parent)) { $parent = Split-Path -Path $parent -Parent }
    if ($parent -and -not (Test-Path -LiteralPath $parent -PathType Container)) { throw "Родительский путь не является папкой: $parent" }
}
$backupRoot = Join-Path $profileRoot ('.artex-skills-backups/' + (Get-Date -Format 'yyyyMMdd-HHmmss-fffffff'))
Assert-NoLinks $backupRoot
$changed = 0
$unchanged = 0
foreach ($op in $operations) {
    if ((Test-Path -LiteralPath $op.Path -PathType Leaf) -and [IO.File]::ReadAllText($op.Path) -ceq $op.Content) {
        $unchanged++
        continue
    }
    if ($PSCmdlet.ShouldProcess($op.Path, 'Установить файл; прежнюю версию сохранить в резервной копии')) {
        if (Test-Path -LiteralPath $op.Path -PathType Leaf) {
            $backup = Join-Path $backupRoot $op.RelativePath
            New-Item -ItemType Directory -Path (Split-Path -Path $backup -Parent) -Force | Out-Null
            Copy-Item -LiteralPath $op.Path -Destination $backup
        }
        New-Item -ItemType Directory -Path (Split-Path -Path $op.Path -Parent) -Force | Out-Null
        [IO.File]::WriteAllText($op.Path, $op.Content, $encoding)
        $changed++
    }
}
Write-Host "Готово. Записано: $changed; без изменений: $unchanged. Профиль: $profileRoot"
if (Test-Path -LiteralPath $backupRoot) { Write-Host "Резервные копии: $backupRoot" }
