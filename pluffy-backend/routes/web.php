<?php

use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminOrderController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('backend-status');
});

Route::get('/admin/login', [AdminAuthController::class, 'showLogin'])
    ->name('admin.login');
Route::post('/admin/login', [AdminAuthController::class, 'login'])
    ->middleware('throttle:5,1')
    ->name('admin.login.submit');
Route::post('/admin/logout', [AdminAuthController::class, 'logout'])
    ->name('admin.logout');

Route::middleware('pluffy.admin')->group(function () {
    Route::get('/admin', [AdminOrderController::class, 'index'])
        ->name('admin.orders.index');

    Route::patch('/admin/orders/{order}/status', [AdminOrderController::class, 'updateStatus'])
        ->name('admin.orders.status');

    Route::patch('/admin/products/{product}', [AdminOrderController::class, 'updateProduct'])
        ->name('admin.products.update');
});
