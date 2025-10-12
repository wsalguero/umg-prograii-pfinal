package com.umg.models;

import java.time.LocalDateTime;

public class Register {

private int id;
private int idUser;
private int typeRegisters;
private float amount;
private int pendingPayment;
private String detail;
private LocalDateTime createAt;
private LocalDateTime updateAt;
private LocalDateTime deletedAt;

 // Getters y Setters
public int getId() {
    return id;
}
public void setId(int id) {
    this.id = id;
}
public int getIdUser() {
    return idUser;
}
public void setIdUser(int idUser) {
    this.idUser = idUser;
}
public int getTypeRegisters() {
    return typeRegisters;
}
public void setTypeRegisters(int typeRegisters) {
    this.typeRegisters = typeRegisters;
}
public float getAmount() {
    return amount;
}
public void setAmount(float amount) {
    this.amount = amount;
}
public int getPendingPayment() {
    return pendingPayment;
}
public void setPendingPayment(int pendingPayment) {
    this.pendingPayment = pendingPayment;
}
public String getDetail() {
    return detail;
}
public void setDetail(String detail) {
    this.detail = detail;
}
public LocalDateTime getCreateAt() {
    return createAt;
}
public void setCreateAt(LocalDateTime createAt) {
    this.createAt = createAt;
}
public LocalDateTime getUpdateAt() {
    return updateAt;
}
public void setUpdateAt(LocalDateTime updateAt) {
    this.updateAt = updateAt;
}
public LocalDateTime getDeletedAt() {
    return deletedAt;
}
public void setDeletedAt(LocalDateTime deletedAt) {
    this.deletedAt = deletedAt;
}

}

