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
          <i class="fa-solid fa-file-invoice-dollar me-2"></i> Registros
        </a>
        <a href="<%= request.getContextPath() %>/billing" class="btn btn-warning text-white">
          <i class="fa-solid fa-file-invoice-dollar me-2"></i> Facturar
        </a>
           <a href="<%= request.getContextPath() %>/history" class="btn btn-info text-white">
          <i class="fa-solid fa-file-invoice-dollar me-2"></i> Historial
        </a>
        <button class="btn btn-outline-warning" data-bs-toggle="modal" data-bs-target="#modalReservation">
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
                  <th class="text-center">Estado</th>
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
    <form class="modal-content needs-validation" novalidate
          method="POST" action="<%=request.getContextPath()%>/reservations" id="formReservation">
      <input type="hidden" name="action" value="create">
      <input type="hidden" name="type_room_id" id="res-type-room-id" required>

      <div class="modal-header">
        <h1 class="modal-title fs-5" id="lblReservation">
          <i class="fa-solid fa-calendar-check me-2"></i> Nueva reservación / check-in
        </h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <div class="modal-body">

        <!-- Huésped -->
        <div class="card mb-3">
          <div class="card-header bg-white fw-semibold">
            <i class="fa-solid fa-user me-2"></i>Huésped
          </div>
          <div class="card-body">
            <div class="row g-3">

              <!-- Huésped existente (opcional) -->
              <div class="col-12">
                <label class="form-label">Huésped existente (opcional)</label>
                <input class="form-control" name="existing_user_id" id="res-existing-user"
                       placeholder="ID de huésped (déjalo vacío si es nuevo)" pattern="^\d*$">
                <div class="form-text">Si lo dejas vacío, se creará un huésped nuevo con los datos de abajo.</div>
              </div>

              <!-- Datos para crear huésped nuevo -->
              <div class="col-md-6">
                <label class="form-label">Primer nombre</label>
                <input class="form-control res-new-required" name="firstname" id="res-firstname" required>
                <div class="invalid-feedback">Requerido.</div>
              </div>
              <div class="col-md-6">
                <label class="form-label">Segundo nombre</label>
                <input class="form-control" name="secondname">
              </div>
              <div class="col-md-6">
                <label class="form-label">Primer apellido</label>
                <input class="form-control res-new-required" name="lastname1" id="res-lastname1" required>
                <div class="invalid-feedback">Requerido.</div>
              </div>
              <div class="col-md-6">
                <label class="form-label">Segundo apellido</label>
                <input class="form-control" name="lastname2">
              </div>
              <div class="col-md-6">
                <label class="form-label">Email</label>
                <input type="email" class="form-control" name="email" id="res-email">
              </div>
              <div class="col-md-6">
                <label class="form-label">Dirección / Teléfono (opcional)</label>
                <input class="form-control" name="address">
              </div>
              <div class="col-md-6">
                <label class="form-label">DPI</label>
                <input class="form-control" name="dpi">
              </div>
              <div class="col-md-6">
                <label class="form-label">NIT</label>
                <input class="form-control" name="nit" placeholder="CF si no aplica">
              </div>
              <div class="col-md-6">
                <label class="form-label">Teléfono</label>
                <input class="form-control" name="phone">
              </div>
            </div>
          </div>
        </div>

        <!-- Habitación / Fechas -->
        <div class="card">
          <div class="card-header bg-white fw-semibold">
            <i class="fa-solid fa-bed me-2"></i>Habitación
          </div>
          <div class="card-body">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label">Habitación libre</label>
                <select class="form-select" name="room_id" id="res-room" required>
                  <option value="">Selecciona…</option>
                  <% if (freeRoomsList != null) {
                       for (Map<String,Object> r : freeRoomsList) {
                         String idRoom   = String.valueOf(r.get("id"));          // ID real
                         String numRoom  = String.valueOf(r.get("room_number"));
                         String typeName = String.valueOf(r.get("room_type"));
                         String typeId   = String.valueOf(r.get("id_type"));
                         String price    = String.valueOf(r.get("price"));
                  %>
                    <option value="<%= idRoom %>"
                            data-typeid="<%= typeId %>"
                            data-price="<%= price %>">
                      #<%= numRoom %> — <%= typeName %> — Q <%= price %>/noche
                    </option>
                  <% } } %>
                </select>
                <div class="invalid-feedback">Elige una habitación.</div>
              </div>

              <div class="col-md-3">
                <label class="form-label">Entrada</label>
                <input type="date" class="form-control" name="checkin" id="res-checkin" required>
                <div class="invalid-feedback">Fecha de entrada requerida.</div>
              </div>
              <div class="col-md-3">
                <label class="form-label">Salida</label>
                <input type="date" class="form-control" name="checkout" id="res-checkout" required>
                <div class="invalid-feedback">Fecha de salida requerida.</div>
              </div>

              <div class="col-md-4">
                <label class="form-label">Noches</label>
                <input class="form-control" id="res-nights" value="1" readonly>
              </div>
              <div class="col-md-4">
                <label class="form-label">Tarifa (Q)</label>
                <input class="form-control" id="res-price" value="0" readonly>
              </div>
              <div class="col-md-4">
                <label class="form-label">Total estimado (Q)</label>
                <input class="form-control" name="amount" id="res-total" value="0" readonly required>
              </div>

              <div class="col-12">
                <label class="form-label">Detalle</label>
                <input class="form-control" name="detail" id="res-detail" placeholder="Check-in reservación" required>
                <div class="invalid-feedback">Detalle requerido.</div>
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
(() => {
  const form     = document.getElementById('formReservation');
  const selRoom  = document.getElementById('res-room');
  const typeId   = document.getElementById('res-type-room-id');
  const checkin  = document.getElementById('res-checkin');
  const checkout = document.getElementById('res-checkout');
  const nights   = document.getElementById('res-nights');
  const price    = document.getElementById('res-price');
  const total    = document.getElementById('res-total');
  const detail   = document.getElementById('res-detail');
  const existing = document.getElementById('res-existing-user');
  const newReqs  = document.querySelectorAll('.res-new-required');

  // fechas mínimas hoy
  const today = new Date().toISOString().slice(0,10);
  checkin.min = today; checkout.min = today;

  function parseD(v){ return v ? new Date(v+'T00:00:00') : null; }
  function diffN(a,b){
    if(!a||!b) return 1;
    const d = Math.ceil((b-a)/86400000);
    return d > 0 ? d : 1;
  }
  function recalc(){
    const opt = selRoom.selectedOptions[0];
    if (opt){
      typeId.value = opt.dataset.typeid || '';
      price.value  = opt.dataset.price || 0;
    }
    const n = diffN(parseD(checkin.value), parseD(checkout.value));
    nights.value = n;
    total.value  = (parseFloat(price.value||0) * n).toFixed(2);
    if(!detail.value){
      const rn = opt ? opt.textContent.split('—')[0].trim() : '';
      detail.value = rn + ' (' + n + ' noche/s) @Q' + (price.value || 0);
    }
  }

  selRoom.addEventListener('change', recalc);
  checkin.addEventListener('change', recalc);
  checkout.addEventListener('change', recalc);

  // Si hay ID de huésped, desactivar requeridos del nuevo huésped
  existing.addEventListener('input', () => {
    const hasId = existing.value.trim().length > 0;
    newReqs.forEach(i => { i.required = !hasId; });
  });

  // Validación Bootstrap/HTML5
  form.addEventListener('submit', (e) => {
    recalc(); // asegurar totales
    // si no hay habitacion o type_id, invalidar
    if (!selRoom.value || !typeId.value) {
      e.preventDefault(); e.stopPropagation();
      selRoom.classList.add('is-invalid');
      return;
    }
    // si no hay huésped existente, exigir nombre y apellido
    if (!existing.value.trim()) {
      let ok = true;
      newReqs.forEach(i => { if(!i.value.trim()) ok = false; });
      if (!ok) { e.preventDefault(); e.stopPropagation(); }
    }
    if (!form.checkValidity()) {
      e.preventDefault(); e.stopPropagation();
    }
    form.classList.add('was-validated');
  });
})();
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

