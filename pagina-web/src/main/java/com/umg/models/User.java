package com.umg.models;

public class User {
    private int id;
    private String user_address;
    private String email;
    private String dpi;
    private String nit;
    private String rol;
    private int user_status;
    private String user_password;
    private String firstname;
    private String secondname;
    private String firstlastname;
    private String secondlastname;

    public User() {
    }

    // Getters y Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUser_address() {
        return user_address;
    }

    public void setUser_address(String user_address) {
        this.user_address = user_address;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getDpi() {
        return dpi;
    }

    public void setDpi(String dpi) {
        this.dpi = dpi;
    }

    public String getNit() {
        return nit;
    }

    public void setNit(String nit) {
        this.nit = nit;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public int getUser_status() {
        return user_status;
    }

    public void setUser_status(int user_status) {
        this.user_status = user_status;
    }

    public String getUser_password() {
        return user_password;
    }

    public void setUser_password(String user_password) {
        this.user_password = user_password;
    }

    public String getFirstname() {
        return firstname;
    }

    public void setFirstname(String firstname) {
        this.firstname = firstname;
    }

    public String getSecondname() {
        return secondname;
    }

    public void setSecondname(String secondname) {
        this.secondname = secondname;
    }

    public String getFirstlastname() {
        return firstlastname;
    }

    public void setFirstlastname(String firstlastname) {
        this.firstlastname = firstlastname;
    }

    public String getSecondlastname() {
        return secondlastname;
    }

    public void setSecondlastname(String secondlastname) {
        this.secondlastname = secondlastname;
    }

    // Método auxiliar para mostrar el nombre completo
    public String getFullName() {
        return String.format("%s %s %s %s",
                firstname != null ? firstname : "",
                secondname != null ? secondname : "",
                firstlastname != null ? firstlastname : "",
                secondlastname != null ? secondlastname : "").trim();
    }
}
