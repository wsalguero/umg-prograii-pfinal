<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.umg.models.Rooms, com.umg.models.TypesRooms" %>
<%
  request.setAttribute("title", "Habitaciones");
  request.setAttribute("active", "rooms");
  List<Rooms> rooms = (List<Rooms>) request.getAttribute("rooms");
  List<TypesRooms> types = (List<TypesRooms>) request.getAttribute("types");
  Map<Integer,String> typeNames = (Map<Integer,String>) request.getAttribute("typeNames");
%>
<%@ include file="/WEB-INF/layouts/header.jspf" %>

<link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">

<div class="container my-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3><i class="fa-solid fa-bed me-2 text-info"></i>Habitaciones</h3>
    <button class="btn btn-info text-white" data-bs-toggle="modal" data-bs-target="#addModal">
      <i class="fa-solid fa-bed-pulse me-1"></i> Nueva habitación
    </button>
  </div>

  <table id="tblRooms" class="display table table-striped w-100">
    <thead>
      <tr>
        <th>N°</th>
        <th>Tipo</th>
        <th>Descripción</th>
        <th>Tarifa (Q)</th>
        <th>Estado</th>
        <th style="width:140px;">Acciones</th>
      </tr>
    </thead>
    <tbody>
      <% if (rooms != null) {
           for (Rooms r : rooms) {
             String tipo = typeNames != null ? typeNames.getOrDefault(r.getIdType(), "—") : ("#" + r.getIdType());
             String estadoTxt, estadoClass;
             if (r.getStatus() == 1) { estadoTxt = "Libre"; estadoClass = "text-bg-success"; }
             else if (r.getStatus() == 2) { estadoTxt = "Ocupada"; estadoClass = "text-bg-warning"; }
             else { estadoTxt = "Inactiva"; estadoClass = "text-bg-secondary"; }
      %>
      <tr>
        <td><%= r.getId() %></td>
        <td><%= tipo %></td>
        <td><%= r.getDescripcion() == null ? "" : r.getDescripcion() %></td>
        <td><%= r.getPrice() %></td>
        <td><span class="badge <%=estadoClass%>"><%=estadoTxt%></span></td>
        <td class="text-nowrap">
          <button class="btn btn-sm btn-outline-secondary me-1"
                  data-bs-toggle="modal" data-bs-target="#editModal"
                  data-id="<%=r.getId()%>"
                  data-id_type="<%=r.getIdType()%>"
                  data-desc="<%=r.getDescripcion()==null?"":r.getDescripcion()%>"
                  data-price="<%=r.getPrice()%>"
                  data-status="<%=r.getStatus()%>">
            <i class="fa-solid fa-pen"></i>
          </button>
          <button class="btn btn-sm btn-outline-danger"
                  data-bs-toggle="modal" data-bs-target="#deleteModal"
                  data-id="<%=r.getId()%>">
            <i class="fa-solid fa-trash"></i>
          </button>
        </td>
      </tr>
      <% } } %>
    </tbody>
  </table>
</div>

<!-- Modal: Crear -->
<div class="modal fade" id="addModal" tabindex="-1">
  <div class="modal-dialog">
    <form action="<%=request.getContextPath()%>/rooms" method="POST" class="modal-content">
      <input type="hidden" name="action" value="create">
      <div class="modal-header">
        <h5 class="modal-title">Nueva habitación</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="row g-2">
          <!-- opcional: número; si lo dejas vacío, se autoincrementa -->
          <div class="col-md-4">
            <label class="form-label">Número</label>
            <input name="number" type="number" min="1" class="form-control" placeholder="(auto)">
          </div>
          <div class="col-md-8">
            <label class="form-label">Tipo</label>
            <select name="id_type" class="form-select" required>
              <% if (types != null) for (TypesRooms t : types) { %>
                <option value="<%=t.getId()%>"><%= t.getTypeDescription() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-12">
            <label class="form-label">Descripción</label>
            <input name="rooms_description" class="form-control" placeholder="Opcional">
          </div>
          <div class="col-md-6">
            <label class="form-label">Tarifa (Q)</label>
            <input name="price" type="number" step="0.01" min="0" value="350" class="form-control" required>
          </div>
          <div class="col-md-6">
            <label class="form-label">Estado</label>
            <select name="status" class="form-select" required>
              <option value="1">Libre</option>
              <option value="2">Ocupada</option>
              <option value="0">Inactiva</option>
            </select>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-info text-white">Guardar</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal: Editar -->
<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog">
    <form action="<%=request.getContextPath()%>/rooms" method="POST" class="modal-content">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="id" id="e-id">
      <div class="modal-header">
        <h5 class="modal-title">Editar habitación</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-md-6">
            <label class="form-label">Tipo</label>
            <select id="e-id_type" name="id_type" class="form-select" required>
              <% if (types != null) for (TypesRooms t : types) { %>
                <option value="<%=t.getId()%>"><%= t.getTypeDescription() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Estado</label>
            <select id="e-status" name="status" class="form-select" required>
              <option value="1">Libre</option>
              <option value="2">Ocupada</option>
              <option value="0">Inactiva</option>
            </select>
          </div>
          <div class="col-12">
            <label class="form-label">Descripción</label>
            <input id="e-desc" name="rooms_description" class="form-control">
          </div>
          <div class="col-md-6">
            <label class="form-label">Tarifa (Q)</label>
            <input id="e-price" name="price" type="number" step="0.01" min="0" class="form-control" required>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-primary">Actualizar</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal: Eliminar (soft-delete: status=0) -->
<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog">
    <form action="<%=request.getContextPath()%>/rooms" method="POST" class="modal-content">
      <input type="hidden" name="action" value="delete">
      <input type="hidden" name="id" id="d-id">
      <div class="modal-header">
        <h5 class="modal-title">Desactivar habitación</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <p class="mb-0">¿Seguro que deseas desactivar esta habitación?</p>
        <small class="text-muted">Se cambiará su <code>status</code> a <strong>0 (Inactiva)</strong>.</small>
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-danger">Desactivar</button>
      </div>
    </form>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script>
  $(function(){ $('#tblRooms').DataTable(); });

  const editModal = document.getElementById('editModal');
  editModal.addEventListener('show.bs.modal', (ev) => {
    const b = ev.relatedTarget;
    document.getElementById('e-id').value = b.dataset.id;
    document.getElementById('e-id_type').value = b.dataset.id_type;
    document.getElementById('e-desc').value = b.dataset.desc || '';
    document.getElementById('e-price').value = b.dataset.price || 0;
    document.getElementById('e-status').value = b.dataset.status || 1;
  });

  const delModal = document.getElementById('deleteModal');
  delModal.addEventListener('show.bs.modal', (ev) => {
    document.getElementById('d-id').value = ev.relatedTarget.dataset.id;
  });
</script>

<%@ include file="/WEB-INF/layouts/footer.jspf" %>
