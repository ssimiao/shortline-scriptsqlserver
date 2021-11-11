use shortline;

--------------------------- Evita alterar mais de 1 registro das tabelas por operação

IF (OBJECT_ID('[dbo].[trgEvita_Dml_Muitos_Registros]') IS NOT NULL) DROP TRIGGER [dbo].[trgEvita_Dml_Muitos_Registros]
GO
 
CREATE TRIGGER [dbo].[trgEvita_Dml_Muitos_Registros] ON [dbo].[TBUSER]
FOR UPDATE, DELETE AS 
BEGIN 
  
    DECLARE 
        @Linhas_Alteradas INT = @@ROWCOUNT, 
        @MsgErro VARCHAR(MAX)
 
    IF (@Linhas_Alteradas > 1)
    BEGIN 
        ROLLBACK TRANSACTION; 
        SET @MsgErro = 'Operações de DELETE e/ou UPDATE só podem atualizar 1 registro por vez na tabela "TBUSER", e você tentou atualizar ' + CAST(@Linhas_Alteradas AS VARCHAR(50))
        RAISERROR (@MsgErro, 15, 1); 
        RETURN;
    END 
  
  
END; 


------------------------- Trigger para impedir alguém de apagar ou alterar os logs|historico de operações efetuadas da aplicação

GO
IF (OBJECT_ID('[dbo].[trgBloqueia_Dml_LGQUEUE]') IS NOT NULL) DROP TRIGGER [dbo].[trgBloqueia_Dml_LGQUEUE]

GO
  
CREATE TRIGGER [dbo].[trgBloqueia_Dml_LGQUEUE] ON [dbo].[LGQUEUE]
FOR INSERT, UPDATE, DELETE AS 
BEGIN 
  
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted) 
    BEGIN 
        ROLLBACK TRANSACTION; 
        RAISERROR ('Operações de DELETE não são permitidas na tabela "Teste_Trigger"', 15, 1); 
        RETURN;
    END 
  
  
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) 
    BEGIN 
        ROLLBACK TRANSACTION; 
        RAISERROR ('Operações de UPDATE não são permitidas na tabela "Teste_Trigger"', 15, 1); 
        RETURN;
    END 
  
END; 
GO


IF (OBJECT_ID('[dbo].[trgBloqueia_Dml_LGRESERVES]') IS NOT NULL) DROP TRIGGER [dbo].[trgBloqueia_Dml_LGRESERVES]
GO
  
CREATE TRIGGER [dbo].[trgBloqueia_Dml_LGRESERVES] ON [dbo].[LGRESERVES]
FOR INSERT, UPDATE, DELETE AS 
BEGIN 
  
  
    IF EXISTS (SELECT * FROM deleted) AND NOT EXISTS (SELECT * FROM inserted) 
    BEGIN 
        ROLLBACK TRANSACTION; 
        RAISERROR ('Operações de DELETE não são permitidas na tabela "LGRESERVES"', 15, 1); 
        RETURN;
    END 
  
  
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted) 
    BEGIN 
        ROLLBACK TRANSACTION; 
        RAISERROR ('Operações de UPDATE não são permitidas na tabela "LGRESERVES"', 15, 1); 
        RETURN;
    END 
  
END; 
GO

----------------
IF (OBJECT_ID('dbo.LGRESERVES') IS NOT NULL) DROP TABLE LGRESERVES
create table LGRESERVES(
	OPERATION CHAR(1) NULL,
	INCLUDE_IN DATETIME NULL,
	ID INT IDENTITY NOT NULL UNIQUE,
	IDQUEUE INT NOT NULL,
	IDUSER INT NOT NULL,
	IDRESERVE INT NOT NULL,
	REGISTER_IN DATETIME NULL,
	CHECK_IN DATETIME NULL,
	CHECK_OUT DATETIME NULL,
	CODE INT NULL,
	STATUS char(1) NULL
	PRIMARY KEY (ID)
);
GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgHistorico_Reserves' AND parent_id = OBJECT_ID('dbo.TBRESERVES')) > 0) DROP TRIGGER trgHistorico_Reserves
GO
 
GO
CREATE TRIGGER [dbo].[trgHistorico_Reserves] ON [dbo].[TBRESERVES] -- Tabela que a trigger será associada
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    
    SET NOCOUNT ON
 
    DECLARE 
        @Login VARCHAR(100) = SYSTEM_USER, 
        @HostName VARCHAR(100) = HOST_NAME(),
        @Data DATETIME = GETDATE()
        
 
    IF (EXISTS(SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
    BEGIN
        INSERT INTO LGRESERVES(OPERATION,INCLUDE_IN,IDUSER, IDRESERVE,IDQUEUE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS)
        SELECT 'U',@Data, IDUSER, ID,IDQUEUE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS
        FROM Inserted
 
    END
    ELSE BEGIN
 
        IF (EXISTS(SELECT * FROM Inserted))
        BEGIN
 
            INSERT INTO LGRESERVES(OPERATION,INCLUDE_IN,IDUSER,IDRESERVE, IDQUEUE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS)
			SELECT 'I',@Data, IDUSER, ID, IDQUEUE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS
            FROM Inserted
 
        END
        ELSE BEGIN
 
            INSERT INTO LGRESERVES(OPERATION,INCLUDE_IN,IDUSER, IDRESERVE, IDQUEUE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS)
			SELECT 'D',@Data, IDUSER, ID, IDQUEUE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS
            FROM Deleted
 
        END
 
    END
 
END

-------------------------------------------------------------

IF (OBJECT_ID('dbo.LGQUEUE') IS NOT NULL) DROP TABLE LGQUEUE
create table LGQUEUE(
	ID INT IDENTITY NOT NULL UNIQUE,
	IDQUEUE INT NOT NULL,
	IDCOMPANY INT NOT NULL,
	DESCRIPTION_LOG VARCHAR(20) NULL,
	BEGIN_DATE DATETIME NULL,
	END_DATE DATETIME NULL,
	MAX_SIZE INT NULL,
	LAST_CODE INT NULL,
	WAIT_INT_LINE INT NULL,
	OPERATION CHAR(1) NULL,
	INCLUDE_IN DATETIME NULL,
	PRIMARY KEY (ID)
);
GO

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgHistorico_Queue' AND parent_id = OBJECT_ID('dbo.TBQUEUE')) > 0) DROP TRIGGER trgHistorico_Queue
GO
 
CREATE TRIGGER [dbo].[trgHistorico_Queue] ON [dbo].[TBQUEUE] -- Tabela que a trigger será associada
AFTER INSERT, UPDATE, DELETE AS
BEGIN
    
    SET NOCOUNT ON
 
    DECLARE 
        @Login VARCHAR(100) = SYSTEM_USER, 
        @HostName VARCHAR(100) = HOST_NAME(),
        @Data DATETIME = GETDATE()
        
 
    IF (EXISTS(SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
    BEGIN
        
        INSERT INTO LGQUEUE(OPERATION,INCLUDE_IN,IDQUEUE,IDCOMPANY,DESCRIPTION_LOG,BEGIN_DATE,END_DATE,MAX_SIZE,LAST_CODE,WAIT_INT_LINE)
        SELECT 'U',@Data, ID, IDCOMPANY, DESCRIPTION_QUEUE,BEGIN_DATE,END_DATE,MAX_SIZE,LAST_CODE,WAIT_INT_LINE
        FROM Inserted
 
    END
    ELSE BEGIN
 
        IF (EXISTS(SELECT * FROM Inserted))
        BEGIN
 
            INSERT INTO LGQUEUE(OPERATION,INCLUDE_IN,IDQUEUE,IDCOMPANY,DESCRIPTION_LOG,BEGIN_DATE,END_DATE,MAX_SIZE,LAST_CODE,WAIT_INT_LINE)
			SELECT 'I',@Data, ID, IDCOMPANY, DESCRIPTION_QUEUE,BEGIN_DATE,END_DATE,MAX_SIZE,LAST_CODE,WAIT_INT_LINE
            FROM Inserted
 
        END
        ELSE BEGIN
 
            INSERT INTO LGQUEUE(OPERATION,INCLUDE_IN,IDQUEUE,IDCOMPANY,DESCRIPTION_LOG,BEGIN_DATE,END_DATE,MAX_SIZE,LAST_CODE,WAIT_INT_LINE)
			SELECT 'D',@Data, ID, IDCOMPANY,DESCRIPTION_QUEUE ,BEGIN_DATE,END_DATE,MAX_SIZE,LAST_CODE,WAIT_INT_LINE
            FROM Deleted
 
        END
 
    END
 
END

------------------------------------ trigger para aumentar e diminuir a contagem de pessoas nas filas campo wait_in_line


IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgAumentaContagem_Queue' AND parent_id = OBJECT_ID('dbo.TBRESERVES')) > 0) DROP TRIGGER trgAumentaContagem_Queue
GO
 
CREATE TRIGGER [dbo].[trgAumentaContagem_Queue] ON [dbo].[TBRESERVES] -- Tabela que a trigger será associada
AFTER INSERT AS
BEGIN
    
    SET NOCOUNT ON
        
        IF (EXISTS(SELECT * FROM Inserted))
        BEGIN
			declare @idQueue int = (Select IDQUEUE FROM inserted);
			declare @waitInLine int = (Select WAIT_INT_LINE from TBQUEUE where id = @idQueue)
            update TBQUEUE set WAIT_INT_LINE = @waitInLine + 1 where ID = @idQueue 
        END
END

------------

IF ((SELECT COUNT(*) FROM sys.triggers WHERE name = 'trgDiminuiContagem_Queue' AND parent_id = OBJECT_ID('dbo.TBRESERVES')) > 0) DROP TRIGGER trgDiminuiContagem_Queue
GO
 
CREATE TRIGGER [dbo].[trgDiminuiContagem_Queue] ON [dbo].[TBRESERVES] -- Tabela que a trigger será associada
AFTER UPDATE AS
BEGIN
    
    SET NOCOUNT ON
        
        IF (EXISTS(SELECT * FROM Inserted) AND EXISTS (SELECT * FROM Deleted))
        BEGIN
			declare @idQueue int = (Select IDQUEUE FROM inserted);
			declare @waitInLine int = (Select WAIT_INT_LINE from TBQUEUE where id = @idQueue)
            update TBQUEUE set WAIT_INT_LINE = @waitInLine - 1 where ID = @idQueue 
        END
END
