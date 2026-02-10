<?php

namespace App\Http\Controllers\YandexParser;

use App\Http\Controllers\Controller;
use App\Http\Requests\YandexParser\ParseFromUrlRequest;
use App\Services\YandexMapsUrlParserService;
use App\Services\YandexParserService;
use Illuminate\Http\JsonResponse;

class YandexParserController extends Controller
{
    public function __construct(
        private YandexParserService $yandexParserService,
        private YandexMapsUrlParserService $urlParserService
    ) {
    }

    public function parse(ParseFromUrlRequest $request): JsonResponse
    {
        $companyId = $this->urlParserService->extractCompanyId($request->getUrl());

        $result = $this->yandexParserService->getCompanyDataWithReviews(
            $companyId,
            $request->shouldForceRefresh(),
            $request->getReviewsCount()
        );

        return response()->json([
            'success' => true,
            'data' => $result->toArray(),
        ]);
    }
}
