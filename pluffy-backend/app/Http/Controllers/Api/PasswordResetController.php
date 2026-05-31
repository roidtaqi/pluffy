<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Mail\Message;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Throwable;

class PasswordResetController extends Controller
{
    private const CODE_EXPIRATION_MINUTES = 15;

    public function requestCode(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email|max:255',
        ]);

        $email = strtolower($validated['email']);
        $user = $this->findUserByEmail($email);

        if (! $user) {
            return $this->codeRequestedResponse();
        }

        $code = (string) random_int(100000, 999999);

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $user->email],
            [
                'token' => Hash::make($code),
                'created_at' => now(),
            ],
        );

        try {
            Mail::raw(
                "Halo {$user->name},\n\nKode verifikasi reset password Pluffy kamu adalah: {$code}\n\nKode ini berlaku selama ".self::CODE_EXPIRATION_MINUTES." menit. Abaikan email ini jika kamu tidak meminta reset password.",
                function (Message $message) use ($user): void {
                    $message
                        ->to($user->email, $user->name)
                        ->subject('Kode reset password Pluffy');
                },
            );
        } catch (Throwable $exception) {
            DB::table('password_reset_tokens')
                ->where('email', $user->email)
                ->delete();

            report($exception);

            return response()->json([
                'success' => false,
                'message' => 'Kode reset belum dapat dikirim. Coba lagi beberapa saat.',
            ], 503);
        }

        return $this->codeRequestedResponse();
    }

    public function reset(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => 'required|email|max:255',
            'code' => ['required', 'string', 'regex:/^\d{6}$/'],
            'password' => 'required|string|min:6|confirmed',
        ]);

        $email = strtolower($validated['email']);
        $user = $this->findUserByEmail($email);

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'Kode verifikasi tidak valid atau sudah kedaluwarsa.',
            ], 422);
        }

        $resetToken = DB::table('password_reset_tokens')
            ->where('email', $user->email)
            ->where('created_at', '>=', now()->subMinutes(self::CODE_EXPIRATION_MINUTES))
            ->first();

        if (! $resetToken || ! Hash::check($validated['code'], $resetToken->token)) {
            return response()->json([
                'success' => false,
                'message' => 'Kode verifikasi tidak valid atau sudah kedaluwarsa.',
            ], 422);
        }

        $user->password = $validated['password'];
        $user->save();
        $user->tokens()->delete();

        DB::table('password_reset_tokens')
            ->where('email', $user->email)
            ->delete();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diperbarui. Silakan login kembali.',
        ]);
    }

    private function codeRequestedResponse(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => 'Jika email terdaftar, kode reset akan dikirim ke email tersebut.',
        ]);
    }

    private function findUserByEmail(string $email): ?User
    {
        return User::whereRaw('LOWER(email) = ?', [$email])->first();
    }
}
