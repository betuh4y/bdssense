CREATE TABLE usuario (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nome_usuario VARCHAR(80),
  CPF_usuario VARCHAR(11),
  telefone VARCHAR(20),
  senha VARCHAR(255) -- campo para armazenar senha com hash
);
CREATE TABLE registro_mov (
  id INT AUTO_INCREMENT PRIMARY KEY,
  ds_registro VARCHAR(200),
  dt_registro DATE,
  hora_registro TIME,
  tp_acao VARCHAR(100)
);
CREATE TABLE log (
  id_log INT AUTO_INCREMENT PRIMARY KEY,
  tp_acao CHAR(1), -- I: Inserção, U: Update, D: Delete
  login_user VARCHAR(20),
  dt_acao DATETIME,
  id_registro_mov INT,
  ds_registro_mov VARCHAR(100),
  tp_acao_registro_antes VARCHAR(100),
  tp_acao_registro_new VARCHAR(100)
);
DELIMITER $$

CREATE PROCEDURE sp_inserir_registro_mov (
  IN p_ds_registro VARCHAR(200),
  IN p_data DATE,
  IN p_hora TIME,
  IN p_tp_acao VARCHAR(100),
  IN p_login_user VARCHAR(20)
)
BEGIN
  INSERT INTO registro_mov (ds_registro, dt_registro, hora_registro, tp_acao)
  VALUES (p_ds_registro, p_data, p_hora, p_tp_acao);

  INSERT INTO log (tp_acao, login_user, dt_acao, id_registro_mov, ds_registro_mov, tp_acao_registro_antes, tp_acao_registro_new)
  VALUES ('I', p_login_user, NOW(), LAST_INSERT_ID(), p_ds_registro, NULL, p_tp_acao);
END$$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER trg_update_registro_mov
BEFORE UPDATE ON registro_mov
FOR EACH ROW
BEGIN
  INSERT INTO log (tp_acao, login_user, dt_acao, id_registro_mov, ds_registro_mov, tp_acao_registro_antes, tp_acao_registro_new)
  VALUES ('U', 'sistema', NOW(), OLD.id, OLD.ds_registro, OLD.tp_acao, NEW.tp_acao);
END$$

DELIMITER ;
DELIMITER $$

CREATE PROCEDURE sp_login_usuario (
  IN p_CPF_usuario VARCHAR(11),
  IN p_senha VARCHAR(255)
)
BEGIN
  SELECT id_usuario, nome_usuario
  FROM usuario
  WHERE CPF_usuario = p_CPF_usuario AND senha = SHA2(p_senha, 256);
END$$

DELIMITER ;
SET GLOBAL event_scheduler = ON;
CREATE EVENT ev_limpar_registros_antigos
ON SCHEDULE EVERY 1 DAY
STARTS CURRENT_TIMESTAMP + INTERVAL 1 MINUTE
DO
  DELETE FROM registro_mov WHERE dt_registro < CURDATE() - INTERVAL 30 DAY;
