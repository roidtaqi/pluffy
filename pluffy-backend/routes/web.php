<?php

use App\Http\Controllers\Admin\AdminOrderController;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/admin', [AdminOrderController::class, 'index'])
    ->name('admin.orders.index');

Route::patch('/admin/orders/{order}/status', [AdminOrderController::class, 'updateStatus'])
    ->name('admin.orders.status');

Route::patch('/admin/products/{product}', [AdminOrderController::class, 'updateProduct'])
    ->name('admin.products.update');
