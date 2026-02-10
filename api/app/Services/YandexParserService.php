<?php

namespace App\Services;

use App\DTO\YandexParser\YandexParserResponseDto;
use App\Enums\YandexParser\ParseType;
use App\Exceptions\YandexParser\YandexParserException;
use App\Repositories\YandexParserRepository;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;

class YandexParserService
{
    private YandexParserRepository $repository;
    private int $cacheTtl;
    private string $cachePrefix;

    public function __construct(YandexParserRepository $repository)
    {
        $this->repository = $repository;
        $this->cacheTtl = config('yandex_parser.cache_ttl');
        $this->cachePrefix = config('yandex_parser.cache_prefix');
    }

    /**
     * @param bool $forceRefresh Принудительно обновить кеш
     */
    public function getCompanyDataWithReviews(int $companyId, bool $forceRefresh = false, ?int $limit = 20): YandexParserResponseDto
    {
        $cacheKey = $this->buildCacheKey($companyId, ParseType::DEFAULT, $limit);

        if ($forceRefresh) {
            Log::info('Force refresh cache for Yandex Parser', ['company_id' => $companyId, 'limit' => $limit]);
            Cache::forget($cacheKey);
        }

        return Cache::remember(
            $cacheKey,
            $this->cacheTtl,
            function () use ($companyId, $limit) {
                Log::info('Cache miss - Requesting data from Yandex Parser', [
                    'company_id' => $companyId,
                    'type' => 'default',
                    'limit' => $limit
                ]);

                return $this->repository->parseAllData($companyId, $limit);
            }
        );
    }

    public function getCompanyInfo(int $companyId, bool $forceRefresh = false): YandexParserResponseDto
    {
        $cacheKey = $this->buildCacheKey($companyId, ParseType::COMPANY);

        if ($forceRefresh) {
            Cache::forget($cacheKey);
        }

        return Cache::remember(
            $cacheKey,
            $this->cacheTtl,
            function () use ($companyId) {
                Log::info('Cache miss - Requesting company info from Yandex Parser', [
                    'company_id' => $companyId
                ]);

                return $this->repository->parseCompanyInfo($companyId);
            }
        );
    }

    public function getCompanyReviews(int $companyId, bool $forceRefresh = false, ?int $limit = 20): YandexParserResponseDto
    {
        $cacheKey = $this->buildCacheKey($companyId, ParseType::REVIEWS, $limit);

        if ($forceRefresh) {
            Cache::forget($cacheKey);
        }

        return Cache::remember(
            $cacheKey,
            $this->cacheTtl,
            function () use ($companyId, $limit) {
                Log::info('Cache miss - Requesting reviews from Yandex Parser', [
                    'company_id' => $companyId,
                    'limit' => $limit
                ]);

                return $this->repository->parseReviews($companyId, $limit);
            }
        );
    }

    /**
     * @param ParseType|null $type Тип данных или null для всех
     */
    public function clearCache(int $companyId, ?ParseType $type = null): void
    {
        if ($type) {
            $cacheKey = $this->buildCacheKey($companyId, $type);
            Cache::forget($cacheKey);
            
            Log::info('Cache cleared for specific type', [
                'company_id' => $companyId,
                'type' => $type->value
            ]);

            return;
        }

        foreach (ParseType::cases() as $cacheType) {
            $cacheKey = $this->buildCacheKey($companyId, $cacheType);
            Cache::forget($cacheKey);
        }

        Log::info('All cache cleared for company', ['company_id' => $companyId]);
    }

    private function buildCacheKey(int $companyId, ParseType $type, ?int $limit = null): string
    {
        $key = "{$this->cachePrefix}:{$type->value}:{$companyId}";
        if ($limit !== null) {
            $key .= ":limit_{$limit}";
        }
        return $key;
    }
}
