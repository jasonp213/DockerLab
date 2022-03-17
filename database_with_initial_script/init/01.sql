CREATE DATABASE IF NOT EXISTS `test`;
GRANT ALL ON `test`.* TO 'user'@'%';

CREATE TABLE IF NOT EXISTS `test`.`users`
(
    id int primary key auto_increment,
    name char(128) not null
);
