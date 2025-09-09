-- Ingreso de datos de los usuarios
INSERT INTO users (
  fullname, user_address, email, dpi, nit, rol, user_status, user_password
) VALUES ('Mario cosiga', 'Zona 1, pinula', 'mario@example.com', '1234567890101', '1234567-8', 'admin', 1, 'mmm123'),
  ('Omar ramos', 'zona 16, Ciudad de Guatemala', 'omar@example.com', '3216549870123', '4567890-1', 'admin', 2, 'oooo123'),
  ('Omar ramos', 'zona 16, Ciudad de Guatemala', 'omar@example.com', '3216549870123', '4567890-1', 'admin', 2, 'oooo123'),
  ('Alex estrada', 'Zona 16, Ciudad de Guatemala', 'alex@example.com', '3216549870123', '4567890-1', 'admin', 1, 'soyhueco456');

  -- Busqueda de usuarios
select * from users
where email = 'omar@example.com';

-- Eliminacion de usuario seleccionado
USE hotelesapp;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM users WHERE email = 'omar@example.com';
SET SQL_SAFE_UPDATES = 1;

-- Vista unica de ID
select id, fullname from users;

-- Actualización de usuarios
UPDATE users
SET 
  fullname = 'Mario Cosiga',
  user_address = 'Zona 2, Santa Catarina Pinula',
  user_status = 1
WHERE email = 'mario@example.com';

-- El status del usuario = 1
select * from users u where u.user_status=1