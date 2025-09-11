<%@ tag body-content="empty" pageEncoding="UTF-8" %>
<%@ attribute name="active" required="false" %>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark">
  <div class="container">
    <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/index.jsp">HotelesApp</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navMain">
      <ul class="navbar-nav ms-auto">
        <li class="nav-item">
          <a class="nav-link ${active == 'hoteles' ? 'active' : ''}"
             href="${pageContext.request.contextPath}/hoteles/lista.jsp">Hoteles</a>
        </li>
        <li class="nav-item">
          <a class="nav-link ${active == 'reportes' ? 'active' : ''}" href="#">Reportes</a>
        </li>
        <li class="nav-item">
          <a class="nav-link ${active == 'config' ? 'active' : ''}" href="#">Configuración</a>
        </li>
      </ul>
    </div>
  </div>
</nav>
