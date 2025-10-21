package com.umg.models;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Register {
    private long id;
    private long idUser;
    private long idRoom;
    private long typeRegisters; // FK a type_registers.id
    private BigDecimal amount;
    private boolean pendingPayment; // 0/1
    private String detail;
    private LocalDateTime createAt;
    private LocalDateTime updateAt;
    private LocalDateTime deletedAt;
    private int status; // 1 activo, 0 anulado

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public long getIdUser() {
        return idUser;
    }

    public void setIdUser(long idUser) {
        this.idUser = idUser;
    }

    public long getIdRoom() {
        return idRoom;
    }

    public void setIdRoom(long idRoom) {
        this.idRoom = idRoom;
    }

    public long getTypeRegisters() {
        return typeRegisters;
    }

    public void setTypeRegisters(long typeRegisters) {
        this.typeRegisters = typeRegisters;
    }

    public java.math.BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(java.math.BigDecimal amount) {
        this.amount = amount;
    }

    public boolean isPendingPayment() {
        return pendingPayment;
    }

    public void setPendingPayment(boolean pendingPayment) {
        this.pendingPayment = pendingPayment;
    }

    public String getDetail() {
        return detail;
    }

    public void setDetail(String detail) {
        this.detail = detail;
    }

    public java.time.LocalDateTime getCreateAt() {
        return createAt;
    }

    public void setCreateAt(java.time.LocalDateTime createAt) {
        this.createAt = createAt;
    }

    public java.time.LocalDateTime getUpdateAt() {
        return updateAt;
    }

    public void setUpdateAt(java.time.LocalDateTime updateAt) {
        this.updateAt = updateAt;
    }

    public java.time.LocalDateTime getDeletedAt() {
        return deletedAt;
    }

    public void setDeletedAt(java.time.LocalDateTime deletedAt) {
        this.deletedAt = deletedAt;
    }

    public int getStatus() {
        return status;
    }

    public void setStatus(int status) {
        this.status = status;
    }
}
