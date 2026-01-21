# 🎭 Playwright MCP - Шпаргалка

## 🚨 ВАЖНО: Используй Playwright, НЕ скриншоты!

---

## ⚡ Быстрые команды

### Навигация
```
browser_navigate("http://localhost:3000")
browser_navigate_back()
```

### Получить структуру страницы (ВМЕСТО скриншота!)
```
browser_snapshot()
```

### Взаимодействие
```
browser_click({ element: "Login button", ref: "abc123" })
browser_type({ element: "Email input", ref: "xyz789", text: "test@test.com" })
browser_fill_form([...])
browser_press_key({ key: "Enter" })
```

### Проверка
```
browser_console_messages({ onlyErrors: true })
browser_network_requests()
browser_verify_element_visible({ role: "button", accessibleName: "Login" })
browser_verify_text_visible({ text: "Welcome" })
```

### Дополнительно
```
browser_tabs({ action: "list" })
browser_take_screenshot({ filename: "page.png" })
browser_evaluate({ function: "() => document.title" })
```

---

## 🎯 Типичные сценарии

### 1. Открыть и посмотреть страницу
```javascript
await browser_navigate("http://localhost:3000")
await browser_snapshot() // НЕ screenshot!
```

### 2. Заполнить форму
```javascript
await browser_snapshot() // Получить refs
await browser_fill_form([
  { name: "email", ref: "email-ref", type: "textbox", value: "test@test.com" },
  { name: "password", ref: "pwd-ref", type: "textbox", value: "Pass123!" }
])
await browser_click({ element: "Submit", ref: "submit-ref" })
```

### 3. Проверить результат
```javascript
await browser_verify_text_visible({ text: "Success" })
await browser_console_messages({ onlyErrors: true })
await browser_network_requests()
```

---

## ✅ DO (Делай)

- ✅ Используй `browser_snapshot` для получения структуры
- ✅ Используй refs из snapshot для кликов
- ✅ Проверяй консоль после действий
- ✅ Проверяй сетевые запросы
- ✅ Тестируй реальное приложение

## ❌ DON'T (Не делай)

- ❌ НЕ используй скриншоты для автоматизации
- ❌ НЕ угадывай селекторы
- ❌ НЕ пропускай проверку после изменений
- ❌ НЕ забывай проверять консоль

---

## 🔄 Стандартный workflow

```
1. Navigate  → browser_navigate()
2. Snapshot  → browser_snapshot()
3. Interact  → browser_click/type/fill_form()
4. Verify    → browser_verify_*()
5. Check     → browser_console_messages()
```

---

## 🎬 Примеры на русском

```
"Открой localhost:3000 и покажи структуру"
"Заполни форму логина с email test@test.com"
"Кликни на кнопку Register"
"Проверь консоль на ошибки"
"Протестируй форму регистрации"
"Проверь, что после логина появляется приветствие"
```

---

## 🔧 Конфигурация

- **Браузер**: Chrome
- **Capabilities**: vision, pdf, tabs
- **Trace**: Включен
- **Video**: 1280x720
- **Локация**: `C:\Users\kulivers\.cursor\mcp.json`

---

## 🆘 Troubleshooting

| Проблема | Решение |
|----------|---------|
| "Cannot connect to browser" | Перезапусти Cursor |
| "Page not found" | Проверь, что `npm start` запущен |
| "Element not found" | Сделай `browser_snapshot()` снова |
| "Timeout" | Увеличь timeout или проверь сеть |

---

## 📖 Документация

- [Полное руководство](../PLAYWRIGHT_MCP_GUIDE.md)
- [Быстрый старт](../PLAYWRIGHT_QUICK_START.md)
- [Правила для AI](./rules/playwright-mcp.mdc)

---

**🎉 Готово к использованию! Просто пиши команды на русском!**

