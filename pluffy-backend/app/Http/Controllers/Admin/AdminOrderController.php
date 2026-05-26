<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminOrderController extends Controller
{
    public function index(): View
    {
        $orders = Order::with(['items.product', 'user'])
            ->orderByDesc('created_at')
            ->get();
        $products = Product::orderBy('category')
            ->orderBy('name')
            ->get();

        $statusCounts = [
            'placed' => $orders->where('status', 'placed')->count(),
            'preparing' => $orders->where('status', 'preparing')->count(),
            'ready' => $orders->where('status', 'ready')->count(),
            'completed' => $orders->where('status', 'completed')->count(),
        ];
        $statuses = array_keys($statusCounts);

        return view('admin.orders', [
            'orders' => $orders,
            'ordersByStatus' => $orders->groupBy('status'),
            'statusCounts' => $statusCounts,
            'statuses' => $statuses,
            'products' => $products,
        ]);
    }

    public function updateStatus(Request $request, Order $order): RedirectResponse
    {
        $validated = $request->validate([
            'status' => 'required|string|in:placed,preparing,ready,completed',
        ]);

        $order->update([
            'status' => $validated['status'],
        ]);

        return redirect()
            ->route('admin.orders.index')
            ->with('success', "Order {$order->id} updated to {$validated['status']}.");
    }

    public function updateProduct(Request $request, Product $product): RedirectResponse
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'required|string',
            'base_price' => 'required|integer|min:0',
            'category' => 'required|string|max:255',
            'rating' => 'nullable|numeric|min:0|max:5',
            'availability_status' => 'required|string|in:available,sold_out,seasonal',
            'stock' => 'required|integer|min:0',
            'is_best_seller' => 'nullable|boolean',
            'is_seasonal' => 'nullable|boolean',
            'is_active' => 'nullable|boolean',
        ]);

        $validated['is_best_seller'] = $request->boolean('is_best_seller');
        $validated['is_seasonal'] = $request->boolean('is_seasonal');
        $validated['is_active'] = $request->boolean('is_active');

        if ($validated['stock'] === 0) {
            $validated['availability_status'] = 'sold_out';
        } elseif ($validated['availability_status'] === 'sold_out') {
            $validated['availability_status'] = 'available';
        }

        $product->update($validated);

        return redirect()
            ->to(route('admin.orders.index').'#products')
            ->with('success', "Product {$product->name} updated.");
    }
}
