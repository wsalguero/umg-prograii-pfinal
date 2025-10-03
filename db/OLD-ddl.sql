drop database if exists hotelesapp;
create database hotelesapp;
use hotelesapp;
create table users(
    id bigint UNSIGNED NOT NULL AUTO_INCREMENT, 
    fullname varchar (100),
    user_address varchar(250),
    email varchar(50),
    dpi varchar (20),
    nit varchar (20),
    rol enum("admin","guest"),
    user_status tinyint,
    user_password varchar(300) , 
    primary key(id)
);

create table type_registers(
    id bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    type_description varchar(300),
    type_key enum("reservation","consumption","assignment","in","out"),
    primary key(id)
);

create table types_rooms (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    type_description VARCHAR(100),
    PRIMARY KEY(id)
);

create table bills(
    num bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    id_user bigint UNSIGNED NOT NULL,
    bills_date datetime,
    total decimal,
    primary key(num),
    foreign key(id_user) references users(id)
);

create table bills_details(
    id bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    num bigint UNSIGNED NOT NULL,
    id_registers bigint UNSIGNED NOT NULL,
    primary key(id),
    foreign key(num) references bills(num)
);

create table rooms (
    id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    id_type BIGINT UNSIGNED,
    rooms_description VARCHAR(20),
    price DECIMAL,
    status BIGINT,
    PRIMARY KEY(id),
    FOREIGN KEY(id_type) REFERENCES types_rooms(id)
);

create table register(
    id bigint UNSIGNED NOT NULL AUTO_INCREMENT,
    id_user bigint UNSIGNED NOT NULL,
    id_room bigint UNSIGNED NOT NULL,
    type_registers bigint UNSIGNED NOT NULL,
    amount decimal,
    pending_payment tinyint,
    detail varchar(250),
    create_at datetime,
    update_at datetime,
    deleted_at datetime,
    primary key(id),
	foreign key(id_user) references users(id),
	foreign key(id_room) references rooms(id),
	foreign key(type_registers) references type_registers(id)
);