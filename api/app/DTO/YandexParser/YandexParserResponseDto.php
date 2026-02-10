<?php

namespace App\DTO\YandexParser;

readonly class YandexParserResponseDto
{
    /**
     * @param ReviewDto[] $companyReviews
     */
    public function __construct(
        public ?CompanyInfoDto $companyInfo,
        public array $companyReviews,
        public int $reviewsCount
    ) {
    }

    public static function fromArray(array $data): self
    {
        $companyInfo = null;
        if (isset($data['company_info'])) {
            $companyInfo = CompanyInfoDto::fromArray($data['company_info']);
        }

        $reviews = [];
        if (isset($data['company_reviews']) && is_array($data['company_reviews'])) {
            foreach ($data['company_reviews'] as $reviewData) {
                $reviews[] = ReviewDto::fromArray($reviewData);
            }
        }

        return new self(
            companyInfo: $companyInfo,
            companyReviews: $reviews,
            reviewsCount: (int) ($data['reviews_count'] ?? count($reviews))
        );
    }

    public function toArray(): array
    {
        return [
            'company_info' => $this->companyInfo?->toArray(),
            'company_reviews' => array_map(static fn(ReviewDto $review) => $review->toArray(), $this->companyReviews),
            'reviews_count' => $this->reviewsCount,
        ];
    }
}
