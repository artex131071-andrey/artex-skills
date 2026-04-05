<#
.SYNOPSIS
    Синхронизирует скиллы из artex-skills в ~/.copilot/copilot-instructions.md

.DESCRIPTION
    Читает все SKILL.md из skills/*/SKILL.md, объединяет их в один файл
    и записывает в $HOME/.copilot/copilot-instructions.md.
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
    $Lines.Add($Body)
}

# Создаём директорию, если нет
$OutputDir = Split-Path $OutputFile -Parent
if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$Lines | Out-File -FilePath $OutputFile -Encoding UTF8 -Force

$SkillCount = $SkillDirs.Count
Write-Host "✓ Синхронизировано $SkillCount скиллов → $OutputFile" -ForegroundColor Green
