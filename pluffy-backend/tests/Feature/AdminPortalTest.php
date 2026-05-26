<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Product;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPortalTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();

        config()->set('pluffy_admin.email', 'admin@pluffy.cafe');
        config()->set('pluffy_admin.password', 'password123');
    }

    public function test_admin_portal_requires_login(): void
    {
        $this->get('/admin')
            ->assertRedirect('/admin/login');

        $this->post('/admin/login', [
            'email' => 'admin@pluffy.cafe',
            'password' => 'password123',
        ])->assertRedirect('/admin');
    }

    public function test_admin_portal_lists_orders_and_updates_status(): void
    {
        $user = User::create([
            'name' => 'Admin Test User',
            'email' => 'admin-test@pluffy.cafe',
            'password' => 'password123',
            'loyalty_points' => 0,
            'loyalty_stamps' => 0,
            'membership_tier' => 'Bronze Member',
        ]);

        $order = Order::create([
            'id' => 'ORD-TEST-1',
            'user_id' => $user->id,
            'subtotal' => 45000,
            'discount' => 0,
            'tax' => 4500,
            'service_fee' => 2000,
            'total' => 51500,
            'status' => 'placed',
            'outlet_name' => 'Pluffy - Juanda Street',
            'payment_method' => 'Pluffy Pay Wallet',
        ]);

        $this->withSession(['pluffy_admin_authenticated' => true])
            ->get('/admin')
            ->assertOk()
            ->assertSee('Pluffy Kitchen Board')
            ->assertSee('ORD-TEST-1');

        $this->withSession(['pluffy_admin_authenticated' => true])
            ->patch("/admin/orders/{$order->id}/status", [
                'status' => 'preparing',
            ])->assertRedirect('/admin');

        $this->assertSame('preparing', $order->fresh()->status);
    }

    public function test_admin_portal_lists_and_updates_products(): void
    {
        $product = Product::create([
            'name' => 'Test Souffle',
            'description' => 'Original description',
            'base_price' => 45000,
            'category' => 'Soufflé',
            'rating' => 4.5,
            'availability_status' => 'available',
            'stock' => 10,
            'is_best_seller' => false,
            'is_seasonal' => false,
            'is_active' => true,
        ]);

        $this->withSession(['pluffy_admin_authenticated' => true])
            ->get('/admin')
            ->assertOk()
            ->assertSee('Product Manager')
            ->assertSee('Test Souffle');

        $this->withSession(['pluffy_admin_authenticated' => true])
            ->patch("/admin/products/{$product->id}", [
                'name' => 'Updated Souffle',
                'description' => 'Updated description',
                'base_price' => 55000,
                'category' => 'Seasonal',
                'rating' => 4.9,
                'availability_status' => 'available',
                'stock' => 3,
                'is_best_seller' => '1',
                'is_active' => '1',
            ])->assertRedirect('/admin#products');

        $product->refresh();

        $this->assertSame('Updated Souffle', $product->name);
        $this->assertSame(55000, $product->base_price);
        $this->assertSame(3, $product->stock);
        $this->assertTrue((bool) $product->is_best_seller);
        $this->assertFalse((bool) $product->is_seasonal);
    }
}
