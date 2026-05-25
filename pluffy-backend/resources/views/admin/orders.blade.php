<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="30">
    <title>Pluffy Kitchen Board</title>
    <style>
        :root {
            --bg: #f4eee8;
            --surface: #fffaf5;
            --surface-muted: #f0e6dc;
            --line: #ddcec2;
            --text: #2f2723;
            --muted: #796b64;
            --brand: #8f2424;
            --brand-dark: #681a1a;
            --placed: #b07422;
            --preparing: #7d4f9f;
            --ready: #287596;
            --completed: #3d7c52;
            --shadow: 0 12px 30px rgba(76, 49, 37, .08);
        }

        * { box-sizing: border-box; }

        body {
            margin: 0;
            min-height: 100vh;
            font-family: Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
            background: var(--bg);
            color: var(--text);
        }

        button { font: inherit; }
        h1, h2, h3, p { margin: 0; }

        header {
            position: sticky;
            top: 0;
            z-index: 3;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            min-height: 76px;
            padding: 14px 24px;
            background: rgba(255, 250, 245, .96);
            border-bottom: 1px solid var(--line);
            box-shadow: var(--shadow);
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .mark {
            display: grid;
            place-items: center;
            width: 42px;
            height: 42px;
            flex: 0 0 42px;
            border-radius: 8px;
            background: var(--brand);
            color: #fff;
            font-weight: 900;
            font-size: 22px;
        }

        .brand h1 {
            font-size: 22px;
            letter-spacing: 0;
        }

        .brand p {
            margin-top: 2px;
            color: var(--muted);
            font-size: 12px;
            font-weight: 700;
        }

        .toolbar {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .pill, .refresh {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            min-height: 36px;
            padding: 8px 12px;
            border-radius: 999px;
            border: 1px solid var(--line);
            background: var(--surface);
            color: var(--muted);
            font-size: 12px;
            font-weight: 800;
            text-decoration: none;
            white-space: nowrap;
        }

        .pill .dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--completed);
        }

        main {
            width: min(1440px, calc(100% - 28px));
            margin: 18px auto 32px;
        }

        .flash {
            margin-bottom: 14px;
            padding: 12px 14px;
            border-radius: 8px;
            border: 1px solid rgba(61, 124, 82, .24);
            background: rgba(61, 124, 82, .08);
            color: var(--completed);
            font-weight: 800;
        }

        .stats {
            display: grid;
            grid-template-columns: repeat(4, minmax(0, 1fr));
            gap: 10px;
            margin-bottom: 14px;
        }

        .stat {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            min-height: 72px;
            padding: 14px;
            border-radius: 8px;
            background: var(--surface);
            border: 1px solid var(--line);
        }

        .stat span {
            color: var(--muted);
            font-size: 12px;
            font-weight: 900;
            text-transform: uppercase;
        }

        .stat strong {
            font-size: 30px;
            line-height: 1;
        }

        .board {
            display: grid;
            grid-template-columns: repeat(4, minmax(260px, 1fr));
            gap: 12px;
            align-items: start;
        }

        .lane {
            min-height: 62vh;
            border-radius: 8px;
            background: var(--surface-muted);
            border: 1px solid var(--line);
            overflow: hidden;
        }

        .lane-header {
            position: sticky;
            top: 76px;
            z-index: 2;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            min-height: 54px;
            padding: 12px 14px;
            background: var(--surface);
            border-bottom: 1px solid var(--line);
        }

        .lane-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 14px;
            font-weight: 950;
            text-transform: uppercase;
        }

        .lane-title::before {
            content: "";
            display: block;
            width: 9px;
            height: 9px;
            border-radius: 50%;
            background: currentColor;
        }

        .lane-count {
            display: grid;
            place-items: center;
            min-width: 28px;
            height: 28px;
            padding: 0 8px;
            border-radius: 999px;
            background: var(--surface-muted);
            border: 1px solid var(--line);
            font-weight: 900;
        }

        .lane-body {
            display: grid;
            gap: 10px;
            padding: 10px;
        }

        .empty {
            display: grid;
            place-items: center;
            min-height: 96px;
            padding: 18px 12px;
            border: 1px dashed #cbb9ac;
            border-radius: 8px;
            color: var(--muted);
            font-size: 13px;
            text-align: center;
        }

        .order {
            border-radius: 8px;
            background: var(--surface);
            border: 1px solid var(--line);
            box-shadow: 0 8px 18px rgba(76, 49, 37, .06);
            overflow: hidden;
        }

        .order-main {
            padding: 12px;
        }

        .order-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 10px;
            margin-bottom: 8px;
        }

        .order-id {
            font-size: 15px;
            font-weight: 950;
            line-height: 1.2;
        }

        .age {
            flex: 0 0 auto;
            color: var(--brand);
            font-size: 12px;
            font-weight: 900;
            white-space: nowrap;
        }

        .meta {
            color: var(--muted);
            font-size: 12px;
            line-height: 1.35;
        }

        .items {
            margin-top: 10px;
            border-top: 1px solid var(--line);
        }

        .item {
            display: flex;
            justify-content: space-between;
            gap: 10px;
            padding: 8px 0;
            border-bottom: 1px solid rgba(221, 206, 194, .65);
            color: #51453f;
            font-size: 13px;
        }

        .item span {
            min-width: 0;
        }

        .item strong {
            white-space: nowrap;
        }

        .order-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            padding: 10px 12px;
            background: #f7eee6;
            border-top: 1px solid var(--line);
        }

        .total {
            color: var(--brand);
            font-size: 16px;
            font-weight: 950;
            white-space: nowrap;
        }

        .next-action {
            min-width: 116px;
            min-height: 38px;
            padding: 0 12px;
            border: 0;
            border-radius: 8px;
            background: var(--brand);
            color: #fff;
            font-size: 12px;
            font-weight: 900;
            cursor: pointer;
        }

        .next-action:hover {
            background: var(--brand-dark);
        }

        .done-label {
            color: var(--completed);
            font-size: 12px;
            font-weight: 900;
        }

        .placed .lane-title { color: var(--placed); }
        .preparing .lane-title { color: var(--preparing); }
        .ready .lane-title { color: var(--ready); }
        .completed .lane-title { color: var(--completed); }

        @media (max-width: 1180px) {
            .board { grid-template-columns: repeat(2, minmax(260px, 1fr)); }
        }

        @media (max-width: 720px) {
            header {
                align-items: flex-start;
                flex-direction: column;
            }

            .toolbar {
                justify-content: flex-start;
            }

            .stats {
                grid-template-columns: repeat(2, minmax(0, 1fr));
            }

            .board {
                grid-template-columns: 1fr;
            }

            .lane {
                min-height: auto;
            }

            .lane-header {
                top: 0;
            }
        }
    </style>
</head>
<body>
    <header>
        <div class="brand">
            <div class="mark">P</div>
            <div>
                <h1>Pluffy Kitchen Board</h1>
                <p>Live order operations</p>
            </div>
        </div>
        <div class="toolbar">
            <a class="refresh" href="{{ route('admin.orders.index') }}">Refresh</a>
            <div class="pill"><span class="dot"></span>Auto-refresh 30s</div>
        </div>
    </header>

    <main>
        @if (session('success'))
            <div class="flash">{{ session('success') }}</div>
        @endif

        <section class="stats" aria-label="Order status summary">
            @foreach ($statusCounts as $status => $count)
                <div class="stat">
                    <span>{{ str_replace('_', ' ', $status) }}</span>
                    <strong>{{ $count }}</strong>
                </div>
            @endforeach
        </section>

        <section class="board" aria-label="Kitchen order lanes">
            @foreach ($statuses as $status)
                @php
                    $laneOrders = $ordersByStatus->get($status, collect());
                @endphp

                <section class="lane {{ $status }}">
                    <div class="lane-header">
                        <h2 class="lane-title">{{ ucwords(str_replace('_', ' ', $status)) }}</h2>
                        <span class="lane-count">{{ $laneOrders->count() }}</span>
                    </div>

                    <div class="lane-body">
                        @forelse ($laneOrders as $order)
                            @php
                                $nextStatus = match ($order->status) {
                                    'placed' => 'preparing',
                                    'preparing' => 'ready',
                                    'ready' => 'completed',
                                    default => null,
                                };
                                $nextLabel = match ($nextStatus) {
                                    'preparing' => 'Start',
                                    'ready' => 'Ready',
                                    'completed' => 'Complete',
                                    default => null,
                                };
                            @endphp

                            <article class="order">
                                <div class="order-main">
                                    <div class="order-top">
                                        <div>
                                            <div class="order-id">{{ $order->id }}</div>
                                            <div class="meta">{{ $order->user?->name ?? 'Guest / deleted user' }}</div>
                                        </div>
                                        <div class="age">{{ $order->created_at?->diffForHumans(null, true) ?? 'now' }}</div>
                                    </div>

                                    <div class="meta">
                                        {{ optional($order->created_at)->format('d M Y, H:i') }}
                                        &middot;
                                        {{ $order->outlet_name }}
                                    </div>

                                    <div class="items">
                                        @forelse ($order->items as $item)
                                            <div class="item">
                                                <span>{{ $item->quantity }}x {{ $item->product?->name ?? 'Unknown product' }}</span>
                                                <strong>Rp {{ number_format($item->unit_price, 0, ',', '.') }}</strong>
                                            </div>
                                        @empty
                                            <div class="item">
                                                <span>No item details saved.</span>
                                            </div>
                                        @endforelse
                                    </div>
                                </div>

                                <div class="order-footer">
                                    <div class="total">Rp {{ number_format($order->total, 0, ',', '.') }}</div>

                                    @if ($nextStatus)
                                        <form method="POST" action="{{ route('admin.orders.status', $order) }}">
                                            @csrf
                                            @method('PATCH')
                                            <input type="hidden" name="status" value="{{ $nextStatus }}">
                                            <button class="next-action" type="submit">{{ $nextLabel }}</button>
                                        </form>
                                    @else
                                        <div class="done-label">Completed</div>
                                    @endif
                                </div>
                            </article>
                        @empty
                            <div class="empty">No {{ str_replace('_', ' ', $status) }} orders.</div>
                        @endforelse
                    </div>
                </section>
            @endforeach
        </section>
    </main>
</body>
</html>
