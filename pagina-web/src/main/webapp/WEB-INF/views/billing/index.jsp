<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*" %>
<%
  request.setAttribute("title", "Facturación");
  request.setAttribute("active", "billing");
  List<Map<String,Object>> guests = (List<Map<String,Object>>) request.getAttribute("guests");
%>
<%@ include file="/WEB-INF/layouts/header.jspf" %>

<link rel="stylesheet" href="https://cdn.datatables.net/1.13.8/css/jquery.dataTables.min.css"/>

<div class="container my-4">
  <div class="d-flex justify-content-between align-items-center mb-3">
    <h3><i class="fa-solid fa-file-invoice-dollar me-2 text-warning"></i> Facturación</h3>
  </div>

  <% String ok=(String)session.getAttribute("flash_ok"); if(ok!=null){ %>
    <div class="alert alert-success"><%= ok %></div>
  <% session.removeAttribute("flash_ok"); } %>
  <% String warn=(String)session.getAttribute("flash_warn"); if(warn!=null){ %>
    <div class="alert alert-warning"><%= warn %></div>
  <% session.removeAttribute("flash_warn"); } %>
  <% String err=(String)session.getAttribute("flash_error"); if(err!=null){ %>
    <div class="alert alert-danger"><%= err %></div>
  <% session.removeAttribute("flash_error"); } %>

  <table id="tblBill" class="display table table-striped w-100">
    <thead>
      <tr>
        <th>ID</th>
        <th>Huésped</th>
        <th>Estado</th>
        <th>Consumos pendientes</th>
        <th>Total (Q)</th>
        <th style="width:230px;">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <% if (guests != null) {
         for (Map<String,Object> g : guests) {
           long cnt = ((Number)g.get("pending_count")).longValue();
           int st   = ((Number)g.get("user_status")).intValue();
           String disabledBill = cnt==0 ? "" : "";       // se puede facturar si hay pendientes
           String disabledOut  = (cnt==0 && st!=3) ? "" : "disabled"; // baja sólo sin pendientes y si no está en 3
           String badge, text;
           if (st==3) { badge="text-bg-secondary"; text="Baja"; }
           else if (st==2) { badge="text-bg-warning"; text="Ocupado"; }
           else if (st==1) { badge="text-bg-success"; text="Activo"; }
           else { badge="text-bg-light"; text="—"; }
    %>
      <tr>
        <td><%= g.get("id") %></td>
        <td><%= g.get("full_name") %></td>
        <td><span class="badge <%=badge%>"><%=text%></span></td>
        <td><%= cnt %></td>
        <td>Q <%= g.get("pending_total") %></td>
        <td class="text-nowrap">
          <form action="<%=request.getContextPath()%>/billing" method="POST" class="d-inline me-1">
            <input type="hidden" name="action" value="bill">
            <input type="hidden" name="user_id" value="<%= g.get("id") %>">
            <button class="btn btn-sm btn-success" <%= (cnt==0 ? "disabled" : "") %>>
              <i class="fa-solid fa-cash-register me-1"></i> Facturar pendientes
            </button>
          </form>

          <form action="<%=request.getContextPath()%>/billing" method="POST" class="d-inline">
            <input type="hidden" name="action" value="checkout">
            <input type="hidden" name="user_id" value="<%= g.get("id") %>">
            <button class="btn btn-sm btn-outline-danger" <%= disabledOut %>>
              <i class="fa-solid fa-person-walking-dashed-line-arrow-right me-1"></i> Dar de baja
            </button>
          </form>
        </td>
      </tr>
    <% } } %>
    </tbody>
  </table>
</div>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.datatables.net/1.13.8/js/jquery.dataTables.min.js"></script>
<script>$(function(){ $('#tblBill').DataTable(); });</script>

<%@ include file="/WEB-INF/layouts/footer.jspf" %>
