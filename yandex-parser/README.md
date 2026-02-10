# Yandex Reviews Parser API

HTTP API сервис для парсинга отзывов с Yandex Карт.

## Endpoint

### POST /parse

Парсинг отзывов через Selenium + Chrome для получения полной информации о компании и её отзывах.

**URL:** `http://yandex-parser:5000/parse` (внутри Docker сети)

**Параметры запроса:**

```json
{
  "company_id": 1010501395,
  "type_parse": "default",
  "limit": 100
}
```

- `company_id` (required, integer) - ID компании из Яндекс.Карт
- `type_parse` (optional, string) - Тип возвращаемых данных:
  - `"default"` - все данные (company_info + company_reviews) - по умолчанию
  - `"company"` - только информация о компании
  - `"reviews"` - только отзывы
- `limit` (optional, integer) - Максимальное количество отзывов для парсинга:
  - Если не указан - парсятся все отзывы (без ограничений)
  - Если указан - парсится не более указанного количества отзывов
  - Должен быть положительным числом

**Ответ (success):**

```json
{
  "success": true,
  "data": {
    "company_info": {
      "name": "Название компании",
      "rating": 4.7,
      "count_rating": 2288,
      "stars": 0
    },
    "company_reviews": [
      {
        "name": "Светлана Нестерова",
        "icon_href": "https://avatars.mds.yandex.net/...",
        "user_link": "https://yandex.ru/maps/user/...",
        "date": 1681992580.04,
        "text": "Текст отзыва",
        "stars": 5.0,
        "answer": "Ответ компании" или null
      }
    ]
  }
}
```

**Ответ (error):**

```json
{
  "success": false,
  "error": "Описание ошибки"
}
```

## Примеры использования

### Из контейнера api (Laravel):

```bash
# Войти в контейнер
docker-compose exec api bash

# Все данные (все отзывы)
curl -X POST http://yandex-parser:5000/parse \
  -H "Content-Type: application/json" \
  -d '{"company_id": 1010501395, "type_parse": "default"}'

# С лимитом на 100 отзывов (для быстрого парсинга)
curl -X POST http://yandex-parser:5000/parse \
  -H "Content-Type: application/json" \
  -d '{"company_id": 1010501395, "type_parse": "default", "limit": 100}'

# Только информация о компании
curl -X POST http://yandex-parser:5000/parse \
  -H "Content-Type: application/json" \
  -d '{"company_id": 1010501395, "type_parse": "company"}'

# Только отзывы (первые 50)
curl -X POST http://yandex-parser:5000/parse \
  -H "Content-Type: application/json" \
  -d '{"company_id": 1010501395, "type_parse": "reviews", "limit": 50}'
```

### Из PHP (Guzzle):

```php
<?php

use GuzzleHttp\Client;

$client = new Client([
    'base_uri' => 'http://yandex-parser:5000',
    'timeout' => 1800, // Увеличено до 30 минут для больших объемов
]);

try {
    $response = $client->post('/parse', [
        'json' => [
            'company_id' => 1010501395,
            'type_parse' => 'default',
            'limit' => 100  // Опционально: ограничить количество отзывов
        ]
    ]);

    $result = json_decode($response->getBody(), true);

    if ($result['success']) {
        $data = $result['data'];
        
        // Информация о компании
        $companyName = $data['company_info']['name'];
        $rating = $data['company_info']['rating'];
        
        // Отзывы
        $reviews = $data['company_reviews'];
        foreach ($reviews as $review) {
            $author = $review['name'];
            $text = $review['text'];
            $answer = $review['answer'] ?? null;
        }
    }
} catch (\Exception $e) {
    error_log("Ошибка парсинга: " . $e->getMessage());
}
```

## Как получить company_id

1. Откройте страницу компании на [Яндекс.Картах](https://yandex.ru/maps/)
2. В URL найдите числовой ID: `https://yandex.ru/maps/org/название/1234567890/`
3. Числовое значение `1234567890` - это `company_id`

## Важные замечания

⚠️ **Время выполнения:**
- С лимитом (100 отзывов): ~30-60 секунд
- Без лимита (все отзывы): ~2-10 минут в зависимости от количества

⚠️ **Кеширование:** НЕТ. Каждый HTTP запрос = новый полный парсинг

⚠️ **Лимитирование отзывов:**
- Используйте параметр `limit` для ограничения количества отзывов
- Без `limit` - парсятся все отзывы (может быть 600+ отзывов)
- Рекомендуется: `limit: 100` для тестирования и быстрого парсинга

⚠️ **Timeout:**
- Для запросов с лимитом: минимум 120 секунд
- Для запросов без лимита: минимум 1800 секунд (30 минут)

## Запуск

```bash
# Пересобрать контейнер
docker-compose build yandex-parser

# Запустить
docker-compose up -d yandex-parser

# Просмотр логов
docker-compose logs -f yandex-parser
```

## Health Check

```bash
curl http://yandex-parser:5000/health
```

Ответ:
```json
{
  "status": "ok",
  "service": "yandex-reviews-parser"
}
```
