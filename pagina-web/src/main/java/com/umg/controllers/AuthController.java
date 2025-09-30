package com.umg.controllers;

import com.umg.models.Login;
import com.umg.utils.Db;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public class AuthController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        String email = trim(req.getParameter("email"));
        String pass = trim(req.getParameter("password"));

        // Validación rápida
        if (email.isEmpty() || pass.isEmpty()) {
            flashAndBack(req, resp, "Ingresa correo y contraseña.");
            return;
        }

        try {
            // Llamada al SP: GetUserByEmail(IN p_email VARCHAR(50))
            List<Map<String, Object>> rows = Db.ejecutarSp("GetUserByEmail", email);

            if (rows.isEmpty()) {
                // No existe usuario con ese correo o user_status != 1
                flashAndBack(req, resp, "Usuario no encontrado o inactivo.");
                return;
            }

            Map<String, Object> row = rows.get(0);

            String dbEmail = asString(row.get("email"));
            String dbPass = asString(row.get("user_password"));

            boolean ok = pass.equals(dbPass);

            if (!ok) {
                flashAndBack(req, resp, "Credenciales inválidas.");
                return;
            }

            // Login correcto: guarda un objeto pequeño en sesión
            HttpSession session = req.getSession(true);
            Login user = new Login();
            user.setEmail(dbEmail);
            user.setPassword(null); // no se guarda password en session
            session.setAttribute("user", user);

            resp.sendRedirect(req.getContextPath() + "/dashboard");
        } catch (SQLException ex) {
            ex.printStackTrace();
            flashAndBack(req, resp, "Error en la base de datos. Intenta de nuevo.");
        } catch (Exception ex) {
            ex.printStackTrace();
            flashAndBack(req, resp, "Error interno. Intenta de nuevo.");
        }
    }

    // ------------------ helpers ------------------

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private static String asString(Object o) {
        return o == null ? null : String.valueOf(o);
    }

    private void flashAndBack(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws IOException {
        req.getSession().setAttribute("flash_error", msg);
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
