--------------------(criação/população) -------------------
	GO
	USE master;
	CREATE DATABASE Universidade;
	GO
	USE Universidade;
	GO
	CREATE TABLE ALUNOS
	(
		MATRICULA INT NOT NULL IDENTITY
			CONSTRAINT PK_ALUNO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE CURSOS
	(
		CURSO CHAR(3) NOT NULL
			CONSTRAINT PK_CURSO PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE PROFESSOR
	(
		PROFESSOR INT IDENTITY NOT NULL
			CONSTRAINT PK_PROFESSOR PRIMARY KEY,
		NOME VARCHAR(50) NOT NULL
	);
	GO
	CREATE TABLE MATERIAS
	(
		SIGLA CHAR(3) NOT NULL,
		NOME VARCHAR(50) NOT NULL,
		CARGAHORARIA INT NOT NULL,
		CURSO CHAR(3) NOT NULL,
		PROFESSOR INT
			CONSTRAINT PK_MATERIA
			PRIMARY KEY (
							SIGLA,
							CURSO,
							PROFESSOR
						)
			CONSTRAINT FK_CURSO
			FOREIGN KEY (CURSO) REFERENCES CURSOS (CURSO),
		CONSTRAINT FK_PROFESSOR
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO
	INSERT ALUNOS
	(
		NOME
	)
	VALUES
	('Pedro');
	GO
	INSERT CURSOS
	(
		CURSO,
		NOME
	)
	VALUES
	('SIS', 'SISTEMAS'),
	('ENG', 'ENGENHARIA');
	GO
	INSERT PROFESSOR
	(
		NOME
	)
	VALUES
	('DORNEL'),
	('WALTER');
	GO
	
	INSERT MATERIAS
	(
		SIGLA,
		NOME,
		CARGAHORARIA,
		CURSO,
		PROFESSOR
	)
	VALUES
	('BDA', 'BANCO DE DADOS', 144, 'ENG', 1),
	('PRG', 'PROGRAMAÇÃO', 144, 'ENG', 2);
	GO
	CREATE TABLE MATRICULA
	(
		MATRICULA INT,
		CURSO CHAR(3),
		MATERIA CHAR(3),
		PROFESSOR INT,
		PERLETIVO INT,
		N1 FLOAT,
		N2 FLOAT,
		N3 FLOAT,
		N4 FLOAT,
		TOTALPONTOS FLOAT,
		MEDIA FLOAT,
		F1 INT,
		F2 INT,
		F3 INT,
		F4 INT,
		TOTALFALTAS INT,
		PERCFREQ FLOAT,
		RESULTADO VARCHAR(20)
			CONSTRAINT PK_MATRICULA
			PRIMARY KEY (
							MATRICULA,
							CURSO,
							MATERIA,
							PROFESSOR,
							PERLETIVO
						),
		CONSTRAINT FK_ALUNOS_MATRICULA
			FOREIGN KEY (MATRICULA)
			REFERENCES ALUNOS (MATRICULA),
		CONSTRAINT FK_CURSOS_MATRICULA
			FOREIGN KEY (CURSO)
			REFERENCES CURSOS (CURSO),
		--CONSTRAINT FK_MATERIAS FOREIGN KEY (MATERIA) REFERENCES MATERIAS (SIGLA),
		CONSTRAINT FK_PROFESSOR_MATRICULA
			FOREIGN KEY (PROFESSOR)
			REFERENCES PROFESSOR (PROFESSOR)
	);
	GO
	ALTER TABLE MATRICULA ADD MEDIAFINAL FLOAT;
	GO
	ALTER TABLE MATRICULA ADD NOTAEXAME FLOAT;
	GO


CREATE PROCEDURE sp_CadastraNotas
	(
		@MATRICULA INT,
		@CURSO CHAR(3),
		@MATERIA CHAR(3),
		@PERLETIVO CHAR(4),
		@NOTA FLOAT,
		@FALTA INT,
		@BIMESTRE INT
	)
	AS
BEGIN

		IF @BIMESTRE = 1
		    BEGIN

                UPDATE MATRICULA
                SET N1 = @NOTA,
                    F1 = @FALTA,
                    TOTALPONTOS = @NOTA,
                    TOTALFALTAS = @FALTA,
                    MEDIA = @NOTA
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
		    END

        ELSE 
        
        IF @BIMESTRE = 2
            BEGIN

                UPDATE MATRICULA
                SET N2 = @NOTA,
                    F2 = @FALTA,
                    TOTALPONTOS = @NOTA + N1,
                    TOTALFALTAS = @FALTA + F1,
                    MEDIA = (@NOTA + N1) / 2
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 3
            BEGIN

                UPDATE MATRICULA
                SET N3 = @NOTA,
                    F3 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2,
                    TOTALFALTAS = @FALTA + F1 + F2,
                    MEDIA = (@NOTA + N1 + N2) / 3
                WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;
            END

        ELSE 
        
        IF @BIMESTRE = 4
            BEGIN

                DECLARE @RESULTADO VARCHAR(50),
                        @FREQUENCIA FLOAT,
                        @MEDIAFINAL FLOAT,
                        @CARGAHORA INT 
                
                SET @CARGAHORA = (
                    SELECT CARGAHORARIA FROM MATERIAS 
                    WHERE       SIGLA = @MATERIA
                            AND CURSO = @CURSO)

                UPDATE MATRICULA
                SET N4 = @NOTA,
                    F4 = @FALTA,
                    TOTALPONTOS = @NOTA + N1 + N2 + N3,
                    TOTALFALTAS = @FALTA + F1 + F2 + F3,
                    MEDIA = (@NOTA + N1 + N2 + N3) / 4,
                    MEDIAFINAL = (@NOTA + N1 + N2 + N3) / 4,
                    PERCFREQ = 100 -( ((@FALTA + F1 + F2 + F3)*@CARGAHORA )/100)
                        WHERE MATRICULA = @MATRICULA
                    AND CURSO = @CURSO
                    AND MATERIA = @MATERIA
                    AND PERLETIVO = @PERLETIVO;

            END
            

		SELECT * FROM MATRICULA	WHERE MATRICULA = @MATRICULA
END

GO
CREATE PROCEDURE procMATRICULAALUNO
(
    @MATRICULA VARCHAR(50),
    @CURSO CHAR(3)
)
AS
BEGIN
    DECLARE @PERLETIVO INT;

    -- Obtém a matrícula do aluno
    SELECT @MATRICULA = MATRICULA
    FROM ALUNOS
    WHERE @MATRICULA = MATRICULA;

    -- Define o período letivo como o ano atual do sistema
    SET @PERLETIVO = YEAR(GETDATE());

    -- Insere os valores na tabela MATRICULA usando uma subconsulta
    INSERT INTO MATRICULA (MATRICULA, CURSO, MATERIA, PROFESSOR, PERLETIVO)
    SELECT @MATRICULA, @CURSO, SIGLA, PROFESSOR, @PERLETIVO
    FROM MATERIAS
    WHERE CURSO = @CURSO;

END
GO

/*           
Exemplo de EXECS de matrícula

EXEC procMATRICULAALUNO '1','ENG' -- Matricula o aluno Pedro (MATRICULA 1) em disciplinas de ENG
EXEC procMATRICULAALUNO '2','SIS' -- Matricula o aluno João (MATRICULA 2) em disciplinas de SIS */

/* Exemplo de EXECS para cadastro de notas

EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'ENG',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 5.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 1      -- int
EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'ENG',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 5.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 2      -- int
EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'ENG',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 5.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 3      -- int
EXEC sp_CadastraNotas @MATRICULA = 1,      -- int
                      @CURSO = 'ENG',      -- char(3)
                      @MATERIA = 'BDA',    -- char(3)
                      @PERLETIVO = '2023', -- char(4)
                      @NOTA = 5.0,         -- float
                      @FALTA = 2,
                      @BIMESTRE = 4      -- int */

----------------------------------------------------------------------------------

GO
CREATE PROCEDURE procCALCULOAPROV
(
    @MATRICULA INT,
    @MATERIA VARCHAR(3)

)
AS
BEGIN
DECLARE
    @MEDIAFINAL INT,
    @PERCFREQ INT

    -- Obtém a matrícula do aluno
    SELECT @MATRICULA = MATRICULA
    FROM ALUNOS
    WHERE @MATRICULA = MATRICULA
 
    -- Obtém a matéria
    SELECT @MATERIA = SIGLA
    FROM MATERIAS
    WHERE @MATERIA = SIGLA

    -- Obtém a média
    SET @MEDIAFINAL = (
    SELECT MEDIAFINAL
    FROM MATRICULA
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA)

    -- Obtém o percentual de frequência
    SET @PERCFREQ = (
    SELECT PERCFREQ
    FROM MATRICULA
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA)

    -- Insere o resultado na coluna RESULTADO dependendo dos cálculos abaixo
    IF @PERCFREQ < 75
    UPDATE MATRICULA 
    SET RESULTADO = 'R'
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA
    
    ELSE
    IF @MEDIAFINAL >= 7 AND @PERCFREQ >= 75
    UPDATE MATRICULA 
    SET RESULTADO='A'
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA
    
    ELSE
    IF @MEDIAFINAL < 7 AND @MEDIAFINAL >= 3 AND @PERCFREQ >= 75
    UPDATE MATRICULA 
    SET RESULTADO='E'
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA

    ELSE
    IF @MEDIAFINAL < 3
    UPDATE MATRICULA 
    SET RESULTADO='R'
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA
END
GO

/* Exemplo de EXEC para o cálculo de aprovação:
EXEC procCALCULOAPROV 1, 'BDA'
EXEC procCALCULOAPROV 1, 'PRG' */

          
          
-------------------------------------------------------------------------------
GO
CREATE PROCEDURE procEXAMEAPROV
(
    @MATRICULA INT,
    @MATERIA VARCHAR(3),
    @NOTAEXAME FLOAT
) 
AS

BEGIN

DECLARE
    @MEDIAFINAL FLOAT,
    @RESULTADO VARCHAR

-- Checa se o aluno está em exame
SET @RESULTADO =
    (SELECT RESULTADO
    FROM MATRICULA
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA)

IF @RESULTADO like 'E'

    BEGIN

    --Insere a nota do exame

    SET @MEDIAFINAL =
    (SELECT MEDIAFINAL
    FROM MATRICULA
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA)

    UPDATE MATRICULA
    SET NOTAEXAME = @NOTAEXAME
    WHERE @MATRICULA = MATRICULA
    AND @MATERIA = MATERIA

    IF @NOTAEXAME + @MEDIAFINAL >= 10
        UPDATE MATRICULA
        SET RESULTADO = 'A'
        WHERE @MATRICULA = MATRICULA
        AND @MATERIA = MATERIA

        ELSE
        UPDATE MATRICULA
        SET RESULTADO = 'DP' --dependência
        WHERE @MATRICULA = MATRICULA
        AND @MATERIA = MATERIA

    END

ELSE
    PRINT 'Não foi possível realizar o cálculo de exame, pois o aluno não está em exame!'

END
GO

/* Exemplo de cálculo de exame:
EXEC procEXAMEAPROV 1, 'BDA', 8
 */