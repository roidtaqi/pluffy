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
      padding: 20px 40px;
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

    .controls {
      display: flex;
      align-items: center;
      gap: 28px;
    }

    /* Premium Simulation Switch */
    .switch-container {
      display: flex;
      align-items: center;
      gap: 12px;
      background: rgba(255, 255, 255, 0.03);
      padding: 10px 18px;
      border-radius: 20px;
      border: 1px solid var(--border);
    }

    .switch-label {
      font-size: 13px;
      font-weight: 500;
      color: var(--text-secondary);
    }

    .switch-label.active {
      color: var(--accent);
    }

    .switch {
      position: relative;
      display: inline-block;
      width: 46px;
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
      background-color: #33201C;
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
      transform: translateX(22px);
      background-color: var(--accent);
    }

    .server-status {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 13px;
      font-weight: 600;
      color: var(--success);
      background: rgba(78, 125, 86, 0.08);
      padding: 8px 16px;
      border-radius: 12px;
      border: 1px solid rgba(78, 125, 86, 0.2);
    }

    .server-dot {
      width: 8px;
      height: 8px;
      background-color: var(--success);
      border-radius: 50%;
      animation: pulse 1.8s infinite;
    }

    @keyframes pulse {
      0% {
        transform: scale(0.95);
        box-shadow: 0 0 0 0 rgba(78, 125, 86, 0.7);
      }
      70% {
        transform: scale(1);
        box-shadow: 0 0 0 6px rgba(78, 125, 86, 0);
      }
      100% {
        transform: scale(0.95);
        box-shadow: 0 0 0 0 rgba(78, 125, 86, 0);
      }
    }

    .dashboard {
      flex: 1;
      padding: 40px;
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 24px;
      max-width: 1600px;
      width: 100%;
      margin: 0 auto;
    }

    .column {
      display: flex;
      flex-direction: column;
      background-color: var(--card-bg);
      border-radius: 24px;
      border: 1.5px solid var(--border);
      padding: 20px;
      height: calc(100vh - 180px);
      min-height: 500px;
      box-shadow: var(--shadow);
    }

    .column-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      padding-bottom: 12px;
      border-bottom: 1.5px solid var(--border);
    }

    .column-title {
      font-size: 16px;
      font-weight: 700;
      letter-spacing: 0.5px;
      color: var(--text-main);
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .column-badge {
      background: var(--border);
      color: var(--accent);
      font-size: 12px;
      font-weight: 700;
      padding: 3px 10px;
      border-radius: 12px;
      min-width: 26px;
      text-align: center;
    }

    .column.placed .column-title { color: #F4A58A; }
    .column.preparing .column-title { color: #E8C9A0; }
    .column.ready .column-title { color: var(--accent); }
    .column.completed .column-title { color: var(--success); }

    .orders-list {
      flex: 1;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
      gap: 16px;
      padding-right: 4px;
    }

    .order-card {
      background-color: rgba(255, 255, 255, 0.015);
      border: 1px solid var(--border);
      border-radius: 16px;
      padding: 16px;
      transition: all 0.3s cubic-bezier(0.16, 1, 0.3, 1);
      display: flex;
      flex-direction: column;
      gap: 12px;
    }

    .order-card:hover {
      background-color: var(--card-hover);
      transform: translateY(-2px);
      border-color: var(--gold-border);
    }

    .order-header {
      display: flex;
      justify-content: space-between;
      align-items: start;
    }

    .order-id {
      font-size: 14px;
      font-weight: 700;
      color: var(--accent);
    }

    .order-time {
      font-size: 11px;
      color: var(--text-secondary);
    }

    .order-outlet {
      font-size: 11px;
      font-weight: 600;
      color: var(--text-secondary);
      background-color: rgba(255, 255, 255, 0.04);
      padding: 4px 8px;
      border-radius: 8px;
      align-self: flex-start;
      margin-top: -4px;
    }

    .order-items {
      border-top: 1px dashed var(--border);
      border-bottom: 1px dashed var(--border);
      padding: 10px 0;
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
      font-weight: 600;
    }

    .order-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 4px;
    }

    .order-total {
      font-size: 14px;
      font-weight: 800;
      color: var(--text-main);
    }

    .btn {
      background-color: var(--primary);
      color: var(--accent);
      border: 1px solid rgba(232, 201, 160, 0.3);
      padding: 8px 16px;
      border-radius: 10px;
      font-size: 12px;
      font-weight: 700;
      cursor: pointer;
      transition: all 0.2s ease;
      display: flex;
      align-items: center;
      gap: 6px;
      box-shadow: 0 4px 12px rgba(155, 27, 27, 0.15);
    }

    .btn:hover {
      background-color: #B82F2F;
      transform: scale(1.03);
      box-shadow: 0 4px 16px rgba(155, 27, 27, 0.3);
    }

    .btn-secondary {
      background-color: #33201C;
      color: var(--accent);
      border: 1px solid var(--border);
      box-shadow: none;
    }

    .btn-secondary:hover {
      background-color: #4A302B;
      box-shadow: none;
    }

    .completed-badge {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 11px;
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

    /* Animate order drop in */
    @keyframes fadeInUp {
      from {
        opacity: 0;
        transform: translateY(8px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .animate-in {
      animation: fadeInUp 0.4s cubic-bezier(0.16, 1, 0.3, 1) both;
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

  <main class="dashboard">
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
          <div class="empty-icon">🔔</div>
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
  </main>

  <script>
    const API_BASE = window.location.origin;
    let autoSimulate = true;

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
        lists[k].innerHTML = '';
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
        badges[k].textContent = counts[k];
        if (counts[k] === 0) {
          lists[k].innerHTML = emptyStates[k];
        }
      });
    }

    // Initial load
    fetchSimulation();
    fetchOrders();

    // Poll every 1.5 seconds
    setInterval(() => {
      fetchOrders();
      fetchSimulation();
    }, 1500);
  </script>
</body>
</html>''';
}
