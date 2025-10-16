-- Tipos de cuarto disponibles
INSERT INTO types_rooms(type_description) VALUES('Habitacion Estandar'),( 'Suite'), ('Habitiacion Premium'); 

-- Tipos de registro (para la factura)
insert into type_registers(type_description, type_key) values('Servicio a la habitacion','consumption'),( 'Consumo Restaurante','reg-CnsRes'), ('Habitacion', 'reg-hb');