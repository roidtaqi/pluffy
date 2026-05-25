<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AdminPortalTest extends TestCase
{
    use RefreshDatabase;

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

        $this->get('/admin')
            ->assertOk()
            ->assertSee('Pluffy Kitchen Board')
            ->assertSee('ORD-TEST-1');

        $this->patch("/admin/orders/{$order->id}/status", [
            'status' => 'preparing',
        ])->assertRedirect('/admin');

        $this->assertSame('preparing', $order->fresh()->status);
    }
}
