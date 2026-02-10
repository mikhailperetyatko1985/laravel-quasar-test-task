<?php

namespace App\Repositories;

use App\DTO\YandexParser\YandexParserResponseDto;
use App\Enums\YandexParser\ParseType;
use App\Exceptions\YandexParser\YandexParserConnectionException;
use App\Exceptions\YandexParser\YandexParserException;
use App\Exceptions\YandexParser\YandexParserInvalidResponseException;
use GuzzleHttp\Client;
use GuzzleHttp\Exception\GuzzleException;
use Illuminate\Support\Facades\Log;

class YandexParserRepository
{
    private Client $client;
    private string $baseUri;

    public function __construct()
    {
        $this->baseUri = config('yandex_parser.url');

        $this->client = new Client([
            'base_uri' => $this->baseUri,
            'timeout' => config('yandex_parser.timeout'),
            'http_errors' => false,
        ]);
    }

    public function parseAllData(int $companyId, ?int $limit = 20): YandexParserResponseDto
    {
        return $this->parse($companyId, ParseType::DEFAULT, $limit);
    }

    public function parseCompanyInfo(int $companyId): YandexParserResponseDto
    {
        return $this->parse($companyId, ParseType::COMPANY, null);
    }

    public function parseReviews(int $companyId, ?int $limit = 20): YandexParserResponseDto
    {
        return $this->parse($companyId, ParseType::REVIEWS, $limit);
    }

    private function parse(int $companyId, ParseType $parseType, ?int $limit): YandexParserResponseDto
    {
        try {
            $requestData = [
                'company_id' => $companyId,
                'type_parse' => $parseType->value,
            ];

            if ($limit !== null) {
                $requestData['limit'] = $limit;
            }

            Log::info('Yandex Parser Request', [
                'company_id' => $companyId,
                'type_parse' => $parseType->value,
                'limit' => $limit,
                'url' => $this->baseUri . '/parse'
            ]);

            $response = $this->client->post('/parse', [
                'json' => $requestData,
            ]);

            $statusCode = $response->getStatusCode();
            $body = $response->getBody()->getContents();

            Log::info('Yandex Parser Response', [
                'status_code' => $statusCode,
                'body_length' => strlen($body)
            ]);

            if ($statusCode !== 200) {
                $errorData = json_decode($body, true);
                $errorMessage = $errorData['error'] ?? 'Unknown error from Yandex Parser';
                
                Log::error('Yandex Parser Error', [
                    'status_code' => $statusCode,
                    'error' => $errorMessage
                ]);

                throw new YandexParserException("Yandex Parser error: {$errorMessage}", $statusCode);
            }

            $data = json_decode($body, true);

            if (!$data || !isset($data['success'])) {
                throw new YandexParserInvalidResponseException('Invalid response format from Yandex Parser');
            }

            if (!$data['success']) {
                $errorMessage = $data['error'] ?? 'Unknown error';
                throw new YandexParserException("Yandex Parser returned error: {$errorMessage}");
            }

            if (!isset($data['data'])) {
                throw new YandexParserInvalidResponseException('Missing data field in Yandex Parser response');
            }

            return YandexParserResponseDto::fromArray($data['data']);

        } catch (GuzzleException $e) {
            Log::error('Guzzle Exception in Yandex Parser Repository', [
                'message' => $e->getMessage(),
                'company_id' => $companyId,
                'type_parse' => $parseType->value
            ]);

            throw new YandexParserConnectionException(
                'Failed to connect to Yandex Parser: ' . $e->getMessage(),
                0,
                $e
            );
        }
    }
}
