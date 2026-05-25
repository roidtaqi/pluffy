<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProductController extends Controller
{
    public function index(): JsonResponse
    {
        $products = Product::where('is_active', true)->get();

        return response()->json([
            'success' => true,
            'message' => 'Products fetched successfully',
            'data' => $products,
        ]);
    }

    public function update(Request $request, $id): JsonResponse
    {
        $product = Product::find($id);

        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found',
            ], 404);
        }

        // Validate the incoming product update request
        $validated = $request->validate([
            'name' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'base_price' => 'sometimes|required|integer|min:0',
            'category' => 'sometimes|required|string',
            'image_url' => 'sometimes|nullable|string',
            'rating' => 'sometimes|nullable|numeric|min:0|max:5',
            'availability_status' => 'sometimes|required|string|in:available,sold_out,seasonal',
            'stock' => 'sometimes|required|integer|min:0',
            'is_best_seller' => 'sometimes|required|boolean',
            'is_seasonal' => 'sometimes|required|boolean',
            'is_active' => 'sometimes|required|boolean',
        ]);

        // Auto toggle availability_status if stock reaches 0 or goes back up
        if (isset($validated['stock'])) {
            if ($validated['stock'] == 0) {
                $validated['availability_status'] = 'sold_out';
            } else if ($validated['stock'] > 0 && (!isset($validated['availability_status']) || $validated['availability_status'] == 'sold_out')) {
                // Only reset to available if it was sold_out or not specified
                $currentStatus = $validated['availability_status'] ?? $product->availability_status;
                if ($currentStatus == 'sold_out') {
                    $validated['availability_status'] = 'available';
                }
            }
        }

        $product->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Product updated successfully',
            'data' => $product,
        ]);
    }
}
