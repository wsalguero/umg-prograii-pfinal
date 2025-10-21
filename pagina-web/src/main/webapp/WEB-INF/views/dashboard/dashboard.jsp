<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List,java.util.Map" %>  <!-- 👈 IMPORTS NECESARIOS -->

<%
  // 🔒 Verificar login
  Object user = session.getAttribute("user");
  if (user == null) {
      response.sendRedirect(request.getContextPath() + "/login");
      return;
  }
  request.setAttribute("title", "Dashboard");
  request.setAttribute("active", "dashboard");
%>
<%@ include file="/WEB-INF/layouts/header.jspf" %>

<%
  String flash = (String) session.getAttribute("flash_error");
  if (flash != null) {
%>
  <div class="alert alert-danger" role="alert"><%= flash %></div>
<%
    session.removeAttribute("flash_error");
  }
%>

<%
  long kFree   = (request.getAttribute("kpi_free_rooms")   != null) ? (Long) request.getAttribute("kpi_free_rooms")   : 0L;
  int  kOcc    = (request.getAttribute("kpi_occupancy")    != null) ? (Integer) request.getAttribute("kpi_occupancy")  : 0;
  long kCheck  = (request.getAttribute("kpi_checkins")     != null) ? (Long) request.getAttribute("kpi_checkins")     : 0L;
  long kRev    = (request.getAttribute("kpi_revenue")      != null) ? (Long) request.getAttribute("kpi_revenue")      : 0L;

  // 👇 OBTENER TODAS LAS LISTAS CON LOS NOMBRES DE ATRIBUTO CORRECTOS
  List<Map<String,Object>> recentGuests =
      (List<Map<String,Object>>) request.getAttribute("recent_guests");
  List<Map<String,Object>> freeRoomsList =
      (List<Map<String,Object>>) request.getAttribute("free_rooms_list");
  List<Map<String,Object>> recentReceipts =
      (List<Map<String,Object>>) request.getAttribute("recent_receipts");
%>

<link rel="stylesheet" href="<%=request.getContextPath()%>/assets/styles/pages/dashboard.css">

<section class="container my-4">

  <!-- KPIs -->
  <div class="row g-3 mb-3">
    <div class="col-6 col-md-3">
      <div class="card shadow-sm h-100">
        <div class="card-body d-flex align-items-center">
          <i class="fa-solid fa-bed fa-2xl me-3 text-primary"></i>
          <div>
            <div class="fw-semibold text-secondary">Hab. disponibles</div>
            <div class="h4 mb-0" id="kpi-rooms-free"><%= kFree %></div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm h-100">
        <div class="card-body">
          <div class="d-flex align-items-center">
            <i class="fa-solid fa-layer-group fa-2xl me-3 text-info"></i>
            <div class="w-100">
              <div class="fw-semibold text-secondary">Ocupación</div>
              <div class="d-flex align-items-center gap-2">
                <span class="h5 mb-0" id="kpi-occupancy"><%= kOcc %>%</span>
                <div class="progress flex-grow-1" style="height:8px;">
                <div class="progress-bar" style="width:<%= kOcc %>%"></div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm h-100">
        <div class="card-body d-flex align-items-center">
          <i class="fa-solid fa-user-check fa-2xl me-3 text-success"></i>
          <div>
            <div class="fw-semibold text-secondary">Check-ins hoy</div>
            <div class="h4 mb-0" id="kpi-checkins"><%= kCheck %></div>
          </div>
        </div>
      </div>
    </div>
    <div class="col-6 col-md-3">
      <div class="card shadow-sm h-100">
        <div class="card-body d-flex align-items-center">
          <i class="fa-solid fa-dollar-sign fa-2xl me-3 text-warning"></i>
          <div>
            <div class="fw-semibold text-secondary">Ingresos (hoy)</div>
            <div class="h4 mb-0" id="kpi-revenue">Q <%= kRev %></div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- Acciones rápidas -->
  <div class="card mb-4 shadow-sm">
    <div class="card-body">
      <div class="d-flex flex-wrap gap-2 justify-content-center">
        <a href="<%= request.getContextPath() %>/guests" class="btn btn-primary">
          <i class="fa-solid fa-users me-2"></i> Ver huéspedes
        </a>
        <a href="<%= request.getContextPath() %>/rooms" class="btn btn-info text-white">
          <i class="fa-solid fa-bed me-2"></i> Ver habitaciones
        </a>
        <a href="<%= request.getContextPath() %>/registers" class="btn btn-success">
          <i class="fa-solid fa-file-invoice-dollar me-2"></i> Ver recibos
        </a>
        <a href="<%= request.getContextPath() %>/billing" class="btn btn-warning text-white">
          <i class="fa-solid fa-file-invoice-dollar me-2"></i> Facturar
        </a>
        <button class="btn btn-outline-success" data-bs-toggle="modal" data-bs-target="#modalReservation">
          <i class="fa-solid fa-calendar-plus me-2"></i> Nueva reservación
        </button>
      </div>
    </div>
  </div>

  <!-- 2 columnas: tablas -->
  <div class="row g-4">
    <!-- Huéspedes recientes -->
    <div class="col-lg-6">
      <div class="card shadow-sm h-100">
        <div class="card-header bg-white">
          <i class="fa-solid fa-user-clock me-2 text-primary"></i>
          Huéspedes recientes
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>Nombre</th>
                  <th>Habitación</th>
                  <th>Entrada</th>
                  <th class="text-end">Acciones</th>
                </tr>
              </thead>
              <tbody>
              <% if (recentGuests == null || recentGuests.isEmpty()) { %>
                <tr><td colspan="4" class="text-center text-muted py-4">No hay huéspedes recientes.</td></tr>
              <% } else {
                  for (Map<String,Object> g : recentGuests) {
                    String nombre = String.valueOf(g.get("firstname"));
                    String sn     = String.valueOf(g.get("secondname"));
                    String ap1    = String.valueOf(g.get("lastname1"));
                    String ap2    = String.valueOf(g.get("lastname2"));
                    String hab    = String.valueOf(g.get("room"));
                    String fecha  = String.valueOf(g.get("checkin_date"));
              %>
                <tr>
                  <td><%= (nombre + " " + (sn==null?"":sn) + " " + (ap1==null?"":ap1) + " " + (ap2==null?"":ap2)).trim() %></td>
                  <td><%= hab %></td>
                  <td><%= fecha %></td>
                  <td class="text-end">
                    <a href="#" class="btn btn-sm btn-outline-secondary"><i class="fa-solid fa-eye"></i></a>
                  </td>
                </tr>
              <% } } %>
              </tbody>
            </table>
          </div>
        </div>
        <div class="card-footer bg-white text-end">
          <a href="/guests" class="btn btn-sm btn-link">Ver todos</a>
        </div>
      </div>
    </div>


    <!-- Habitaciones disponibles -->
    <div class="col-lg-6">
      <div class="card shadow-sm h-100">
        <div class="card-header bg-white">
          <i class="fa-solid fa-door-open me-2 text-success"></i>
          Habitaciones disponibles
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>#</th><th>Tipo</th><th>Tarifa</th>
                  <th class="text-center">Estado</th><th class="text-end">Acciones</th>
                </tr>
              </thead>
              <tbody id="tbl-free-rooms">
              <% if (freeRoomsList == null || freeRoomsList.isEmpty()) { %>
                <tr><td colspan="5" class="text-center text-muted py-4">No hay habitaciones libres.</td></tr>
              <% } else {
                  for (Map<String,Object> r : freeRoomsList) {
                    String num   = String.valueOf(r.get("room_number"));
                    String type  = String.valueOf(r.get("room_type"));
                    String price = String.valueOf(r.get("price"));
              %>
                <tr>
                  <td><%= num %></td>
                  <td><%= type %></td>
                  <td>Q <%= price %> /noche</td>
                  <td class="text-center"><span class="badge text-bg-success">Libre</span></td>
                  <td class="text-end"><a href="#" class="btn btn-sm btn-outline-secondary"><i class="fa-solid fa-eye"></i></a></td>
                </tr>
              <% } } %>
              </tbody>
            </table>
          </div>
        </div>
        <div class="card-footer bg-white text-end">
          <a href="/rooms" class="btn btn-sm btn-link">Ver todas</a>
        </div>
      </div>
    </div>


    <!-- Recibos recientes (fila completa) -->
    <div class="col-12">
      <div class="card shadow-sm">
        <div class="card-header bg-white">
          <i class="fa-solid fa-receipt me-2 text-warning"></i>
          Recibos recientes
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-striped align-middle mb-0">
              <thead class="table-light">
                <tr>
                  <th>#</th>
                  <th>Huésped</th>
                  <th>Fecha</th>
                  <th>Total</th>
                  <th class="text-end">Acciones</th>
                </tr>
              </thead>
              <tbody id="tbl-recent-receipts">
<% if (recentReceipts == null || recentReceipts.isEmpty()) { %>
  <tr><td colspan="5" class="text-center text-muted py-4">No hay recibos recientes.</td></tr>
<% } else {
     for (Map<String,Object> r : recentReceipts) {
       String num   = String.valueOf(r.get("num"));
       String guest = String.valueOf(r.get("guest_name"));
       String fecha = String.valueOf(r.get("bills_date"));
       String total = String.valueOf(r.get("total"));
%>
  <tr>
    <td><%= num %></td>
    <td><%= guest %></td>
    <td><%= fecha %></td>
    <td>Q <%= total %></td>
    <td class="text-end">
      <a href="#" class="btn btn-sm btn-outline-secondary"><i class="fa-solid fa-eye"></i></a>
      <a href="#" class="btn btn-sm btn-outline-primary"><i class="fa-solid fa-file-pdf"></i></a>
    </td>
  </tr>
<%   } } %>
</tbody>
            </table>
          </div>
        </div>
        <div class="card-footer bg-white text-end">
          <a href="<%= request.getContextPath() %>/registers" class="btn btn-sm btn-link">Ver todos</a>
        </div>
      </div>
    </div>
  </div>
</section>


<!-- Modal: Nueva reservación -->
<div class="modal fade" id="modalReservation" tabindex="-1" aria-labelledby="lblReservation" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <form class="modal-content" method="POST" action="<%=request.getContextPath()%>/reservations" id="formReservation">
      <input type="hidden" name="action" value="create">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="lblReservation">
          <i class="fa-solid fa-calendar-check me-2"></i> Nueva reservación / check-in
        </h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <div class="modal-body">
        <!-- Huésped -->
        <div class="card mb-3">
          <div class="card-header bg-white fw-semibold"><i class="fa-solid fa-user me-2"></i>Huésped</div>
          <div class="card-body">
            <div class="row g-3">

              <!-- Opción: seleccionar existente -->
              <div class="col-12">
                <label class="form-label">Huésped existente (opcional)</label>
                <input class="form-control" name="existing_user_id" placeholder="ID de huésped (déjalo vacío si es nuevo)">
                <div class="form-text">Si lo dejas vacío, se creará un huésped nuevo con los datos de abajo.</div>
              </div>

              <!-- Nuevo huésped -->
              <div class="col-md-6">
                <label class="form-label">Primer nombre</label>
                <input class="form-control" name="firstname">
              </div>
              <div class="col-md-6">
                <label class="form-label">Segundo nombre</label>
                <input class="form-control" name="secondname">
              </div>
              <div class="col-md-6">
                <label class="form-label">Primer apellido</label>
                <input class="form-control" name="firstlastname">
              </div>
              <div class="col-md-6">
                <label class="form-label">Segundo apellido</label>
                <input class="form-control" name="secondlastname">
              </div>
              <div class="col-md-6">
                <label class="form-label">Email</label>
                <input type="email" class="form-control" name="email">
              </div>
              <div class="col-md-6">
                <label class="form-label">Teléfono / Dirección (opcional)</label>
                <input class="form-control" name="user_address">
              </div>
              <div class="col-md-6">
                <label class="form-label">DPI</label>
                <input class="form-control" name="dpi">
              </div>
              <div class="col-md-6">
                <label class="form-label">NIT</label>
                <input class="form-control" name="nit" placeholder="CF si no aplica">
              </div>
            </div>
          </div>
        </div>

        <!-- Habitación / Fechas -->
        <div class="card">
          <div class="card-header bg-white fw-semibold"><i class="fa-solid fa-bed me-2"></i>Habitación</div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label">Habitación libre</label>
                <select class="form-select" name="room_id" id="res-room" required>
                  <option value="">Selecciona…</option>
                  <% if (freeRoomsList != null) {
                       for (Map<String,Object> r : freeRoomsList) { %>
                    <option 
                      value="<%= r.get("room_number") %>"
                      data-price="<%= r.get("price") %>">
                      #<%= r.get("room_number") %> — <%= r.get("room_type") %> — Q <%= r.get("price") %>/noche
                    </option>
                  <% } } %>
                </select>
              </div>
              <div class="col-md-3">
                <label class="form-label">Entrada</label>
                <input type="date" class="form-control" name="checkin" id="res-checkin" required>
              </div>
              <div class="col-md-3">
                <label class="form-label">Salida</label>
                <input type="date" class="form-control" name="checkout" id="res-checkout" required>
              </div>
              <div class="col-md-4">
                <label class="form-label">Noches</label>
                <input class="form-control" name="nights" id="res-nights" value="1" readonly>
              </div>
              <div class="col-md-4">
                <label class="form-label">Tarifa (Q)</label>
                <input class="form-control" id="res-price" value="0" readonly>
              </div>
              <div class="col-md-4">
                <label class="form-label">Total estimado (Q)</label>
                <input class="form-control" name="amount" id="res-total" value="0" readonly>
              </div>
              <div class="col-12">
                <label class="form-label">Detalle</label>
                <input class="form-control" name="detail" placeholder="Check-in reservación">
              </div>
            </div>
          </div>
        </div>

      </div>

      <div class="modal-footer">
        <button class="btn btn-success">
          <i class="fa-solid fa-circle-check me-1"></i> Confirmar reservación
        </button>
      </div>
    </form>
  </div>
</div>

<script>
  // abrir modal desde los botones rápidos (puedes poner un botón en tarjetas)
  // new bootstrap.Modal(document.getElementById('modalReservation')).show();

  const selRoom   = document.getElementById('res-room');
  const inDate    = document.getElementById('res-checkin');
  const outDate   = document.getElementById('res-checkout');
  const nights    = document.getElementById('res-nights');
  const price     = document.getElementById('res-price');
  const total     = document.getElementById('res-total');

  function daysDiff(a,b){
    if(!a || !b) return 0;
    const d1 = new Date(a), d2 = new Date(b);
    const ms = (d2 - d1);
    return Math.max(0, Math.ceil(ms / (1000*60*60*24)));
  }

  function recalc(){
    const n  = daysDiff(inDate.value, outDate.value) || 1;
    const p  = parseFloat(selRoom.options[selRoom.selectedIndex]?.dataset.price || 0);
    nights.value = n;
    price.value  = p.toFixed(2);
    total.value  = (n * p).toFixed(2);
  }

  selRoom.addEventListener('change', recalc);
  inDate.addEventListener('change', recalc);
  outDate.addEventListener('change', recalc);
</script>


<script type="text/javascript">

  document.getElementById("btn-cf").addEventListener("click", function (el) {
    el.preventDefault();

    const input = document.getElementById("inp-nit");

    if (input.value === "CF") {
      input.removeAttribute("disabled");
      input.value = "";

      return;
    } else {
      input.setAttribute("disabled", "true");
      input.value = "CF";

      return;
    }
  });

 </script>


<%@ include file="/WEB-INF/layouts/footer.jspf" %>

