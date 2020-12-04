create database Laborator
go
use Laborator
go

CREATE TABLE Profession(
idProfession int PRIMARY KEY,
profName VARCHAR(50)
);

CREATE TABLE Player(
idPlayer int PRIMARY KEY,
timePlayed int,
idProf int FOREIGN KEY REFERENCES Profession(idProfession));

CREATE TABLE RoleWar(
idRole int PRIMARY KEY,
roleName VARCHAR(50),
idLead INT FOREIGN KEY REFERENCES Player(idPlayer));

CREATE TABLE WeaponryClasses(
idWeaponC int PRIMARY KEY,
weaponName VARCHAR(50));

CREATE TABLE Class(
idClass int PRIMARY KEY,
lvl int, className VARCHAR(50),
idWeapon INT FOREIGN KEY REFERENCES WeaponryClasses(idWeaponC));

CREATE TABLE Guild(
guildName VARCHAR(50) PRIMARY KEY,
idClass int FOREIGN KEY REFERENCES Class(idClass));

CREATE TABLE WeaponryGuild(
idWeaponG int PRIMARY KEY,
weaponName VARCHAR(50)
);

CREATE TABLE Weaponry_GuildLink(
guildName VARCHAR(50) FOREIGN KEY REFERENCES Guild(guildName),
idWeapon int FOREIGN KEY REFERENCES WeaponryGuild(idWeaponG)
Constraint pk_WeaponryGuild PRIMARY KEY (guildName, idWeapon)
);

CREATE TABLE Guild_PlayerLink
(idP int FOREIGN KEY REFERENCES Player(idPlayer),
gName VARCHAR(50) FOREIGN KEY REFERENCES Guild(guildName)
constraint pk_gpLink PRIMARY KEY (idP, gName)
);

CREATE TABLE Map(
idMap int PRIMARY KEY,
mapLocation VARCHAR(50));

CREATE TABLE NwAttend(
idAttend int,
idPlayer int FOREIGN KEY REFERENCES Player(idPlayer),
idMap int FOREIGN KEY REFERENCES Map(idMap),
Constraint pk_NwAttend PRIMARY KEY (idPlayer, idMap)
);
/*Caractere care se pot bate (Where, 2 tabele)*/
SELECT className as "Class",lvl as "Level", weaponName as "Weapon" FROM Class
INNER JOIN WeaponryClasses 
ON idWeapon = idWeaponC
Where lvl>=60

/*Clanuri de batalii (Where, 2 tabele)*/
SELECT guildName as "War Guild", className as "Class" from Guild
INNER JOIN Class
on Class.idClass = Guild.idClass
Where lvl>=60

/*Clanuri cu abilitati de viata (Where, 4 tabele, m-n)*/
SELECT gName as "Lifeskill Guild", profName as "Profession" from Guild_PlayerLink
INNER JOIN Guild
on Guild_PlayerLink.gName = Guild.guildName
INNER JOIN Player
on Guild_PlayerLink.idP = Player.idPlayer
INNER JOIN Profession
on Player.idProf = Profession.idProfession
Where timePlayed >= 500

/*Artileria de la ghilde (2 tabele, m-n)*/
Select guildName as "Guild Name", weaponName as "Guild Weapon" FROM Weaponry_GuildLink
INNER JOIN WeaponryGuild
on Weaponry_GuildLink.idWeapon = WeaponryGuild.idWeaponG

/*Tipurile de arme disponibile*/
Select DISTINCT weaponName as "Weapon Name" from WeaponryClasses
/*Tipuri de clase disponibile*/
Select DISTINCT className as "Classes" from Class

Select COUNT(idClass) as "Total Classes by level", lvl from Class
Group by lvl
Having lvl > 50;

Select COUNT(idPlayer) as "Players Medium-Skill", timePlayed from Player
group by timePlayed
Having timePlayed > 500 and timePlayed <= 1000;

Select COUNT(idPlayer) as "Players per profession ID", idProf as "ID Profession" from Player
group by idProf

Select idPlayer as "Player ID", roleName as "Role" from Player
INNER JOIN RoleWar
on Player.idPlayer = RoleWar.idLead;
/*Attendance not deserving payout*/
Select mapLocation as "Location", idPlayer as "ID Player NO PAYOUT", idAttend as "Attendance" from NwAttend
INNER JOIN Map
on NwAttend.idMap=Map.idMap
where idAttend <5;

/*Attendance deserving payout*/
Select mapLocation as "Location", idPlayer as "ID Player WITH PAYOUT", idAttend as "Attendance" from NwAttend
INNER JOIN Map
on NwAttend.idMap=Map.idMap 
where idAttend >= 5;

/*5Where,2-mn,7 multe tabele, 2 Distinct, 3 grup by, 2 having*/

create table Versions(
ver float 
);


drop table Versions;
go

drop procedure Up1To2;
drop procedure Up2To3;
drop procedure Up3To4;
drop procedure Up4To5;
drop procedure Up5To6;
drop procedure Down2To1;
drop procedure Down3To2;
drop procedure Down4To3;
drop procedure Down5To4;
drop procedure Down6To5;
go


create procedure Up1To2
as
begin
	alter table Versions
	alter column ver int;
	update Versions set ver = 2;
	Select * from Versions;
end;
go

create procedure Down2To1
as
begin
	alter table Versions
	alter column ver float;
	update Versions set ver = 1;
	Select * from Versions;
end;
go

create procedure Up2To3
as
begin
	alter table Class
	add constraint df_lvl
	default 1 for lvl;
	update Versions set ver = 3;
	select * from Versions;
end;
go

create procedure Down3To2
as
begin
	alter table Class
	drop constraint df_lvl;
	update Versions set ver = 2;
	select * from Versions;
end;
go

create procedure Up3To4
as
begin
	create table nimic(
		nimeni int);
	update Versions set ver = 4;
	select * from Versions;
end;
go

create procedure Down4To3
as
begin 
	drop table nimic;
	update Versions set ver = 3;
	select * from Versions;
end;
go

create procedure Up4To5
as
begin
	alter table nimic
	add nimeni2 int not null;
	update Versions set ver = 5;
	select * from Versions;
end;
go

create procedure Down5To4
as
begin
	alter table nimic
	drop column nimeni2;
	update Versions set ver = 4;
	select * from Versions;
end;
go

create procedure Up5to6
as
begin
	alter table nimic
	add constraint fk_nimeni2
	foreign key(nimeni2) references Profession(idProfession);
	update Versions set ver = 6;
	select * from Versions;
end;
go


create procedure Down6To5
as
begin
	alter table nimic
	drop constraint fk_nimeni2
	update Versions set ver = 5;
	select * from Versions;
end;
go

create procedure SetVersion @Version int
as
begin
	if (@Version > 0 AND @Version < 7)
	begin
		While(select ver from Versions) < @Version
		begin
			if (select ver from Versions) = 1
			begin
				exec Up1To2
				print('Version is a integer now!')
			end;
			else if (select ver from Versions) = 2
			begin
				exec Up2To3
				print('Level is 1 by default now!')
			end;
			else if (select ver from Versions) = 3
			begin
				exec Up3To4
				print('A table nothing with a column nobody that accepts integers has been created!')
			end;
			else if (select ver from Versions) = 4
			begin
				exec Up4To5
				print('A column nobody2 that accepts integers has been created!')
			end;
			else if (select ver from Versions) = 5
			begin
				exec Up5To6
				print('Nobody2 references now the profession id!')
			end;
		end;
		While(select ver from Versions) > @Version
		begin
			if (select ver from Versions) = 6
			begin
				exec Down6To5
				print('Nobody2 no longer referes the profession id!')
			end;
			else if (select ver from Versions) = 5
			begin
				exec Down5To4
				print('The column nobody2 has been deleted!')
			end;
			else if (select ver from Versions) = 4
			begin
				exec Down4To3
				print('The table nothing has been deleted!')
			end;
			else if (select ver from Versions) = 3
			begin
				exec Down3To2
				print('The level no longer has a default value!')
			end;
			else if (select ver from Versions) = 2
			begin
				exec Down2To1
				print('Version is a float now!')
			end;
		end;
	end;
	else
	begin
		print('Give a value between 1-6')
	end;
end;
drop procedure SetVersion

exec Up1To2
exec Up2To3
exec Up3To4
exec Up4To5
exec Up5To6
exec Down6To5
exec Down5To4
exec Down4To3
exec Down3To2
exec Down2To1

exec SetVersion 1
