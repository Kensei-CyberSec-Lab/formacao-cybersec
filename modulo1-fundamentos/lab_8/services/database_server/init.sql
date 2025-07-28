# services/database_server/init.sql
# Script de inicialização do banco de dados.
CREATE DATABASE segredos;
USE segredos;
CREATE TABLE flags (id INT, flag VARCHAR(255));
INSERT INTO flags (id, flag) VALUES (1, 'KENSEI{SQL_INJECTION_AVANTE}');