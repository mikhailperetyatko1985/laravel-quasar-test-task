<?php

namespace App\Http\Requests\YandexParser;

use Illuminate\Foundation\Http\FormRequest;

class ParseCompanyRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // Можно добавить проверку прав доступа если нужно
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'company_id' => ['required', 'integer', 'min:1'],
            'force_refresh' => ['sometimes', 'boolean'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     *
     * @return array
     */
    public function messages(): array
    {
        return [
            'company_id.required' => 'ID компании обязателен',
            'company_id.integer' => 'ID компании должен быть числом',
            'company_id.min' => 'ID компании должен быть положительным числом',
            'force_refresh.boolean' => 'Параметр force_refresh должен быть булевым значением',
        ];
    }

    /**
     * Get the company ID from the validated data.
     *
     * @return int
     */
    public function getCompanyId(): int
    {
        return (int) $this->validated()['company_id'];
    }

    /**
     * Check if cache should be forcefully refreshed.
     *
     * @return bool
     */
    public function shouldForceRefresh(): bool
    {
        return (bool) ($this->validated()['force_refresh'] ?? false);
    }
}
