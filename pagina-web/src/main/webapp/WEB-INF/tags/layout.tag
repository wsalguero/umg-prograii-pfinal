<%@ tag body-content="scriptless" pageEncoding="UTF-8" %>
<%@ attribute name="title"   required="true" %>
<%@ attribute name="active"  required="false" %>
<%@ attribute name="styles"  fragment="true" required="false" %>
<%@ attribute name="actions" fragment="true" required="false" %>
<%@ attribute name="scripts" fragment="true" required="false" %>

<%@ taglib prefix="ui" tagdir="/WEB-INF/tags" %>

<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${title}</title>

  <!-- CSS global (Bootstrap opcional) -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />

  <!-- Slot de estilos por página -->
  <jsp:invoke fragment="styles" />
</head>
<body class="bg-light">
  <ui:navbar active="${empty active ? '' : active}" />

  <main class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
      <h1 class="h4 m-0">${title}</h1>
      <div><jsp:invoke fragment="actions" /></div>
    </div>

    <!-- AQUÍ SE RENDERIZA EL CONTENIDO DE home.jsp / login.jsp -->
    <jsp:doBody/>
  </main>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <!-- Slot de scripts por página -->
  <jsp:invoke fragment="scripts" />
</body>
</html>
