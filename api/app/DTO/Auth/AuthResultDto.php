<?php

declare(strict_types=1);

namespace App\DTO\Auth;

use App\DTO\User\UserDto;

readonly class AuthResultDto
{
    /**
     * @param UserDto $user Данные пользователя
     * @param string $token Токен аутентификации
     */
    public function __construct(
        public UserDto $user,
        public string $token,
    ) {
    }

    public function toArray(): array
    {
        return [
            'user' => $this->user->toArray(),
            'token' => $this->token,
        ];
    }
}
