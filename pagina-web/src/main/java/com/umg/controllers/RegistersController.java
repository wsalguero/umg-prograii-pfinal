package com.umg.controllers;

import com.umg.models.Register;
import com.umg.models.Rooms;
import com.umg.models.User;
import com.umg.models.TypeRegisters; // si tu clase se llama TypeRegisters
import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.*;
import java.util.*;

public class RegistersController extends HttpServlet {

    // ---------- mappers ----------
    private Register mapRegister(ResultSet rs) throws SQLException {
        Register r = new Register();
        r.setId(rs.getLong("id"));
        r.setIdUser(rs.getLong("id_user"));
        r.setIdRoom(rs.getLong("id_room"));
        r.setTypeRegisters(rs.getLong("type_registers"));
        r.setAmount(rs.getBigDecimal("amount") == null ? BigDecimal.ZERO : rs.getBigDecimal("amount"));
        r.setPendingPayment(rs.getBoolean("pending_payment"));
        r.setDetail(rs.getString("detail"));
        r.setStatus(rs.getInt("status"));
        Timestamp c = rs.getTimestamp("create_at");
        if (c != null)
            r.setCreateAt(c.toLocalDateTime());
        Timestamp u = rs.getTimestamp("update_at");
        if (u != null)
            r.setUpdateAt(u.toLocalDateTime());
        Timestamp d = rs.getTimestamp("deleted_at");
        if (d != null)
            r.setDeletedAt(d.toLocalDateTime());
        return r;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFirstname(rs.getString("firstname"));
        u.setSecondname(rs.getString("secondname"));
        u.setFirstlastname(rs.getString("firstlastname"));
        u.setSecondlastname(rs.getString("secondlastname"));
        return u;
    }

    private Rooms mapRoom(ResultSet rs) throws SQLException {
        Rooms r = new Rooms();
        r.setId(rs.getInt("id"));
        r.setIdType(rs.getInt("id_type"));
        r.setDescripcion(rs.getString("rooms_description"));
        r.setPrice(rs.getFloat("price"));
        r.setStatus(rs.getInt("status"));
        return r;
    }

    private TypeRegisters mapTypeReg(ResultSet rs) throws SQLException {
        TypeRegisters t = new TypeRegisters();
        t.setId(rs.getLong("id"));
        t.setTypeDescription(rs.getString("type_description"));
        // si tu clase tiene typeKey, también:
        // t.setTypeKey(new TypeKey(rs.getString("type_key")));
        return t;
    }

    // ---------- queries ----------
    private List<Register> getAllRegisters() throws SQLException {
        String sql = "SELECT * FROM register WHERE status<>0 ORDER BY create_at DESC";
        List<Register> list = new ArrayList<>();
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapRegister(rs));
        }
        System.out.println("[Registers] total=" + list.size());
        return list;
    }

    private List<User> getGuests() throws SQLException {
        String sql = "SELECT id, firstname, secondname, firstlastname, secondlastname FROM users WHERE rol='guest' AND user_status=1 ORDER BY id";
        List<User> list = new ArrayList<>();
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapUser(rs));
        }
        System.out.println("[Registers] guests=" + list.size());
        return list;
    }

    private List<Rooms> getFreeRoomsOrAll() throws SQLException {
        // Puedes cambiar a WHERE status=1 (libres) si así lo deseas
        String sql = "SELECT id, id_type, rooms_description, price, status FROM rooms ORDER BY id";
        List<Rooms> list = new ArrayList<>();
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapRoom(rs));
        }
        System.out.println("[Registers] rooms=" + list.size());
        return list;
    }

    private List<TypeRegisters> getRegisterTypes() throws SQLException {
        String sql = "SELECT id, type_description, type_key FROM type_registers ORDER BY id";
        List<TypeRegisters> list = new ArrayList<>();
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapTypeReg(rs));
        }
        System.out.println("[Registers] types=" + list.size());
        return list;
    }

    private void insertRegister(long idUser, long idRoom, long typeId, BigDecimal amount,
            boolean pending, String detail) throws SQLException {
        String sql = "INSERT INTO register (id_user, id_room, type_registers, amount, pending_payment, detail, create_at, status) "
                +
                "VALUES (?, ?, ?, ?, ?, ?, NOW(), 1)";
        try (Connection con = Db.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, idUser);
            ps.setLong(2, idRoom);
            ps.setLong(3, typeId);
            ps.setBigDecimal(4, amount);
            ps.setBoolean(5, pending);
            ps.setString(6, detail);
            ps.executeUpdate();
        }
    }

    private void updateRegister(long id, long idUser, long idRoom, long typeId, BigDecimal amount,
            boolean pending, String detail, int status) throws SQLException {
        String sql = "UPDATE register SET id_user=?, id_room=?, type_registers=?, amount=?, pending_payment=?, detail=?, status=?, update_at=NOW() WHERE id=?";
        try (Connection con = Db.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setLong(1, idUser);
            ps.setLong(2, idRoom);
            ps.setLong(3, typeId);
            ps.setBigDecimal(4, amount);
            ps.setBoolean(5, pending);
            ps.setString(6, detail);
            ps.setInt(7, status);
            ps.setLong(8, id);
            ps.executeUpdate();
        }
    }

    private void softDelete(long id) throws SQLException {
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con
                        .prepareStatement("UPDATE register SET status=0, deleted_at=NOW() WHERE id=?")) {
            ps.setLong(1, id);
            ps.executeUpdate();
        }
    }

    // ---------- handlers ----------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (req.getSession(false) == null || req.getSession(false).getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Register> regs = getAllRegisters();
            List<User> guests = getGuests();
            List<Rooms> rooms = getFreeRoomsOrAll();
            List<TypeRegisters> types = getRegisterTypes();

            // maps para mostrar nombres en la tabla
            Map<Long, String> guestNames = new HashMap<>();
            for (User u : guests) {
                String full = String.format("%s %s %s %s",
                        nullToEmpty(u.getFirstname()),
                        nullToEmpty(u.getSecondname()),
                        nullToEmpty(u.getFirstlastname()),
                        nullToEmpty(u.getSecondlastname())).trim();
                guestNames.put((long) u.getId(), full.replaceAll(" +", " "));
            }
            Map<Long, String> roomNames = new HashMap<>();
            for (Rooms r : rooms)
                roomNames.put((long) r.getId(), String.valueOf(r.getId()));
            Map<Long, String> typeNames = new HashMap<>();
            for (TypeRegisters t : types)
                typeNames.put(t.getId(), t.getTypeDescription());

            req.setAttribute("registers", regs);
            req.setAttribute("guests", guests);
            req.setAttribute("rooms", rooms);
            req.setAttribute("types", types);
            req.setAttribute("guestNames", guestNames);
            req.setAttribute("roomNames", roomNames);
            req.setAttribute("typeNames", typeNames);

            req.setAttribute("title", "Registros");
            req.setAttribute("active", "registers");

            req.getRequestDispatcher("/WEB-INF/views/registers/index.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al cargar registros.");
            req.getRequestDispatcher("/WEB-INF/views/registers/index.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null)
            action = "create";

        try {
            switch (action) {
                case "create": {
                    long idUser = Long.parseLong(req.getParameter("id_user"));
                    long idRoom = Long.parseLong(req.getParameter("id_room"));
                    long typeId = Long.parseLong(req.getParameter("type_registers"));
                    BigDecimal amount = new BigDecimal(req.getParameter("amount"));
                    boolean pending = "1".equals(req.getParameter("pending_payment"));
                    String detail = req.getParameter("detail");
                    insertRegister(idUser, idRoom, typeId, amount, pending, detail);
                    break;
                }
                case "update": {
                    long id = Long.parseLong(req.getParameter("id"));
                    long idUser = Long.parseLong(req.getParameter("id_user"));
                    long idRoom = Long.parseLong(req.getParameter("id_room"));
                    long typeId = Long.parseLong(req.getParameter("type_registers"));
                    BigDecimal amount = new BigDecimal(req.getParameter("amount"));
                    boolean pending = "1".equals(req.getParameter("pending_payment"));
                    String detail = req.getParameter("detail");
                    int status = Integer.parseInt(req.getParameter("status"));
                    updateRegister(id, idUser, idRoom, typeId, amount, pending, detail, status);
                    break;
                }
                case "delete": {
                    long id = Long.parseLong(req.getParameter("id"));
                    softDelete(id);
                    break;
                }
            }
            resp.sendRedirect(req.getContextPath() + "/registers");
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Operación no realizada.");
            req.getRequestDispatcher("/WEB-INF/views/registers/index.jsp").forward(req, resp);
        }
    }

    private static String nullToEmpty(String s) {
        return (s == null) ? "" : s;
    }
}
