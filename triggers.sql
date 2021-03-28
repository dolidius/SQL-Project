CREATE OR ALTER TRIGGER ArchiwizujPostyUpdate
ON Posty
AFTER UPDATE 
AS
IF UPDATE(Treść) BEGIN
    INSERT INTO Posty_Archiwum (Treść, Id_Autora, Id_Grupy, Ilość_Polubień, Data_Dodania, Data_Zmiany, Stan) 
    SELECT Treść, Id_Autora, Id_Grupy, Ilość_Polubień, Data_Dodania, GETDATE(), 'edycja'
    FROM Inserted 
END
GO

--------------------------------------------------------------------------------

CREATE OR ALTER TRIGGER ArchiwizujPostyDelete
ON Posty
INSTEAD OF DELETE 
AS

IF ((SELECT COUNT (*) FROM Posty P INNER JOIN Deleted ON P.Id = Deleted.Id) = 0) BEGIN
    ROLLBACK
    RAISERROR('Nie istnieje post który próbowano usunąć', 16, 1)
END

IF ((SELECT COUNT (*) FROM Posty P INNER JOIN Deleted ON P.Id = Deleted.Id) > 1) BEGIN
    ROLLBACK
    RAISERROR('Można usunąć tylko jeden post naraz', 16, 1)
END

DECLARE @DeletedID INT
SET @DeletedID = (
    SELECT Id FROM Deleted
)

DELETE FROM Posty
WHERE Id = @DeletedID

INSERT INTO Posty_Archiwum (Treść, Id_Autora, Id_Grupy, Ilość_Polubień, Data_Dodania, Data_Zmiany, Stan) 
SELECT Treść, Id_Autora, Id_Grupy, Ilość_Polubień, Data_Dodania, GETDATE(), 'usunięcie'
FROM Deleted

DELETE FROM Komentarze
WHERE Id_Postu = @DeletedID

GO

--------------------------------------

CREATE OR ALTER TRIGGER DodajKonto
ON Konta
INSTEAD OF INSERT
AS

DECLARE @Count INT
SET @Count = (
    SELECT COUNT(*) FROM inserted
)

IF(@Count > 1)
BEGIN
    ROLLBACK
    RAISERROR('Można dodać tylko jednego użytkownika na raz', 16, 1)
END

DECLARE @Id INT
DECLARE @Login VARCHAR(20)

SET @Login = (
    SELECT Login FROM inserted
)

DECLARE @Hasło VARCHAR(255)
SET @Hasło = (
    SELECT Hasło FROM inserted
)

SET @Hasło = (SELECT HASHBYTES('SHA2_256', @Hasło))

INSERT INTO Konta (Login, Hasło, Email)
SELECT Login, @Hasło, Email FROM inserted

SET @Id = (
    SELECT Id FROM Konta WHERE Login = @Login
)

INSERT INTO Zdjęcia_Profilowe (Id_Konta, Id_Zdjęcia) VALUES(@Id, null)

GO

-----------------------------------------------

CREATE OR ALTER TRIGGER EdytujKonto
ON Konta
INSTEAD OF UPDATE
AS

IF ((SELECT COUNT(*) FROM inserted) > 1)
BEGIN
    ROLLBACK
    RAISERROR('Można zrobić tylko jedną aktualizację konta na raz!', 16, 1)
END

IF (UPDATE(Hasło) AND UPDATE(Email))
BEGIN
    ROLLBACK
    RAISERROR('Nie można aktualizować hasła i emailu jednocześnie!', 16, 1)
END
IF (UPDATE(Login))
BEGIN
    ROLLBACK
    RAISERROR('Nie można aktualizować loginu konta!', 16, 1)
END

DECLARE @Id INT
SET @Id = (
    SELECT Id FROM inserted
)

DECLARE @LiczbaZnajomychWcześniej INT
DECLARE @LiczbaZnajomychPóźniej INT
SET @LiczbaZnajomychWcześniej = (
    SELECT Liczba_Znajomych
    FROM Konta
    WHERE Id = @Id
)
SET @LiczbaZnajomychPóźniej = (
    SELECT Liczba_Znajomych
    FROM inserted
)

IF(@LiczbaZnajomychPóźniej - @LiczbaZnajomychWcześniej <> 0 AND 
    @LiczbaZnajomychPóźniej - @LiczbaZnajomychWcześniej <> 1 AND
    @LiczbaZnajomychPóźniej - @LiczbaZnajomychWcześniej <> -1)
BEGIN
    ROLLBACK
    RAISERROR('Liczba znajomych może się zmienić co najwyżej o 1!', 16, 1)
END

IF (UPDATE(Hasło))
BEGIN
    DECLARE @Hasło VARCHAR(255)
    SET @Hasło = (
        SELECT Hasło FROM inserted
    )

    SET @Hasło = (SELECT HASHBYTES('SHA2_256', @Hasło))

    UPDATE k
    SET Hasło = @Hasło
    FROM Konta k
END

IF (UPDATE(Email))
BEGIN
    DECLARE @Email VARCHAR(30)
    SET @Email = (
        SELECT Email FROM inserted
    )

    UPDATE k
    SET Email = @Email
    FROM Konta k
END

IF (UPDATE(Liczba_Znajomych))
BEGIN
    UPDATE k
    SET Liczba_Znajomych = @LiczbaZnajomychPóźniej
    FROM Konta k
    WHERE k.Id = @Id
END

GO

---------------------------------------------

CREATE OR ALTER TRIGGER DodajZnajomych
ON Znajomi
AFTER INSERT
AS

DECLARE @Id1 INT
DECLARE @Id2 INT
SET @Id1 = (
    SELECT Id1 FROM inserted
)

SET @Id2 = (
    SELECT Id2 FROM inserted
)

UPDATE k
SET k.Liczba_znajomych = k.Liczba_znajomych + 1
FROM Konta k
WHERE k.Id = @Id1

UPDATE k
SET k.Liczba_znajomych = k.Liczba_znajomych + 1
FROM Konta k
WHERE k.Id = @Id2

GO


---------------------------------------------------
CREATE OR ALTER TRIGGER UsuńZnajomych
ON Znajomi
AFTER DELETE
AS

DECLARE @Id1 INT
DECLARE @Id2 INT
SET @Id1 = (
    SELECT Id1 FROM deleted
)

SET @Id2 = (
    SELECT Id2 FROM deleted
)

UPDATE k
SET k.Liczba_znajomych = k.Liczba_znajomych - 1
FROM Konta k
WHERE k.Id = @Id1

UPDATE k
SET k.Liczba_znajomych = k.Liczba_znajomych - 1
FROM Konta k
WHERE k.Id = @Id2

GO
