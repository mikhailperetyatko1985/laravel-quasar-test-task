<?php

namespace App\DTO\YandexParser;

readonly class ReviewDto
{
    public function __construct(
        public string $name,
        public ?string $iconHref,
        public ?string $userLink,
        public float $date,
        public string $text,
        public float $stars,
        public ?string $answer
    ) {
    }

    public static function fromArray(array $data): self
    {
        return new self(
            name: $data['name'] ?? '',
            iconHref: $data['icon_href'] ?? null,
            userLink: $data['user_link'] ?? null,
            date: (float) ($data['date'] ?? 0),
            text: $data['text'] ?? '',
            stars: (float) ($data['stars'] ?? 0),
            answer: $data['answer'] ?? null
        );
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'icon_href' => $this->iconHref,
            'user_link' => $this->userLink,
            'date' => $this->date,
            'text' => $this->text,
            'stars' => $this->stars,
            'answer' => $this->answer,
        ];
    }
}
