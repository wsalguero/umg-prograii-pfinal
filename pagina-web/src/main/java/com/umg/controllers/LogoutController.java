package com.umg.controllers;

import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

public class LogoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // borra SOLO si existe; no crea una nueva
        HttpSession session = req.getSession(false);
        if (session != null)
            session.invalidate();

        // vuelve al login
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp); // opcional: soporta POST también
    }
}
