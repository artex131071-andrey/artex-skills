---
name: "project-intake"
description: "Adaptive repository onboarding before noticeable work. Use when the agent needs to quickly restore the current project agreements, read the required docs, identify the affected zone, and summarize the current state before making changes. Works across docs-first repos, bootstrap repos, and monorepos by checking common fallback paths such as `AGENTS.md`, `README.md`, `commands/start.md` or `.commands/start.md`, `docs/README.md`, `docs/CONTRIBUTING.md` or `docs/CONTRIBUTION.md`, `docs/architecture.md` or `docs/ARCHITECTURE.md`, `docs/tasks/TASK.md` or `tasks/TASK.md`, `docs/CHANGELOG.md`, and relevant ADR or zone-specific docs."
---

# Project Intake

Собирай стартовый контекст перед заметной правкой и не переходи к изменениям, пока не восстановишь текущие договоренности проекта.

## Когда применять

- начинается новая заметная задача;
- агент входит в незнакомый или давно не открывавшийся репозиторий;
- затронута новая зона монорепозитория;
- перед реализацией нужно понять правила, документацию, локальные команды и ограничения проекта.

## Workflow

1. Сначала прочитай `AGENTS.md`, если файл существует.
2. Прочитай корневой `README.md`.
3. Найди и прочитай стартовый входной файл:
   `commands/start.md` или `.commands/start.md`, если он существует.
4. Затем по возможности прочитай документы в таком порядке:
   - `docs/README.md`
   - `docs/CONTRIBUTING.md` или `docs/CONTRIBUTION.md`
   - `docs/architecture.md` или `docs/ARCHITECTURE.md`
   - `docs/tasks/TASK.md` или `tasks/TASK.md`
   - `docs/CHANGELOG.md`
5. Если есть `docs/decisions/`, прочитай список ADR и открой только те решения, которые формируют текущий архитектурный курс для задачи.
6. Если репозиторий похож на монорепозиторий, сначала определи релевантную зону задачи и не читай весь репозиторий без необходимости.
7. Если задача связана с frontend, дизайном, UI или версткой, дополнительно проверь, есть ли design brief или аналогичные design docs.
8. Если проект использует служебные команды или локальные памятки, прочитай только те из них, которые реально связаны с текущей задачей.
9. Если документы противоречат друг другу, явно перечисли расхождения и укажи, какой документ сейчас выглядит источником истины.

## Output

Возвращай короткое резюме в 4 блоках:

- статус проекта или релевантной зоны;
- что уже зафиксировано;
- что еще открыто, спорно или рискованно;
- какие документы потребуется обновить при текущей задаче.

## Guardrails

- Не редактируй файлы, не запускай тесты и не предлагай коммит на этапе intake.
- Не читай весь монорепозиторий без необходимости.
- Для trivial-изменений не делай тяжелый intake: достаточно общих правил и ближайшей релевантной документации.
- Не подменяй реальные документы догадками о структуре проекта.
- Если обязательный файл по типовой структуре отсутствует, просто зафиксируй это как часть контекста, а не как ошибку сам по себе.
