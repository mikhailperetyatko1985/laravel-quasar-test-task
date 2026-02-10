<?php

declare(strict_types=1);

namespace App\Http\Controllers\Auth;

use App\DTO\Auth\LoginDto;
use App\DTO\Auth\RegisterDto;
use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Http\Requests\Auth\RegisterRequest;
use App\Services\AuthService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    public function __construct(
        private readonly AuthService $authService
    ) {
    }

    public function register(RegisterRequest $request): JsonResponse
    {
        $dto = RegisterDto::fromArray($request->validated());
        $result = $this->authService->register($dto);
        
        return response()->json([
            'message' => __('auth.registered'),
            'user' => $result->user->toArray(),
            'token' => $result->token,
        ], Response::HTTP_CREATED);
    }

    public function login(LoginRequest $request): JsonResponse
    {
        $dto = LoginDto::fromArray($request->validated());
        $result = $this->authService->login($dto);

        return response()->json([
            'message' => __('auth.login_success'),
            'user' => $result->user->toArray(),
            'token' => $result->token,
        ], Response::HTTP_OK);
    }

    public function logout(Request $request): JsonResponse
    {
        $this->authService->logout($request->user());
        
        return response()->json([
            'message' => __('auth.logout_success'),
        ], Response::HTTP_OK);
    }

    public function user(Request $request): JsonResponse
    {
        return response()->json([
            'user' => $request->user(),
        ], Response::HTTP_OK);
    }
}

