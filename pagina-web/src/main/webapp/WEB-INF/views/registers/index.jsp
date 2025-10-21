<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.math.BigDecimal,
                 com.umg.models.Register, com.umg.models.User, com.umg.models.Rooms, com.umg.models.TypeRegisters" %>

<%
  request.setAttribute("title","Registros");
  request.setAttribute("active","registers");

  List<Register> registers = (List<Register>) request.getAttribute("registers");
  List<User> guests = (List<User>) request.getAttribute("guests");
  List<Rooms> rooms = (List<Rooms>) request.getAttribute("rooms");
  List<TypeRegisters> types = (List<TypeRegisters>) request.getAttribute("types");

  Map<Long,String> guestNames = (Map<Long,String>) request.getAttribute("guestNames");
  Map<Long,String> roomNames  = (Map<Long,String>) request.getAttribute("roomNames");
  Map<Long,String> typeNames  = (Map<Long,String>) request.getAttribute("typeNames");
%>
<%@ include file="/WEB-INF/layouts/header.jspf" %>
<link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css"/>

<div class="container my-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3><i class="fa-solid fa-list me-2 text-primary"></i>Registros</h3>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal">
      <i class="fa-solid fa-plus me-1"></i> Nuevo registro
    </button>
  </div>

  <table id="tblRegs" class="display table table-striped w-100">
    <thead>
      <tr>
        <th>#</th>
        <th>Huésped</th>
        <th>Hab.</th>
        <th>Tipo</th>
        <th>Monto</th>
        <th>Pendiente</th>
        <th>Detalle</th>
        <th>Estado</th>
        <th style="width:120px;">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <% if (registers != null) {
       for (Register r : registers) {
          String gname = guestNames != null ? guestNames.getOrDefault(r.getIdUser(),"#"+r.getIdUser()) : ("#"+r.getIdUser());
          String room  = roomNames  != null ? roomNames.getOrDefault(r.getIdRoom(),"#"+r.getIdRoom()) : ("#"+r.getIdRoom());
          String tname = typeNames  != null ? typeNames.getOrDefault(r.getTypeRegisters(),"—") : ("#"+r.getTypeRegisters());
          String stxt  = (r.getStatus()==1)?"Activo":"Anulado";
          String scls  = (r.getStatus()==1)?"text-bg-success":"text-bg-secondary";
    %>
      <tr>
        <td><%= r.getId() %></td>
        <td><%= gname %></td>
        <td><%= room %></td>
        <td><%= tname %></td>
        <td>Q <%= r.getAmount() %></td>
        <td><span class="badge <%= r.isPendingPayment()? "text-bg-warning":"text-bg-success" %>"><%= r.isPendingPayment()?"Sí":"No" %></span></td>
        <td><%= r.getDetail()==null?"":r.getDetail() %></td>
        <td><span class="badge <%= scls %>"><%= stxt %></span></td>
        <td class="text-nowrap">
          <button class="btn btn-sm btn-outline-secondary me-1"
              data-bs-toggle="modal" data-bs-target="#editModal"
              data-id="<%=r.getId()%>"
              data-id_user="<%=r.getIdUser()%>"
              data-id_room="<%=r.getIdRoom()%>"
              data-type_registers="<%=r.getTypeRegisters()%>"
              data-amount="<%=r.getAmount()%>"
              data-pending="<%= r.isPendingPayment() ? "1" : "0" %>"
              data-detail="<%= r.getDetail()==null?"":r.getDetail() %>"
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
    <form class="modal-content" method="POST" action="<%=request.getContextPath()%>/registers">
      <input type="hidden" name="action" value="create">
      <div class="modal-header">
        <h5 class="modal-title">Nuevo registro</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-md-6">
            <label class="form-label">Huésped</label>
            <select name="id_user" class="form-select" required>
              <% if (guests!=null) for (User u: guests) { %>
                <option value="<%=u.getId()%>">
                  <%= (u.getFirstname()==null?"":u.getFirstname()) %> <%= (u.getSecondname()==null?"":u.getSecondname()) %>
                  <%= (u.getFirstlastname()==null?"":u.getFirstlastname()) %> <%= (u.getSecondlastname()==null?"":u.getSecondlastname()) %>
                </option>
              <% } %>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Habitación</label>
            <select name="id_room" class="form-select" required>
              <% if (rooms!=null) for (Rooms r: rooms) { %>
                <option value="<%=r.getId()%>"><%= r.getId() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Tipo</label>
            <select name="type_registers" class="form-select" required>
              <% if (types!=null) for (TypeRegisters t: types) { %>
                <option value="<%=t.getId()%>"><%= t.getTypeDescription() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Monto (Q)</label>
            <input type="number" step="0.01" min="0" name="amount" class="form-control" value="0.00" required>
          </div>
          <div class="col-12">
            <label class="form-label">Detalle</label>
            <input name="detail" class="form-control" placeholder="Descripción (opcional)">
          </div>
          <div class="col-12">
            <div class="form-check">
              <input class="form-check-input" type="checkbox" value="1" id="a-pending" name="pending_payment">
              <label class="form-check-label" for="a-pending">Pendiente de pago</label>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-primary">Guardar</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal: Editar -->
<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="POST" action="<%=request.getContextPath()%>/registers">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="id" id="e-id">
      <div class="modal-header">
        <h5 class="modal-title">Editar registro</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-md-6">
            <label class="form-label">Huésped</label>
            <select id="e-id_user" name="id_user" class="form-select" required>
              <% if (guests!=null) for (User u: guests) { %>
                <option value="<%=u.getId()%>">
                  <%= (u.getFirstname()==null?"":u.getFirstname()) %> <%= (u.getSecondname()==null?"":u.getSecondname()) %>
                  <%= (u.getFirstlastname()==null?"":u.getFirstlastname()) %> <%= (u.getSecondlastname()==null?"":u.getSecondlastname()) %>
                </option>
              <% } %>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Habitación</label>
            <select id="e-id_room" name="id_room" class="form-select" required>
              <% if (rooms!=null) for (Rooms r: rooms) { %>
                <option value="<%=r.getId()%>"><%= r.getId() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Tipo</label>
            <select id="e-type_registers" name="type_registers" class="form-select" required>
              <% if (types!=null) for (TypeRegisters t: types) { %>
                <option value="<%=t.getId()%>"><%= t.getTypeDescription() %></option>
              <% } %>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Monto (Q)</label>
            <input id="e-amount" type="number" step="0.01" min="0" name="amount" class="form-control" required>
          </div>
          <div class="col-12">
            <label class="form-label">Detalle</label>
            <input id="e-detail" name="detail" class="form-control">
          </div>
          <div class="col-md-6">
            <label class="form-label">Pendiente</label>
            <select id="e-pending" name="pending_payment" class="form-select">
              <option value="1">Sí</option>
              <option value="0">No</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Estado</label>
            <select id="e-status" name="status" class="form-select">
              <option value="1">Activo</option>
              <option value="0">Anulado</option>
            </select>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-primary">Actualizar</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal: Anular (status=0) -->
<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog">
    <form class="modal-content" method="POST" action="<%=request.getContextPath()%>/registers">
      <input type="hidden" name="action" value="delete">
      <input type="hidden" name="id" id="d-id">
      <div class="modal-header">
        <h5 class="modal-title">Anular registro</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        ¿Seguro que deseas anular este registro?
      </div>
      <div class="modal-footer">
        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-danger">Anular</button>
      </div>
    </form>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script>
  $(function(){ $('#tblRegs').DataTable(); });

  const editModal = document.getElementById('editModal');
  editModal.addEventListener('show.bs.modal', (ev) => {
    const b = ev.relatedTarget;
    document.getElementById('e-id').value = b.dataset.id;
    document.getElementById('e-id_user').value = b.dataset.id_user;
    document.getElementById('e-id_room').value = b.dataset.id_room;
    document.getElementById('e-type_registers').value = b.dataset.type_registers;
    document.getElementById('e-amount').value = b.dataset.amount || 0;
    document.getElementById('e-detail').value = b.dataset.detail || '';
    document.getElementById('e-pending').value = b.dataset.pending || '0';
    document.getElementById('e-status').value = b.dataset.status || '1';
  });

  const delModal = document.getElementById('deleteModal');
  delModal.addEventListener('show.bs.modal', (ev) => {
    document.getElementById('d-id').value = ev.relatedTarget.dataset.id;
  });
</script>

<%@ include file="/WEB-INF/layouts/footer.jspf" %>
