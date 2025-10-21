package com.umg.controllers;

import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.*;

/**
 * Controlador del Dashboard
 * - KPIs
 * - Listas recientes
 */
// @WebServlet(name = "DashboardController", urlPatterns = { "/dashboard" })
public class DashboardController extends HttpServlet {

    // ---------- helpers de salida ----------
    private void flashAndBack(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws IOException {
        req.getSession().setAttribute("flash_error", msg);
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    // Ejecuta SELECT con parámetros y devuelve List<Map<String,Object>>
    private List<Map<String, Object>> query(String sql, Object... params) throws SQLException {
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                List<Map<String, Object>> list = new ArrayList<>();
                ResultSetMetaData md = rs.getMetaData();
                int n = md.getColumnCount();
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    for (int i = 1; i <= n; i++) {
                        row.put(md.getColumnLabel(i), rs.getObject(i));
                    }
                    list.add(row);
                }
                return list;
            }
        }
    }

    // Ejecuta SELECT escalar (ej. COUNT/SUM)
    private long scalarLong(String sql, Object... params) throws SQLException {
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql)) {
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getLong(1);
                return 0L;
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("user") == null) {
            flashAndBack(req, resp, "Inicia sesión para continuar.");
            return;
        }

        try {
            System.out.println("===== DASHBOARD CONTROLLER INICIADO =====");

            // ===== KPIs =====
            long totalRooms = scalarLong("SELECT COUNT(*) FROM rooms");
            long freeRooms = scalarLong("SELECT COUNT(*) FROM rooms WHERE status = 1");
            long busyRooms = Math.max(0, totalRooms - freeRooms);
            long checkinsHoy = scalarLong(
                    "SELECT COUNT(*) FROM register " +
                            "WHERE DATE(create_at)=CURDATE() AND type_registers = ?",
                    3);

            long revenueHoy = scalarLong(
                    "SELECT COALESCE(SUM(total),0) FROM bills WHERE DATE(bills_date)=CURDATE()");

            System.out.println("[KPI] Total rooms = " + totalRooms);
            System.out.println("[KPI] Free rooms  = " + freeRooms);
            System.out.println("[KPI] Check-ins hoy (type=3) = " + checkinsHoy);
            System.out.println("[KPI] Revenue hoy = " + revenueHoy);

            int occupancy = (totalRooms == 0)
                    ? 0
                    : (int) Math.round(((double) busyRooms / (double) totalRooms) * 100.0);

            // Huéspedes recientes (últimos check-ins)
            // type_registers: 3 = Habitación (según tu tabla type_registers)
            List<Map<String, Object>> recentGuests = query(
                    "SELECT " +
                            "  u.firstname, u.secondname, u.firstlastname AS lastname1, u.secondlastname AS lastname2, "
                            +
                            "  r.id_room AS room, DATE(r.create_at) AS checkin_date, " +
                            "  tr.type_description AS register_type, " +
                            "  rm.id_type, ty.type_description AS room_type " +
                            "FROM register r " +
                            "JOIN users u         ON u.id = r.id_user " +
                            "LEFT JOIN rooms rm   ON rm.id = r.id_room " +
                            "LEFT JOIN types_rooms ty ON ty.id = rm.id_type " +
                            "JOIN type_registers tr ON tr.id = r.type_registers " +
                            "WHERE r.type_registers = 3 " + // sólo check-ins (habitación)
                            "ORDER BY r.create_at DESC " +
                            "LIMIT 10");

            // Habitaciones libres (con tipo textual)
            List<Map<String, Object>> freeRoomsList = query(
                    "SELECT rm.id AS room_number, ty.type_description AS room_type, rm.price, rm.status " +
                            "FROM rooms rm " +
                            "LEFT JOIN types_rooms ty ON ty.id = rm.id_type " +
                            "WHERE rm.status = 1 " + // 1 = libre
                            "ORDER BY rm.id " +
                            "LIMIT 10");

            // Recibos recientes (ya estaba bien; dejo igual, sólo orden por fecha)
            List<Map<String, Object>> recentReceipts = query(
                    "SELECT b.num, DATE(b.bills_date) AS bills_date, b.total, " +
                            "       CONCAT(u.firstname,' ',COALESCE(u.secondname,''),' '," +
                            "              COALESCE(u.firstlastname,''),' ',COALESCE(u.secondlastname,'')) AS guest_name "
                            +
                            "FROM bills b " +
                            "LEFT JOIN users u ON u.id = b.id_user " +
                            "ORDER BY b.bills_date DESC " +
                            "LIMIT 10");

            // ===== LOGS DE LOS LISTADOS =====
            System.out.println("[List] recentGuests size = " + recentGuests.size());
            System.out.println("[List] freeRoomsList size = " + freeRoomsList.size());
            System.out.println("[List] recentReceipts size = " + recentReceipts.size());

            System.out.println("Recent Guests -> " + recentGuests);
            System.out.println("Free Rooms -> " + freeRoomsList);
            System.out.println("Recent Receipts -> " + recentReceipts);

            // ===== Exponer =====
            req.setAttribute("kpi_total_rooms", totalRooms);
            req.setAttribute("kpi_free_rooms", freeRooms);
            req.setAttribute("kpi_occupancy", occupancy);
            req.setAttribute("kpi_checkins", checkinsHoy);
            req.setAttribute("kpi_revenue", revenueHoy);

            req.setAttribute("recent_guests", recentGuests);
            req.setAttribute("free_rooms_list", freeRoomsList);
            req.setAttribute("recent_receipts", recentReceipts);

            req.getRequestDispatcher("/WEB-INF/views/dashboard/dashboard.jsp").forward(req, resp);

        } catch (SQLException ex) {
            ex.printStackTrace();
            flashAndBack(req, resp, "Error en la base de datos. Intenta de nuevo.");
        } catch (Exception ex) {
            ex.printStackTrace();
            flashAndBack(req, resp, "Error interno. Intenta de nuevo.");
        }
    }

}
