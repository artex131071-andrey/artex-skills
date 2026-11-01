# artex-skills

Общие правила и 11 рабочих навыков Андрея для Codex и Claude. Репозиторий позволяет перенести одинаковые инструкции между компьютерами Windows: клонировать, выполнить установку и повторять её после обновлений Git.

## Установка на Windows

Нужны Git, Windows PowerShell 5.1 или PowerShell 7, установленные Codex и Claude. Доступ к GitHub по SSH настраивается отдельно.

```powershell
git clone git@github.com:artex131071-andrey/artex-skills.git
cd artex-skills
.\install-windows.ps1 -WhatIf
.\install-windows.ps1
```

Если политика Windows блокирует запуск скачанного скрипта, после просмотра файла можно разрешить его только для текущего процесса:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install-windows.ps1
```

Установка создаёт физические копии:

- Codex: `%USERPROFILE%\.codex\AGENTS.md` и `%USERPROFILE%\.codex\skills\<имя>\`.
- Claude: `%USERPROFILE%\.claude\CLAUDE.md` и `%USERPROFILE%\.claude\commands\<имя>.md`.

В глобальный файл Claude включаются полный текст трёх базовых процессов и общий языковой стандарт. Остальные процессы доступны отдельными командами. Существующие изменяемые файлы предварительно сохраняются в `%USERPROFILE%\.artex-skills-backups\<дата-время>\`. Нужные локальные дополнения следует вручную объединить с шаблонами перед установкой; установщик заменяет управляемые файлы целиком.

Полное руководство, восстановление резервных копий, ограничения и инструкция для разработчика: [docs/WINDOWS.md](docs/WINDOWS.md).

## Обновление на другом компьютере

```powershell
cd <путь-к-artex-skills>
git pull --ff-only
.\install-windows.ps1 -WhatIf
.\install-windows.ps1
```

Затем перезапустите Codex и Claude. Сам `git pull` не обновляет установленные физические копии. Чтобы изменения появились на другом ПК, их сначала нужно закоммитить и отправить в GitHub на исходном ПК.

## Навыки

| Навык | Назначение |
|---|---|
| `project-intake` | Изучение правил, документов и контекста перед заметной работой. |
| `plan-and-wait` | Показ понимания/плана и ожидание команды, когда пользователь просит паузу. |
| `docs-closeout` | Проверка документации при завершении задачи. |
| `context7-check` | Проверка документации, стабильности и совместимости зависимостей. |
| `review-code` | Ревью ошибок, регрессий, рисков и пробелов проверки. |
| `readme-refresh` | Синхронизация README с реальным состоянием проекта. |
| `api-doc-sync` | Обновление API-документации. |
| `cleanup-pass` | Локальная уборка кода без расширения задачи. |
| `env-drift-check` | Проверка различий окружений и Windows/Linux. |
| `db-change-safety` | Безопасность изменений схемы и данных. |
| `gh-actions-repair` | Диагностика и исправление GitHub Actions. |

## Структура и правила сопровождения

```text
skills/<имя>/SKILL.md         Канонические правила навыка
skills/<имя>/meta.yaml        Метаданные
instructions/codex/AGENTS.md  Общие инструкции Codex
instructions/claude/CLAUDE.md Общие инструкции Claude
AGENTS.md, CLAUDE.md          Инструкции для работы с этим репозиторием
docs/WINDOWS.md              Инструкция переноса и сопровождения
install-windows.ps1           Установка Codex/Claude на Windows
sync-skills.ps1               Прежний сценарий Copilot/Claude
```

Общение и документация — на русском языке. Проектные AGENTS.md/CLAUDE.md других репозиториев остаются вместе с их кодом. Не переносим секреты, историю, конфиги авторизации, локальные runtime-пути и разрешения команд. Сторонние и системные плагины устанавливаются отдельно.

Старые сценарии Gemini/Copilot и Linux не удалены, но новый установщик их не обслуживает. `sync-skills.ps1` не является заменой установки Codex и не устанавливает глобальный CLAUDE.md.
