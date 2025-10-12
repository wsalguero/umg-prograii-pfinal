package com.umg.models;

public class TypeRegisters {
    private long id;
    private String typeDescription;
    private TypeKey typeKey; 

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public String getTypeDescription() {
        return typeDescription;
    }

    public void setTypeDescription(String typeDescription) {
        this.typeDescription = typeDescription;
    }

    public TypeKey getTypeKey() {
        return typeKey;
    }

    public void setTypeKey(TypeKey typeKey) {
        this.typeKey = typeKey;
    }

    public TypeRegisters() {}

    public TypeRegisters(long id, String typeDescription, TypeKey typeKey) {
        this.id = id;
        this.typeDescription = typeDescription;
        this.typeKey = typeKey;

    }
}