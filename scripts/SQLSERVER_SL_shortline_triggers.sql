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

---------------- Evita delete sem where