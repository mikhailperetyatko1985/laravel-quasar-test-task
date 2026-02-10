<?php

declare(strict_types=1);

namespace App\Services;

use App\DTO\Auth\AuthResultDto;
use App\DTO\Auth\LoginDto;
use App\DTO\Auth\RegisterDto;
use App\DTO\User\UserDto;
use App\Exceptions\InvalidCredentialsException;
use App\Models\User;
use App\Repositories\UserRepository;
use Illuminate\Support\Facades\Auth;

class AuthService
{
    public function __construct(
        private readonly UserRepository $userRepository
    ) {
    }

    public function register(RegisterDto $dto): AuthResultDto
    {
        $user = $this->userRepository->create($dto);
        $token = $this->createTokenForUser($user);

        return new AuthResultDto(
            user: UserDto::fromModel($user),
            token: $token,
        );
    }

    public function login(LoginDto $dto): AuthResultDto
    {
        if (!Auth::attempt($dto->toArray())) {
            throw new InvalidCredentialsException();
        }

        $user = Auth::user();
        
        if ($user === null) {
            throw new InvalidCredentialsException();
        }

        $token = $this->createTokenForUser($user);

        return new AuthResultDto(
            user: UserDto::fromModel($user),
            token: $token,
        );
    }

    public function logout(?User $user): void
    {
        if ($user === null) {
            return;
        }

        $this->revokeCurrentToken($user);
    }

    private function createTokenForUser(User $user): string
    {
        return $user->createToken('auth_token')->plainTextToken;
    }

    private function revokeCurrentToken(User $user): void
    {
        $user->currentAccessToken()?->delete();
    }
}

