USE shortline;

GO
DECLARE @sql VARCHAR(MAX)='';

SELECT @sql=@sql+'drop procedure ['+name +'];' FROM sys.objects 
WHERE type = 'p' AND  is_ms_shipped = 0

exec(@sql);

-------------------------------------- SP PADROES

GO
create procedure spConsultaComId
(
 @tabela varchar(max),
 @id varchar(max)
)
as
begin
 declare @sql varchar(max);
 set @sql = 'select * from ' + @tabela +
 ' where id = ' + @id
 exec(@sql)
end
 
 GO
create procedure spConsultaComJoin
(
 @tabela varchar(max),
 @campoTabela varchar(max),
 @tabelaJoin varchar(max),
 @campoJoin varchar(max),
 @campo varchar(max),
 @id varchar(max)
)
as
begin
 declare @sql varchar(max);
 set @sql = 'select * from ' + @tabela + ' inner join ' + @tabelaJoin + ' on ' + @tabela + '.' + @campoTabela + ' = ' + @tabelaJoin + '.' + @campoJoin +
 ' where ' + @tabela + '.' + @campo + ' = ''' + @id + ''''
 exec(@sql)
end
 
GO
create procedure spDelete
(
 @id int ,
 @tabela varchar(max)
)
as
begin
 declare @sql varchar(max);
 set @sql = ' delete ' + @tabela +
 ' where id = ' + cast(@id as varchar(max))
 exec(@sql)
end

GO
create procedure spConsulta
(
 @tabela varchar(max),
 @campo varchar(max),
 @id varchar(max)
)
as
begin
 declare @sql varchar(max);
 set @sql = 'select * from ' + @tabela +
 ' where ' + @campo + ' = ''' + @id + ''''
 exec(@sql)
end

GO
create procedure spListagem
(
 @tabela varchar(max),
 @ordem varchar(max))
as
begin
 exec('select * from ' + @tabela +
 ' order by ' + @ordem)
end

--------------- SP USER

GO
create procedure spInsert_TBUSER
(
 @login varchar(100),
 @first_Name varchar(100),
 @last_Name varchar(100),
 @password varchar(100),
 @company bit
)
as
begin
 insert into TBUSER
 (LOGIN, FIRST_NAME, LAST_NAME, PASSWORD, COMPANY)
 values
 (@login, @first_Name, @last_Name, @password, @company)
end

GO 
create procedure spUpdate_TBUSER
(
 @id int,
 @login varchar(100),
 @first_Name varchar(100),
 @last_Name varchar(100),
 @password varchar(100),
 @company bit
)
as
begin
 update TBUSER set
 login = @login,
 FIRST_NAME = @first_Name,
 LAST_NAME = @last_Name,
 PASSWORD = @password,
 COMPANY = @company
 where id = @id 
end

---------------------------- SP RESERVE

GO
create procedure spInsert_TBRESERVES
(
	@idUser INT,
	@idQueue INT,
	@registerIN DATETIME,
	@checkIN DATETIME = null,
	@checkOut DATETIME = null,
	@code INT,
	@status char(1)
)
as
begin
 insert into TBRESERVES
 (IDUSER, IDQUEUE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS)
 values
 (@idUser,
	@idQueue,
	@registerIN,
	@checkIN,
	@checkOut,
	@code,
	@status)
end

GO 
create procedure spUpdate_TBRESERVES
(
 @id int,
 @idUser INT,
	@idQueue INT,
	@registerIN DATETIME,
	@checkIN DATETIME,
	@checkOut DATETIME = null,
	@code INT,
	@status char(1) = null
)
as
begin
 update TBRESERVES set
 IDUSER = @idUser,
 IDQUEUE = @idQueue,
 REGISTER_IN = @registerIN,
 CHECK_IN = @checkIN,
 CHECK_OUT = @checkOut,
 CODE = @code,
 STATUS = @status
 where id = @id 
end

---------------------------------- SP QUEUE

GO
create procedure spInsert_TBQUEUE
(
	@idCompany INT,
	@description varchar(100),
	@beginDate DATETIME,
	@endDate DATETIME,
	@maxSize INT,
	@lastCode INT = 0,
	@waitInLine INT = 0,
	@vacancies INT,
	@avgWait INT = null
)
as
begin
 insert into TBQUEUE
 (IDCOMPANY,
	DESCRIPTION_QUEUE,
	BEGIN_DATE,
	END_DATE,
	MAX_SIZE,
	LAST_CODE,
	WAIT_INT_LINE,
	AVG_WAITING,
	VACANCIES
	)
 values
 (@idCompany,
	@description,
	@beginDate,
	@endDate,
	@maxSize,
	@lastCode,
	@waitInLine,
	@avgWait,
	@vacancies
	)
end

GO 
create procedure spUpdate_TBQUEUE
(
 @id int,
 @idCompany INT,
	@description varchar(100),
	@beginDate DATETIME,
	@endDate DATETIME,
	@maxSize INT,
	@lastCode INT,
	@waitInLine INT = 0,
	@vacancies INT = 0,
	@avgWait INT = null
)
as
begin
 update TBQUEUE set
 IDCOMPANY = @idCompany,
 BEGIN_DATE = @beginDate,
 END_DATE = @endDate,
 MAX_SIZE = @maxSize,
 LAST_CODE = @lastCode,
 WAIT_INT_LINE = @waitInLine,
 DESCRIPTION_QUEUE = @description,
 AVG_WAITING = @avgWait,
 VACANCIES = @vacancies
 where ID = @id 
end

---------------------------------------- SP COMPANY

GO
create procedure spInsert_TBCompany
(
	@idUser INT,
	@name varchar(100),
	@postalCode varchar(20),
	@addressNumber INT,
	@latitude decimal(11,8),
	@longitude decimal(11,8)
)
as
begin
 insert into TBCOMPANY
	(
	IDUSER,
	NAME,
	POSTAL_CODE,
	ADDRESS_NUMBER,
	LATITUDE,
	LONGITUDE
	)
 values
 (	@idUser,
	@name,
	@postalCode,
	@addressNumber,
	@latitude,
	@longitude)
end

GO 
create procedure spUpdate_TBCompany
(
	@id int,
	@idUser int,
	@name varchar(100),
	@postalCode varchar(20),
	@addressNumber INT,
	@latitude decimal(11,8),
	@longitude decimal(11,8)
)
as
begin
 update TBCOMPANY set
 NAME = @name, 
 IDUSER = @idUser,
 POSTAL_CODE = @postalCode,
 ADDRESS_NUMBER = @addressNumber,
 LATITUDE = @latitude,
 LONGITUDE = @longitude
 where ID = @id 
end
go

create procedure spGetCompanyLoginByUserId
(
	@idUser int
)
as
begin
	select *
	from TBCOMPANY
	where IDUSER = @idUser
end

-------######## Procedures Legado ########-----------

GO
create procedure spIncluiUser
(
 @login varchar(100),
 @firstName varchar(100),
 @lastName varchar(100),
 @password varchar(100)
)
as
begin
 insert into TBUSER
 (LOGIN, FIRST_NAME, LAST_NAME, PASSWORD)
 values
 (@login, @firstName, @lastName, @password)
end

drop procedure spIncluiUser

--GO
--exec spIncluiUser 'samuel','severo','simiao','senha';

GO 
create procedure spAlteraUser
(
 @id int,
 @login varchar(100),
 @firstName varchar(100),
 @lastName varchar(100),
 @password varchar(100)
)
as
begin
 update TBUSER set
 login = @login,
 FIRST_NAME = @firstName,
 LAST_NAME = @lastName,
 PASSWORD = @password
 where id = @id 
end

GO
create procedure spExcluiUser
(
 @id int 
)
as
begin
 delete TBUSER where ID = @id 
end

GO
create procedure spConsultaUser
(
 @id int 
)
as
begin
 select * from TBUSER where ID = @id
end

GO
create procedure spListagemUser
as
begin
 select * from TBUSER 
end

GO
create procedure spProximoId
(@tabela varchar(max))
as
begin
 exec('select isnull(max(id) +1, 1) as MAIOR from '
+@tabela)
end
GO

------- LEGADO RESERVE

GO
create procedure spIncluiReserve
(
	@idUser INT,
	@idQueue INT,
	@registerIN DATETIME,
	@checkIN DATETIME,
	@checkOut DATETIME,
	@code INT,
	@status char(1)
)
as
begin
 insert into TBRESERVES
 (IDUSER, IDQUEUE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS)
 values
 (@idUser,
	@idQueue,
	@registerIN,
	@checkIN,
	@checkOut,
	@code,
	@status)
end

GO 
create procedure spAlteraReserve
(
 @id int,
 @idUser INT,
	@idQueue INT,
	@registerIN DATETIME,
	@checkIN DATETIME,
	@checkOut DATETIME,
	@code INT,
	@status char(1)
)
as
begin
 update TBRESERVES set
 IDUSER = @idUser,
 IDQUEUE = @idQueue,
 REGISTER_IN = @registerIN,
 CHECK_IN = @checkIN,
 CHECK_OUT = @checkOut,
 CODE = @code,
 STATUS = @status
 where id = @id 
end

GO
create procedure spExcluiReserve
(
 @id int 
)
as
begin
 delete TBRESERVES where ID = @id 
end

GO
create procedure spConsultaReserve
(
 @id int 
)
as
begin
 select * from TBRESERVES where ID = @id
end

GO
create procedure spListagemReserve
as
begin
 select * from TBRESERVES 
end

------- LEGADO QUEUE


GO
create procedure spIncluiQueue
(
	@idCompany INT,
	@description varchar(100),
	@beginDate DATETIME,
	@endDate DATETIME,
	@maxSize INT,
	@lastCode INT,
	@waitInLine INT,
	@vacancies INT,
	@avgWait INT
)
as
begin
 insert into TBQUEUE
 (IDCOMPANY,
	DESCRIPTION_QUEUE,
	BEGIN_DATE,
	END_DATE,
	MAX_SIZE,
	LAST_CODE,
	WAIT_INT_LINE,
	AVG_WAITING,
	VACANCIES
	)
 values
 (@idCompany,
	@description,
	@beginDate,
	@endDate,
	@maxSize,
	@lastCode,
	@waitInLine,
	@avgWait,
	@vacancies
	)
end

GO 
create procedure spAlteraQueue
(
 @id int,
 @idCompany INT,
	@description varchar(100),
	@beginDate DATETIME,
	@endDate DATETIME,
	@maxSize INT,
	@lastCode INT,
	@waitInLine INT,
	@vacancies INT,
	@avgWait INT
)
as
begin
 update TBQUEUE set
 IDCOMPANY = @idCompany,
 BEGIN_DATE = @beginDate,
 END_DATE = @endDate,
 MAX_SIZE = @maxSize,
 LAST_CODE = @lastCode,
 WAIT_INT_LINE = @waitInLine,
 DESCRIPTION_QUEUE = @description,
 AVG_WAITING = @avgWait,
 VACANCIES = @vacancies
 where ID = @id 
end

GO
create procedure spExcluiQueue
(
 @id int 
)
as
begin
 delete TBRESERVES where ID = @id 
end

GO
create procedure spConsultaQueue
(
 @id int 
)
as
begin
 select * from TBQUEUE where ID = @id
end

GO
create procedure spListagemQueue
as
begin
 select * from TBQUEUE	 
end

------- LEGADO COMPANY

GO
create procedure spIncluiCompany
(
	@idUser INT,
	@name varchar(100),
	@postalCode varchar(20),
	@addressNumber INT,
	@latitude decimal(11,8),
	@longitude decimal(11,8)
)
as
begin
 insert into TBCOMPANY
	(
	IDUSER,
	NAME,
	POSTAL_CODE,
	ADDRESS_NUMBER,
	LATITUDE,
	LONGITUDE
	)
 values
 (	@idUser,
	@name,
	@postalCode,
	@addressNumber,
	@latitude,
	@longitude)
end

GO 
create procedure spAlteraCompany
(
	@id int,
	@idUser int,
	@name varchar(100),
	@postalCode varchar(20),
	@addressNumber INT,
	@latitude decimal(8,5),
	@longitude decimal(8,5)
)
as
begin
 update TBCOMPANY set
 NAME = @name, 
 IDUSER = @idUser,
 POSTAL_CODE = @postalCode,
 ADDRESS_NUMBER = @addressNumber,
 LATITUDE = @latitude,
 LONGITUDE = @longitude
 where ID = @id 
end

GO
create procedure spExcluiCompany
(
 @id int 
)
as
begin
 delete TBCOMPANY where ID = @id 
end

GO
create procedure spConsultaCompany
(
 @id int 
)
as
begin
 select * from TBCOMPANY where ID = @id
end

GO
create procedure spListagemCompany
as
begin
 select * from TBCOMPANY	 
end

------- LEGADO LOGRESERVE

GO
create procedure spIncluiLogReserve
(
	@idUser INT,
	@idQueue INT,
	@idReserve INT,
	@registerIN DATETIME,
	@checkIN DATETIME,
	@checkOut DATETIME,
	@code INT,
	@status char(1),
	@operation char(1),
	@includeIn datetime
)
as
begin
 insert into LGRESERVES
 (IDUSER, IDQUEUE,IDRESERVE, REGISTER_IN, CHECK_IN, CHECK_OUT, CODE, STATUS,OPERATION,INCLUDE_IN)
 values
 (@idUser,
	@idQueue,
	@idReserve,
	@registerIN,
	@checkIN,
	@checkOut,
	@code,
	@status,
	@operation,
	@includeIn)
end

/*GO 
create procedure spAlteraLogReserve
(
 @id int,
 @idUser INT,
	@idQueue INT,
	@registerIN DATETIME,
	@checkIN DATETIME,
	@checkOut DATETIME,
	@code INT,
	@status char(1)
)
as
begin
 update TBRESERVES set
 IDUSER = @idUser,
 IDQUEUE = @idQueue,
 REGISTER_IN = @registerIN,
 CHECK_IN = @checkIN,
 CHECK_OUT = @checkOut,
 CODE = @code,
 STATUS = @status
 where iduser = @id 
end


GO
create procedure spExcluiLogReserve
(
 @id int 
)
as
begin
 delete TBRESERVES where IDRESERVE = @id 
end
*/

GO
create procedure spConsultaLogReserve
(
 @id int 
)
as
begin
 select * from LGRESERVES where ID = @id
end

GO
create procedure spListagemLogReserve
as
begin
 select * from LGRESERVES 
end

------- LEGADO LOGQUEUE


GO
create procedure spIncluiLogQueue
(
	@idCompany INT,
	@idQueue INT,
	@description varchar(100),
	@beginDate DATETIME,
	@endDate DATETIME,
	@maxSize INT,
	@lastCode INT,
	@waitInLine INT,
	@operation char(1),
	@includeIn datetime
)
as
begin
 insert into LGQUEUE
 (
	IDCOMPANY,
	IDQUEUE,
	DESCRIPTION_LOG,
	BEGIN_DATE,
	END_DATE,
	MAX_SIZE,
	LAST_CODE,
	WAIT_INT_LINE,
	OPERATION,
	INCLUDE_IN
 )
 values
 (@idCompany,
	@idQueue,
	@description,
	@beginDate,
	@endDate,
	@maxSize,
	@lastCode,
	@waitInLine,
	@operation,
	@includeIn)
end

GO
create procedure spConsultaLogQueue
(
 @id int 
)
as
begin
 select * from LGQUEUE where ID = @id
end

GO
create procedure spListagemLogQueue
as
begin
 select * from LGQUEUE	 
end
