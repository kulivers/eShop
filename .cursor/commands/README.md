# Commands Structure

Эта папка содержит команды (commands) для Cursor, организованные по категориям для удобного использования в различных типах проектов.

## Структура категорий

### General
- `general/` - Общие команды, применимые к любому проекту
  - code-review.md - Проверка кода
  - create-pr.md - Создание Pull Request
  - create-prompt.md - Создание промпта
  - debug-issue.md - Отладка проблем
  - fix-compile-errors.md - Исправление ошибок компиляции
  - onboard-new-developer.md - Онбординг нового разработчика
  - setup-new-feature.md - Настройка новой функции
  - optimize-performance.md - Оптимизация производительности
  - refactor-code.md - Рефакторинг кода

### Backend
- `backend/` - Команды для backend разработки
  - database-migration.md - Миграции базы данных
  - add-error-handling.md - Добавление обработки ошибок

### Frontend
- `frontend/` - Команды для frontend разработки
  - accessibility-audit.md - Аудит доступности

### DevOps
- `devops/` - Команды для DevOps задач

### Testing
- `testing/` - Команды для тестирования
  - run-all-tests-and-fix.md - Запуск всех тестов и исправление
  - write-unit-tests.md - Написание unit тестов

### Security
- `security/` - Команды для безопасности
  - security-audit.md - Аудит безопасности
  - security-review.md - Обзор безопасности

### Documentation
- `documentation/` - Команды для документации
  - add-documentation.md - Добавление документации
  - generate-api-docs.md - Генерация API документации

### Git
- `git/` - Команды для работы с Git
  - fix-git-issues.md - Исправление проблем Git
  - address-github-pr-comments.md - Обработка комментариев PR
  - generate-pr-description.md - Генерация описания PR
  - light-review-existing-diffs.md - Легкий обзор существующих изменений

### Code Quality
- `code-quality/` - Команды для качества кода
  - lint-fix.md - Исправление линтинга
  - lint-suite.md - Набор линтинга
  - import_rule.md - Импорт правил

## Использование

Для добавления команд в проект:

1. **Backend проект**: Используйте команды из `backend/`, `general/`, `testing/`, `security/`, `documentation/`, `git/`, `code-quality/`

2. **Frontend проект**: Используйте команды из `frontend/`, `general/`, `testing/`, `security/`, `documentation/`, `git/`, `code-quality/`

3. **Full-stack проект**: Комбинируйте команды из соответствующих категорий

## Пример структуры для проекта

```
.cursor/
  commands/
    general/
      code-review.md
      refactor-code.md
    backend/
      database-migration.md
    testing/
      write-unit-tests.md
    git/
      create-pr.md
```

