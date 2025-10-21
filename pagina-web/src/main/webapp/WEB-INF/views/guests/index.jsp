<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, com.umg.models.User" %>
<%
  request.setAttribute("title", "Huéspedes");
  request.setAttribute("active", "guests");
  List<User> users = (List<User>) request.getAttribute("users");
%>
<%@ include file="/WEB-INF/layouts/header.jspf" %>

<link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css">

<div class="container my-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3><i class="fa-solid fa-users me-2 text-primary"></i>Lista de Huéspedes</h3>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addModal">
      <i class="fa-solid fa-user-plus me-1"></i> Nuevo huésped
    </button>
  </div>

  <table id="tblGuests" class="display table table-striped w-100">
    <thead>
      <tr>
        <th>ID</th>
        <th>Nombre completo</th>
        <th>Email</th>
        <th>DPI</th>
        <th>NIT</th>
        <th>Dirección</th>
        <th style="width:140px;">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <% if (users != null) {
         for (User u : users) { %>
      <tr>
        <td><%= u.getId() %></td>
        <td><%= u.getFullName() %></td>
        <td><%= u.getEmail() %></td>
        <td><%= u.getDpi() %></td>
        <td><%= u.getNit() %></td>
        <td><%= u.getUser_address() %></td>
        <td class="text-nowrap">
          <button
            class="btn btn-sm btn-outline-secondary me-1"
            data-bs-toggle="modal" data-bs-target="#editModal"
            data-id="<%=u.getId()%>"
            data-firstname="<%=u.getFirstname()%>"
            data-secondname="<%=u.getSecondname()%>"
            data-firstlastname="<%=u.getFirstlastname()%>"
            data-secondlastname="<%=u.getSecondlastname()%>"
            data-email="<%=u.getEmail()%>"
            data-dpi="<%=u.getDpi()%>"
            data-nit="<%=u.getNit()%>"
            data-address="<%=u.getUser_address()%>">
            <i class="fa-solid fa-pen"></i>
          </button>
          <button
            class="btn btn-sm btn-outline-danger"
            data-bs-toggle="modal" data-bs-target="#deleteModal"
            data-id="<%=u.getId()%>"
            data-name="<%=u.getFullName()%>">
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
    <form action="<%=request.getContextPath()%>/guests" method="POST" class="modal-content">
      <input type="hidden" name="action" value="create">
      <div class="modal-header">
        <h5 class="modal-title">Nuevo huésped</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-md-6"><input name="firstname" class="form-control" placeholder="Primer nombre" required></div>
          <div class="col-md-6"><input name="secondname" class="form-control" placeholder="Segundo nombre"></div>
          <div class="col-md-6"><input name="firstlastname" class="form-control" placeholder="Primer apellido" required></div>
          <div class="col-md-6"><input name="secondlastname" class="form-control" placeholder="Segundo apellido"></div>
          <div class="col-md-6"><input name="email" type="email" class="form-control" placeholder="Email"></div>
          <div class="col-md-6"><input name="user_address" class="form-control" placeholder="Dirección"></div>
          <div class="col-md-6"><input name="dpi" class="form-control" placeholder="DPI"></div>
          <div class="col-md-6"><input name="nit" class="form-control" placeholder="NIT (CF si no aplica)"></div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-success">Guardar</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal: Editar -->
<div class="modal fade" id="editModal" tabindex="-1">
  <div class="modal-dialog">
    <form action="<%=request.getContextPath()%>/guests" method="POST" class="modal-content">
      <input type="hidden" name="action" value="update">
      <input type="hidden" name="id" id="e-id">
      <div class="modal-header">
        <h5 class="modal-title">Editar huésped</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-md-6"><input id="e-firstname" name="firstname" class="form-control" required></div>
          <div class="col-md-6"><input id="e-secondname" name="secondname" class="form-control"></div>
          <div class="col-md-6"><input id="e-firstlastname" name="firstlastname" class="form-control" required></div>
          <div class="col-md-6"><input id="e-secondlastname" name="secondlastname" class="form-control"></div>
          <div class="col-md-6"><input id="e-email" name="email" type="email" class="form-control"></div>
          <div class="col-md-6"><input id="e-address" name="user_address" class="form-control"></div>
          <div class="col-md-6"><input id="e-dpi" name="dpi" class="form-control"></div>
          <div class="col-md-6"><input id="e-nit" name="nit" class="form-control"></div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-primary">Actualizar</button>
      </div>
    </form>
  </div>
</div>

<!-- Modal: Eliminar (soft-delete) -->
<div class="modal fade" id="deleteModal" tabindex="-1">
  <div class="modal-dialog">
    <form action="<%=request.getContextPath()%>/guests" method="POST" class="modal-content">
      <input type="hidden" name="action" value="delete">
      <input type="hidden" name="id" id="d-id">
      <div class="modal-header">
        <h5 class="modal-title">Eliminar huésped</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
      </div>
      <div class="modal-body">
        <p class="mb-0">¿Seguro que deseas desactivar a <strong id="d-name"></strong>?</p>
        <small class="text-muted">Esto solo cambia <code>user_status</code> a <code>0</code>. Puedes reactivarlo manualmente si lo necesitas.</small>
      </div>
      <div class="modal-footer">
        <button class="btn btn-outline-secondary" type="button" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-danger">Eliminar</button>
      </div>
    </form>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script>
  $(function () { $('#tblGuests').DataTable(); });

  // Rellenar modal de edición
  const editModal = document.getElementById('editModal');
  editModal.addEventListener('show.bs.modal', (ev) => {
    const b = ev.relatedTarget;
    document.getElementById('e-id').value = b.dataset.id;
    document.getElementById('e-firstname').value = b.dataset.firstname || '';
    document.getElementById('e-secondname').value = b.dataset.secondname || '';
    document.getElementById('e-firstlastname').value = b.dataset.firstlastname || '';
    document.getElementById('e-secondlastname').value = b.dataset.secondlastname || '';
    document.getElementById('e-email').value = b.dataset.email || '';
    document.getElementById('e-address').value = b.dataset.address || '';
    document.getElementById('e-dpi').value = b.dataset.dpi || '';
    document.getElementById('e-nit').value = b.dataset.nit || '';
  });

  // Rellenar modal de borrado
  const delModal = document.getElementById('deleteModal');
  delModal.addEventListener('show.bs.modal', (ev) => {
    const b = ev.relatedTarget;
    document.getElementById('d-id').value = b.dataset.id;
    document.getElementById('d-name').textContent = b.dataset.name || '';
  });
</script>

<%@ include file="/WEB-INF/layouts/footer.jspf" %>
