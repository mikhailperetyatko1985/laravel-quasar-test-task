<?php

declare(strict_types=1);

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

/**
 * Миграция для создания таблицы пользователей
 */
return new class extends Migration
{
    /**
     * Выполнить миграцию
     */
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->rememberToken();
            $table->timestamps();
            
            // Индексы для оптимизации поиска
            $table->index('email');
        });
    }

    /**
     * Откатить миграцию
     */
    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
