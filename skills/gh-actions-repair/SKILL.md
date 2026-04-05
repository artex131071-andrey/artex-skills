---
name: "gh-actions-repair"
description: "GitHub Actions failure diagnosis and repair loop through gh. Use when the user says GitHub Actions failed, CI is red, checks failed after push, or asks to inspect and fix workflow failures end-to-end. Diagnose the failing run, identify the exact broken job and step, apply a minimal fix, push when appropriate, and re-check the next run until green or an explicit blocker."
---

# GH Actions Repair

Используй этот skill, когда после `push` на GitHub падает workflow, CI, линтер, сборка или smoke-check, и нужно пройти путь от диагностики до повторной проверки статуса.

## Когда применять

- пользователь пишет, что в GitHub Actions есть ошибки;
- пользователь пишет, что на GitHub красный CI;
- после `push` упал workflow, линтер, build, test, migration smoke-check или другая проверка в GitHub;
- нужно разобрать failed run через `gh`, исправить причину и перепроверить новый run.

## Workflow

1. Сначала проверь локальное состояние репозитория, чтобы не смешать починку CI с несвязанными незакоммиченными изменениями.
2. Найди актуальные workflow и последние запуски через `gh`.
3. Выбери релевантный run для текущей ветки или последнего `push`.
4. Получи детали failing run, job и step через `gh run view`, включая логи упавшего шага.
5. Назови точную причину падения:
   workflow, job, step и текст ошибки.
6. По возможности воспроизведи проблему локально теми же или максимально близкими командами, что используются в workflow.
7. Исправляй минимальную реальную причину, а не симптом.
8. Если меняются workflow, команды, CI baseline, правила работы или документация по процессу, обнови релевантные документы.
9. Если пользователь просит именно починить GitHub Actions и нет отдельного запрета, доводи задачу до `commit` и `push`.
10. После `push` снова проверь статус нового run через `gh`.
11. Если новый run снова падает, повтори цикл, но не более 2-3 итераций за одну задачу. Потом явно покажи blocker.

## Output

Возвращай короткий результат в таком виде:

- какой workflow и какой run падал;
- какой job и step были проблемными;
- в чем реальная причина;
- что именно исправлено;
- был ли сделан `commit` и `push`;
- какой статус у последнего run после исправления.

## Guardrails

- Не коммить и не пушь несвязанные пользовательские изменения.
- Не чини вслепую: сначала найди failing step и текст ошибки.
- Не уходи в бесконечный цикл `push -> fail -> push -> fail`.
- Если проблема в secrets, правах GitHub, внешнем outage, недоступной VM или другом внешнем факторе, явно остановись и назови blocker.
- Если для починки нужно пересмотреть архитектурное решение, сначала подними точку согласования, а не меняй курс молча.
