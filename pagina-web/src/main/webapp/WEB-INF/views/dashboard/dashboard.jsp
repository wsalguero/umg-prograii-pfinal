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


<!-- Modales -->
<!-- Modal: Agregar Huésped -->
<div class="modal fade" id="modalAddGuest" tabindex="-1" aria-labelledby="lblAddGuest" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="lblAddGuest">
          <i class="fa-solid fa-user-plus me-2"></i>Crear huésped
        </h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <div class="modal-body">
        <form class="row g-3 needs-validation" novalidate id="formAddGuest">
          <div class="col-md-6">
            <label for="g-firstname" class="form-label">Primer nombre</label>
            <input id="g-firstname" class="form-control" required>
            <div class="invalid-feedback">Requerido.</div>
          </div>
          <div class="col-md-6">
            <label for="g-secondname" class="form-label">Segundo nombre</label>
            <input id="g-secondname" class="form-control">
          </div>
          <div class="col-md-6">
            <label for="g-lastname1" class="form-label">Primer apellido</label>
            <input id="g-lastname1" class="form-control" required>
            <div class="invalid-feedback">Requerido.</div>
          </div>
          <div class="col-md-6">
            <label for="g-lastname2" class="form-label">Segundo apellido</label>
            <input id="g-lastname2" class="form-control">
          </div>
          <div class="col-md-6">
            <label for="g-email" class="form-label">Email</label>
            <input id="g-email" type="email" class="form-control" placeholder="ejemplo@ejemplo.com">
          </div>
          <div class="col-md-6">
            <label for="g-phone" class="form-label">Teléfono</label>
            <input id="g-phone" class="form-control" placeholder="+502 5555 5555">
          </div>
          <div class="col-12">
            <label for="g-address" class="form-label">Dirección</label>
            <input id="g-address" class="form-control" placeholder="Dirección">
          </div>
          <div class="col-md-6">
            <label for="g-dpi" class="form-label">DPI</label>
            <input id="g-dpi" class="form-control">
          </div>
          <div class="col-md-6">
            <label for="g-nit" class="form-label">NIT</label>
            <div class="input-group">
              <input id="g-nit" class="form-control" placeholder="CF si no aplica">
              <button class="btn btn-outline-secondary" type="button" id="btn-cf">
                <i class="fa-solid fa-id-card"></i>
              </button>
            </div>
          </div>
          <div class="col-12 text-end">
            <button class="btn btn-primary">
              <i class="fa-solid fa-floppy-disk me-1"></i> Crear
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Modal: Agregar Habitación -->
<div class="modal fade" id="modalAddRoom" tabindex="-1" aria-labelledby="lblAddRoom" aria-hidden="true">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="lblAddRoom">
          <i class="fa-solid fa-bed-pulse me-2"></i>Nueva habitación
        </h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <div class="modal-body">
        <form class="row g-3" id="formAddRoom">
          <div class="col-md-4">
            <label for="r-number" class="form-label">N°</label>
            <input id="r-number" class="form-control" required>
          </div>
          <div class="col-md-4">
            <label for="r-type" class="form-label">Tipo</label>
            <select id="r-type" class="form-select">
              <option>Single</option>
              <option>Queen</option>
              <option>King</option>
              <option>Suite</option>
            </select>
          </div>
          <div class="col-md-4">
            <label for="r-rate" class="form-label">Tarifa (Q/noche)</label>
            <input id="r-rate" type="number" min="0" class="form-control" value="350">
          </div>
          <div class="col-12 text-end">
            <button class="btn btn-info text-white">
              <i class="fa-solid fa-floppy-disk me-1"></i> Guardar
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Modal: Nuevo recibo -->
<div class="modal fade" id="modalAddReceipt" tabindex="-1" aria-labelledby="lblAddReceipt" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="lblAddReceipt">
          <i class="fa-solid fa-file-circle-plus me-2"></i>Nuevo recibo
        </h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <div class="modal-body">
        <form class="row g-3" id="formAddReceipt">
          <div class="col-12">
            <label for="rcp-guest" class="form-label">Huésped</label>
            <input id="rcp-guest" class="form-control" placeholder="Nombre del huésped">
          </div>
          <div class="col-6">
            <label for="rcp-date" class="form-label">Fecha</label>
            <input id="rcp-date" type="date" class="form-control">
          </div>
          <div class="col-6">
            <label for="rcp-total" class="form-label">Total (Q)</label>
            <input id="rcp-total" type="number" min="0" class="form-control">
          </div>
          <div class="col-12 text-end">
            <button class="btn btn-success">
              <i class="fa-solid fa-floppy-disk me-1"></i> Crear recibo
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>


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

