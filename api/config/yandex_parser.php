<?php

return [
    /*
    |--------------------------------------------------------------------------
    | Yandex Parser Service Configuration
    |--------------------------------------------------------------------------
    |
    | Настройки для подключения к микросервису yandex-parser
    |
    */

    // URL микросервиса yandex-parser
    'url' => env('YANDEX_PARSER_URL', 'http://yandex-parser:5000'),

    // Timeout для HTTP запросов в секундах (парсинг занимает ~2-3 минуты)
    'timeout' => (int) env('YANDEX_PARSER_TIMEOUT', 300),

    // TTL кеша в секундах (по умолчанию 1 час = 3600 секунд)
    'cache_ttl' => (int) env('YANDEX_PARSER_CACHE_TTL', 3600),

    // Префикс для ключей кеша
    'cache_prefix' => 'yandex_parser',
];
