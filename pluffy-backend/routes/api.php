<?php

use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PasswordResetController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\UserController;
use Illuminate\Support\Facades\Route;

Route::get('/products', [ProductController::class, 'index']);

Route::post('/register', [UserController::class, 'register'])
    ->middleware('throttle:10,1');
Route::post('/login', [UserController::class, 'login'])
    ->middleware('throttle:10,1');
Route::post('/forgot-password', [PasswordResetController::class, 'requestCode'])
    ->middleware('throttle:5,1');
Route::post('/reset-password', [PasswordResetController::class, 'reset'])
    ->middleware('throttle:5,1');

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/users/{id}', [UserController::class, 'show']);
    Route::put('/users/{id}', [UserController::class, 'update']);

    Route::get('/orders', [OrderController::class, 'index'])
        ->middleware('throttle:60,1');
    Route::post('/orders', [OrderController::class, 'store'])
        ->middleware('throttle:30,1');
});
