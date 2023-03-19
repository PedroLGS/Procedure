CREATE DATABASE cpf_cadastro

USE cpf_cadastro

CREATE TABLE cliente (
cpf					CHAR(11)		NOT NULL,
nome				VARCHAR(100)	NOT NULL,
email				VARCHAR(200)	NOT NULL,
limite_de_credito	DECIMAL(7,2)	NOT NULL,
dt_nascimento		DATE			NOT NULL
PRIMARY KEY(cpf)
)

CREATE PROCEDURE calc_prim_dig (@cpf CHAR(11), @digito INT, @valido INT OUTPUT)
AS
		DECLARE @parte1		VARCHAR(09),
				@partecpf	INT,
				@n1		    INT,
				@n2		    INT,
				@valor		DECIMAL(38,5),	
				@i			INT
		SET @i = 10
		SET @parte1 = ''
		SET @partecpf = 1
		SET @valor = 0
		SET @valido = 0

		WHILE (@digito > 0)
		BEGIN
				SET @parte1 = SUBSTRING(@cpf, @partecpf, 1)
				SET @partecpf = @partecpf + 1
				SET @valido = @valido + (CAST(@parte1 AS INT) * (@digito + 1))
				SET @digito = @digito - 1
		END
		SET @n1 = @valido / 11
		SET @n2 = @valido % 11
		SET @valido = 0
		IF (@n2 >= 2)
	    BEGIN
				SET @valido = 11 - @n2
		END

CREATE PROCEDURE calc_seg_dig (@cpf CHAR(11), @valido1 BIT OUTPUT)
AS
	SET @valido1 = 1
	SET @cpf = REPLACE(REPLACE(@cpf,'.', ''), '-', '')
	PRINT (@cpf)
	IF (LEN(@cpf) != 11)
		BEGIN
				SET @valido1 = 0
		END
	ELSE
			BEGIN
					DECLARE @digito1	INT,
							@res		INT
					SET @digito1 = 9
					SET @res = 0 
					WHILE (@digito1 <= 10)
						BEGIN
					EXEC calc_prim_dig @cpf, @digito1, @res OUTPUT
					IF (@res != SUBSTRING(@cpf, (@digito1 + 1), 1))
							BEGIN
									SET @valido1 = 0
									BREAK

							END
					SET @digito1 = @digito1 + 1
				END
			END


INSERT INTO cliente VALUES
('14889785060', 'Brian', 'brian@email.com', 15.90, GETDATE()),
('09631433013', 'Ryan', 'ryan@email.com', 139.00, GETDATE()),
('15842631059', 'Michael', 'michael@email.com', 27.50, GETDATE())

DELETE cliente 
WHERE cliente.cpf LIKE '%09631433013%'

UPDATE cliente
SET cliente.nome = 'Brian', cliente.email = 'brian@email.com', cliente.limite_de_credito = 100.00,
cliente.dt_nascimento = GETDATE()
WHERE cliente.cpf LIKE '%14889785060%'

SELECT * FROM cliente
	
CREATE PROCEDURE sp_pessoa (@opcao CHAR(1), @cpf VARCHAR(11), @nome VARCHAR(100), @email VARCHAR(200), @limite_de_credito DECIMAL(7,2),
							@dt_nascimento DATE, @saida VARCHAR(100) OUTPUT)
AS
		SET @cpf = REPLACE(REPLACE(@cpf, '.', ''), '-' , '')
		DECLARE @valido BIT
		SET @valido = 0
		EXEC calc_seg_dig @cpf, @valido OUTPUT
		IF (@cpf IS NOT NULL AND @valido = 1)
		BEGIN
			IF (UPPER(@opcao) = 'D' AND (SELECT c.cpf FROM cliente c WHERE c.cpf LIKE @cpf) IS NOT NULL)
			BEGIN
						SET @saida = 'CPF #'+CAST(@cpf AS VARCHAR(11))+' excluído'
						DELETE cliente WHERE cliente.cpf LIKE @cpf
			END
			ELSE
			BEGIN
			IF (UPPER(@opcao) = 'D' AND (SELECT c.cpf FROM cliente c WHERE c.cpf LIKE @cpf) IS NULL)
			BEGIN
						SET @saida = 'Pessoa não cadastrada'
			END
			IF (@nome IS NOT NULL OR @email IS NOT NULL OR @limite_de_credito IS NOT NULL OR @dt_nascimento IS NOT NULL)
			BEGIN
			IF (UPPER(@opcao) = 'I' AND (SELECT c.cpf FROM cliente c WHERE c.cpf LIKE @cpf) IS NULL)
			BEGIN
						SET @saida = 'CPF #'+CAST(@cpf AS VARCHAR(11))+' inserida'
						INSERT INTO cliente VALUES
							(@cpf, @nome, @email, @limite_de_credito, @dt_nascimento)
			END
			ELSE
			BEGIN
			IF (UPPER(@opcao) = 'I' AND (SELECT c.cpf FROM cliente c WHERE c.cpf LIKE @cpf) IS NOT NULL)
			BEGIN
						SET @saida = 'Pessoa ja cadastrada'
					END
			END
			IF (UPPER(@opcao) = 'A' AND (SELECT c.cpf FROM cliente c WHERE c.cpf LIKE @cpf) IS NOT NULL)
			BEGIN
						SET @saida = 'CPF #'+CAST(@cpf AS VARCHAR(11))+' atualizado'
						UPDATE cliente
						SET cliente.nome = @nome, cliente.email = @email, cliente.limite_de_credito = @limite_de_credito, cliente.dt_nascimento = @dt_nascimento
						WHERE cliente.cpf LIKE @cpf
			END
			ELSE	
			BEGIN
			IF (UPPER(@opcao) = 'A'	AND (SELECT c.cpf FROM cliente c WHERE c.cpf LIKE @cpf) IS NULL)
			BEGIN
						SET @saida = 'Pessoa não cadastrada'
			END
			END
			END
			ELSE
			BEGIN
						SET @saida = 'pessoa nula ou invalida'
			END
			END
			END
			ELSE
			BEGIN
						SET @saida = 'cpf invalido'
			END

DECLARE @opcao1 VARCHAR(01),
		@cpf1 VARCHAR(11),
		@nome1 VARCHAR(100),
		@email1 VARCHAR(200),
		@limite_de_credito1 DECIMAL(7,2),
		@dt_nascimento1 DATE,
		@saida1 VARCHAR(100)

SET @opcao1 = 'D'
SET @cpf1 = '14889785060'
SET @nome1 = 'Brian'
SET @email1 = 'brian@email.com'
SET @limite_de_credito1 = 100.00
SET @dt_nascimento1 = GETDATE()
SET @saida1 = ''

EXEC sp_pessoa @opcao1, @cpf1, @nome1, @email1, @limite_de_credito1, @dt_nascimento1, @saida1 OUTPUT
PRINT @saida1

SELECT c.cpf, c.nome, c.email , c.limite_de_credito, c.dt_nascimento 
FROM cliente c