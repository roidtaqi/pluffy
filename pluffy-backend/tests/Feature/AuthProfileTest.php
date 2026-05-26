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
        $registerResponse = $this->postJson('/api/register', [
            'name' => 'New Pluffy User',
            'email' => 'new@pluffy.cafe',
            'password' => 'secret123',
        ])
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.email', 'new@pluffy.cafe')
            ->assertJsonStructure(['token']);

        $registerToken = $registerResponse->json('token');

        $user = User::where('email', 'new@pluffy.cafe')->firstOrFail();

        $loginResponse = $this->postJson('/api/login', [
            'email' => 'new@pluffy.cafe',
            'password' => 'secret123',
        ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.id', $user->id)
            ->assertJsonStructure(['token']);

        $this->putJson("/api/users/{$user->id}", [
            'name' => 'Blocked Pluffy User',
            'email' => 'blocked@pluffy.cafe',
        ])->assertUnauthorized();

        $this->withHeader('Authorization', "Bearer {$registerToken}")
            ->putJson("/api/users/{$user->id}", [
                'name' => 'Updated Pluffy User',
                'email' => 'updated@pluffy.cafe',
                'password' => 'newpass123',
            ])
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.name', 'Updated Pluffy User')
            ->assertJsonPath('data.email', 'updated@pluffy.cafe');

        $this->withHeader('Authorization', 'Bearer '.$loginResponse->json('token'))
            ->putJson("/api/users/{$user->id}", [
                'name' => 'Updated Pluffy User Again',
                'email' => 'updated-again@pluffy.cafe',
            ])
            ->assertOk();

        $this->postJson('/api/login', [
            'email' => 'updated-again@pluffy.cafe',
            'password' => 'newpass123',
        ])
            ->assertOk()
            ->assertJsonPath('success', true);
    }

    public function test_authenticated_user_cannot_update_another_profile(): void
    {
        $owner = User::factory()->create([
            'password' => 'secret123',
        ]);
        $other = User::factory()->create([
            'name' => 'Updated Pluffy User',
            'email' => 'updated@pluffy.cafe',
        ]);

        $token = $owner->createToken('test-token')->plainTextToken;

        $this->withHeader('Authorization', "Bearer {$token}")
            ->putJson("/api/users/{$other->id}", [
                'name' => 'Wrong Update',
                'email' => 'wrong@pluffy.cafe',
            ])
            ->assertForbidden();
    }
}
