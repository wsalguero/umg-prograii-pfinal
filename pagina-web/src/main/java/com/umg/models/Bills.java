package com.umg.models;

import java.time.LocalDateTime;

public class Bills {
    private long num;
    private int idUser;
    private LocalDateTime billsDate;
    private float total;
    private BillsDetails[] details;

    public long getNum() {
        return num;
    }

    public BillsDetails[] getDetails() {
        return details;
    }

    public void setDetails(BillsDetails[] details) {
        this.details = details;
    }

    public void setNum(long num) {
        this.num = num;
    }

    public int getIdUser() {
        return idUser;
    }

    public void setIdUser(int idUser) {
        this.idUser = idUser;
    }

    public LocalDateTime getBillsDate() {
        return billsDate;
    }

    public void setBillsDate(LocalDateTime billsDate) {
        this.billsDate = billsDate;
    }

    public float getTotal() {
        return total;
    }

    public void setTotal(float total) {
        this.total = total;
    }

}
