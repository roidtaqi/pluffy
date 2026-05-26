<?php

namespace Tests\Feature;

use Tests\TestCase;

class BackendReadinessTest extends TestCase
{
    public function test_backend_root_shows_pluffy_status_page(): void
    {
        $this->get('/')
            ->assertOk()
            ->assertSee('Pluffy Backend')
            ->assertSee('API Running')
            ->assertHeader('X-Frame-Options', 'DENY')
            ->assertHeader('X-Content-Type-Options', 'nosniff')
            ->assertHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
    }

    public function test_api_cors_preflight_allows_configured_frontend_origin(): void
    {
        config()->set('cors.allowed_origins', ['https://pluffy.example.com']);

        $this->options('/api/products', [
            'Origin' => 'https://pluffy.example.com',
            'Access-Control-Request-Method' => 'GET',
        ])
            ->assertOk()
            ->assertHeader('Access-Control-Allow-Origin', 'https://pluffy.example.com');
    }

    public function test_protected_api_routes_return_json_unauthenticated_response(): void
    {
        $this->get('/api/orders')
            ->assertUnauthorized()
            ->assertJsonPath('success', false)
            ->assertJsonPath('message', 'Unauthenticated.');
    }
}
