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
(1, 'Alice', 'alice@gmail.com', 1, '7d517eab69064ea2ba0a013f74333061e737301350b5fd0ac3272800798f0d58', '370e4aefaa8be404caa015690d41c484b0560cab2b33981f6f4e201be9f91d20', '-----BEGIN PUBLIC KEY-----
 MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA1PfM3LQ0qmwKb3sIfrXq
 se8gV+gfr/JkUPfe8woqROlOehSa/PO/FydulV+XEFay4X9+avFrH8bPaBL/+Kvs
 awS/SMJW4kcGI3GQFFsmFQnoRkRHq8HVwiEIkK5ALNNf9y98jShzCVuJt4/DfpWu
 IpcY4RnEjM/TCKYXq+eL9uhvSK4+jhdhwkj6c8AdZuYwhq2dikJi5guGRdqHjozp
 SOqhh1NgFYRvRLUouAVFRD1IBKqJ4wOUXQu0TvYRD3B0hhysd29kPdr2mPeIItdx
 8F+HhrIo9KpjCYlLvrJFbKM0uBvJwxUPTCu05yVnBbW8mNGPTr+ra/bB4yihxPIu
 6wIDAQAB
 -----END PUBLIC KEY-----'
 , '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'),
(2, 'Bob', 'bob@gmail.com', 1, '85e96f80d06c3535808fe2e05b8059317a1ce8f84aca29701a4f23f1c2e24e07', '5c4d3d1810d848a3e4033eb000031ae3569445cf1e863d34107195df943eec22', '-----BEGIN PUBLIC KEY-----
 MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyMvB2SCba7CoRC/ZhTRB
 9CC5QkTaL8g0+okhyHQcxD7DhS2eUgKAJM1ZKcSsiIwsaIxBK96Gt5HigcJpYR90
 kdcZ6yMAbu+DVW6wwcMVWqETyzQ0eCRE5gefjEyHVSpbDj34EyxlaBkWcsMKHJNh
 Cn8WnqnVSYbFSFfy/hTFVR+GJrImHh/3bgZZkB5EpV1C44J9SIT5SLE7T/teMtN2
 DrOoS66X7iHBpSQ4VZLRjNptcscVE977oZtZAlhoN/dohrPg0hx38cfd5XaJqRjW
 gbUBhE0WHElL1LTiXyxviDUB3uBQeOKNxa5KluqoBRs1/FlAQ6E5L6Px1CvOab6V
 qQIDAQAB
 -----END PUBLIC KEY-----
 ','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');


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
   
