<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
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
}
