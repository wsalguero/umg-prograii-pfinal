<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
  // Variables “de layout”
  request.setAttribute("title", "Login");
  request.setAttribute("active", "login");

  Object user = session.getAttribute("user");
  if (user == null) {
      response.sendRedirect(request.getContextPath() + "/login");
      return;
  }else{
      response.sendRedirect(request.getContextPath() + "/dashboard");
      return;
  }

%>
