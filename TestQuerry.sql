use Laborator
go

--Insert Procedures
go
create or alter procedure insertProfession(@noRows int)
as
begin
	--Profession
	declare @id int = 1, @profName VARCHAR(50)= newID();
	while(@id < @noRows) begin
		insert into Profession
		values(@id,@profName)
		set @id = @id + 1;
		set @profName = newID();
	end
end
go
create or alter procedure insertPlayer(@noRows int)
as
begin
	--Player
	declare @id int = 1, @time int = 50;
	while(@id < @noRows) begin
		insert into Player
		values(@id,@time,@id)
		set @id = @id + 1;
	end
end
go
create or alter procedure insertMap(@noRows int)
as
begin
	--Map
	declare @id int = 1,@location VARCHAR(50) = newId();
	while(@id < @noRows) begin
		insert into Map
		values(@id,@location)
		set @id = @id + 1;
		set @location = newId()
	end
end
go
create or alter procedure insertNwAttend(@noRows int)
as
begin
	--NwAttend
	declare @id int = 1;
	while(@id < @noRows) begin
		insert into NwAttend
		values(@id, @id, @id) --id, idPlayer, idMap
		set @id = @id + 1;
	end
end
go



--Insert into Tables
create or alter procedure insertintoTables (@tableName nchar(20),@noRows int)
as
begin
	if(@tableName = 'Profession') exec insertProfession @noRows
	if(@tableName = 'Player') exec insertPlayer @noRows
	if(@tableName = 'Map') exec insertMap @noRows
	if(@tableName = 'NwAttend') exec insertNwAttend @noRows
end
go

create or alter procedure Test
as
begin
	--Stergem ce trebuie sters :^)
	delete from NwAttend
	delete from Map
	delete from RoleWar
	delete from Guild_PlayerLink
	delete from Player
	delete from Profession
	delete from TestRuns

	--Declaram si contiuam >:)
	declare @id_test int, @test_name varchar(30)
	declare @stringSql varchar(100)
	declare @noRows int, @name varchar(25), @id_table int, @id_view int
	declare @start datetime, @id_testRuns int

	declare cursor_teste cursor 
		for select * from Tests

	open cursor_teste

	fetch next from cursor_teste into @id_test, @test_name

	while @@FETCH_STATUS = 0 begin
		declare cursor_tabele cursor 
		for select Name from TestTables TT
		inner join Tables T on TT.TableID = T.TableID
			where TT.TestID = @id_test order by Position

		open cursor_tabele
		fetch next from cursor_tabele into @name--stergerea datelor din tabele
		while @@FETCH_STATUS = 0 begin
		
			set @stringSql = 'delete from ' + @name
			exec (@stringSql)

			fetch next from cursor_tabele into @name
		end

		close cursor_tabele
		deallocate cursor_tabele

	
		declare cursor_tabele cursor
		for select T.TableID, NoOfRows, Name from TestTables TT
		inner join Tables T on TT.TableID = T.TableID
			where TT.TestID = @id_test order by Position desc

		open cursor_tabele

		insert into TestRuns
		values(@test_name, GETDATE(), null)
		set @id_testRuns = SCOPE_IDENTITY()

		fetch next from cursor_tabele into @id_table, @noRows, @name--introducerea datelor in ordine inversa
		while @@FETCH_STATUS = 0 begin

			set @start = GETDATE()
			exec insertIntoTables @name, @noRows
			insert into TestRunTables values (@id_testRuns ,@id_table, @start, GETDATE())

			fetch next from cursor_tabele into @id_table, @noRows, @name
		end
		close cursor_tabele
		deallocate cursor_tabele


		declare cursor_view cursor
		for select TV.ViewID, Name from TestViews TV
		inner join Views V on TV.ViewID = V.ViewID
			where TV.TestID = @id_test 

		open cursor_view
		fetch next from cursor_view into @id_view, @name--evaluarea timpului de executie a view-urilor
		while @@FETCH_STATUS = 0 begin

		
			set @stringSql = 'select * from ' + @name
			set @start = GETDATE()
			exec (@stringSql)
			--exec sp_execute @stringSql

			insert into TestRunViews values (@id_testRuns ,@id_view, @start, GETDATE())
			fetch next from cursor_view into @id_view, @name
		end
		close cursor_view
		deallocate cursor_view

		update TestRuns
		set EndAt = GETDATE()
		where TestRuns.TestRunID = @id_testRuns--salvam in TestRuns

		fetch next from cursor_teste into @id_test, @test_name
	end

	close cursor_teste
	deallocate cursor_teste
end
go


exec Test
Select * from TestRuns
Select * from TestRunTables
Select * from TestRunViews