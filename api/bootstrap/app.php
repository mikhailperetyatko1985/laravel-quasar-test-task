<?php

use App\Exceptions\InvalidCredentialsException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpKernel\Exception\HttpException;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {
        // Добавляем обработку CORS для всех запросов
        $middleware->use([
            \Illuminate\Http\Middleware\HandleCors::class,
        ]);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        // Обработка кастомного исключения InvalidCredentialsException
        $exceptions->render(function (InvalidCredentialsException $e) {
            Log::warning('Попытка входа с неверными учетными данными', [
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'message' => $e->getMessage(),
            ], $e->getCode() ?: 401);
        });

        // Централизованная обработка всех исключений с логированием
        $exceptions->render(function (\Throwable $e) {
            // Не обрабатываем HTTP исключения и ValidationException - они уже правильно форматируются Laravel
            if ($e instanceof HttpException || $e instanceof \Illuminate\Validation\ValidationException) {
                return null;
            }

            Log::error('Необработанное исключение в приложении', [
                'exception' => get_class($e),
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'message' => __('auth.server_error'),
                'error' => config('app.debug') ? $e->getMessage() : 'Internal Server Error',
            ], 500);
        });
    })->create();
