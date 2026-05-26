<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class OrderApiSecurityTest extends TestCase
{
    use RefreshDatabase;

    public function test_order_endpoints_require_authentication(): void
    {
        $this->getJson('/api/orders')->assertUnauthorized();
        $this->postJson('/api/orders', [])->assertUnauthorized();
        $this->postJson('/api/orders/update', [])->assertNotFound();
    }

    public function test_authenticated_user_can_place_and_list_only_own_orders(): void
    {
        $user = User::factory()->create();
        $otherUser = User::factory()->create();
        $product = Product::create([
            'name' => 'Cloud Souffle',
            'description' => 'Soft souffle',
            'base_price' => 45000,
            'category' => 'Soufflé',
            'rating' => 4.9,
            'availability_status' => 'available',
            'stock' => 10,
            'is_best_seller' => true,
            'is_seasonal' => false,
            'is_active' => true,
        ]);

        Order::create([
            'id' => 'ORD-OTHER-1',
            'user_id' => $otherUser->id,
            'subtotal' => 45000,
            'discount' => 0,
            'tax' => 4500,
            'service_fee' => 2000,
            'total' => 51500,
            'status' => 'placed',
            'outlet_name' => 'Pluffy - Juanda Street',
            'payment_method' => 'Pluffy Pay',
        ]);

        $token = $user->createToken('test-token')->plainTextToken;

        $orderResponse = $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/orders', [
                'outlet_name' => 'Pluffy - Juanda Street',
                'payment_method' => 'Pluffy Pay',
                'subtotal' => 45000,
                'discount' => 0,
                'tax' => 4500,
                'service_fee' => 2000,
                'total' => 51500,
                'items' => [
                    [
                        'product_id' => $product->id,
                        'quantity' => 1,
                        'price' => 45000,
                    ],
                ],
            ])
            ->assertOk()
            ->assertJsonPath('success', true);

        $orderId = $orderResponse->json('data.order_id');

        $this->withHeader('Authorization', "Bearer {$token}")
            ->getJson('/api/orders')
            ->assertOk()
            ->assertJsonFragment(['id' => $orderId])
            ->assertJsonMissing(['id' => 'ORD-OTHER-1']);
    }

    public function test_public_api_does_not_expose_order_status_or_product_update_mutations(): void
    {
        $user = User::factory()->create();
        $token = $user->createToken('test-token')->plainTextToken;

        $this->withHeader('Authorization', "Bearer {$token}")
            ->postJson('/api/orders/update', [
                'id' => 'ORD-OTHER-2',
                'status' => 'preparing',
            ])
            ->assertNotFound();

        $this->withHeader('Authorization', "Bearer {$token}")
            ->putJson('/api/products/1', [
                'stock' => 0,
            ])
            ->assertNotFound();
    }
}
