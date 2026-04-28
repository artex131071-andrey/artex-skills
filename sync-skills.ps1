<#
.SYNOPSIS
    Синхронизирует скиллы из artex-skills в Copilot CLI и Claude Code.

.DESCRIPTION
    Читает все SKILL.md из skills/*/SKILL.md и:
    1. Объединяет их в $HOME/.copilot/copilot-instructions.md (для Copilot CLI)
    2. Копирует каждый SKILL.md в $HOME/.claude/commands/<name>.md (для Claude Code slash-команд)
    Запускать вручную после добавления или обновления скиллов.

.EXAMPLE
    .\sync-skills.ps1
#>

$SkillsDir = Join-Path $PSScriptRoot "skills"
$OutputFile = Join-Path $HOME ".copilot\copilot-instructions.md"

if (-not (Test-Path $SkillsDir)) {
    Write-Error "Папка skills не найдена: $SkillsDir"
    exit 1
}

$SkillDirs = Get-ChildItem -Path $SkillsDir -Directory | Sort-Object Name

if ($SkillDirs.Count -eq 0) {
    Write-Error "Скиллы не найдены в: $SkillsDir"
    exit 1
}

$Lines = [System.Collections.Generic.List[string]]::new()

$Lines.Add("# Пользовательские скиллы Андрея (artex-skills)")
$Lines.Add("")
$Lines.Add("Следующие разделы описывают поведенческие скиллы для работы с проектами. Каждый скилл сам определяет условия своего применения через секцию «Когда применять». Источник истины: ``$SkillsDir``.")
$Lines.Add("")
$Lines.Add("## Доступные скиллы")
$Lines.Add("")

foreach ($dir in $SkillDirs) {
    $Lines.Add("- ``$($dir.Name)``")
}

foreach ($dir in $SkillDirs) {
    $SkillFile = Join-Path $dir.FullName "SKILL.md"

    if (-not (Test-Path $SkillFile)) {
        Write-Warning "SKILL.md не найден в: $($dir.FullName) — пропускаю"
        continue
    }

    $Content = Get-Content $SkillFile -Raw -Encoding UTF8

    # Убираем YAML frontmatter (блок между первыми двумя ---)
    if ($Content -match '(?s)^---\n.*?\n---\n(.*)$') {
        $Body = $Matches[1].Trim()
    } else {
        $Body = $Content.Trim()
    }

    # Понижаем уровень заголовков: # → ## (чтобы вписать в общую структуру)
    $Body = $Body -replace '(?m)^(#{1,5}) ', '$1# '

    $Lines.Add("")
    $Lines.Add("---")
    $Lines.Add("")
    $Lines.Add("## ``$($dir.Name)``")
    $Lines.Add("")
    $Lines.Add($Body)
}

# Создаём директорию, если нет
$OutputDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$Lines | Out-File -FilePath $OutputFile -Encoding UTF8 -Force

$SkillCount = $SkillDirs.Count
Write-Host "✓ Copilot: синхронизировано $SkillCount скиллов → $OutputFile" -ForegroundColor Green

# --- Claude Code: копируем каждый SKILL.md как slash-команду ---
$ClaudeCommandsDir = Join-Path $HOME ".claude\commands"
if (-not (Test-Path $ClaudeCommandsDir)) {
    New-Item -ItemType Directory -Path $ClaudeCommandsDir -Force | Out-Null
}

$ClaudeCount = 0
foreach ($dir in $SkillDirs) {
    $SkillFile = Join-Path $dir.FullName "SKILL.md"
    if (-not (Test-Path $SkillFile)) { continue }

    $Dest = Join-Path $ClaudeCommandsDir "$($dir.Name).md"
    Copy-Item $SkillFile $Dest -Force
    $ClaudeCount++
}

Write-Host "OK Claude: $ClaudeCount skills -> $ClaudeCommandsDir" -ForegroundColor Cyan
