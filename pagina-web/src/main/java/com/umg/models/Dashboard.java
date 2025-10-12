package com.umg.models;

public class Dashboard {
    public Rooms[] rooms;
    public User[] guest;
    public Bills[] bills;

    public Rooms[] getRooms() {
        return rooms;
    }

    public void setRooms(Rooms[] rooms) {
        this.rooms = rooms;
    }

    public User[] getGuest() {
        return guest;
    }

    public void setGuest(User[] guest) {
        this.guest = guest;
    }

    public Bills[] getBills() {
        return bills;
    }

    public void setBills(Bills[] bills) {
        this.bills = bills;
    }

}
