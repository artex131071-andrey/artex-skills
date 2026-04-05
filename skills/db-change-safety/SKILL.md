---
name: "db-change-safety"
description: "Database change safety review. Use when migrations, schema updates, SQL changes, seed updates, data backfills, indexes, constraints, or query behavior are modified and the change should be checked for compatibility, rollback, and data safety."
---

# DB Change Safety

Используй этот skill, когда изменения затрагивают базу данных, миграции или данные и их нужно проверить на безопасность до завершения задачи.

## Когда применять

- добавляются или меняются миграции;
- меняются схемы таблиц, индексы, ограничения, типы колонок;
- меняются SQL-запросы, влияющие на совместимость или производительность;
- есть backfill, data fix, seed update или ручная правка данных;
- меняется способ чтения или записи критичных данных.

## Workflow

1. Определи, что именно меняется:
   schema, data, indexes, constraints, queries, migration order.
2. Проверь совместимость:
   старый код с новой схемой, новый код со старой схемой, порядок выката.
3. Проверь rollback и recovery:
   можно ли откатить, что произойдет с уже измененными данными, есть ли необратимые шаги.
4. Проверь риски:
   data loss, locks, downtime, long-running migrations, reindexing, duplicate data, nullability issues.
5. Проверь, нужна ли дополнительная документация или runbook.

## Output

Возвращай:

- тип изменения БД;
- основные риски;
- совместимость и требования к порядку деплоя;
- есть ли безопасный rollback;
- что нужно обновить в документации или operational notes.

## Guardrails

- Не считай миграцию безопасной только потому, что она проходит локально.
- Не игнорируй необратимые изменения данных.
- Не забывай про порядок выката между приложением и БД.
- Если безопасность изменения не подтверждена, явно пометь это как блокер или точку согласования.
