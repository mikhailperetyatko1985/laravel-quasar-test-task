<?php

namespace App\Http\Requests\YandexParser;

use Illuminate\Foundation\Http\FormRequest;

class ParseFromUrlRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'url' => [
                'required',
                'string',
                'regex:/yandex\.ru\/maps\/org\/[^\/]+\/\d+/',
            ],
            'force_refresh' => ['sometimes', 'boolean'],
            'reviews_count' => ['sometimes', 'integer', 'min:1', 'max:100'],
        ];
    }

    public function messages(): array
    {
        return [
            'url.required' => __('yandex_parser.url_required'),
            'url.string' => __('yandex_parser.url_string'),
            'url.regex' => __('yandex_parser.url_regex'),
            'force_refresh.boolean' => __('yandex_parser.force_refresh_boolean'),
        ];
    }

    public function getUrl(): string
    {
        return $this->validated()['url'];
    }

    public function shouldForceRefresh(): bool
    {
        return (bool) ($this->validated()['force_refresh'] ?? false);
    }

    public function getReviewsCount(): ?int
    {
        return $this->validated()['reviews_count'] ?? null;
    }
}
