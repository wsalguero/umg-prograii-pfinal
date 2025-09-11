DELIMITER //

DROP PROCEDURE IF EXISTS USERS_GetByEmail
CREATE PROCEDURE USERS_GetByEmail (
    IN p_email varchar(50)
)

BEGIN 
    SELECT id, user_password, email, user_address from users us where us.email = p_email and user_status = 1
END

//