<?php

namespace App\Services;

use App\Exceptions\YandexParser\InvalidYandexMapsUrlException;

class YandexMapsUrlParserService
{
    public function extractCompanyId(string $url): int
    {
        // /org/название/[ЧИСЛОВОЙ_ID]
        $pattern = '/yandex\.ru\/maps\/org\/[^\/]+\/(\d+)/';

        if (!preg_match($pattern, $url, $matches)) {
            throw new InvalidYandexMapsUrlException(__('yandex_parser.invalid_url_format'));
        }

        $companyId = (int) $matches[1];

        if ($companyId <= 0) {
            throw new InvalidYandexMapsUrlException(__('yandex_parser.invalid_company_id'));
        }

        return $companyId;
    }
}
