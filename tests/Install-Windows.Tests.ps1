# Самостоятельная проверка установщика, без Pester и без изменения рабочего профиля.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$repoRoot = Split-Path -Path $PSScriptRoot -Parent
$installer = Join-Path $repoRoot 'install-windows.ps1'
$testRoot = Join-Path $env:TEMP ('artex-skills-tests-' + [guid]::NewGuid().ToString('N'))
$profile = Join-Path $testRoot 'profile'
function Assert([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}

# -WhatIf не создаёт даже корень профиля.
& $installer -TargetProfile $profile -WhatIf 6>$null
Assert (-not (Test-Path -LiteralPath $testRoot)) 'WhatIf изменил файловую систему'
& $installer -TargetProfile $profile 6>$null
Assert (@(Get-ChildItem -LiteralPath (Join-Path $profile '.codex/skills') -Directory).Count -eq 11) 'Нет 11 навыков Codex'
Assert (@(Get-ChildItem -LiteralPath (Join-Path $profile '.claude/commands') -File).Count -eq 11) 'Нет 11 команд Claude'
$claudeText = [IO.File]::ReadAllText((Join-Path $profile '.claude/CLAUDE.md'))
foreach ($heading in @('# Project Intake', '# Plan And Wait', '# Docs Closeout')) {
    Assert ($claudeText.Contains($heading)) "Нет базового процесса: $heading"
}
Assert (-not $claudeText.Contains('description:')) 'В глобальный CLAUDE.md попал YAML frontmatter'
$command = [IO.File]::ReadAllText((Join-Path $profile '.claude/commands/plan-and-wait.md'))
Assert ($command.StartsWith('# Plan And Wait')) 'Команда содержит служебный frontmatter'

# Повторная установка не переписывает файлы и не создаёт резервных копий.
$codexRules = Join-Path $profile '.codex/AGENTS.md'
$initialTime = (Get-Item -LiteralPath $codexRules).LastWriteTimeUtc
& $installer -TargetProfile $profile 6>$null
Assert ((Get-Item -LiteralPath $codexRules).LastWriteTimeUtc -eq $initialTime) 'Повторная установка переписала одинаковый файл'
Assert (-not (Test-Path -LiteralPath (Join-Path $profile '.artex-skills-backups'))) 'Появилась лишняя резервная копия'

# Локальное дополнение сохраняется, а сторонние навыки не затрагиваются.
$customText = 'Мои локальные правила'
[IO.File]::WriteAllText($codexRules, $customText)
$customSkill = Join-Path $profile '.codex/skills/custom/SKILL.md'
New-Item -ItemType Directory -Path (Split-Path -Path $customSkill -Parent) -Force | Out-Null
[IO.File]::WriteAllText($customSkill, 'Не менять')
& $installer -TargetProfile $profile 6>$null
$backups = @(Get-ChildItem -LiteralPath (Join-Path $profile '.artex-skills-backups') -File -Recurse)
Assert ($backups.Count -eq 1) 'Неверное число резервных копий'
Assert ([IO.File]::ReadAllText($backups[0].FullName) -ceq $customText) 'Резервная копия не сохранила прежний текст'
Assert ([IO.File]::ReadAllText($customSkill) -ceq 'Не менять') 'Изменён сторонний навык'

# Можно устанавливать инструменты независимо.
$claudeOnly = Join-Path $testRoot 'claude-only'
& $installer -TargetProfile $claudeOnly -Agents Claude 6>$null
Assert (-not (Test-Path -LiteralPath (Join-Path $claudeOnly '.codex'))) 'Claude-only затронул Codex'
$codexOnly = Join-Path $testRoot 'codex-only'
& $installer -TargetProfile $codexOnly -Agents Codex 6>$null
Assert (-not (Test-Path -LiteralPath (Join-Path $codexOnly '.claude'))) 'Codex-only затронул Claude'

# При junction установщик не пишет ни через ссылку, ни другие запланированные файлы.
$linkProfile = Join-Path $testRoot 'linked-profile'
$linkParent = Join-Path $linkProfile '.codex/skills'
$linkTarget = Join-Path $testRoot 'link-target'
New-Item -ItemType Directory -Path $linkParent, $linkTarget -Force | Out-Null
$sentinel = Join-Path $linkTarget 'SKILL.md'
[IO.File]::WriteAllText($sentinel, 'Сохранять источник')
New-Item -ItemType Junction -Path (Join-Path $linkParent 'project-intake') -Target $linkTarget | Out-Null
$blocked = $false
try { & $installer -TargetProfile $linkProfile 6>$null } catch {
    if ($_.Exception.Message -notmatch 'junction') { throw }
    $blocked = $true
}
Assert $blocked 'Запись через junction не заблокирована'
Assert ([IO.File]::ReadAllText($sentinel) -ceq 'Сохранять источник') 'Изменён целевой каталог junction'
Assert (-not (Test-Path -LiteralPath (Join-Path $linkProfile '.codex/AGENTS.md'))) 'Предварительная проверка допустила частичную установку'

Write-Host "Все проверки пройдены. Тестовые файлы: $testRoot"
