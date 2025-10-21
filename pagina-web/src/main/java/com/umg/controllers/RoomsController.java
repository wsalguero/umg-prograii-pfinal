package com.umg.controllers;

import com.umg.models.Rooms;
import com.umg.models.TypesRooms;
import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RoomsController extends HttpServlet {

    // ---------- Mappers ----------
    private Rooms mapRoom(ResultSet rs) throws SQLException {
        Rooms r = new Rooms();
        r.setId(rs.getInt("id"));
        r.setIdType(rs.getInt("id_type"));
        r.setDescripcion(rs.getString("rooms_description"));
        r.setPrice(rs.getFloat("price"));
        r.setStatus(rs.getInt("status"));
        // si quieres mostrar el nombre del tipo en la vista, puedes agregarlo al modelo
        // o como atributo aparte en la request. Para mantener tu modelo simple, lo leo
        // aparte:
        return r;
    }

    private TypesRooms mapType(ResultSet rs) throws SQLException {
        TypesRooms t = new TypesRooms();
        t.setId(rs.getInt("id"));
        t.setTypeDescription(rs.getString("type_description"));
        return t;
    }

    // ---------- Queries ----------
    private List<Rooms> getAllRooms() throws SQLException {
        String sql = "SELECT r.id, r.id_type, r.rooms_description, r.price, r.status " +
                "FROM rooms r WHERE r.status > 0 ORDER BY r.id DESC";
        List<Rooms> list = new ArrayList<>();
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapRoom(rs));
        }
        System.out.println("[RoomsController] rooms cargadas: " + list.size());
        return list;
    }

    private List<TypesRooms> getAllTypes() throws SQLException {
        String sql = "SELECT id, type_description FROM types_rooms ORDER BY id";
        List<TypesRooms> list = new ArrayList<>();
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next())
                list.add(mapType(rs));
        }
        System.out.println("[RoomsController] tipos cargados: " + list.size());
        return list;
    }

    private void insertRoom(Integer idNumber, int idType, String desc, float price, int status) throws SQLException {
        // si idNumber es null -> INSERT con NULL para que MySQL asigne autoincrement
        String sql = "INSERT INTO rooms (id, id_type, rooms_description, price, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection con = Db.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            if (idNumber == null)
                ps.setNull(1, Types.BIGINT);
            else
                ps.setInt(1, idNumber);
            ps.setInt(2, idType);
            ps.setString(3, desc);
            ps.setFloat(4, price);
            ps.setInt(5, status);
            ps.executeUpdate();
        }
    }

    private void updateRoom(int id, int idType, String desc, float price, int status) throws SQLException {
        String sql = "UPDATE rooms SET id_type=?, rooms_description=?, price=?, status=? WHERE id=?";
        try (Connection con = Db.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, idType);
            ps.setString(2, desc);
            ps.setFloat(3, price);
            ps.setInt(4, status);
            ps.setInt(5, id);
            ps.executeUpdate();
        }
    }

    private void softDeleteRoom(int id) throws SQLException {
        // “Eliminar” = desactivar (status = 0)
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement("UPDATE rooms SET status=0 WHERE id=?")) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    // ---------- Handlers ----------
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (req.getSession(false) == null || req.getSession(false).getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Rooms> rooms = getAllRooms();
            List<TypesRooms> types = getAllTypes();

            // Para mostrar el nombre del tipo al listar, creo un map id_type -> nombre
            // y lo paso a la vista:
            java.util.Map<Integer, String> typeNames = new java.util.HashMap<>();
            for (TypesRooms t : types) {
                typeNames.put(t.getId(), t.getTypeDescription());
            }

            req.setAttribute("rooms", rooms);
            req.setAttribute("types", types);
            req.setAttribute("typeNames", typeNames);

            req.getRequestDispatcher("/WEB-INF/views/rooms/index.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al cargar habitaciones.");
            req.getRequestDispatcher("/WEB-INF/views/rooms/index.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String action = req.getParameter("action");
        if (action == null)
            action = "create";

        try {
            switch (action) {
                case "create": {
                    String rawNumber = req.getParameter("number"); // opcional
                    Integer number = null;
                    if (rawNumber != null && !rawNumber.isBlank())
                        number = Integer.parseInt(rawNumber);

                    int idType = Integer.parseInt(req.getParameter("id_type"));
                    String desc = req.getParameter("rooms_description");
                    float price = Float.parseFloat(req.getParameter("price"));
                    int status = Integer.parseInt(req.getParameter("status")); // 1 libre, 2 ocupada, 0 desactivada
                    insertRoom(number, idType, desc, price, status);
                    break;
                }
                case "update": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    int idType = Integer.parseInt(req.getParameter("id_type"));
                    String desc = req.getParameter("rooms_description");
                    float price = Float.parseFloat(req.getParameter("price"));
                    int status = Integer.parseInt(req.getParameter("status"));
                    updateRoom(id, idType, desc, price, status);
                    break;
                }
                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    softDeleteRoom(id);
                    break;
                }
            }
            resp.sendRedirect(req.getContextPath() + "/rooms");
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Operación no realizada.");
            req.getRequestDispatcher("/WEB-INF/views/rooms/index.jsp").forward(req, resp);
        }
    }
}
