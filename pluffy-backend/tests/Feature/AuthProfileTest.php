<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthProfileTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_login_and_update_profile(): void
    {
        $this->postJson('/api/register', [
            'name' => 'New Pluffy User',
            'email' => 'new@pluffy.cafe',
            'password' => 'secret123',
        ])
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.email', 'new@pluffy.cafe');

        $user = User::where('email', 'new@pluffy.cafe')->firstOrFail();

        $this->postJson('/api/login', [
            'email' => 'new@pluffy.cafe',
            'password' => 'secret123',
        ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id', $user->id);

        $this->putJson("/api/users/{$user->id}", [
            'name' => 'Updated Pluffy User',
            'email' => 'updated@pluffy.cafe',
            'password' => 'newpass123',
        ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.name', 'Updated Pluffy User')
            ->assertJsonPath('data.email', 'updated@pluffy.cafe');

        $this->postJson('/api/login', [
            'email' => 'updated@pluffy.cafe',
            'password' => 'newpass123',
        ])
            ->assertOk()
            ->assertJsonPath('success', true);
    }
}
