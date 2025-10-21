--Para crear el procedimiento primero se tuvo que ingresar los datos
USE hotelesapp;
SELECT * FROM rooms;

INSERT INTO types_rooms (type_description)
VALUES
('Suite De William'),
('Habitación Doble para Omar y Joseph'),
('Individual Económica de Alex'),
('Suite Ejecutiva De Mario');


INSERT INTO rooms (id_type, rooms_description, price, status)
VALUES
(1, 'Suite De William', 158.00, 1),
(2, 'Habitación Doble para Omar y Joseph', 99.00, 1),
(3, 'Individual Económica de Alex', 59.00, 1),
(4, 'Suite Ejecutiva De Mario', 200.00, 1);

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