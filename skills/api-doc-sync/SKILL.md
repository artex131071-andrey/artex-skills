---
name: "api-doc-sync"
description: "API documentation synchronization workflow. Use when endpoint behavior, schemas, payloads, authentication, query parameters, error responses, integrations, or transport contracts changed and API docs should be checked and updated."
---

# API Doc Sync

Используй этот skill, когда код API изменился и нужно привести документацию в соответствие с реальным контрактом.

## Когда применять

- добавлены или изменены endpoint-ы;
- изменились request/response payload-ы;
- изменились DTO, схемы, валидация или сериализация;
- изменились auth, permissions, rate limits или интеграции;
- изменились error codes, query params, headers или webhooks.

## Workflow

1. Найди канонический источник API-контракта:
   код, schema, OpenAPI, маршруты, DTO, validation layer.
2. Определи, какие части контракта изменились фактически.
3. Проверь связанные документы:
   `README`, OpenAPI, docs по endpoint-ам, integration docs, examples, Postman-like collections.
4. Обнови документацию так, чтобы она отражала поведение системы, а не намерение.
5. Если контракт изменился breaking-образом, отметь это явно.

## Output

Возвращай:

- какие API-части изменились;
- какие документы обновлены;
- есть ли breaking changes;
- какие клиенты или интеграции могут быть затронуты;
- что еще нужно синхронизировать, если работа не завершена.

## Guardrails

- Не описывай API по предположению, если контракт нельзя подтвердить кодом.
- Не скрывай breaking changes за нейтральной формулировкой.
- Не забывай про error responses и auth-flow.
- Если часть API не покрыта явной схемой, пометь ее как риск.
