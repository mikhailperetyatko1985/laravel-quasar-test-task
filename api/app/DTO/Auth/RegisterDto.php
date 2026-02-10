<?php

declare(strict_types=1);

namespace App\DTO\Auth;

readonly class RegisterDto
{
    /**
     * @param string $name Имя пользователя
     * @param string $email Email пользователя
     * @param string $password Пароль пользователя
     */
    public function __construct(
        public string $name,
        public string $email,
        public string $password,
    ) {
    }

    public static function fromArray(array $data): self
    {
        return new self(
            name: $data['name'],
            email: $data['email'],
            password: $data['password'],
        );
    }

    public function toArray(): array
    {
        return [
            'name' => $this->name,
            'email' => $this->email,
            'password' => $this->password,
        ];
    }
}
