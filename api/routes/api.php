<?php

declare(strict_types=1);

use App\Http\Controllers\Auth\AuthController;
use App\Http\Controllers\YandexParser\YandexParserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Здесь регистрируются API маршруты для вашего приложения. Эти
| маршруты загружаются RouteServiceProvider в группе "api".
|
*/

// Публичные маршруты аутентификации
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register'])->name('auth.register');
    Route::post('/login', [AuthController::class, 'login'])->name('auth.login');
});

// Защищенные маршруты (требуют аутентификации)
Route::middleware('auth:sanctum')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout'])->name('auth.logout');
        Route::get('/user', [AuthController::class, 'user'])->name('auth.user');
    });
    
    // Маршрут для работы с Yandex Parser
    // Парсинг компании по URL из Яндекс.Карт
    Route::post('/yandex-parser/parse', [YandexParserController::class, 'parse'])
        ->name('yandex-parser.parse');
});
