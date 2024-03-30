-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema app_db
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema app_db
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `app_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `app_db` ;

-- -----------------------------------------------------
-- Table `app_db`.`user`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`user` (
  `idUser` INT NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(45) NULL DEFAULT NULL,
  `email` VARCHAR(45) NULL DEFAULT NULL,
  `is_validate` TINYINT NULL DEFAULT 0,
  `password_hash` VARCHAR(255) NULL DEFAULT NULL,
  `salt` VARCHAR(255) NULL DEFAULT NULL,
  `public_key` VARCHAR(4096) NULL DEFAULT NULL,
  `private_key` VARCHAR(4096) NULL DEFAULT NULL,
  PRIMARY KEY (`idUser`),
  UNIQUE (`email`))
ENGINE = InnoDB
AUTO_INCREMENT = 15
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`contact`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`contact` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `id_user` INT NULL DEFAULT NULL,
  `id_contact` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `Iduser_idx` (`id_user` ASC) VISIBLE,
  INDEX `Idcontact_idx` (`id_contact` ASC) VISIBLE,
  CONSTRAINT `Idcontact`
    FOREIGN KEY (`id_contact`)
    REFERENCES `app_db`.`user` (`idUser`),
  CONSTRAINT `Iduser`
    FOREIGN KEY (`id_user`)
    REFERENCES `app_db`.`user` (`idUser`))
ENGINE = InnoDB
AUTO_INCREMENT = 15
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`conv`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`conv` (
  `idConv` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL DEFAULT NULL,
  `type` VARCHAR(45) NULL DEFAULT NULL,
  `creation_date` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`idConv`))
ENGINE = InnoDB
AUTO_INCREMENT = 6
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`convmember`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`convmember` (
  `idconvMember` INT NOT NULL AUTO_INCREMENT,
  `idConv` INT NULL DEFAULT NULL,
  `idUser` INT NULL DEFAULT NULL,
  `role` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`idconvMember`),
  INDEX `conv_idx` (`idConv` ASC) VISIBLE,
  INDEX `user_idx` (`idUser` ASC) VISIBLE,
  CONSTRAINT `conv`
    FOREIGN KEY (`idConv`)
    REFERENCES `app_db`.`conv` (`idConv`),
  CONSTRAINT `user`
    FOREIGN KEY (`idUser`)
    REFERENCES `app_db`.`user` (`idUser`))
ENGINE = InnoDB
AUTO_INCREMENT = 11
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`message`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`message` (
  `idMessage` INT NOT NULL AUTO_INCREMENT,
  `id_conv` INT NULL DEFAULT NULL,
  `id_sender` INT NULL DEFAULT NULL,
  `content` VARCHAR(300) NULL DEFAULT NULL,
  `date` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  `is_read` TINYINT NULL DEFAULT 0,
  PRIMARY KEY (`idMessage`),
  INDEX `sender_idx` (`id_sender` ASC) VISIBLE,
  INDEX `id_conv_idx` (`id_conv` ASC) VISIBLE,
  CONSTRAINT `id_conv`
    FOREIGN KEY (`id_conv`)
    REFERENCES `app_db`.`conv` (`idConv`),
  CONSTRAINT `sender`
    FOREIGN KEY (`id_sender`)
    REFERENCES `app_db`.`user` (`idUser`))
ENGINE = InnoDB
AUTO_INCREMENT = 3
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`tokenblocklist`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`tokenblocklist` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `jti` VARCHAR(36) NULL DEFAULT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

INSERT INTO user (idUser, username, email, is_validate, password_hash, salt, public_key, private_key) VALUES 
(1, 'Alice', 'alice@gmail.com', 1, '7d517eab69064ea2ba0a013f74333061e737301350b5fd0ac3272800798f0d58', '370e4aefaa8be404caa015690d41c484b0560cab2b33981f6f4e201be9f91d20', '-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1PfM3LQ0qmwKb3sIfrXq\nse8gV+gfr/JkUPfe8woqROlOehSa/PO/FydulV+XEFay4X9+avFrH8bPaBL/+Kvs\nawS/SMJW4kcGI3GQFFsmFQnoRkRHq8HVwiEIkK5ALNNf9y98jShzCVuJt4/DfpWu\nIpcY4RnEjM/TCKYXq+eL9uhvSK4+jhdh...\nqk3o+TZpFFdAsGYyI4KrhkmlQpNg0ASxBZ2ryyXYJYKXLPUt5JEde82X/gJBGhkRNl0ayn+Pf7Vv5hylkA3Tl8S0BLRDb9rIV8wOlfgMmc12ns0bRg1HKGTJpjHDgjnks3wIQRLlphSeDVjfef9GQwyM4QPn6itek9zXcdC/uyac4ZbYLB+jx75VLqFEzwjGlyu0p/d94szki0K5l6ESbavpFbH/LziQn/13dNZKhwjGHkdl1cn3FcSL5WndyV...'),
(2, 'Bob', 'bob@gmail.com', 1, '85e96f80d06c3535808fe2e05b8059317a1ce8f84aca29701a4f23f1c2e24e07', '5c4d3d1810d848a3e4033eb000031ae3569445cf1e863d34107195df943eec22', '-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyMvB2SCba7CoRC/ZhTRB\n9CC5QkTaL8g0+okhyHQcxD7DhS2eUgKAJM1ZKcSsiIwsaIxBK96Gt5HigcJpYR90\nkdcZ6yMAbu+DVW6wwcMVWqETyzQ0eCRE5gefjEyHVSpbDj34EyxlaBkWcsMKHJNh\nCn8WnqnVSYbFSFfy/hTFVR+GJrImHh/3...\n/p7asaNIL8WTf5CIJ7q87hsIvFABtvr8UmUkmx47ooRmYHiCoR9JjzWo2R3VTVXJ6HR1kf9Jm+sGV76amSnYQE1/PC7tdy2lgOb9EyQQF97MEheom6jIG98Tc6FVnjNKnVCpNBqfxCWwyr2Rl8OT+tdeRK48udKNL3IlzvnpPU7K+G/qL3zQU7SyJi+xm/93aKa6z8UqeSoz56R99cnEgc1gg1rippzHN63lsS5CegvFpK8iCJD0QEF3cU65jX...');


INSERT INTO contact (id, id_user, id_contact) VALUES 
(1,2,1),
(2,1,12);

INSERT INTO conv (name, type, creation_date)
VALUES ('Alice#1_Bob#2', 'private', '2024-03-28 12:00:00');

INSERT INTO convmember (idConv, idUser, role)
VALUES (1, 1, ''),
       (1, 2, '');

INSERT INTO message (id_conv, id_sender, content, date, is_read)
VALUES (1, 1, 'Hello how are you today my dear friend ?', '2024-03-28 13:00:00', TRUE),
       (1, 2, 'I'm fine thank you and you ?', '2024-03-28 13:05:00', TRUE);
   
