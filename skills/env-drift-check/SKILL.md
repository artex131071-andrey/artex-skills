---
name: "env-drift-check"
description: "Environment drift review. Use when setup, scripts, paths, environment variables, OS assumptions, containers, CI, or local tooling may have diverged and the project should be checked for Windows/Linux consistency."
---

# Env Drift Check

Используй этот skill, когда нужно проверить, не разъехались ли реальные требования проекта между разными окружениями и способами запуска.

## Когда применять

- проект запускается или разрабатывается и на Windows, и на Linux;
- менялись scripts, shell-команды, пути, Docker, CI или `.env`-переменные;
- были жалобы, что “у меня запускается, а у тебя нет”;
- менялись инструкции по локальному запуску, сборке, тестам или деплою.

## Workflow

1. Проверь точки запуска:
   scripts, make targets, package manager commands, Docker, compose, CI jobs.
2. Проверь окружение:
   `.env.example`, documented variables, required secrets, default values, platform assumptions.
3. Проверь платформенные риски:
   path separators, case sensitivity, shell-specific syntax, permissions, executable bits, line endings.
4. Сравни документацию с реальными командами и конфигами.
5. Если найдены расхождения, раздели их на blocking и non-blocking.

## Output

Возвращай:

- найденные расхождения окружения;
- какие из них критичны для запуска или разработки;
- что нужно поправить в конфиге, скриптах или документации;
- есть ли отдельно Windows/Linux-специфичные условия.

## Guardrails

- Не предполагай кроссплатформенность без проверки команд и путей.
- Не ограничивайся только `.env.example`, если реальный запуск зависит еще и от scripts или контейнеров.
- Если подтверждения для одной из платформ нет, явно укажи это.
