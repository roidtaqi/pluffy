<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pluffy Kitchen Board</title>
    <style>
        :root {
            --bg: #f7f3ef;
            --surface: #fffaf5;
            --surface-muted: #efe7df;
            --line: #dfd1c6;
            --text: #2f2723;
            --muted: #71665f;
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
            background: linear-gradient(180deg, #fbf8f4 0, var(--bg) 220px);
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
            min-height: 72px;
            padding: 12px 24px;
            background: rgba(255, 250, 245, .96);
            border-bottom: 1px solid var(--line);
            box-shadow: 0 8px 20px rgba(76, 49, 37, .07);
            backdrop-filter: blur(10px);
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
            font-size: 21px;
            letter-spacing: 0;
            line-height: 1.15;
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

        .logout-form {
            margin: 0;
        }

        .tabs {
            display: inline-grid;
            grid-template-columns: 1fr 1fr;
            gap: 3px;
            padding: 3px;
            border: 1px solid var(--line);
            border-radius: 8px;
            background: #eee5dd;
        }

        .tab {
            display: grid;
            place-items: center;
            min-height: 34px;
            padding: 0 12px;
            border-radius: 6px;
            color: var(--muted);
            font-size: 12px;
            font-weight: 900;
            text-decoration: none;
            white-space: nowrap;
        }

        .tab.active {
            background: var(--surface);
            color: var(--brand);
            box-shadow: 0 1px 4px rgba(76, 49, 37, .1);
        }

        .pill, .refresh {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            min-height: 36px;
            padding: 0 12px;
            border-radius: 8px;
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

        .logout-button {
            min-height: 36px;
            padding: 8px 12px;
            border: 1px solid var(--line);
            border-radius: 999px;
            background: var(--surface);
            color: var(--muted);
            font: inherit;
            font-size: 12px;
            font-weight: 800;
            cursor: pointer;
        }

        body:has(#products:target) .orders-panel,
        body:not(:has(#products:target)) .products-panel {
            display: none;
        }

        body:has(#products:target) .products-tab,
        body:not(:has(#products:target)) .orders-tab {
            background: var(--surface);
            color: var(--brand);
            box-shadow: 0 1px 4px rgba(76, 49, 37, .1);
        }

        main {
            width: min(1480px, calc(100% - 28px));
            margin: 16px auto 28px;
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
            gap: 12px;
            margin-bottom: 12px;
        }

        .stat {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
            min-height: 68px;
            padding: 14px;
            border-radius: 8px;
            background: var(--surface);
            border: 1px solid var(--line);
            box-shadow: 0 6px 16px rgba(76, 49, 37, .05);
        }

        .stat span {
            color: var(--muted);
            font-size: 12px;
            font-weight: 900;
            text-transform: uppercase;
            letter-spacing: 0;
        }

        .stat strong {
            font-size: 28px;
            line-height: 1;
        }

        .board {
            display: grid;
            grid-template-columns: repeat(4, minmax(260px, 1fr));
            gap: 12px;
            align-items: stretch;
        }

        .lane {
            display: flex;
            flex-direction: column;
            min-height: calc(100vh - 192px);
            border-radius: 8px;
            background: #f0e7df;
            border: 1px solid var(--line);
            overflow: clip;
        }

        .lane-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
            min-height: 52px;
            padding: 12px 14px;
            background: var(--surface);
            border-bottom: 1px solid var(--line);
            flex: 0 0 auto;
        }

        .lane-title {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 13px;
            font-weight: 950;
            text-transform: uppercase;
            letter-spacing: 0;
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
            height: 26px;
            padding: 0 8px;
            border-radius: 999px;
            background: #f4ece5;
            border: 1px solid var(--line);
            font-weight: 900;
            font-size: 13px;
        }

        .lane-body {
            display: flex;
            flex-direction: column;
            gap: 10px;
            padding: 10px;
            flex: 1;
            overflow-y: auto;
        }

        .empty {
            display: grid;
            place-items: center;
            min-height: 112px;
            padding: 18px 12px;
            border: 1px dashed #cbb9ac;
            border-radius: 8px;
            color: var(--muted);
            font-size: 13px;
            text-align: center;
            background: rgba(255, 250, 245, .42);
        }

        .order {
            border-radius: 8px;
            background: var(--surface);
            border: 1px solid var(--line);
            box-shadow: 0 8px 18px rgba(76, 49, 37, .07);
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
            margin-bottom: 10px;
        }

        .order-id {
            font-size: 15px;
            font-weight: 950;
            line-height: 1.2;
            word-break: break-word;
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
            line-height: 1.35;
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
            background: #f8f0e8;
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
            white-space: nowrap;
        }

        .products-panel {
            scroll-margin-top: 96px;
        }

        .products-head {
            display: flex;
            align-items: end;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 14px;
            padding-bottom: 14px;
            border-bottom: 1px solid var(--line);
        }

        .products-head h2 {
            font-size: 22px;
            line-height: 1.15;
        }

        .products-head p {
            margin-top: 4px;
            color: var(--muted);
            font-size: 13px;
            line-height: 1.4;
        }

        .products-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 12px;
        }

        .product-card {
            border: 1px solid var(--line);
            border-radius: 8px;
            background: var(--surface);
            box-shadow: 0 8px 18px rgba(76, 49, 37, .06);
            overflow: hidden;
        }

        .product-card form {
            display: grid;
            gap: 12px;
            padding: 14px;
        }

        .product-card-head {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 12px;
        }

        .product-card-title {
            min-width: 0;
        }

        .product-card-title strong {
            display: block;
            font-size: 15px;
            line-height: 1.25;
        }

        .product-card-title span {
            display: inline-block;
            margin-top: 4px;
            color: var(--muted);
            font-size: 11px;
            font-weight: 900;
            text-transform: uppercase;
        }

        .product-price {
            flex: 0 0 auto;
            color: var(--brand);
            font-size: 14px;
            font-weight: 950;
        }

        .field {
            display: grid;
            gap: 5px;
        }

        .field label {
            color: var(--muted);
            font-size: 11px;
            font-weight: 900;
        }

        .field input,
        .field select,
        .field textarea {
            width: 100%;
            min-height: 38px;
            padding: 8px 10px;
            border: 1px solid var(--line);
            border-radius: 8px;
            background: #fff;
            color: var(--text);
            font: inherit;
            font-size: 13px;
        }

        .field textarea {
            min-height: 78px;
            resize: vertical;
            line-height: 1.4;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
        }

        .checks {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
        }

        .check {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            min-height: 34px;
            padding: 0 10px;
            border: 1px solid var(--line);
            border-radius: 8px;
            background: #f8f0e8;
            color: var(--muted);
            font-size: 12px;
            font-weight: 900;
        }

        .save-product {
            min-height: 38px;
            border: 0;
            border-radius: 8px;
            background: var(--brand);
            color: #fff;
            font-weight: 950;
            cursor: pointer;
        }

        .save-product:hover {
            background: var(--brand-dark);
        }

        .placed .lane-title { color: var(--placed); }
        .preparing .lane-title { color: var(--preparing); }
        .ready .lane-title { color: var(--ready); }
        .completed .lane-title { color: var(--completed); }

        @media (max-width: 1180px) {
            .board { grid-template-columns: repeat(2, minmax(260px, 1fr)); }

            .lane {
                min-height: 420px;
            }
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

            .products-head {
                align-items: flex-start;
                flex-direction: column;
            }

            .board {
                grid-template-columns: 1fr;
            }

            .products-grid,
            .form-row {
                grid-template-columns: 1fr;
            }

            .lane {
                min-height: auto;
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
            <div class="tabs" aria-label="Admin sections">
                <a class="tab orders-tab" href="#orders">Orders</a>
                <a class="tab products-tab" href="#products">Products</a>
            </div>
            <a class="refresh" href="{{ route('admin.orders.index') }}">Refresh</a>
            <div class="pill"><span class="dot"></span>Orders refresh 5s</div>
            <form class="logout-form" method="POST" action="{{ route('admin.logout') }}">
                @csrf
                <button class="logout-button" type="submit">Logout</button>
            </form>
        </div>
    </header>

    <main>
        @if (session('success'))
            <div class="flash">{{ session('success') }}</div>
        @endif

        <span id="orders"></span>
        <section class="orders-panel">
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
        </section>

        <section class="products-panel" id="products" aria-label="Product manager">
            <div class="products-head">
                <div>
                    <h2>Product Manager</h2>
                    <p>Ubah harga, stok, status ketersediaan, visibilitas menu, dan detail produk dari backend admin.</p>
                </div>
                <strong>{{ $products->count() }} products</strong>
            </div>

            <div class="products-grid">
                @foreach ($products as $product)
                    <article class="product-card">
                        <form method="POST" action="{{ route('admin.products.update', $product) }}">
                            @csrf
                            @method('PATCH')

                            <div class="product-card-head">
                                <div class="product-card-title">
                                    <strong>{{ $product->name }}</strong>
                                    <span>{{ $product->category }}</span>
                                </div>
                                <div class="product-price">Rp {{ number_format($product->base_price, 0, ',', '.') }}</div>
                            </div>

                            <div class="field">
                                <label for="product-{{ $product->id }}-name">Nama produk</label>
                                <input id="product-{{ $product->id }}-name" name="name" value="{{ old('name', $product->name) }}" required>
                            </div>

                            <div class="form-row">
                                <div class="field">
                                    <label for="product-{{ $product->id }}-category">Kategori</label>
                                    <input id="product-{{ $product->id }}-category" name="category" value="{{ old('category', $product->category) }}" required>
                                </div>
                                <div class="field">
                                    <label for="product-{{ $product->id }}-price">Harga</label>
                                    <input id="product-{{ $product->id }}-price" name="base_price" type="number" min="0" step="1000" value="{{ old('base_price', $product->base_price) }}" required>
                                </div>
                            </div>

                            <div class="form-row">
                                <div class="field">
                                    <label for="product-{{ $product->id }}-stock">Stok</label>
                                    <input id="product-{{ $product->id }}-stock" name="stock" type="number" min="0" value="{{ old('stock', $product->stock) }}" required>
                                </div>
                                <div class="field">
                                    <label for="product-{{ $product->id }}-rating">Rating</label>
                                    <input id="product-{{ $product->id }}-rating" name="rating" type="number" min="0" max="5" step="0.1" value="{{ old('rating', $product->rating) }}">
                                </div>
                            </div>

                            <div class="field">
                                <label for="product-{{ $product->id }}-status">Status ketersediaan</label>
                                <select id="product-{{ $product->id }}-status" name="availability_status">
                                    @foreach (['available' => 'Tersedia', 'sold_out' => 'Sold Out', 'seasonal' => 'Seasonal'] as $value => $label)
                                        <option value="{{ $value }}" @selected(old('availability_status', $product->availability_status) === $value)>{{ $label }}</option>
                                    @endforeach
                                </select>
                            </div>

                            <div class="field">
                                <label for="product-{{ $product->id }}-description">Deskripsi</label>
                                <textarea id="product-{{ $product->id }}-description" name="description" required>{{ old('description', $product->description) }}</textarea>
                            </div>

                            <div class="checks">
                                <label class="check">
                                    <input type="checkbox" name="is_active" value="1" @checked(old('is_active', $product->is_active))>
                                    Tampil di menu
                                </label>
                                <label class="check">
                                    <input type="checkbox" name="is_best_seller" value="1" @checked(old('is_best_seller', $product->is_best_seller))>
                                    Best seller
                                </label>
                                <label class="check">
                                    <input type="checkbox" name="is_seasonal" value="1" @checked(old('is_seasonal', $product->is_seasonal))>
                                    Seasonal
                                </label>
                            </div>

                            <button class="save-product" type="submit">Simpan Produk</button>
                        </form>
                    </article>
                @endforeach
            </div>
        </section>
    </main>
    <script>
        if (window.location.hash !== '#products') {
            window.setTimeout(() => {
                window.location.reload();
            }, 5000);
        }
    </script>
</body>
</html>
