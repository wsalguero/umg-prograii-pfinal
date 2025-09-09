<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>

<ui:layout title="Inicio" active="home">
  <jsp:attribute name="styles">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/pages/home/home.page.css">
  </jsp:attribute>

  <jsp:body>
    <p>Bienvenido a HotelesApp.</p>
    <a class="btn btn-primary" href="${pageContext.request.contextPath}/login">Ir a Login</a>
  </jsp:body>
</ui:layout>
