<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
  request.setAttribute("title", "Historial");
  request.setAttribute("active", "history");
  List<Map<String,Object>> rows   = (List<Map<String,Object>>) request.getAttribute("rows");
  Map<String,Object> totals       = (Map<String,Object>) request.getAttribute("totals");
  List<Map<String,Object>> types  = (List<Map<String,Object>>) request.getAttribute("types");

  Long    f_user_id = (Long)    request.getAttribute("f_user_id");
  Integer f_type    = (Integer) request.getAttribute("f_type");
  Integer f_pending = (Integer) request.getAttribute("f_pending");
  String  f_q       = (String)  request.getAttribute("f_q");
  Object  f_from    = request.getAttribute("f_from");
  Object  f_to      = request.getAttribute("f_to");
  Long    f_resid   = (Long)    request.getAttribute("f_reservation_id");
%>
<%@ include file="/WEB-INF/layouts/header.jspf" %>

<link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css"/>

<div class="container my-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <h3><i class="fa-solid fa-clock-rotate-left me-2 text-secondary"></i> Historial</h3>
  </div>

  <!-- Filtros -->
  <form class="card mb-3" method="GET">
    <div class="card-body">
      <div class="row g-2">
        <div class="col-md-2">
          <label class="form-label">Usuario (ID)</label>
          <input name="user_id" class="form-control" value="<%= f_user_id==null?"":f_user_id %>">
        </div>
        <div class="col-md-2">
          <label class="form-label">Reserva (ID)</label>
          <input name="reservation_id" class="form-control" value="<%= f_resid==null?"":f_resid %>">
        </div>
        <div class="col-md-3">
          <label class="form-label">Tipo</label>
          <select name="type" class="form-select">
            <option value="">Todos</option>
            <% if(types!=null) for (Map<String,Object> t : types) {
                 String id = String.valueOf(t.get("id"));
                 String desc = String.valueOf(t.get("type_description"));
                 String sel = (f_type!=null && id.equals(String.valueOf(f_type)))? "selected":"";
            %>
              <option value="<%=id%>" <%=sel%>><%=desc%></option>
            <% } %>
          </select>
        </div>
        <div class="col-md-2">
          <label class="form-label">Estado</label>
          <select name="pending" class="form-select">
            <option value="">Todos</option>
            <option value="1" <%= (f_pending!=null && f_pending==1)?"selected":"" %>>Pendiente</option>
            <option value="0" <%= (f_pending!=null && f_pending==0)?"selected":"" %>>Pagado</option>
          </select>
        </div>
        <div class="col-md-3">
          <label class="form-label">Buscar</label>
          <input name="q" class="form-control" placeholder="detalle / nombre" value="<%= f_q==null?"":f_q %>">
        </div>

        <div class="col-md-2">
          <label class="form-label">Desde</label>
          <input type="date" name="from" class="form-control" value="<%= f_from==null?"":f_from %>">
        </div>
        <div class="col-md-2">
          <label class="form-label">Hasta</label>
          <input type="date" name="to" class="form-control" value="<%= f_to==null?"":f_to %>">
        </div>
        <div class="col-md-8 align-self-end text-end">
          <button class="btn btn-primary"><i class="fa-solid fa-magnifying-glass me-1"></i> Filtrar</button>
          <a href="<%=request.getContextPath()%>/history" class="btn btn-outline-secondary">Limpiar</a>
        </div>
      </div>
    </div>
  </form>

  <!-- Totales -->
  <div class="row g-3 mb-3">
    <div class="col-md-4">
      <div class="card shadow-sm">
        <div class="card-body d-flex justify-content-between">
          <span class="fw-semibold text-secondary">Pendiente</span>
          <span class="h5 mb-0">Q <%= totals==null?0:totals.get("sum_pending") %></span>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card shadow-sm">
        <div class="card-body d-flex justify-content-between">
          <span class="fw-semibold text-secondary">Pagado</span>
          <span class="h5 mb-0">Q <%= totals==null?0:totals.get("sum_paid") %></span>
        </div>
      </div>
    </div>
    <div class="col-md-4">
      <div class="card shadow-sm">
        <div class="card-body d-flex justify-content-between">
          <span class="fw-semibold text-secondary">Total</span>
          <span class="h5 mb-0">Q <%= totals==null?0:totals.get("sum_total") %></span>
        </div>
      </div>
    </div>
  </div>

  <!-- Tabla -->
  <div class="card">
    <div class="card-body">
      <table id="tblHistory" class="display table table-striped w-100">
        <thead>
          <tr>
            <th>#</th>
            <th>Fecha</th>
            <th>Huésped</th>
            <th>Reserva</th>
            <th>Tipo</th>
            <th>Detalle</th>
            <th class="text-end">Monto (Q)</th>
            <th>Pago</th>
            <th>Hab.</th>
          </tr>
        </thead>
        <tbody>
        <% if(rows!=null) for (Map<String,Object> r : rows) {
             String badge = "text-bg-secondary";
             String txt   = "Pagado";
             Object pp    = r.get("pending_payment");
             boolean pend = (pp!=null && (pp.equals(1) || pp.equals(true)));
             if (pend) { badge="text-bg-warning"; txt="Pendiente"; }
        %>
          <tr>
            <td><%= r.get("id") %></td>
            <td><%= r.get("create_at") %></td>
            <td><%= r.get("guest")==null?"":r.get("guest") %></td>
            <td><%= r.get("reservation_id")==null?"":r.get("reservation_id") %></td>
            <td><%= r.get("type_description")==null?"":r.get("type_description") %></td>
            <td><%= r.get("detail")==null?"":r.get("detail") %></td>
            <td class="text-end"><%= r.get("amount") %></td>
            <td><span class="badge <%=badge%>"><%=txt%></span></td>
            <td><%= r.get("id_room")==null?"":r.get("id_room") %></td>
          </tr>
        <% } %>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script>$(function(){ $('#tblHistory').DataTable({pageLength:25}); });</script>

<%@ include file="/WEB-INF/layouts/footer.jspf" %>
