<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  // 🔒 Verificar login
  Object user = session.getAttribute("user");
  if (user == null) {
      response.sendRedirect(request.getContextPath() + "/login");
      return;
  }

  // Variables para el layout
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

<link rel="stylesheet" href="<%=request.getContextPath()%>/assets/styles/pages/dashboard.css">

<section class="container page-container">

  <div class="page-part" class="page-part">
  </div>
  
  <aside class="sidebar page-part">
    <div class="">
      <h1>Huespedes</h1>
      <ul class="sidebar-list">
        <li class="mb-2">
          <a href="/guests" class="btn btn-primary">
            Ver huespedes  
          </a>
        </li>
        <li class="mb-2">
          <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#modalAddGuesst">
            Agregar huesped
          </button>
        </li>
      </ul>
    </div>

    <div class="">
      <h1>Habitaciones</h1>
      <ul class="sidebar-list">
        <li class="mb-2">
          <a href="/rooms" class="btn btn-primary">
            Ver Habitaciones  
          </a>
        </li>
        <li class="mb-2">
          <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#modalAddRoom">
            Agregar habitacion
          </button>
        </li>
      </ul>
    </div>
  </aside>

  <div class="">

  </div>
  
</section>


<!-- Modales -->


<div class="modal fade" id="modalAddGuesst" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="Add Guest" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="staticBackdropLabel">Crear Huesped</h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
       <form class="row g-3">
          <div class="col-6">
            <label for="inp-fname" class="form-label">Primer nombre</label>
            <input type="text" class="form-control" id="inp-fname" placeholder="Primer nombre">
          </div>

          <div class="col-6">
            <label for="inp-sname" class="form-label">Segundo nombre</label>
            <input type="text" class="form-control" id="inp-sname" placeholder="Segundo nombre">
          </div>

          <div class="col-6">
            <label for="inp-flname" class="form-label">Primer Apellido</label>
            <input type="text" class="form-control" id="inp-flname" placeholder="Primer Apellido">
          </div>

          <div class="col-6">
            <label for="inp-slname" class="form-label">Segundo Apellido</label>
            <input type="text" class="form-control" id="inp-slname" placeholder="Segundo Apellido">
          </div>

          <div class="col-6">
            <label for="inp-email" class="form-label">Email</label>
            <input type="text" class="form-control" id="inp-email" placeholder="ejemplo@ejemplo.com">
          </div>

          <div class="">
            <label for="inp-address" class="form-label">Dirección</label>
            <input type="text" class="form-control" id="inp-address" placeholder="Dirección">
          </div>

          <div class="  ">
            <label for="inp-dpi" class="form-label">DPI</label>
            <input type="text" class="form-control" id="inp-dpi" placeholder="DPI">
          </div>

          <div class="">
            <label for="inp-dpi" class="form-label">NIT</label>
            <div class="d-flex justify-content-between">
              <input type="text" class="form-control" id="inp-nit" placeholder="NIT">

              <a id="btn-cf" href="#" class="btn btn-sm btn-outline-secondary">
                <i class="fa-solid fa-id-card"></i>
              </a>

            </div>
          </div>

          <div class="">
            <button type="submit" class="btn btn-primary mb-3">Create</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="modalAddRoom" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-labelledby="Add Room" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h1 class="modal-title fs-5" id="staticBackdropLabel">Crear Huesped</h1>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">
       <form class="row g-3">
          <div class="col-6">
            <label for="inp-fname" class="form-label">Primer nombre</label>
            <input type="text" class="form-control" id="inp-fname" placeholder="Primer nombre">
          </div>

          <div class="col-6">
            <label for="inp-sname" class="form-label">Segundo nombre</label>
            <input type="text" class="form-control" id="inp-sname" placeholder="Segundo nombre">
          </div>

          <div class="col-6">
            <label for="inp-flname" class="form-label">Primer Apellido</label>
            <input type="text" class="form-control" id="inp-flname" placeholder="Primer Apellido">
          </div>

          <div class="col-6">
            <label for="inp-slname" class="form-label">Segundo Apellido</label>
            <input type="text" class="form-control" id="inp-slname" placeholder="Segundo Apellido">
          </div>

          <div class="col-6">
            <label for="inp-email" class="form-label">Email</label>
            <input type="text" class="form-control" id="inp-email" placeholder="ejemplo@ejemplo.com">
          </div>

          <div class="">
            <label for="inp-address" class="form-label">Dirección</label>
            <input type="text" class="form-control" id="inp-address" placeholder="Dirección">
          </div>

          <div class="  ">
            <label for="inp-dpi" class="form-label">DPI</label>
            <input type="text" class="form-control" id="inp-dpi" placeholder="DPI">
          </div>

          <div class="">
            <label for="inp-dpi" class="form-label">NIT</label>
            <div class="d-flex justify-content-between">
              <input type="text" class="form-control" id="inp-nit" placeholder="NIT">

              <a id="btn-cf" href="#" class="btn btn-sm btn-outline-secondary">
                <i class="fa-solid fa-id-card"></i>
              </a>

            </div>
          </div>

          <div class="">
            <button type="submit" class="btn btn-primary mb-3">Create</button>
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

