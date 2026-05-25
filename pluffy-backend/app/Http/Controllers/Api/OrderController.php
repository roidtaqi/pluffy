<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Product;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class OrderController extends Controller
{
    /**
     * Display a listing of the orders.
     */
    public function index(): JsonResponse
    {
        $orders = Order::with('items.product')->orderBy('created_at', 'desc')->get();

        $mappedOrders = $orders->map(function ($order) {
            return [
                'id' => $order->id,
                'orderDate' => $order->created_at->toIso8601String(),
                'outletName' => $order->outlet_name,
                'total' => (float) $order->total,
                'status' => $order->status,
                'items' => $order->items->map(function ($item) {
                    return [
                        'productName' => $item->product ? $item->product->name : 'Unknown Product',
                        'quantity' => (int) $item->quantity,
                        'price' => (float) $item->unit_price,
                    ];
                })->toArray(),
            ];
        });

        return response()->json([
            'orders' => $mappedOrders,
        ]);
    }

    /**
     * Store a newly created order in storage.
     */
    public function store(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'subtotal' => 'required|integer',
            'discount' => 'required|integer',
            'tax' => 'required|integer',
            'service_fee' => 'required|integer',
            'total' => 'required|integer',
            'outlet_name' => 'required|string',
            'payment_method' => 'required|string',
            'voucher_code' => 'nullable|string',
            'user_id' => 'required|integer|exists:users,id',
            'items' => 'required|array|min:1',
            'items.*.product_id' => 'required|integer',
            'items.*.quantity' => 'required|integer|min:1',
            'items.*.price' => 'required|integer',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 400);
        }

        $userId = $request->input('user_id');

        try {
            $order = DB::transaction(function () use ($request, $userId) {
                // 1. Generate unique ORD-XXXX ID using timestamp
                $rand = rand(1000, 9999);
                $time = round(microtime(true) * 1000) % 1000;
                $orderId = "ORD-{$rand}-{$time}";

                // 2. Create Order
                $order = Order::create([
                    'id' => $orderId,
                    'user_id' => $userId,
                    'subtotal' => $request->input('subtotal'),
                    'discount' => $request->input('discount'),
                    'tax' => $request->input('tax'),
                    'service_fee' => $request->input('service_fee'),
                    'total' => $request->input('total'),
                    'status' => 'placed',
                    'outlet_name' => $request->input('outlet_name'),
                    'payment_method' => $request->input('payment_method'),
                    'voucher_code' => $request->input('voucher_code'),
                ]);

                $totalItemsQty = 0;

                // 3. Save Items & Deduct Stock
                foreach ($request->input('items') as $itemData) {
                    $productId = $itemData['product_id'];
                    $qty = $itemData['quantity'];
                    $unitPrice = $itemData['price'];

                    $totalItemsQty += $qty;

                    // Save item
                    OrderItem::create([
                        'order_id' => $orderId,
                        'product_id' => $productId,
                        'quantity' => $qty,
                        'unit_price' => $unitPrice,
                    ]);

                    // Deduct stock in database
                    $product = Product::lockForUpdate()->find($productId);
                    if ($product) {
                        $product->stock = max(0, $product->stock - $qty);
                        if ($product->stock == 0) {
                            $product->availability_status = 'sold_out';
                        }
                        $product->save();
                    }
                }

                // 4. Update Loyalty points & stamps
                $user = User::lockForUpdate()->find($userId);
                if ($user) {
                    // Generous loyal points: spent total / 100
                    $pointsEarned = (int) ($request->input('total') / 100);
                    $user->loyalty_points += $pointsEarned;

                    // Stamps: 1 stamp per quantity item ordered, reset/cycle at 10
                    $newStamps = $user->loyalty_stamps + $totalItemsQty;
                    $user->loyalty_stamps = $newStamps % 10;

                    // Update Tier level based on cumulative points
                    if ($user->loyalty_points >= 1000) {
                        $user->membership_tier = 'Gold Member';
                    } elseif ($user->loyalty_points >= 500) {
                        $user->membership_tier = 'Silver Member';
                    } else {
                        $user->membership_tier = 'Bronze Member';
                    }

                    $user->save();
                }

                return $order;
            });

            // Retrieve newly updated user details
            $updatedUser = User::find($userId);

            return response()->json([
                'success' => true,
                'message' => 'Order placed successfully',
                'data' => [
                    'order_id' => $order->id,
                    'total' => (float) $order->total,
                    'status' => $order->status,
                    'user' => [
                        'loyalty_points' => $updatedUser->loyalty_points,
                        'loyalty_stamps' => $updatedUser->loyalty_stamps,
                        'membership_tier' => $updatedUser->membership_tier,
                    ],
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to place order: '.$e->getMessage(),
            ], 500);
        }
    }

    /**
     * Update order status (used by Admin Web Console).
     */
    public function updateStatus(Request $request): JsonResponse
    {
        $validator = Validator::make($request->all(), [
            'id' => 'required|string',
            'status' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $validator->errors(),
            ], 400);
        }

        $orderId = $request->input('id');
        $status = $request->input('status');

        $order = Order::find($orderId);
        if (! $order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
            ], 404);
        }

        $order->status = $status;
        $order->save();

        return response()->json([
            'success' => true,
            'message' => 'Order status updated successfully',
        ]);
    }
}
