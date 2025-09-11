<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>

<ui:layout title="Login" active="login">
    <jsp:attribute name="styles">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/views/login/login.page.css">
    </jsp:attribute>

    <jsp:body>
        <div class="contenedor">
            <h2>Página de Login</h2>
            <form>
                <input type="text" placeholder="Usuario" />
                <input type="password" placeholder="Contraseña" />
                <button class="btn btn-primary">Ingresar</button>
            </form>
        </div>
    </jsp:body>
</ui:layout>
