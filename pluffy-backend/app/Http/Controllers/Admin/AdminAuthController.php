<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminAuthController extends Controller
{
    public function showLogin(): View
    {
        return view('admin.auth.login');
    }

    public function login(Request $request): RedirectResponse
    {
        if (! config('pluffy_admin.email') || ! config('pluffy_admin.password')) {
            return back()
                ->withErrors(['email' => 'Login admin belum dikonfigurasi.'])
                ->onlyInput('email');
        }

        $credentials = $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if (
            ! hash_equals((string) config('pluffy_admin.email'), $credentials['email']) ||
            ! hash_equals((string) config('pluffy_admin.password'), $credentials['password'])
        ) {
            return back()
                ->withErrors(['email' => 'Email atau password admin tidak sesuai.'])
                ->onlyInput('email');
        }

        $request->session()->put('pluffy_admin_authenticated', true);
        $request->session()->regenerate();

        return redirect()->intended(route('admin.orders.index'));
    }

    public function logout(Request $request): RedirectResponse
    {
        $request->session()->forget('pluffy_admin_authenticated');
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }
}
