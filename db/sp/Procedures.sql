-- Crear un nuevo registro de BILLS
ALTER TABLE bills MODIFY COLUMN num BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;

DELIMITER //
	Create procedure Create_NewBill(num bigint, id_user bigint, bills_date datetime, total decimal)
		Begin
			Insert Into bills(num, id_user, bills_date, total)
            Values(num, id_user, bills_date, total);
		End //
DELIMITER //

CALL Create_NewBill(1001, 3, '2025-10-12 09:30:00', 250.75);

-----------------
-- Crea un nuevo registro en bills_details

ALTER TABLE bills_details MODIFY COLUMN id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;

DELIMITER //
CREATE PROCEDURE Create_NewBills_details(num BIGINT, id_registers BIGINT)
BEGIN
    INSERT INTO bills_details(num, id_registers)
    VALUES(num, id_registers);
END //

DELIMITER ;

CALL Create_NewBills_details(1006, 506);
-----------
-- Crear un nuevo procedimiento en la tabla register

DELIMITER //
	CREATE PROCEDURE Create_NewRegister(id bigint, id_user bigint, id_room bigint, type_registers bigint, amount decimal, 
    pending_payment tinyint, detail varchar(250), create_at datetime, update_at datetime, deleted_at datetime)
    
		Begin 
			Insert Into register(id, id_user, id_room, type_registers, amount, pending_payment, detail, create_at, update_at, deleted_at)
            Values (id, id_user, id_room, type_registers, amount, pending_payment, detail, create_at, update_at, deleted_at);
		End//
DELIMITER //

CALL Create_NewRegister(1, 1, 1, 1, 1000, 1, 'se ha confirmado...', NOW(), NULL, NULL);
--------
-- Se obtiene el ID de register

DELIMITER //
	
    CREATE procedure Get_IdRegister()
		Begin 
        Select id FROM register;
	END//
    
DELIMITER //
    
Call Get_Id();
------------------
-- Se obtiene el ID de rooms

DELIMITER //
	
    CREATE procedure Get_Id()
		Begin 
        Select id FROM rooms;
	END//
    
DELIMITER //
    
Call Get_Id();
---------------------
-- Se obtiene por STATUS de rooms

DELIMITER //
	Create procedure Get_Status()
		Begin 
        Select Status from rooms;
	End //
    
DELIMITER //

Call Get_Status();
----------------
-- Obtener todos los datos de bills

DELIMITER //
	Create procedure Get_AllBills()
		Begin
		select * from bills ORDER BY id ASC;
	End //
DELIMITER //

Call Get_AllBills();
-----------------------------
-- Se obtiene todo de register

DELIMITER //
	
    CREATE procedure Get_AllRegister()
		Begin 
        Select * FROM register ORDER BY id ASC;
	END//
		
DELIMITER //
    
Call Get_AllRegister();
---------------------
-- Llamar todo de la tabla rooms

DELIMITER //
	Create procedure Get_All()
		Begin
			Select * from rooms ORDER BY id ASC;
	End//
DELIMITER //

Call Get_All();
-----------------
-- Se obtiener users de register

DELIMITER //
	
    CREATE procedure Get_Users()
		Begin 
        Select id_user FROM register;
	END//
    
DELIMITER //
    
Call Get_Users();
----------------------
