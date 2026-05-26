<?php

$frontendUrls = array_filter(array_map(
    'trim',
    explode(',', (string) env('PLUFFY_FRONTEND_URLS', 'http://127.0.0.1:8082,http://localhost:8082'))
));

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    'allowed_methods' => ['*'],
    'allowed_origins' => $frontendUrls,
    'allowed_origins_patterns' => [],
    'allowed_headers' => ['*'],
    'exposed_headers' => [],
    'max_age' => 0,
    'supports_credentials' => false,
];
