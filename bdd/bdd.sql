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
  `idUser` INT NOT NULL,
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
  `id` INT NOT NULL,
  `id_user` INT NULL DEFAULT NULL,
  `id_contact` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `id_user_idx` (`id_user` ASC) VISIBLE,
  CONSTRAINT `id_contact`
    FOREIGN KEY (`id_user`)
    REFERENCES `app_db`.`user` (`idUser`),
  CONSTRAINT `id_user`
    FOREIGN KEY (`id_user`)
    REFERENCES `app_db`.`user` (`idUser`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`conv`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`conv` (
  `idConv` INT NOT NULL,
  `name` VARCHAR(45) NULL DEFAULT NULL,
  `type` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`idConv`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`conv_member`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`conv_member` (
  `idconvMember` INT NOT NULL AUTO_INCREMENT,
  `idConv` INT NULL DEFAULT NULL,
  `idUser` INT NULL DEFAULT NULL,
  `role` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`idconvMember`),
  INDEX `idConv` (`idConv` ASC) VISIBLE,
  INDEX `idUser` (`idUser` ASC) VISIBLE,
  CONSTRAINT `conv_member_ibfk_1`
    FOREIGN KEY (`idConv`)
    REFERENCES `app_db`.`conv` (`idConv`),
  CONSTRAINT `conv_member_ibfk_2`
    FOREIGN KEY (`idUser`)
    REFERENCES `app_db`.`user` (`idUser`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`convmember`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`convmember` (
  `idconvMember` INT NOT NULL,
  `idConv` INT NULL DEFAULT NULL,
  `idUser` INT NULL DEFAULT NULL,
  `role` VARCHAR(45) NULL DEFAULT NULL,
  PRIMARY KEY (`idconvMember`),
  INDEX `id_conv_idx` (`idConv` ASC) VISIBLE,
  INDEX `id_member_idx` (`idUser` ASC) VISIBLE,
  CONSTRAINT `id_conv`
    FOREIGN KEY (`idConv`)
    REFERENCES `app_db`.`conv` (`idConv`),
  CONSTRAINT `id_member`
    FOREIGN KEY (`idUser`)
    REFERENCES `app_db`.`user` (`idUser`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`message`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`message` (
  `idMessage` INT NOT NULL,
  `id_conv` INT NULL DEFAULT NULL,
  `id_sender` INT NULL DEFAULT NULL,
  `content` VARCHAR(300) NULL DEFAULT NULL,
  `date` DATETIME NULL DEFAULT NULL,
  PRIMARY KEY (`idMessage`),
  INDEX `conv_idx` (`id_conv` ASC) VISIBLE,
  INDEX `sender_idx` (`id_sender` ASC) VISIBLE,
  CONSTRAINT `conv`
    FOREIGN KEY (`id_conv`)
    REFERENCES `app_db`.`conv` (`idConv`),
  CONSTRAINT `sender`
    FOREIGN KEY (`id_sender`)
    REFERENCES `app_db`.`user` (`idUser`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `app_db`.`tokenblocklist`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `app_db`.`tokenblocklist` (
  `id` INT NOT NULL,
  `jti` VARCHAR(36) NULL DEFAULT NULL,
  `created_at` DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
