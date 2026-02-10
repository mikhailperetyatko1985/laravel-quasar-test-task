<?php

return [
    // Validation messages
    'url_required' => 'URL обязателен',
    'url_string' => 'URL должен быть строкой',
    'url_regex' => 'URL должен соответствовать формату Яндекс.Карт: yandex.ru/maps/org/название_компании/ID',
    'force_refresh_boolean' => 'Параметр force_refresh должен быть булевым значением',
    
    // URL parsing errors
    'invalid_url_format' => 'Не удалось извлечь ID компании из URL. URL должен соответствовать формату: yandex.ru/maps/org/название_компании/ID',
    'invalid_company_id' => 'Извлеченный ID компании не является положительным числом',
    
    // Cache messages
    'cache_cleared' => 'Кеш успешно очищен',
];
