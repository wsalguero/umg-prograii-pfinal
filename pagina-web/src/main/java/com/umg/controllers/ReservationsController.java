package com.umg.controllers;

import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.List;

/**
 * ReservationsController
 * - Crea reservas
 * - Inserta cargo de habitación en `register` (pendiente o cobrado)
 * - Consulta disponibilidad
 * - Checkout de reservas
 *
 * Estados sugeridos en `reservations.status`:
 * 1 = reservada/activa (aún sin check-in)
 * 2 = ocupada (si manejas evento de check-in real)
 * 3 = finalizada (check-out)
 */
public class ReservationsController extends HttpServlet {

    // ---------- Helpers UI ----------
    private void flash(HttpServletRequest req, String type, String msg) {
        req.getSession().setAttribute("flash_" + type, msg);
    }

    private void redirect(HttpServletRequest req, HttpServletResponse resp, String path) throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
    }

    // ---------- Disponibilidad ----------
    // ¿La habitación está libre en [from, to) considerando reservas y bloqueos?
    private boolean isRoomAvailable(Connection con, long roomId, LocalDate from, LocalDate to) throws SQLException {
        // Reservas que se solapan con [from, to)
        final String q1 = "SELECT COUNT(*) " +
                "FROM reservations " +
                "WHERE room_id = ? AND status IN (1,2) " + // 1=reservada, 2=ocupada
                "  AND NOT (checkout <= ? OR checkin >= ?)";
        try (PreparedStatement ps = con.prepareStatement(q1)) {
            ps.setLong(1, roomId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                if (rs.getInt(1) > 0)
                    return false;
            }
        }

        // Bloqueos de habitación que se solapan con [from, to)
        final String q2 = "SELECT COUNT(*) " +
                "FROM room_locks " +
                "WHERE room_id = ? " +
                "  AND NOT (to_date <= ? OR from_date >= ?)";
        try (PreparedStatement ps = con.prepareStatement(q2)) {
            ps.setLong(1, roomId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                rs.next();
                return rs.getInt(1) == 0;
            }
        }
    }

    // ---------- Tarifas ----------
    // Busca tarifa por temporada; si no hay, usa rooms.price
    private float resolveRate(Connection con, int typeRoomId, LocalDate from, LocalDate to) throws SQLException {
        final String seasonal = "SELECT price " +
                "FROM room_rates " +
                "WHERE type_room_id=? AND valid_from<=? AND valid_to>=? " +
                "ORDER BY valid_from DESC LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(seasonal)) {
            ps.setInt(1, typeRoomId);
            ps.setDate(2, Date.valueOf(from));
            ps.setDate(3, Date.valueOf(to));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getBigDecimal(1).floatValue();
            }
        }

        final String fallback = "SELECT price FROM rooms WHERE id_type=? LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(fallback)) {
            ps.setInt(1, typeRoomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getBigDecimal(1).floatValue();
            }
        }
        return 0f;
    }

    // ---------- Huésped ----------
    // Crea huésped (rol=guest) si no existe por DPI o email; retorna id
    private long ensureGuest(Connection con,
            String firstname, String secondname, String lastname1, String lastname2,
            String email, String dpi, String nit, String address, String phone) throws SQLException {
        // Heurística: DPI o email
        final String sel = "SELECT id FROM users WHERE (dpi=? AND dpi<>'') OR (email=? AND email<>'') LIMIT 1";
        try (PreparedStatement ps = con.prepareStatement(sel)) {
            ps.setString(1, dpi == null ? "" : dpi);
            ps.setString(2, email == null ? "" : email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getLong(1);
            }
        }

        final String ins = "INSERT INTO users " +
                "(user_address, email, dpi, nit, rol, user_status, user_password, firstname, secondname, firstlastname, secondlastname) "
                +
                "VALUES (?, ?, ?, ?, 'guest', 1, '12345', ?, ?, ?, ?)";
        try (PreparedStatement ps = con.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, address);
            ps.setString(2, email);
            ps.setString(3, dpi);
            ps.setString(4, nit);
            ps.setString(5, firstname);
            ps.setString(6, secondname);
            ps.setString(7, lastname1);
            ps.setString(8, lastname2);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                keys.next();
                return keys.getLong(1);
            }
        }
    }

    // ---------- Reserva ----------
    private long insertReservation(Connection con, long primaryGuestId, long roomId,
            LocalDate checkin, LocalDate checkout) throws SQLException {
        final String ins = "INSERT INTO reservations (primary_guest_id, room_id, checkin, checkout, status, created_at) "
                +
                "VALUES (?, ?, ?, ?, 1, NOW())"; // 1 = reservada
        try (PreparedStatement ps = con.prepareStatement(ins, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, primaryGuestId);
            ps.setLong(2, roomId);
            ps.setDate(3, Date.valueOf(checkin));
            ps.setDate(4, Date.valueOf(checkout));
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                keys.next();
                return keys.getLong(1);
            }
        }
    }

    private void insertReservationGuest(Connection con, long reservationId, long userId, String role)
            throws SQLException {
        final String ins = "INSERT INTO reservation_guests (reservation_id, user_id, role) VALUES (?,?,?)";
        try (PreparedStatement ps = con.prepareStatement(ins)) {
            ps.setLong(1, reservationId);
            ps.setLong(2, userId);
            ps.setString(3, role);
            ps.executeUpdate();
        }
    }

    // ---------- Cargo de habitación ----------
    private void insertRoomCharge(Connection con, long reservationId, long userId, long roomId,
            float amount, String detail, int pendingFlag) throws SQLException {
        final String ins = "INSERT INTO register " +
                "(id_user, id_room, reservation_id, type_registers, amount, pending_payment, detail, create_at) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, NOW())";
        try (PreparedStatement ps = con.prepareStatement(ins)) {
            ps.setLong(1, userId);
            ps.setLong(2, roomId);
            ps.setLong(3, reservationId);
            ps.setInt(4, 3); // 3 = Habitación
            ps.setBigDecimal(5, new java.math.BigDecimal(String.valueOf(amount)));
            ps.setInt(6, pendingFlag); // 1 = pendiente, 0 = cobrado
            ps.setString(7, detail);
            ps.executeUpdate();
        }
    }

    // ---------- Estado de habitación ----------
    private void setRoomStatus(Connection con, long roomId, int status) throws SQLException {
        try (PreparedStatement ps = con.prepareStatement("UPDATE rooms SET status=? WHERE id=?")) {
            ps.setInt(1, status);
            ps.setLong(2, roomId);
            ps.executeUpdate();
        }
    }

    // ---------- GET ----------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Endpoint sencillo para consultar disponibilidad por tipo
        // /reservations?from=YYYY-MM-DD&to=YYYY-MM-DD&type_id=#
        String fromStr = req.getParameter("from");
        String toStr = req.getParameter("to");
        String typeStr = req.getParameter("type_id");

        if (fromStr != null && toStr != null && typeStr != null) {
            try (Connection con = Db.getConnection()) {
                LocalDate from = LocalDate.parse(fromStr);
                LocalDate to = LocalDate.parse(toStr);
                int typeId = Integer.parseInt(typeStr);

                final String qRooms = "SELECT id FROM rooms WHERE id_type=? AND status IN (1,2)";
                List<Long> free = new ArrayList<>();
                try (PreparedStatement ps = con.prepareStatement(qRooms)) {
                    ps.setInt(1, typeId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) {
                            long roomId = rs.getLong(1);
                            if (isRoomAvailable(con, roomId, from, to))
                                free.add(roomId);
                        }
                    }
                }
                req.setAttribute("available_rooms", free);
                req.getRequestDispatcher("/WEB-INF/views/reservations/availability.jsp").forward(req, resp);
                return;
            } catch (Exception e) {
                e.printStackTrace();
                resp.sendError(500, "Error al consultar disponibilidad.");
                return;
            }
        }

        // (Opcional) listado básico de reservas
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(
                        "SELECT r.id, r.primary_guest_id, r.room_id, r.checkin, r.checkout, r.status, " +
                                "       u.firstname, u.firstlastname " +
                                "FROM reservations r JOIN users u ON u.id=r.primary_guest_id " +
                                "ORDER BY r.id DESC");
                ResultSet rs = ps.executeQuery()) {

            req.setAttribute("reservations_rs", rs); // o mapear a lista si prefieres
            req.getRequestDispatcher("/WEB-INF/views/reservations/index.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendError(500, "Error al listar reservas.");
        }
    }

    // ---------- POST ----------
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if ("create".equals(action)) {
            handleCreate(req, resp);
        } else if ("checkout".equals(action)) {
            handleCheckout(req, resp);
        } else {
            redirect(req, resp, "/dashboard");
        }
    }

    // Crear reserva desde la modal del dashboard
    private void handleCreate(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        // Huésped (nuevo u existente)
        String existingId = req.getParameter("existing_user_id");

        String firstname = req.getParameter("firstname");
        String secondname = req.getParameter("secondname");
        String lastname1 = req.getParameter("lastname1");
        String lastname2 = req.getParameter("lastname2");
        String email = req.getParameter("email");
        String dpi = req.getParameter("dpi");
        String nit = req.getParameter("nit");
        String address = req.getParameter("address");
        String phone = req.getParameter("phone");

        // Habitación / Fechas / Precio
        long roomId = Long.parseLong(req.getParameter("room_id"));
        int typeRoomId = Integer.parseInt(req.getParameter("type_room_id"));
        LocalDate checkin = LocalDate.parse(req.getParameter("checkin"));
        LocalDate checkout = LocalDate.parse(req.getParameter("checkout"));

        // ¿Cobrar ahora el cargo de habitación?
        boolean chargePaid = "on".equalsIgnoreCase(req.getParameter("charge_paid"));
        int pendingFlag = chargePaid ? 0 : 1;

        // Validaciones mínimas
        if (!checkout.isAfter(checkin)) {
            flash(req, "warn", "La fecha de salida debe ser posterior a la de entrada.");
            redirect(req, resp, "/dashboard");
            return;
        }

        try (Connection con = Db.getConnection()) {
            con.setAutoCommit(false);
            try {
                // 1) huésped
                long guestId;
                if (existingId != null && !existingId.isBlank()) {
                    guestId = Long.parseLong(existingId);
                } else {
                    guestId = ensureGuest(con, firstname, secondname, lastname1, lastname2, email, dpi, nit, address,
                            phone);
                }

                // 2) disponibilidad
                if (!isRoomAvailable(con, roomId, checkin, checkout)) {
                    con.rollback();
                    flash(req, "warn", "La habitación no está disponible en ese rango.");
                    redirect(req, resp, "/dashboard");
                    return;
                }

                // 3) tarifa y total
                float nightly = resolveRate(con, typeRoomId, checkin, checkout);
                long nights = Math.max(1, ChronoUnit.DAYS.between(checkin, checkout));
                float total = nightly * nights;

                // 4) inserta reserva
                long reservationId = insertReservation(con, guestId, roomId, checkin, checkout);
                insertReservationGuest(con, reservationId, guestId, "titular");

                // 5) inserta cargo de habitación (register)
                String detail = "Habitación " + roomId + " (" + nights + " noche/s) @Q" + nightly;
                insertRoomCharge(con, reservationId, guestId, roomId, total, detail, pendingFlag);

                // 6) ocupa habitación (status=2)
                setRoomStatus(con, roomId, 2);

                con.commit();
                flash(req, "ok", "Reserva creada (#" + reservationId + ").");
            } catch (Exception ex) {
                con.rollback();
                ex.printStackTrace();
                flash(req, "error", "No se pudo crear la reserva.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            flash(req, "error", "No se pudo crear la reserva (DB).");
        }

        redirect(req, resp, "/dashboard");
    }

    // Checkout: finaliza reserva y libera habitación
    private void handleCheckout(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        long reservationId = Long.parseLong(req.getParameter("reservation_id"));
        long roomId = Long.parseLong(req.getParameter("room_id"));

        try (Connection con = Db.getConnection()) {
            con.setAutoCommit(false);
            try (PreparedStatement ps = con.prepareStatement(
                    "UPDATE reservations SET status=3 WHERE id=?")) { // 3 = finalizada
                ps.setLong(1, reservationId);
                ps.executeUpdate();
            }
            setRoomStatus(con, roomId, 1); // 1 = libre
            con.commit();
            flash(req, "ok", "Check-out realizado.");
        } catch (SQLException e) {
            e.printStackTrace();
            flash(req, "error", "No se pudo realizar el check-out.");
        }
        redirect(req, resp, "/dashboard");
    }
}
