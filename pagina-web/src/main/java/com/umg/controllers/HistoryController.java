package com.umg.controllers;

import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.sql.Date;
import java.time.LocalDate;
import java.util.*;

/**
 * Historial de registros (solo consulta).
 * Filtros (GET):
 * - user_id (Long) -> id del huésped
 * - type (Integer) -> id en type_registers
 * - pending (Integer) -> 0=pagado, 1=pendiente, -1/todos = ignora
 * - q (String) -> texto libre en 'detail'
 * - from, to (yyyy-MM-dd) -> rango por create_at (inclusive)
 * - reservation_id (Long) -> opcional
 */
public class HistoryController extends HttpServlet {

    // lee string (opcional)
    private String p(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        return (v == null ? "" : v.trim());
    }

    private Integer pInt(HttpServletRequest req, String name) {
        String v = p(req, name);
        try {
            return v.isEmpty() ? null : Integer.valueOf(v);
        } catch (Exception e) {
            return null;
        }
    }

    private Long pLong(HttpServletRequest req, String name) {
        String v = p(req, name);
        try {
            return v.isEmpty() ? null : Long.valueOf(v);
        } catch (Exception e) {
            return null;
        }
    }

    private LocalDate pDate(HttpServletRequest req, String name) {
        String v = p(req, name);
        try {
            return v.isEmpty() ? null : LocalDate.parse(v);
        } catch (Exception e) {
            return null;
        }
    }

    private List<Map<String, Object>> query(String sql, List<Object> params) throws SQLException {
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++)
                ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> list = new ArrayList<>();
                ResultSetMetaData md = rs.getMetaData();
                int n = md.getColumnCount();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= n; i++)
                        row.put(md.getColumnLabel(i), rs.getObject(i));
                    list.add(row);
                }
                return list;
            }
        }
    }

    private Map<String, Object> scalarSums(Connection con, String where, List<Object> params) throws SQLException {
        String sql = "SELECT " +
                "COALESCE(SUM(CASE WHEN r.pending_payment=1 THEN r.amount END),0) AS sum_pending, " +
                "COALESCE(SUM(CASE WHEN r.pending_payment=0 THEN r.amount END),0) AS sum_paid, " +
                "COALESCE(SUM(r.amount),0) AS sum_total " +
                "FROM register r " +
                "LEFT JOIN users u ON u.id=r.id_user " +
                "LEFT JOIN type_registers tr ON tr.id=r.type_registers " +
                where;
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.size(); i++)
                ps.setObject(i + 1, params.get(i));
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                Map<String, Object> m = new HashMap<>();
                m.put("sum_pending", rs.getBigDecimal("sum_pending"));
                m.put("sum_paid", rs.getBigDecimal("sum_paid"));
                m.put("sum_total", rs.getBigDecimal("sum_total"));
                return m;
            }
        }
    }

    /** Traer catálogo de tipos para el filtro */
    private List<Map<String, Object>> loadTypes() throws SQLException {
        return query("SELECT id, type_description FROM type_registers ORDER BY id", List.of());
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // filtros
        Long userId = pLong(req, "user_id");
        Integer type = pInt(req, "type");
        Integer pending = pInt(req, "pending"); // 0/1, otro = ignorar
        String q = p(req, "q");
        LocalDate from = pDate(req, "from");
        LocalDate to = pDate(req, "to");
        Long reservationId = pLong(req, "reservation_id");

        StringBuilder where = new StringBuilder(" WHERE r.deleted_at IS NULL ");
        List<Object> params = new ArrayList<>();

        if (userId != null) {
            where.append(" AND r.id_user = ? ");
            params.add(userId);
        }
        if (type != null) {
            where.append(" AND r.type_registers = ? ");
            params.add(type);
        }
        if (pending != null && (pending == 0 || pending == 1)) {
            where.append(" AND r.pending_payment = ? ");
            params.add(pending);
        }
        if (reservationId != null) {
            where.append(" AND r.reservation_id = ? ");
            params.add(reservationId);
        }
        if (from != null) {
            where.append(" AND DATE(r.create_at) >= ? ");
            params.add(Date.valueOf(from));
        }
        if (to != null) {
            where.append(" AND DATE(r.create_at) <= ? ");
            params.add(Date.valueOf(to));
        }
        if (!q.isEmpty()) {
            where.append(" AND (r.detail LIKE ? OR u.firstname LIKE ? OR u.firstlastname LIKE ?) ");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
            params.add("%" + q + "%");
        }

        String base = "SELECT r.id, r.reservation_id, r.id_user, " +
                "  CONCAT(u.firstname,' ',COALESCE(u.secondname,''),' ',COALESCE(u.firstlastname,''),' ',COALESCE(u.secondlastname,'')) AS guest, "
                +
                "  r.id_room, r.type_registers, tr.type_description, r.amount, r.pending_payment, r.detail, r.create_at "
                +
                "FROM register r " +
                "LEFT JOIN users u ON u.id=r.id_user " +
                "LEFT JOIN type_registers tr ON tr.id=r.type_registers ";

        String order = " ORDER BY r.create_at DESC, r.id DESC ";

        try (Connection con = Db.getConnection()) {
            // listado
            List<Map<String, Object>> rows = new ArrayList<>();
            try (PreparedStatement ps = con.prepareStatement(base + where + order)) {
                for (int i = 0; i < params.size(); i++)
                    ps.setObject(i + 1, params.get(i));
                try (ResultSet rs = ps.executeQuery()) {
                    ResultSetMetaData md = rs.getMetaData();
                    int n = md.getColumnCount();
                    while (rs.next()) {
                        Map<String, Object> row = new LinkedHashMap<>();
                        for (int i = 1; i <= n; i++)
                            row.put(md.getColumnLabel(i), rs.getObject(i));
                        rows.add(row);
                    }
                }
            }

            // totales
            Map<String, Object> totals = scalarSums(con, where.toString(), params);

            // catálogo de tipos para el combo
            List<Map<String, Object>> types = loadTypes();

            // exponer
            req.setAttribute("rows", rows);
            req.setAttribute("totals", totals);
            req.setAttribute("types", types);

            // también reinyectar filtros para mantenerlos en el form
            req.setAttribute("f_user_id", userId);
            req.setAttribute("f_type", type);
            req.setAttribute("f_pending", pending);
            req.setAttribute("f_q", q);
            req.setAttribute("f_from", from);
            req.setAttribute("f_to", to);
            req.setAttribute("f_reservation_id", reservationId);

            req.getRequestDispatcher("/WEB-INF/views/history/index.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(500, "Error al consultar historial");
        }
    }
}
