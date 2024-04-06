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
  `valid_code` VARCHAR(6) NULL DEFAULT NULL,
  `salt` VARCHAR(255) NULL DEFAULT NULL,
  `public_key` VARCHAR(4096) NULL DEFAULT NULL,
  `private_key` VARCHAR(4096) NULL DEFAULT NULL,
  PRIMARY KEY (`idUser`),
  UNIQUE(`username`),
  UNIQUE (`email`))
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

-- mdp = 123Test!
INSERT INTO user (idUser, username, email, is_validate, valid_code, password_hash, salt, public_key, private_key) VALUES
(1,'Bob','bob.bob@gmail.com',	1,'023617',	'5fadd9e9104d9b253b9cfe7cf472e265d7d9967957feb04c97166bb9e555b812','woPPMsVNslJ9euh40y2WpcZ4GEVBdEj3ky/vDmPDpVM=','1/8uzd6LRVME7D6OS1aSvP1K+bU2YIuFHRtqD++hXAg=','bui2qKzBuUf0g9qtkaFIxCXJF7+oMCYww4PpYxPZ6etWEwxYxEERrcZrhySnL4eA'),
(2,'Alice','alice.alice@gmail.com',1,'862168','3a69837b4e63087ef3d04297bfe3a9de6f3f70ae00ac851b965f1fac764b7865','cBm2hSDL+NglXxwtgsSdo+ESxT24dHYuDObK2WJuz1Y=','QR3WTQgOjrZoSuTkXXeTQ6YZEv7MlIJUlAskTdB0tzI=','iKaV6juMwRUIpA6ymfcN5t736taY6/hNOMu9PJIwrGyMWEyCsUAt2RSuiV+RW+dY');
