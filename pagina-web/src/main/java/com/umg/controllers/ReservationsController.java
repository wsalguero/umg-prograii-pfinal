package com.umg.controllers;

import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;

public class ReservationsController extends HttpServlet {

    private void flash(HttpServletRequest req, String type, String msg) {
        req.getSession().setAttribute("flash_" + type, msg);
    }

    private void back(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/dashboard");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (!"create".equals(action)) {
            back(req, resp);
            return;
        }

        // datos del huésped existente/nuevo
        String existing = req.getParameter("existing_user_id");
        Integer userId = (existing != null && !existing.isBlank()) ? Integer.valueOf(existing) : null;

        String firstname = req.getParameter("firstname");
        String secondname = req.getParameter("secondname");
        String firstlastname = req.getParameter("firstlastname");
        String secondlastname = req.getParameter("secondlastname");
        String email = req.getParameter("email");
        String user_address = req.getParameter("user_address");
        String dpi = req.getParameter("dpi");
        String nit = req.getParameter("nit");

        // habitación / fechas / monto
        int roomId = Integer.parseInt(req.getParameter("room_id"));
        LocalDate checkin = LocalDate.parse(req.getParameter("checkin"));
        LocalDate checkout = LocalDate.parse(req.getParameter("checkout"));
        int nights = Integer.parseInt(req.getParameter("nights"));
        float amount = Float.parseFloat(req.getParameter("amount"));
        String detail = req.getParameter("detail");

        if (nights <= 0)
            nights = 1;
        if (detail == null || detail.isBlank())
            detail = "Check-in " + checkin + " - " + checkout;

        try (Connection con = Db.getConnection()) {
            con.setAutoCommit(false);

            // 1) si no hay userId, crear huésped
            if (userId == null) {
                try (PreparedStatement ps = con.prepareStatement(
                        "INSERT INTO users (user_address,email,dpi,nit,rol,user_status,user_password,firstname,secondname,firstlastname,secondlastname) "
                                +
                                "VALUES (?,?,?,?, 'guest', 1, '12345', ?,?,?,?)",
                        Statement.RETURN_GENERATED_KEYS)) {
                    ps.setString(1, nullToEmpty(user_address));
                    ps.setString(2, nullToEmpty(email));
                    ps.setString(3, nullToEmpty(dpi));
                    ps.setString(4, nullToEmpty(nit));
                    ps.setString(5, nullToEmpty(firstname));
                    ps.setString(6, nullToEmpty(secondname));
                    ps.setString(7, nullToEmpty(firstlastname));
                    ps.setString(8, nullToEmpty(secondlastname));
                    ps.executeUpdate();
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next())
                            userId = rs.getInt(1);
                    }
                }
            }

            // 2) verificar que la habitación siga libre y traer tarifa
            float price;
            try (PreparedStatement ps = con.prepareStatement(
                    "SELECT price FROM rooms WHERE id=? AND status=1 FOR UPDATE")) {
                ps.setInt(1, roomId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) {
                        con.rollback();
                        flash(req, "error", "La habitación ya no está disponible.");
                        back(req, resp);
                        return;
                    }
                    price = rs.getFloat(1);
                }
            }
            // recalcular por seguridad si el front mandó 0/alterado
            if (amount <= 0)
                amount = price * nights;

            // 3) crear register (type_registers = 3 habitación)
            try (PreparedStatement ps = con.prepareStatement(
                    "INSERT INTO register (id_user,id_room,type_registers,amount,pending_payment,detail,create_at,status) "
                            +
                            "VALUES (?,?,3,?,1,?,NOW(),1)")) {
                ps.setInt(1, userId);
                ps.setInt(2, roomId);
                ps.setBigDecimal(3, new java.math.BigDecimal(String.format(java.util.Locale.US, "%.2f", amount)));
                ps.setString(4, detail);
                ps.executeUpdate();
            }

            // 4) marcar habitación ocupada
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE rooms SET status=2 WHERE id=?")) {
                ps.setInt(1, roomId);
                ps.executeUpdate();
            }

            con.commit();
            flash(req, "ok", "Reservación creada. Huésped #" + userId + ", Habitación #" + roomId +
                    ", Noches: " + nights + ", Total Q" + String.format(java.util.Locale.US, "%.2f", amount));
        } catch (Exception ex) {
            ex.printStackTrace();
            flash(req, "error", "No se pudo crear la reservación.");
        }

        back(req, resp);
    }

    private String nullToEmpty(String s) {
        return (s == null) ? "" : s.trim();
    }
}
