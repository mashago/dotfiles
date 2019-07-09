
-- custom init sql
CREATE USER 'testmn'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'testmn'@'%';
