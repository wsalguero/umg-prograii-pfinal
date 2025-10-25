package com.umg.controllers;

import com.umg.models.Bills;
import com.umg.models.BillsDetails;
import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.*;

public class BillsController extends HttpServlet {

    private void flash(HttpServletRequest req, String type, String msg) {
        req.getSession().setAttribute("flash_" + type, msg);
    }

    private void redirect(HttpServletRequest req, HttpServletResponse resp, String path) throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
    }

    /**
     * Huéspedes con resumen de pendientes (incluye user_status para mostrar
     * badge/validar baja)
     */
    private List<Map<String, Object>> listGuestsWithPending() throws SQLException {
        String sql = """
                    SELECT u.id,
                           u.user_status,
                           CONCAT(u.firstname,' ',COALESCE(u.secondname,''),' ',
                                  COALESCE(u.firstlastname,''),' ',COALESCE(u.secondlastname,'')) AS full_name,
                           COALESCE(SUM(CASE WHEN r.pending_payment=1 THEN r.amount ELSE 0 END),0) AS pending_total,
                           SUM(CASE WHEN r.pending_payment=1 THEN 1 ELSE 0 END) AS pending_count
                    FROM users u
                    LEFT JOIN register r ON r.id_user = u.id AND r.deleted_at IS NULL
                    WHERE u.rol='guest'
                    GROUP BY u.id, u.user_status
                    ORDER BY u.id DESC
                """;

        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            List<Map<String, Object>> guests = new ArrayList<>();
            while (rs.next()) {
                Map<String, Object> g = new HashMap<>();
                g.put("id", rs.getLong("id"));
                g.put("user_status", rs.getInt("user_status"));
                g.put("full_name", rs.getString("full_name"));
                g.put("pending_total", rs.getBigDecimal("pending_total"));
                g.put("pending_count", rs.getInt("pending_count"));
                guests.add(g);
            }
            return guests;
        }
    }

    private List<Long> pendingRegisterIdsByUser(Connection con, long userId) throws SQLException {
        String sql = "SELECT id FROM register WHERE id_user=? AND pending_payment=1 AND deleted_at IS NULL";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                List<Long> ids = new ArrayList<>();
                while (rs.next())
                    ids.add(rs.getLong("id"));
                return ids;
            }
        }
    }

    private float pendingTotalByUser(Connection con, long userId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(amount),0) FROM register WHERE id_user=? AND pending_payment=1 AND deleted_at IS NULL";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getFloat(1);
            }
        }
    }

    // ---------- GET ----------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            req.setAttribute("guests", listGuestsWithPending());
            req.getRequestDispatcher("/WEB-INF/views/billing/index.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            flash(req, "error", "Error al cargar lista de huéspedes.");
            redirect(req, resp, "/dashboard");
        }
    }

    // ---------- POST ----------
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null) {
            redirect(req, resp, "/billing");
            return;
        }

        try (Connection con = Db.getConnection()) {
            switch (action) {
                case "bill": { // FACTURAR (NO cambia estado del huésped)
                    long userId = Long.parseLong(req.getParameter("user_id"));
                    con.setAutoCommit(false);

                    List<Long> regIds = pendingRegisterIdsByUser(con, userId);
                    if (regIds.isEmpty()) {
                        flash(req, "warn", "No hay consumos pendientes.");
                        redirect(req, resp, "/billing");
                        return;
                    }

                    float total = pendingTotalByUser(con, userId);

                    // Crear factura
                    Bills bill = new Bills();
                    bill.setIdUser((int) userId);
                    bill.setBillsDate(LocalDateTime.now());
                    bill.setTotal(total);

                    String insBill = "INSERT INTO bills (id_user, bills_date, total) VALUES (?, NOW(), ?)";
                    try (PreparedStatement ps = con.prepareStatement(insBill, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setLong(1, userId);
                        ps.setFloat(2, total);
                        ps.executeUpdate();
                        try (ResultSet k = ps.getGeneratedKeys()) {
                            if (k.next())
                                bill.setNum(k.getLong(1));
                        }
                    }

                    // Detalles
                    List<BillsDetails> dets = new ArrayList<>();
                    String insDet = "INSERT INTO bills_details (num, id_registers) VALUES (?, ?)";
                    try (PreparedStatement ps = con.prepareStatement(insDet)) {
                        for (Long rid : regIds) {
                            ps.setLong(1, bill.getNum());
                            ps.setLong(2, rid);
                            ps.addBatch();

                            BillsDetails d = new BillsDetails();
                            d.setNum((int) bill.getNum());
                            d.setIdRegisters(rid.intValue());
                            dets.add(d);
                        }
                        ps.executeBatch();
                    }
                    bill.setDetails(dets.toArray(new BillsDetails[0]));

                    // Marcar registros como pagados
                    String ph = String.join(",", Collections.nCopies(regIds.size(), "?"));
                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE register SET pending_payment=0 WHERE id IN (" + ph + ")")) {
                        int i = 1;
                        for (Long id : regIds)
                            ps.setLong(i++, id);
                        ps.executeUpdate();
                    }

                    con.commit();
                    flash(req, "ok", "Factura #" + bill.getNum() + " creada. Total Q" + bill.getTotal());
                    redirect(req, resp, "/billing");
                    return;
                }

                case "checkout": { // DAR DE BAJA
                    long userId = Long.parseLong(req.getParameter("user_id"));

                    // bloquear el checkout si aún tiene pendientes
                    try (PreparedStatement ps = con.prepareStatement(
                            "SELECT COUNT(*) FROM register WHERE id_user=? AND pending_payment=1 AND deleted_at IS NULL")) {
                        ps.setLong(1, userId);
                        try (ResultSet rs = ps.executeQuery()) {
                            rs.next();
                            if (rs.getLong(1) > 0) {
                                flash(req, "warn",
                                        "No se puede dar de baja: el huésped aún tiene consumos pendientes.");
                                redirect(req, resp, "/billing");
                                return;
                            }
                        }
                    }

                    try (PreparedStatement ps = con.prepareStatement(
                            "UPDATE users SET user_status=3 WHERE id=?")) {
                        ps.setLong(1, userId);
                        ps.executeUpdate();
                    }
                    flash(req, "ok", "Huésped dado de baja correctamente.");
                    redirect(req, resp, "/billing");
                    return;
                }

                default:
                    redirect(req, resp, "/billing");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            flash(req, "error", "Operación no realizada.");
            redirect(req, resp, "/billing");
        }
    }
}
