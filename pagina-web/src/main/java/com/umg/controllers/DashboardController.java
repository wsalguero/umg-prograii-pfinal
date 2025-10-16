package com.umg.controllers;

import java.io.IOException;
import java.util.List;
import java.util.Map;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.umg.models.Dashboard;
import com.umg.utils.Db;

public class DashboardController extends HttpServlet {

    private void flashAndBack(HttpServletRequest req, HttpServletResponse resp, String msg)
            throws IOException {
        req.getSession().setAttribute("flash_error", msg);
        resp.sendRedirect(req.getContextPath() + "/login");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Dashboard obj = new Dashboard();

        try {
            // List<Map<String, Object>> rowsRooms = Db.ejecutarSp("GetUserByEmail", email);

        } catch (Exception ex) {
            ex.printStackTrace();
            flashAndBack(req, resp, "Error interno. Intenta de nuevo.");
        }
    }

}
