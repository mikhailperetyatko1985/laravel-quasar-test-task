<?php

namespace App\DTO\YandexParser;

readonly class CompanyInfoDto
{
    public function __construct(
        public string $name,
        public float $rating,
        public int $countRating,
        public float $stars,
        public int $totalReviews
    ) {
    }

    public static function fromArray(array $data): self
    {
        return new self(
            name: $data['name'] ?? '',
            rating: (float) ($data['rating'] ?? 0),
            countRating: (int) ($data['count_rating'] ?? 0),
            stars: (float) ($data['stars'] ?? 0),
            totalReviews: (int) ($data['total_reviews'] ?? 0)
        );
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'rating' => $this->rating,
            'count_rating' => $this->countRating,
            'stars' => $this->stars,
            'total_reviews' => $this->totalReviews,
        ];
    }
}
