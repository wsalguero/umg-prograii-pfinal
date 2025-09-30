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

<div class="d-flex justify-content-center">
  <h1>Hola Dashboard</h1>
</div>

<%@ include file="/WEB-INF/layouts/footer.jspf" %>
