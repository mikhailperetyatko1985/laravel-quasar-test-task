<?php

declare(strict_types=1);

namespace App\DTO\User;

use App\Models\User;

readonly class UserDto
{
    /**
     * @param int $id ID пользователя
     * @param string $name Имя пользователя
     * @param string $email Email пользователя
     * @param string|null $emailVerifiedAt Дата верификации email
     * @param string $createdAt Дата создания
     * @param string $updatedAt Дата обновления
     */
    public function __construct(
        public int $id,
        public string $name,
        public string $email,
        public ?string $emailVerifiedAt,
        public string $createdAt,
        public string $updatedAt,
    ) {
    }

    public static function fromModel(User $user): self
    {
        return new self(
            id: $user->id,
            name: $user->name,
            email: $user->email,
            emailVerifiedAt: $user->email_verified_at?->toIso8601String(),
            createdAt: $user->created_at->toIso8601String(),
            updatedAt: $user->updated_at->toIso8601String(),
        );
    }

    public static function fromArray(array $data): self
    {
        return new self(
            id: (int) $data['id'],
            name: $data['name'],
            email: $data['email'],
            emailVerifiedAt: $data['email_verified_at'] ?? null,
            createdAt: $data['created_at'],
            updatedAt: $data['updated_at'],
        );
    }

    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'email' => $this->email,
            'email_verified_at' => $this->emailVerifiedAt,
            'created_at' => $this->createdAt,
            'updated_at' => $this->updatedAt,
        ];
    }
}
