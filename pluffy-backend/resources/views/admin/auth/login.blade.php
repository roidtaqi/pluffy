<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pluffy Admin Login</title>
    <style>
        :root {
            --bg: #f4eee8;
            --surface: #fffaf5;
            --line: #ddcec2;
            --text: #2f2723;
            --muted: #796b64;
            --brand: #8f2424;
            --brand-dark: #681a1a;
            --error: #b83232;
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            display: grid;
            place-items: center;
            padding: 24px;
            font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        .panel {
            width: min(420px, 100%);
            padding: 28px;
            border-radius: 8px;
            background: var(--surface);
            border: 1px solid var(--line);
            box-shadow: 0 16px 40px rgba(76, 49, 37, .1);
        }

        .mark {
            display: grid;
            place-items: center;
            width: 48px;
            height: 48px;
            margin-bottom: 18px;
            border-radius: 8px;
            background: var(--brand);
            color: #fff;
            font-size: 24px;
            font-weight: 900;
        }

        h1 {
            margin: 0;
            font-size: 25px;
            letter-spacing: 0;
        }

        p {
            margin: 6px 0 22px;
            color: var(--muted);
            line-height: 1.45;
        }

        label {
            display: block;
            margin-bottom: 14px;
            color: var(--muted);
            font-size: 13px;
            font-weight: 800;
        }

        input {
            width: 100%;
            min-height: 46px;
            margin-top: 6px;
            padding: 0 12px;
            border-radius: 8px;
            border: 1px solid var(--line);
            background: #fff;
            color: var(--text);
            font: inherit;
        }

        button {
            width: 100%;
            min-height: 48px;
            margin-top: 6px;
            border: 0;
            border-radius: 8px;
            background: var(--brand);
            color: #fff;
            font: inherit;
            font-weight: 900;
            cursor: pointer;
        }

        button:hover { background: var(--brand-dark); }

        .error {
            margin-bottom: 14px;
            padding: 10px 12px;
            border-radius: 8px;
            border: 1px solid rgba(184, 50, 50, .22);
            background: rgba(184, 50, 50, .08);
            color: var(--error);
            font-size: 13px;
            font-weight: 800;
        }
    </style>
</head>
<body>
    <main class="panel">
        <div class="mark">P</div>
        <h1>Pluffy Admin</h1>
        <p>Login untuk mengelola order dan produk Pluffy.</p>

        @if ($errors->any())
            <div class="error">{{ $errors->first() }}</div>
        @endif

        <form method="POST" action="{{ route('admin.login.submit') }}">
            @csrf
            <label>
                Email
                <input name="email" type="email" value="{{ old('email') }}" autocomplete="email" required autofocus>
            </label>
            <label>
                Password
                <input name="password" type="password" autocomplete="current-password" required>
            </label>
            <button type="submit">Login</button>
        </form>
    </main>
</body>
</html>
