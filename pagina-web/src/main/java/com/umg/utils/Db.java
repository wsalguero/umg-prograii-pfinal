package com.umg.utils;

import java.sql.*;
import java.util.*;

public class Db {
    private static final String URL = "jdbc:mysql://localhost:3307/hotelesapp" +
            "?useSSL=false&allowPublicKeyRetrieval=true" +
            "&serverTimezone=UTC&characterEncoding=UTF-8&useUnicode=true";
    private static final String USER = "root";
    private static final String PASS = "root";

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    /**
     * Ejecuta un procedimiento almacenado con parámetros y devuelve los resultados
     * como una lista de mapas (cada fila = Map columna->valor).
     */
    public static List<Map<String, Object>> ejecutarSp(String spName, Object... params) throws SQLException {
        List<Map<String, Object>> resultList = new ArrayList<>();

        // Construimos llamada dinámica: ej. { call mi_proc(?, ?) }
        StringBuilder call = new StringBuilder("{ call ");
        call.append(spName).append("(");
        for (int i = 0; i < params.length; i++) {
            call.append("?");
            if (i < params.length - 1)
                call.append(",");
        }
        call.append(") }");

        try (Connection con = getConnection();
                CallableStatement stmt = con.prepareCall(call.toString())) {

            // Pasar parámetros
            for (int i = 0; i < params.length; i++) {
                stmt.setObject(i + 1, params[i]);
            }

            boolean hasResult = stmt.execute();
            if (hasResult) {
                try (ResultSet rs = stmt.getResultSet()) {
                    ResultSetMetaData meta = rs.getMetaData();
                    int columnCount = meta.getColumnCount();

                    while (rs.next()) {
                        Map<String, Object> row = new HashMap<>();
                        for (int i = 1; i <= columnCount; i++) {
                            row.put(meta.getColumnLabel(i), rs.getObject(i));
                        }
                        resultList.add(row);
                    }
                }
            }
        }

        return resultList;
    }
}
