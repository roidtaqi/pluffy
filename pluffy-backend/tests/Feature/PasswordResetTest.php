<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Tests\TestCase;

class PasswordResetTest extends TestCase
{
    use RefreshDatabase;

    public function test_registered_user_can_request_a_reset_code_without_storing_plaintext(): void
    {
        Mail::fake();

        User::factory()->create([
            'email' => 'customer@pluffy.cafe',
        ]);

        $this->postJson('/api/forgot-password', [
            'email' => 'Customer@Pluffy.Cafe',
        ])
            ->assertOk()
            ->assertJsonPath('success', true);

        $resetToken = DB::table('password_reset_tokens')
            ->where('email', 'customer@pluffy.cafe')
            ->first();

        $this->assertNotNull($resetToken);
        $this->assertNotSame('123456', $resetToken->token);
    }

    public function test_request_does_not_reveal_that_an_email_is_not_registered(): void
    {
        Mail::fake();

        $this->postJson('/api/forgot-password', [
            'email' => 'unknown@pluffy.cafe',
        ])
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertDatabaseMissing('password_reset_tokens', [
            'email' => 'unknown@pluffy.cafe',
        ]);
    }

    public function test_user_can_reset_password_with_a_valid_code_and_old_tokens_are_revoked(): void
    {
        $user = User::factory()->create([
            'email' => 'customer@pluffy.cafe',
            'password' => 'old-password',
        ]);
        $user->createToken('existing-session');

        DB::table('password_reset_tokens')->insert([
            'email' => $user->email,
            'token' => Hash::make('123456'),
            'created_at' => now(),
        ]);

        $this->postJson('/api/reset-password', [
            'email' => $user->email,
            'code' => '123456',
            'password' => 'new-password',
            'password_confirmation' => 'new-password',
        ])
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->assertTrue(Hash::check('new-password', $user->fresh()->password));
        $this->assertDatabaseMissing('password_reset_tokens', [
            'email' => $user->email,
        ]);
        $this->assertDatabaseCount('personal_access_tokens', 0);
    }

    public function test_expired_or_incorrect_code_is_rejected(): void
    {
        $user = User::factory()->create([
            'email' => 'customer@pluffy.cafe',
        ]);

        DB::table('password_reset_tokens')->insert([
            'email' => $user->email,
            'token' => Hash::make('123456'),
            'created_at' => now()->subMinutes(16),
        ]);

        $this->postJson('/api/reset-password', [
            'email' => $user->email,
            'code' => '123456',
            'password' => 'new-password',
            'password_confirmation' => 'new-password',
        ])
            ->assertUnprocessable()
            ->assertJsonPath('success', false);
    }
}
