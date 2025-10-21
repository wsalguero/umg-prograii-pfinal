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
        <th>Consumos pendientes</th>
        <th>Total (Q)</th>
        <th style="width:160px;">Acciones</th>
      </tr>
    </thead>
    <tbody>
    <% if (guests != null) {
         for (Map<String,Object> g : guests) {
           long cnt = ((Number)g.get("pending_count")).longValue();
           String disabled = cnt==0 ? "disabled" : "";
    %>
      <tr>
        <td><%= g.get("id") %></td>
        <td><%= g.get("full_name") %></td>
        <td><%= cnt %></td>
        <td>Q <%= g.get("pending_total") %></td>
        <td>
          <form action="<%=request.getContextPath()%>/billing" method="POST" class="d-inline">
            <input type="hidden" name="action" value="bill">
            <input type="hidden" name="user_id" value="<%= g.get("id") %>">
            <button class="btn btn-sm btn-success" <%=disabled%>>
              <i class="fa-solid fa-cash-register me-1"></i> Facturar
            </button>
          </form>
          <a href="<%=request.getContextPath()%>/guests" class="btn btn-sm btn-outline-secondary">
            <i class="fa-solid fa-eye"></i>
          </a>
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
