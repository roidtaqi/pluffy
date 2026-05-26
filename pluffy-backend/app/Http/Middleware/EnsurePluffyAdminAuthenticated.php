<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsurePluffyAdminAuthenticated
{
    public function handle(Request $request, Closure $next): Response
    {
        if (! $request->session()->get('pluffy_admin_authenticated', false)) {
            return redirect()->route('admin.login');
        }

        return $next($request);
    }
}
