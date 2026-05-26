<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pluffy Backend</title>
    <style>
        :root {
            --bg: #f4eee8;
            --surface: #fffaf5;
            --line: #ddcec2;
            --text: #2f2723;
            --muted: #796b64;
            --brand: #8f2424;
            --ok: #3d7c52;
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

        main {
            width: min(680px, 100%);
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
            margin: 0 0 8px;
            font-size: 28px;
            letter-spacing: 0;
        }

        p {
            margin: 0;
            color: var(--muted);
            line-height: 1.55;
        }

        .status {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            margin: 18px 0;
            padding: 8px 12px;
            border-radius: 999px;
            background: rgba(61, 124, 82, .08);
            color: var(--ok);
            font-weight: 900;
        }

        .dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--ok);
        }

        .links {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 22px;
        }

        a {
            display: inline-flex;
            align-items: center;
            min-height: 40px;
            padding: 0 14px;
            border-radius: 8px;
            background: var(--brand);
            color: #fff;
            text-decoration: none;
            font-weight: 900;
        }

        a.secondary {
            background: transparent;
            color: var(--brand);
            border: 1px solid var(--line);
        }
    </style>
</head>
<body>
    <main>
        <div class="mark">P</div>
        <h1>Pluffy Backend</h1>
        <p>Laravel API untuk aplikasi Pluffy sedang berjalan. Gunakan endpoint API untuk frontend, atau masuk ke admin portal untuk mengelola order dan produk.</p>
        <div class="status"><span class="dot"></span>API Running</div>
        <div class="links">
            <a href="/admin">Open Admin</a>
            <a class="secondary" href="/api/products">View Products API</a>
        </div>
    </main>
</body>
</html>
