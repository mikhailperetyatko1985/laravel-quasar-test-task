<?php

namespace App\Enums\YandexParser;

enum ParseType: string
{
    case DEFAULT = 'default';   // Все данные (компания + отзывы)
    case COMPANY = 'company';   // Только информация о компании
    case REVIEWS = 'reviews';   // Только отзывы
}
