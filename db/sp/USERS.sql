-- GetUserByEmail: Se obtiene los datos por medio del email

DELIMITER //
DROP PROCEDURE IF EXISTS GetUserByEmail //

CREATE PROCEDURE GetUserByEmail (
    IN p_email VARCHAR(50)
)
BEGIN
    SELECT id, user_password, email, user_address, fullname,  user_status
    FROM users
    WHERE email = p_email
    AND user_status = 1;
END //

DELIMITER ;

call GetUserByEmail('wesito2004@gmail.com')