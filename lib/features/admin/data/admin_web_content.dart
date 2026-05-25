class AdminWebContent {
  AdminWebContent._();

  static const String html = '''<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Pluffy Café - Kitchen Admin Console 🥞</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700;800&family=Playfair+Display:ital,wght@0,600;0,700;1,500&display=swap" rel="stylesheet">
  <style>
    :root {
      --primary: #9B1B1B;
      --bg: #120B0A;
      --card-bg: #1C1210;
      --card-hover: #261A17;
      --border: #3D2924;
      --gold-border: #E8C9A0;
      --accent: #FAF0DC;
      --text-main: #F5EBE6;
      --text-secondary: #A69490;
      --success: #4E7D56;
      --success-light: #DFEDE1;
      --shadow: 0 10px 30px rgba(0, 0, 0, 0.5);
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
      font-family: 'Outfit', sans-serif;
    }

    body {
      background-color: var(--bg);
      color: var(--text-main);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      overflow-x: hidden;
    }

    /* Custom Scrollbar */
    ::-webkit-scrollbar {
      width: 6px;
      height: 6px;
    }
    ::-webkit-scrollbar-track {
      background: var(--bg);
    }
    ::-webkit-scrollbar-thumb {
      background: var(--border);
      border-radius: 4px;
    }
    ::-webkit-scrollbar-thumb:hover {
      background: var(--gold-border);
    }

    header {
      background-color: var(--card-bg);
      border-bottom: 1.5px solid var(--border);
      padding: 15px 40px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: var(--shadow);
      position: sticky;
      top: 0;
      z-index: 100;
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
    }

    .brand-logo {
      font-size: 28px;
    }

    .brand-text h1 {
      font-family: 'Playfair Display', serif;
      font-size: 24px;
      font-weight: 700;
      color: var(--accent);
      letter-spacing: 0.5px;
    }

    .brand-text p {
      font-size: 11px;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 1.5px;
      margin-top: 2px;
    }

    .header-nav {
      display: flex;
      align-items: center;
      gap: 16px;
    }

    .nav-tabs {
      display: flex;
      background-color: rgba(0, 0, 0, 0.25);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 4px;
      gap: 4px;
    }

    .nav-tab {
      background: transparent;
      border: none;
      color: var(--text-secondary);
      padding: 8px 16px;
      border-radius: 8px;
      font-size: 13px;
      font-weight: 600;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      transition: all 0.3s ease;
    }

    .nav-tab:hover {
      color: var(--text-main);
      background-color: rgba(255, 255, 255, 0.03);
    }

    .nav-tab.active {
      background-color: var(--primary);
      color: var(--accent);
      box-shadow: 0 4px 12px rgba(155, 27, 27, 0.3);
    }

    .controls {
      display: flex;
      align-items: center;
      gap: 24px;
    }

    .switch-container {
      display: flex;
      align-items: center;
      gap: 10px;
    }

    .switch-label {
      font-size: 12px;
      font-weight: 600;
      color: var(--text-secondary);
      letter-spacing: 0.5px;
      text-transform: uppercase;
    }

    .switch-label.active {
      color: var(--accent);
    }

    .switch {
      position: relative;
      display: inline-block;
      width: 44px;
      height: 24px;
    }

    .switch input {
      opacity: 0;
      width: 0;
      height: 0;
    }

    .slider {
      position: absolute;
      cursor: pointer;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: #3D2924;
      transition: .4s;
      border-radius: 24px;
      border: 1px solid var(--border);
    }

    .slider:before {
      position: absolute;
      content: "";
      height: 16px;
      width: 16px;
      left: 3px;
      bottom: 3px;
      background-color: var(--text-secondary);
      transition: .4s;
      border-radius: 50%;
    }

    input:checked + .slider {
      background-color: var(--primary);
      border-color: var(--primary);
    }

    input:checked + .slider:before {
      transform: translateX(20px);
      background-color: var(--accent);
    }

    .server-status {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 11px;
      font-weight: 700;
      letter-spacing: 1px;
      color: var(--success);
      background-color: rgba(78, 125, 86, 0.1);
      padding: 6px 12px;
      border-radius: 20px;
      border: 1px solid rgba(78, 125, 86, 0.2);
    }

    .server-dot {
      width: 6px;
      height: 6px;
      background-color: var(--success);
      border-radius: 50%;
      box-shadow: 0 0 8px var(--success);
    }

    /* Views */
    .view-panel {
      display: none;
      flex: 1;
      padding: 30px 40px;
      animation: fadeIn 0.4s ease both;
    }

    .view-panel.active {
      display: block;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(6px); }
      to { opacity: 1; transform: translateY(0); }
    }

    /* Orders Dashboard Layout */
    .dashboard {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 20px;
      height: calc(100vh - 140px);
      min-height: 500px;
    }

    .column {
      background-color: var(--card-bg);
      border: 1.5px solid var(--border);
      border-radius: 16px;
      display: flex;
      flex-direction: column;
      overflow: hidden;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
    }

    .column-header {
      padding: 18px 20px;
      border-bottom: 1.5px solid var(--border);
      display: flex;
      justify-content: space-between;
      align-items: center;
      background-color: rgba(0, 0, 0, 0.15);
    }

    .column-title {
      font-size: 14px;
      font-weight: 700;
      color: var(--accent);
      letter-spacing: 0.5px;
      text-transform: uppercase;
    }

    .column-badge {
      background-color: var(--border);
      color: var(--text-main);
      font-size: 12px;
      font-weight: 700;
      padding: 3px 8px;
      border-radius: 20px;
      min-width: 24px;
      text-align: center;
    }

    .orders-list {
      flex: 1;
      padding: 16px;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    /* Order Card Style */
    .order-card {
      background-color: rgba(255, 255, 255, 0.02);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 16px;
      transition: all 0.3s ease;
      display: flex;
      flex-direction: column;
      gap: 12px;
      position: relative;
    }

    .order-card:hover {
      background-color: var(--card-hover);
      border-color: var(--gold-border);
      transform: translateY(-2px);
      box-shadow: 0 6px 18px rgba(0, 0, 0, 0.3);
    }

    .order-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .order-id {
      font-size: 13px;
      font-weight: 700;
      color: var(--accent);
      font-family: monospace;
    }

    .order-time {
      font-size: 11px;
      color: var(--text-secondary);
    }

    .order-outlet {
      font-size: 11px;
      font-weight: 600;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 1px;
      background-color: rgba(255, 255, 255, 0.03);
      padding: 3px 8px;
      border-radius: 4px;
      align-self: flex-start;
    }

    .order-items {
      border-top: 1px dashed var(--border);
      border-bottom: 1px dashed var(--border);
      padding: 8px 0;
      display: flex;
      flex-direction: column;
      gap: 6px;
    }

    .item-row {
      display: flex;
      justify-content: space-between;
      font-size: 13px;
    }

    .item-qty-name {
      color: var(--text-main);
      font-weight: 500;
    }

    .item-price {
      color: var(--text-secondary);
    }

    .order-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 4px;
    }

    .order-total {
      font-size: 16px;
      font-weight: 700;
      color: var(--accent);
    }

    /* Buttons */
    .btn {
      background-color: var(--primary);
      color: var(--accent);
      border: 1px solid var(--primary);
      padding: 8px 16px;
      border-radius: 8px;
      font-size: 12px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .btn:hover {
      background-color: transparent;
      color: var(--accent);
      border-color: var(--gold-border);
      box-shadow: 0 4px 12px rgba(155, 27, 27, 0.2);
    }

    .btn-secondary {
      background-color: transparent;
      color: var(--accent);
      border-color: var(--border);
    }

    .btn-secondary:hover {
      background-color: rgba(255, 255, 255, 0.05);
      border-color: var(--gold-border);
    }

    .completed-badge {
      font-size: 12px;
      font-weight: 700;
      color: var(--success);
      background-color: rgba(78, 125, 86, 0.1);
      padding: 4px 10px;
      border-radius: 8px;
      border: 1px solid rgba(78, 125, 86, 0.2);
    }

    /* Empty state */
    .empty-state {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 12px;
      color: var(--text-secondary);
      height: 100%;
      text-align: center;
      padding: 20px;
      font-size: 13px;
    }

    .empty-icon {
      font-size: 32px;
      opacity: 0.3;
    }

    /* Product Grid Layout */
    .products-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
      border-bottom: 1.5px solid var(--border);
      padding-bottom: 16px;
    }

    .products-title-area h2 {
      font-family: 'Playfair Display', serif;
      font-size: 26px;
      color: var(--accent);
    }

    .products-title-area p {
      font-size: 13px;
      color: var(--text-secondary);
      margin-top: 4px;
    }

    .products-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 20px;
    }

    .product-admin-card {
      background-color: var(--card-bg);
      border: 1.5px solid var(--border);
      border-radius: 16px;
      padding: 20px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
      display: flex;
      flex-direction: column;
      gap: 14px;
      transition: all 0.3s ease;
    }

    .product-admin-card:hover {
      border-color: var(--gold-border);
      background-color: var(--card-hover);
      transform: translateY(-2px);
    }

    .product-admin-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      gap: 12px;
    }

    .product-admin-info h3 {
      font-size: 16px;
      font-weight: 700;
      color: var(--accent);
    }

    .product-admin-info .category-badge {
      font-size: 10px;
      font-weight: 700;
      color: var(--gold-border);
      text-transform: uppercase;
      letter-spacing: 1px;
      display: inline-block;
      margin-top: 4px;
    }

    .product-price-label {
      font-size: 18px;
      font-weight: 800;
      color: var(--accent);
      font-family: monospace;
    }

    .product-admin-desc {
      font-size: 13px;
      color: var(--text-secondary);
      line-height: 1.5;
      min-height: 60px;
    }

    .product-admin-badges {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
    }

    .badge-status {
      font-size: 11px;
      font-weight: 700;
      padding: 4px 10px;
      border-radius: 20px;
      border: 1px solid transparent;
      display: flex;
      align-items: center;
      gap: 6px;
    }

    .badge-status.available {
      color: var(--success);
      background-color: rgba(78, 125, 86, 0.1);
      border-color: rgba(78, 125, 86, 0.2);
    }

    .badge-status.sold_out {
      color: var(--primary);
      background-color: rgba(155, 27, 27, 0.1);
      border-color: rgba(155, 27, 27, 0.2);
    }

    .badge-status.active {
      color: var(--accent);
      background-color: rgba(232, 201, 160, 0.1);
      border-color: rgba(232, 201, 160, 0.2);
    }

    .badge-status.hidden {
      color: var(--text-secondary);
      background-color: rgba(255, 255, 255, 0.05);
      border-color: rgba(255, 255, 255, 0.08);
    }

    .product-admin-footer {
      border-top: 1px solid var(--border);
      padding-top: 14px;
      display: flex;
      justify-content: flex-end;
      gap: 8px;
      margin-top: auto;
    }

    /* Modal Form Styles */
    .modal-overlay {
      position: fixed;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background-color: rgba(0, 0, 0, 0.85);
      backdrop-filter: blur(8px);
      z-index: 1000;
      display: none;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }

    .modal-overlay.active {
      display: flex;
    }

    .modal-container {
      background-color: var(--card-bg);
      border: 2px solid var(--border);
      border-radius: 20px;
      width: 100%;
      max-width: 520px;
      box-shadow: var(--shadow);
      animation: modalScale 0.3s cubic-bezier(0.34, 1.56, 0.64, 1) both;
      overflow: hidden;
    }

    @keyframes modalScale {
      from { opacity: 0; transform: scale(0.95); }
      to { opacity: 1; transform: scale(1); }
    }

    .modal-header {
      padding: 20px 24px;
      border-bottom: 1.5px solid var(--border);
      display: flex;
      justify-content: space-between;
      align-items: center;
      background-color: rgba(0, 0, 0, 0.15);
    }

    .modal-title {
      font-family: 'Playfair Display', serif;
      font-size: 20px;
      color: var(--accent);
    }

    .modal-close-btn {
      background: transparent;
      border: none;
      color: var(--text-secondary);
      font-size: 22px;
      cursor: pointer;
      transition: color 0.2s;
    }

    .modal-close-btn:hover {
      color: var(--primary);
    }

    .modal-body {
      padding: 24px;
      max-height: 70vh;
      overflow-y: auto;
    }

    .form-group {
      margin-bottom: 18px;
    }

    .form-label {
      display: block;
      font-size: 12px;
      font-weight: 700;
      color: var(--text-secondary);
      text-transform: uppercase;
      letter-spacing: 0.5px;
      margin-bottom: 6px;
    }

    .form-control {
      width: 100%;
      background-color: rgba(0, 0, 0, 0.2);
      border: 1.5px solid var(--border);
      border-radius: 10px;
      color: var(--text-main);
      padding: 10px 14px;
      font-size: 14px;
      transition: all 0.3s ease;
    }

    .form-control:focus {
      outline: none;
      border-color: var(--gold-border);
      background-color: rgba(0, 0, 0, 0.3);
    }

    textarea.form-control {
      min-height: 80px;
      resize: vertical;
    }

    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }

    .modal-footer {
      padding: 16px 24px;
      border-top: 1.5px solid var(--border);
      display: flex;
      justify-content: flex-end;
      gap: 12px;
      background-color: rgba(0, 0, 0, 0.15);
    }

    /* General animation */
    @keyframes fadeInUp {
      from { opacity: 0; transform: translateY(8px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .animate-in {
      animation: fadeInUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) both;
    }

    .error-card-connection {
      grid-column: 1 / -1;
      background-color: rgba(155, 27, 27, 0.05);
      border: 1.5px dashed var(--primary);
      border-radius: 16px;
      padding: 30px;
      text-align: center;
      color: var(--accent);
    }
  </style>
</head>
<body>

  <header>
    <div class="brand">
      <img src="/api/logo" style="width: 44px; height: 44px; object-fit: contain; border-radius: 50%; border: 1.5px solid var(--gold-border);" alt="Logo">
      <div class="brand-text">
        <h1>Pluffy Café</h1>
        <p>Kitchen Admin Console</p>
      </div>
    </div>
    
    <div class="header-nav">
      <div class="nav-tabs">
        <button class="nav-tab active" id="tab-orders" onclick="switchView('orders')">🛎️ Order Monitor</button>
        <button class="nav-tab" id="tab-products" onclick="switchView('products')">🥞 Product Manager</button>
      </div>
    </div>

    <div class="controls">
      <div class="switch-container">
        <span class="switch-label" id="simulation-label">Auto-Simulate Orders</span>
        <label class="switch">
          <input type="checkbox" id="simulation-toggle" onchange="toggleSimulation()">
          <span class="slider"></span>
        </label>
      </div>
      <div class="server-status">
        <div class="server-dot"></div>
        <span>SERVER ACTIVE</span>
      </div>
    </div>
  </header>

  <!-- 1. ORDERS MONITOR VIEW -->
  <main class="view-panel active" id="view-orders">
    <div class="dashboard">
      <!-- PLACED COLUMN -->
      <div class="column placed">
        <div class="column-header">
          <div class="column-title">📥 Pesanan Baru</div>
          <div class="column-badge" id="badge-placed">0</div>
        </div>
        <div class="orders-list" id="list-placed">
          <div class="empty-state">
            <div class="empty-icon">🛎️</div>
            <div>Belum ada pesanan masuk</div>
          </div>
        </div>
      </div>

      <!-- PREPARING COLUMN -->
      <div class="column preparing">
        <div class="column-header">
          <div class="column-title">🍳 Dapur (Kitchen)</div>
          <div class="column-badge" id="badge-preparing">0</div>
        </div>
        <div class="orders-list" id="list-preparing">
          <div class="empty-state">
            <div class="empty-icon">🔥</div>
            <div>Dapur sedang kosong</div>
          </div>
        </div>
      </div>

      <!-- READY COLUMN -->
      <div class="column ready">
        <div class="column-header">
          <div class="column-title">🥞 Siap Diambil</div>
          <div class="column-badge" id="badge-ready">0</div>
        </div>
        <div class="orders-list" id="list-ready">
          <div class="empty-state">
            <div class="empty-icon"></div>
            <div>Belum ada hidangan siap diambil</div>
          </div>
        </div>
      </div>

      <!-- COMPLETED COLUMN -->
      <div class="column completed">
        <div class="column-header">
          <div class="column-title">✅ Selesai</div>
          <div class="column-badge" id="badge-completed">0</div>
        </div>
        <div class="orders-list" id="list-completed">
          <div class="empty-state">
            <div class="empty-icon">📦</div>
            <div>Belum ada pesanan selesai</div>
          </div>
        </div>
      </div>
    </div>
  </main>

  <!-- 2. PRODUCT MANAGEMENT VIEW -->
  <main class="view-panel" id="view-products">
    <div class="products-header">
      <div class="products-title-area">
        <h2>🥞 Product Catalog & Availability</h2>
        <p>Kelola harga, stok sisa, detail produk soufflé, kopi, dan atur ketersediaan menu secara dinamis (Terkoneksi ke Laravel API).</p>
      </div>
      <div>
        <button class="btn btn-secondary" onclick="fetchProducts()"><span style="font-size:14px;">🔄</span> Refresh List</button>
      </div>
    </div>
    
    <div class="products-grid" id="products-grid">
      <!-- Products dynamically loaded here -->
    </div>
  </main>

  <!-- 3. EDIT PRODUCT MODAL OVERLAY -->
  <div class="modal-overlay" id="product-modal">
    <div class="modal-container">
      <div class="modal-header">
        <h3 class="modal-title" id="modal-title">Edit Detail Produk</h3>
        <button class="modal-close-btn" onclick="closeModal()">×</button>
      </div>
      
      <div class="modal-body">
        <form id="product-edit-form">
          <input type="hidden" id="edit-prod-id">
          
          <div class="form-group">
            <label class="form-label" for="edit-prod-name">Nama Produk</label>
            <input class="form-control" type="text" id="edit-prod-name" required>
          </div>

          <div class="form-group">
            <label class="form-label" for="edit-prod-category">Kategori</label>
            <input class="form-control" type="text" id="edit-prod-category" required>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label" for="edit-prod-price">Harga (Rupiah)</label>
              <input class="form-control" type="number" id="edit-prod-price" min="0" required>
            </div>
            <div class="form-group">
              <label class="form-label" for="edit-prod-stock">Stok Produk (Pcs)</label>
              <input class="form-control" type="number" id="edit-prod-stock" min="0" required>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label" for="edit-prod-desc">Deskripsi Keterangan</label>
            <textarea class="form-control" id="edit-prod-desc" rows="3" required></textarea>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label class="form-label" for="edit-prod-status">Status Ketersediaan</label>
              <select class="form-control" id="edit-prod-status">
                <option value="available">Tersedia (Available)</option>
                <option value="sold_out">Habis Terjual (Sold Out)</option>
                <option value="seasonal">Musiman (Seasonal)</option>
              </select>
            </div>
            <div class="form-group">
              <label class="form-label" for="edit-prod-active">Visibilitas Menu</label>
              <select class="form-control" id="edit-prod-active">
                <option value="1">Tampilkan ke Pembeli</option>
                <option value="0">Sembunyikan dari Menu</option>
              </select>
            </div>
          </div>
        </form>
      </div>

      <div class="modal-footer">
        <button class="btn btn-secondary" onclick="closeModal()">Batal</button>
        <button class="btn" onclick="saveProductChanges()">Simpan Perubahan 💾</button>
      </div>
    </div>
  </div>

  <script>
    const API_BASE = window.location.origin;
    const LARAVEL_API = 'http://127.0.0.1:8000/api';
    let autoSimulate = true;

    // Switch View Panel
    function switchView(viewName) {
      const tabOrders = document.getElementById('tab-orders');
      const tabProducts = document.getElementById('tab-products');
      const viewOrders = document.getElementById('view-orders');
      const viewProducts = document.getElementById('view-products');

      if (viewName === 'orders') {
        tabOrders.classList.add('active');
        tabProducts.classList.remove('active');
        viewOrders.classList.add('active');
        viewProducts.classList.remove('active');
      } else {
        tabOrders.classList.remove('active');
        tabProducts.classList.add('active');
        viewOrders.classList.remove('active');
        viewProducts.classList.add('active');
        fetchProducts(); // Fetch latest from Laravel on switch
      }
    }

    // --- PRODUCTS API LOGIC ---
    let cachedProducts = [];

    async function fetchProducts() {
      const grid = document.getElementById('products-grid');
      try {
        const res = await fetch(`\${LARAVEL_API}/products`);
        const result = await res.json();
        
        if (result.success) {
          cachedProducts = result.data;
          renderProducts(cachedProducts);
        } else {
          showProductsConnectionError(result.message || 'Gagal memuat produk.');
        }
      } catch (err) {
        showProductsConnectionError('Tidak dapat terhubung ke Backend Laravel (Port 8000). Pastikan Anda sudah menjalankan "php artisan serve" di folder backend!');
      }
    }

    function showProductsConnectionError(msg) {
      const grid = document.getElementById('products-grid');
      grid.innerHTML = `
        <div class="error-card-connection">
          <span style="font-size:40px; margin-bottom:12px; display:block;">🔌</span>
          <h4 style="font-family:'Playfair Display', serif; font-size:18px; margin-bottom:8px; color:var(--accent);">Koneksi API Backend Terputus</h4>
          <p style="font-size:13px; color:var(--text-secondary); max-width:400px; margin: 0 auto; line-height:1.6;">\${msg}</p>
        </div>
      `;
    }

    function formatRupiah(num) {
      return 'Rp ' + Number(num).toLocaleString('id-ID');
    }

    function renderProducts(products) {
      const grid = document.getElementById('products-grid');
      grid.innerHTML = '';

      if (products.length === 0) {
        grid.innerHTML = `
          <div class="empty-state" style="grid-column: 1/-1; padding:50px;">
            <div class="empty-icon">🍽️</div>
            <div>Belum ada produk terdaftar di database</div>
          </div>
        `;
        return;
      }

      products.forEach(p => {
        const isSoldOut = p.availability_status === 'sold_out' || p.stock === 0;
        const isHidden = !p.is_active || p.is_active == 0;

        let statusBadge = '';
        if (isSoldOut) {
          statusBadge += `<span class="badge-status sold_out">❌ Sold Out</span>`;
        } else {
          statusBadge += `<span class="badge-status available">✅ Bisa Dipesan</span>`;
        }

        if (isHidden) {
          statusBadge += `<span class="badge-status hidden">👁️ Draft (Hidden)</span>`;
        } else {
          statusBadge += `<span class="badge-status active">🌐 Publik</span>`;
        }

        // Stock indicators
        let stockBadge = '';
        if (p.stock === 0) {
          stockBadge = `<span class="badge-status sold_out" style="border-style:dashed;">🚫 Habis (Stok: 0)</span>`;
        } else if (p.stock <= 5) {
          stockBadge = `<span class="badge-status" style="color:#FFA500; background:rgba(255,165,0,0.1); border-color:rgba(255,165,0,0.2);">⚠️ Stok Menipis: \${p.stock} pcs</span>`;
        } else {
          stockBadge = `<span class="badge-status" style="color:var(--text-secondary); background:rgba(255,255,255,0.03); border-color:var(--border);">📦 Stok: \${p.stock} pcs</span>`;
        }

        grid.innerHTML += `
          <div class="product-admin-card animate-in">
            <div class="product-admin-header">
              <div class="product-admin-info">
                <h3>\${p.name}</h3>
                <span class="category-badge">\${p.category}</span>
              </div>
              <div class="product-price-label">\${formatRupiah(p.base_price)}</div>
            </div>
            
            <p class="product-admin-desc">\${p.description || 'Tidak ada keterangan deskripsi.'}</p>
            
            <div class="product-admin-badges">
              \${statusBadge}
              \${stockBadge}
              \${p.is_best_seller ? '<span class="badge-status" style="background:rgba(232, 201, 160, 0.15); border-color:var(--gold-border); color:var(--gold-border);">⭐ Best Seller</span>' : ''}
            </div>

            <div class="product-admin-footer">
              <button class="btn btn-secondary" onclick="openEditModal(\${p.id})">Edit Detail 📝</button>
            </div>
          </div>
        `;
      });
    }

    // Modal Control
    function openEditModal(productId) {
      const p = cachedProducts.find(x => x.id === productId);
      if (!p) return;

      document.getElementById('edit-prod-id').value = p.id;
      document.getElementById('edit-prod-name').value = p.name;
      document.getElementById('edit-prod-category').value = p.category;
      document.getElementById('edit-prod-price').value = p.base_price;
      document.getElementById('edit-prod-stock').value = p.stock !== undefined ? p.stock : 10;
      document.getElementById('edit-prod-desc').value = p.description;
      document.getElementById('edit-prod-status').value = p.availability_status;
      document.getElementById('edit-prod-active').value = p.is_active ? "1" : "0";

      document.getElementById('product-modal').classList.add('active');
    }

    function closeModal() {
      document.getElementById('product-modal').classList.remove('active');
    }

    async function saveProductChanges() {
      const id = document.getElementById('edit-prod-id').value;
      const name = document.getElementById('edit-prod-name').value;
      const category = document.getElementById('edit-prod-category').value;
      const base_price = parseInt(document.getElementById('edit-prod-price').value);
      const stock = parseInt(document.getElementById('edit-prod-stock').value);
      const description = document.getElementById('edit-prod-desc').value;
      const availability_status = document.getElementById('edit-prod-status').value;
      const is_active = document.getElementById('edit-prod-active').value === "1";

      const payload = {
        name,
        category,
        base_price,
        stock,
        description,
        availability_status,
        is_active
      };

      try {
        const res = await fetch(`\${LARAVEL_API}/products/\${id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });

        const data = await res.json();
        
        if (data.success) {
          closeModal();
          fetchProducts(); // Refresh list dynamically
        } else {
          alert('Gagal menyimpan perubahan: ' + data.message);
        }
      } catch (err) {
        console.error('Error saving product:', err);
        alert('Terjadi kesalahan koneksi saat menyimpan perubahan.');
      }
    }

    // --- ORDERS API LOGIC ---
    async function fetchOrders() {
      try {
        const res = await fetch(`\${API_BASE}/api/orders`);
        const data = await res.json();
        renderOrders(data.orders);
      } catch (err) {
        console.error('Error fetching orders:', err);
      }
    }

    async function fetchSimulation() {
      try {
        const res = await fetch(`\${API_BASE}/api/simulation`);
        const data = await res.json();
        autoSimulate = data.autoSimulate;
        
        const toggle = document.getElementById('simulation-toggle');
        const label = document.getElementById('simulation-label');
        
        toggle.checked = autoSimulate;
        if (autoSimulate) {
          label.classList.add('active');
        } else {
          label.classList.remove('active');
        }
      } catch (err) {
        console.error('Error fetching simulation state:', err);
      }
    }

    async function toggleSimulation() {
      const toggle = document.getElementById('simulation-toggle');
      try {
        const res = await fetch(`\${API_BASE}/api/simulation/toggle`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ autoSimulate: toggle.checked })
        });
        fetchSimulation();
      } catch (err) {
        console.error('Error toggling simulation:', err);
      }
    }

    async function updateStatus(orderId, newStatus) {
      try {
        const res = await fetch(`\${API_BASE}/api/orders/update`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ id: orderId, status: newStatus })
        });
        fetchOrders();
      } catch (err) {
        console.error('Error updating order status:', err);
      }
    }

    function formatDate(dateStr) {
      try {
        const d = new Date(dateStr);
        return d.toLocaleTimeString('id-ID', { hour: '2-digit', minute: '2-digit' }) + ' • ' + d.toLocaleDateString('id-ID', { month: 'short', day: 'numeric' });
      } catch (e) {
        return dateStr;
      }
    }

    function createOrderCard(order) {
      const itemsHtml = order.items && order.items.length > 0
        ? order.items.map(item => `
            <div class="item-row">
              <span class="item-qty-name">\${item.quantity}x \${item.productName}</span>
              <span class="item-price">\$ \${(item.price * item.quantity).toFixed(2)}</span>
            </div>
          `).join('')
        : '<div style="font-size:11px;color:var(--text-secondary);">Simple historical item</div>';

      let actionButtonHtml = '';
      if (order.status === 'placed') {
        actionButtonHtml = `<button class="btn" onclick="updateStatus('\${order.id}', 'preparing')">Terima & Masak 🍳</button>`;
      } else if (order.status === 'preparing') {
        actionButtonHtml = `<button class="btn" onclick="updateStatus('\${order.id}', 'ready')">Mark as Ready 🥞</button>`;
      } else if (order.status === 'ready') {
        actionButtonHtml = `<button class="btn btn-secondary" onclick="updateStatus('\${order.id}', 'completed')">Selesaikan Pengambilan ✅</button>`;
      } else {
        actionButtonHtml = `<div class="completed-badge">✨ Selesai</div>`;
      }

      return `
        <div class="order-card animate-in">
          <div class="order-header">
            <span class="order-id">\${order.id}</span>
            <span class="order-time">\${formatDate(order.orderDate)}</span>
          </div>
          <span class="order-outlet">\${order.outletName.replace('Pluffy - ', '')}</span>
          <div class="order-items">
            \${itemsHtml}
          </div>
          <div class="order-footer">
            <div class="order-total">\$ \${order.total.toFixed(2)}</div>
            \${actionButtonHtml}
          </div>
        </div>
      `;
    }

    function renderOrders(orders) {
      const lists = {
        placed: document.getElementById('list-placed'),
        preparing: document.getElementById('list-preparing'),
        ready: document.getElementById('list-ready'),
        completed: document.getElementById('list-completed')
      };

      const badges = {
        placed: document.getElementById('badge-placed'),
        preparing: document.getElementById('badge-preparing'),
        ready: document.getElementById('badge-ready'),
        completed: document.getElementById('badge-completed')
      };

      const emptyStates = {
        placed: `<div class="empty-state"><div class="empty-icon">🛎️</div><div>Belum ada pesanan masuk</div></div>`,
        preparing: `<div class="empty-state"><div class="empty-icon">🔥</div><div>Dapur sedang kosong</div></div>`,
        ready: `<div class="empty-state"><div class="empty-icon">🥞</div><div>Belum ada hidangan siap diambil</div></div>`,
        completed: `<div class="empty-state"><div class="empty-icon">📦</div><div>Belum ada pesanan selesai</div></div>`
      };

      // Clear lists
      Object.keys(lists).forEach(k => {
        if (lists[k]) lists[k].innerHTML = '';
      });

      // Count map
      const counts = { placed: 0, preparing: 0, ready: 0, completed: 0 };

      orders.forEach(order => {
        const status = order.status;
        if (lists[status]) {
          lists[status].innerHTML += createOrderCard(order);
          counts[status]++;
        }
      });

      // Populate badges
      Object.keys(badges).forEach(k => {
        if (badges[k]) {
          badges[k].textContent = counts[k];
          if (counts[k] === 0) {
            lists[k].innerHTML = emptyStates[k];
          }
        }
      });
    }

    // Initial load
    fetchSimulation();
    fetchOrders();

    // Poll every 1.5 seconds for orders (only if on orders tab)
    setInterval(() => {
      const tabOrders = document.getElementById('tab-orders');
      if (tabOrders && tabOrders.classList.contains('active')) {
        fetchOrders();
      }
      fetchSimulation();
    }, 1500);
  </script>
</body>
</html>''';
}
