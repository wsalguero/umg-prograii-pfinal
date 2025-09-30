<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  request.setAttribute("title", "Login");
  request.setAttribute("active", "login");
%>
<%@ include file="/WEB-INF/layouts/header.jspf" %>

<%
  String flash = (String) session.getAttribute("flash_error");
  if (flash != null) {
%>
  <!-- Toast container -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index: 1100">
    <div id="liveToast" class="toast align-items-center text-bg-danger border-0 show" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body">
          <%= flash %>
        </div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
  </div>
<%
    session.removeAttribute("flash_error");
  }
%>

<div class="d-flex justify-content-center">
  <form class="login-form" method="post" action="<%=request.getContextPath()%>/auth">
    <h2>Iniciar sesión</h2>
    <div class="mb-3">
      <label for="lg-user" class="form-label">Email</label>
      <input id="lg-user" name="email" type="email" class="form-control" required>
    </div>
    <div class="mb-3">
      <label for="lg-password" class="form-label">Password</label>
      <input id="lg-password" name="password" type="password" class="form-control" required>
    </div>
    <button class="btn btn-primary" type="submit">Ingresar</button>
  </form>
</div>

<%@ include file="/WEB-INF/layouts/footer.jspf" %>

<script>
  // Inicializar toasts si están en la página
  document.addEventListener("DOMContentLoaded", function() {
    var toastElList = [].slice.call(document.querySelectorAll('.toast'))
    toastElList.map(function(toastEl) {
      return new bootstrap.Toast(toastEl).show()
    })
  });
</script>
