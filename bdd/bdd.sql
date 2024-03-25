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
  `password_hash` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`idUser`))
ENGINE = InnoDB
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
AUTO_INCREMENT = 2
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`conv`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`conv` (
  `idConv` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(45) NULL DEFAULT NULL,
  `type` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`idConv`))
ENGINE = InnoDB
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
AUTO_INCREMENT = 3
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
  `is_read` TINYINT NULL DEFAULT NULL,
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

-- ---------------------------------------------------
-- Insérer des valeurs dans la table `user`
INSERT INTO app_db.user (idUser, username, email, password_hash) VALUES
(1, 'Alice', 'alice@gmail.com', '123test'),
(2, 'Bob', 'bob@gmail.com', '123test');

-- Insérer des valeurs dans la table `contact`
INSERT INTO app_db.contact (id, id_user, id_contact) VALUES
(1, 1, 2),
(2, 2, 1);

-- Insérer des valeurs dans la table `conv`
INSERT INTO app_db.conv (idConv, name, type) VALUES
(1, 'Group 1', ''),
(2, 'Group 2', '');

-- Insérer des valeurs dans la table `conv_member`
INSERT INTO app_db.convmember (idconvMember, idConv, idUser, role) VALUES
(1, 1, 1, ''),
(2, 1, 2, ''),
(3, 2, 1, ''),
(4, 2, 2, '');

-- Insérer des valeurs dans la table `message`
INSERT INTO app_db.message (idMessage, id_conv, id_sender, content, date) VALUES
(1, 1, 1, 'Hello, how are you?', '2024-03-09 12:00:00',1),
(2, 1, 2, 'Hi, I am fine thanks!', '2024-03-09 12:05:00',1);
