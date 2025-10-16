--Procedimiento para llamar los datos rooms
	Delimiter //
    Create procedure VerRooms ()
    Begin 
		Select * from rooms;
	End //
    Delimiter 
    
    
    Call	VerRooms();

--Procedimiento para insertar datos
DROP PROCEDURE IF EXISTS GuardarDatos;
DELIMITER //
CREATE PROCEDURE GuardarDatos(IN id_type BIGINT, IN rooms_description VARCHAR(20), IN price DECIMAL, IN status BIGINT
)
BEGIN
    INSERT INTO rooms (id_type, rooms_description, price, status)
    VALUES (id_type, rooms_description, price, status);
END //
DELIMITER ;

CALL GuardarDatos(4, 'Cuarto de invitados', 75.50, 2);