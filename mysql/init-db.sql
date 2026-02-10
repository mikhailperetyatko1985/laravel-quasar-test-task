-- Создание пользователя приложения и назначение прав
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

-- Предоставление необходимых прав для миграций и обычных операций
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE, DROP, INDEX, ALTER, 
      CREATE TEMPORARY TABLES, LOCK TABLES, EXECUTE, CREATE VIEW, 
      SHOW VIEW, CREATE ROUTINE, ALTER ROUTINE, EVENT, TRIGGER 
ON `${MYSQL_DATABASE}`.* TO '${MYSQL_USER}'@'%';

-- Применение изменений
FLUSH PRIVILEGES;
