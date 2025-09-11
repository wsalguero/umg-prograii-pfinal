-- Se llaman todos los datos de la tabla 
DELIMITER //

CREATE PROCEDURE VerUsuarios()
BEGIN 
	SELECT * FROM users;
    END //

DELIMITER //

-- Se manda a llamar
CALL VerUsuarios();

-----------------------------------
-- Se obtiene los datos por medio del EMAIL

DELIMITER //
DROP PROCEDURE IF EXISTS GetByEmail //

CREATE PROCEDURE GetByEmail (
    IN p_email VARCHAR(50)
)
BEGIN
    SELECT id, user_password, email, user_address
    FROM users
    WHERE email = p_email
    AND user_status = 1;
END //

DELIMITER ;

-- Se mandan a llamar los datos
CALL GetByEmail('omar@example.com');
----------------------------------------
-- Se eliminara un usuario del correo que nosotros queramos
DELIMITER //
CREATE PROCEDURE DeleteUser(
    IN p_email VARCHAR(50)
)
BEGIN
    DELETE FROM users
    WHERE email = p_email;
END //

DELIMITER ;

-- Para ejecutar la llamada
CALL DeleteUser('omar@example.com')
-----------------------------------
-- Mostrara unicamente el DI y el nombre completo de la tabla USERS
DELIMITER //
CREATE PROCEDURE VerDato()
BEGIN 
	SELECT id, fullname FROM users;
END //

DELIMITER //

-- Se ejecutara el dato
CALL VerDato();
--------------------------------------
DELIMITER //
CREATE PROCEDURE UpUsers(
IN fullname varchar (100),
IN user_address varchar(250),
IN user_status tinyint
)
BEGIN 
    UPDATE users
    SET fullname = p_fullname,
        user_address = p_user_address,
        user_status = p_user_status
    WHERE email = p_email;
END //

DELIMITER ;


-- Se va a llamar para actualizar
CALL UpUsers ('Mario Cosigua', 'Santa Catarina Pinula', 1)
------------------------------
DELIMITER //

DROP PROCEDURE IF EXISTS UserAct;

CREATE PROCEDURE UserAct()
BEGIN
    SELECT *
    FROM users
    WHERE user_status = 1;
END //

DELIMITER ;

CALL UserAct();