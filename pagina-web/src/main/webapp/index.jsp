<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
  // Variables "de layout"
  request.setAttribute("title", "Login");
  request.setAttribute("active", "login");

  Object user = session.getAttribute("user");
  if (user == null) {
      response.sendRedirect(request.getContextPath() + "/login");
  } else {
      response.sendRedirect(request.getContextPath() + "/dashboard");
  }
  return;
%><%-- --%>