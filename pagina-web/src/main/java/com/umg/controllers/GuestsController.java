package com.umg.controllers;

import com.umg.models.User;
import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GuestsController extends HttpServlet {

    // ---------- Mappers / Queries ----------
    private User mapUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setUser_address(rs.getString("user_address"));
        u.setEmail(rs.getString("email"));
        u.setDpi(rs.getString("dpi"));
        u.setNit(rs.getString("nit"));
        u.setRol(rs.getString("rol"));
        u.setUser_status(rs.getInt("user_status"));
        u.setUser_password(rs.getString("user_password"));
        u.setFirstname(rs.getString("firstname"));
        u.setSecondname(rs.getString("secondname"));
        u.setFirstlastname(rs.getString("firstlastname"));
        u.setSecondlastname(rs.getString("secondlastname"));
        return u;
    }

    private List<User> getAllGuests(boolean onlyActive) throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users " + (onlyActive ? "WHERE user_status=1 " : "")
                + "AND role = 'guest' ORDER BY id DESC";
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {

            while (rs.next())
                users.add(mapUser(rs));
        }
        System.out.println("[GuestsController] usuarios cargados: " + users.size());
        return users;
    }

    private void insertGuest(User user) throws SQLException {
        String sql = "INSERT INTO users (user_address, email, dpi, nit, rol, user_status, user_password," +
                " firstname, secondname, firstlastname, secondlastname) " +
                "VALUES (?, ?, ?, ?, 'guest', 1, ?, ?, ?, ?, ?)";
        try (Connection con = Db.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, user.getUser_address());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getDpi());
            ps.setString(4, (user.getNit() == null || user.getNit().isBlank()) ? "CF" : user.getNit());
            ps.setString(5, user.getUser_password());
            ps.setString(6, user.getFirstname());
            ps.setString(7, user.getSecondname());
            ps.setString(8, user.getFirstlastname());
            ps.setString(9, user.getSecondlastname());
            ps.executeUpdate();
        }
    }

    private void updateGuest(User user) throws SQLException {
        String sql = "UPDATE users SET user_address=?, email=?, dpi=?, nit=?, " +
                "firstname=?, secondname=?, firstlastname=?, secondlastname=? " +
                "WHERE id=?";
        try (Connection con = Db.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, user.getUser_address());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getDpi());
            ps.setString(4, user.getNit());
            ps.setString(5, user.getFirstname());
            ps.setString(6, user.getSecondname());
            ps.setString(7, user.getFirstlastname());
            ps.setString(8, user.getSecondlastname());
            ps.setInt(9, user.getId());
            ps.executeUpdate();
        }
    }

    private void softDeleteGuest(int id) throws SQLException {
        try (Connection con = Db.getConnection();
                PreparedStatement ps = con.prepareStatement("UPDATE users SET user_status=0 WHERE id=?")) {
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
            List<User> users = getAllGuests(true); // solo activos
            req.setAttribute("users", users);
            req.getRequestDispatcher("/WEB-INF/views/guests/index.jsp").forward(req, resp);
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al cargar huéspedes.");
            req.getRequestDispatcher("/WEB-INF/views/guests/index.jsp").forward(req, resp);
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
                    User u = new User();
                    u.setFirstname(req.getParameter("firstname"));
                    u.setSecondname(req.getParameter("secondname"));
                    u.setFirstlastname(req.getParameter("firstlastname"));
                    u.setSecondlastname(req.getParameter("secondlastname"));
                    u.setEmail(req.getParameter("email"));
                    u.setDpi(req.getParameter("dpi"));
                    u.setNit(req.getParameter("nit"));
                    u.setUser_address(req.getParameter("user_address"));
                    u.setUser_password("12345"); // default
                    insertGuest(u);
                    break;
                }
                case "update": {
                    User u = new User();
                    u.setId(Integer.parseInt(req.getParameter("id")));
                    u.setFirstname(req.getParameter("firstname"));
                    u.setSecondname(req.getParameter("secondname"));
                    u.setFirstlastname(req.getParameter("firstlastname"));
                    u.setSecondlastname(req.getParameter("secondlastname"));
                    u.setEmail(req.getParameter("email"));
                    u.setDpi(req.getParameter("dpi"));
                    u.setNit(req.getParameter("nit"));
                    u.setUser_address(req.getParameter("user_address"));
                    updateGuest(u);
                    break;
                }
                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    softDeleteGuest(id); // status -> 0
                    break;
                }
            }
            resp.sendRedirect(req.getContextPath() + "/guests");
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Operación no realizada.");
            req.getRequestDispatcher("/WEB-INF/views/guests/index.jsp").forward(req, resp);
        }
    }
}
