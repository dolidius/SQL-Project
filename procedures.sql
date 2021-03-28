CREATE OR ALTER PROCEDURE DodajAdresOsobie(
    @IdOsoby INT, 
    @Województwo VARCHAR(19), 
    @Miasto VARCHAR(30), 
    @Ulica VARCHAR(30),
    @KodPocztowy VARCHAR(6))
AS

DECLARE @IdAdresu INT
SET @IdAdresu = (SELECT Id FROM Adresy WHERE Województwo = @Województwo AND Miasto = @Miasto AND Ulica = @Ulica)

IF(@IdAdresu IS NULL)
BEGIN
    DECLARE @LastId INT
    SET @LastId = (SELECT MAX(id) FROM Adresy)
    IF(@LastId IS NULL)
    BEGIN
        SET @LastId = 0
    END
    ELSE
    BEGIN
        SET @LastId = @LastId + 1
    END

    INSERT INTO Adresy VALUES(@LastId, @Województwo, @Miasto, @Ulica, @KodPocztowy)

    UPDATE d
    SET d.Id_Adresu = @LastId
    FROM Dane_Osobowe d
END
ELSE
BEGIN
    UPDATE d
    SET d.Id_Adresu = @IdAdresu
    FROM Dane_Osobowe d
END
GO

------------------------------------------

CREATE OR ALTER PROCEDURE DodajAdresWydarzeniu(
    @IdWydarzenia INT, 
    @Województwo VARCHAR(19), 
    @Miasto VARCHAR(30), 
    @Ulica VARCHAR(30),
    @KodPocztowy VARCHAR(6))
AS

DECLARE @IdAdresu INT
SET @IdAdresu = (SELECT Id FROM Adresy WHERE Województwo = @Województwo AND Miasto = @Miasto AND Ulica = @Ulica)

IF(@IdAdresu IS NULL)
BEGIN
    DECLARE @LastId INT
    SET @LastId = (SELECT MAX(id) FROM Adresy)
    IF(@LastId IS NULL)
    BEGIN
        SET @LastId = 0
    END
    ELSE
    BEGIN
        SET @LastId = @LastId + 1
    END

    INSERT INTO Adresy VALUES(@LastId, @Województwo, @Miasto, @Ulica, @KodPocztowy)

    UPDATE w
    SET w.Id_Adresu = @LastId
    FROM Wydarzenia w
END
ELSE
BEGIN
    UPDATE w
    SET w.Id_Adresu = @IdAdresu
    FROM Wydarzenia w
END
GO

-----------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE PrzywróćUsuniętyPost(@IdPostu INT)
AS
BEGIN TRANSACTION

    DECLARE @Stan VARCHAR(9)
    SET @Stan = (
        SELECT Stan FROM Posty_Archiwum
        WHERE Id = @IdPostu
    )

    IF(@Stan <> 'usunięcie')
    BEGIN
        ROLLBACK
        RAISERROR('Post nigdy nie został usunięty!', 16, 1)
    END

    INSERT INTO Posty (Treść, Id_Autora, Id_Grupy, Ilość_Polubień, Data_Dodania)
    SELECT Treść, Id_Autora, Id_Grupy, Ilość_Polubień, Data_Dodania
    FROM Posty_Archiwum
    WHERE Id = @IdPostu

    DELETE FROM Posty_Archiwum
    WHERE Id = @IdPostu

COMMIT
GO


-------------------------------------------------------------------------

CREATE OR ALTER PROCEDURE UsuńPost(@IdUżytkownika INT, @IdPostu INT)
AS
BEGIN TRANSACTION

DECLARE @IdAutora INT
SET @IdAutora = (
    SELECT Id_Autora
    FROM Posty
    WHERE Id = @IdPostu
)

IF (@IdAutora = @IdUżytkownika)
BEGIN
    DELETE FROM Posty
    WHERE Id = @IdPostu

    DELETE FROM Komentarze
    WHERE Id_Postu = @IdPostu
END
ELSE
BEGIN
    DECLARE @IdGrupy INT
    SET @IdGrupy = (
        SELECT Id_Grupy FROM Posty
        WHERE Id = @IdPostu
    )

    DECLARE @Uprawnienia INT
    SET @Uprawnienia =  ( 
        SELECT Uprawnienia
        FROM Moderatorzy_Grup
        WHERE Id_Grupy = @IdGrupy AND Id_Moderatora = @IdUżytkownika
        )
    IF(@Uprawnienia <> 2 AND @Uprawnienia <> 3)
    BEGIN
        ROLLBACK
        RAISERROR('Brak uprawnień użytkownika do usunięcia postu!', 16, 1)
    END
    ELSE
    BEGIN
        DELETE FROM Posty
        WHERE Id = @IdPostu

        DELETE FROM Komentarze
        WHERE Id_Postu = @IdPostu
    END
END
COMMIT
GO

--------

CREATE OR ALTER PROCEDURE ZmieńZdjęcieProfilowe (@IdKonta INT, @Ścieżka VARCHAR(255) = NULL, @IdNowegoProfilowego INT = NULL, @Podpis VARCHAR(30) = NULL, @Wymiary VARCHAR(11) = NULL)
AS
BEGIN TRANSACTION

    IF ((SELECT COUNT (*) FROM Konta WHERE Id = @IdKonta) = 0) BEGIN
        ROLLBACK
        RAISERROR('Brak konta któremu probowano zmienić zdjęcie profilowe', 16, 1)
    END
    
    IF ((SELECT COUNT(*) FROM Zdjęcia WHERE Id = @IdNowegoProfilowego) = 1) 
    BEGIN
        UPDATE Zdjęcia_Profilowe
        SET Id_Zdjęcia = @IdNowegoProfilowego
        WHERE Id_Konta = @IdKonta
    END
    ELSE
    BEGIN

        IF (@Ścieżka = NULL OR @Podpis = NULL OR @Wymiary = NULL) BEGIN
            ROLLBACK
            RAISERROR('Brak odpowiednich paramatrów do zmiany zdjęcia profilowego', 16, 1)
        END
        
        INSERT INTO Zdjęcia (Ścieżka, Id_Konta, Podpis, Wymiary) VALUES (@Ścieżka, @IdKonta, @Podpis, @Wymiary)

        SET @IdNowegoProfilowego = (
            SELECT Id
            FROM Zdjęcia
            WHERE Ścieżka = @Ścieżka
        )

        UPDATE Zdjęcia_Profilowe
        SET Id_Zdjęcia = @IdNowegoProfilowego
        WHERE Id_Konta = @IdKonta
    END
COMMIT
GO

---------------------------------------

CREATE OR ALTER PROCEDURE ZaktualizujNajlepszychPosterówGrupy(@IdGrupy INT)
AS
BEGIN TRANSACTION

    DECLARE @NajlepsiPosterzy TABLE (
        IdPostera INT
    )

    INSERT INTO @NajlepsiPosterzy (IdPostera)
    SELECT Id_Konta FROM dbo.NajlepsiPosterzyWGrupie(@IdGrupy)

    UPDATE gc
    SET Najlepszy_Poster = 0
    FROM Grupy_Członkowie gc
    WHERE Id_Grupy = @IdGrupy

    UPDATE gc
    SET Najlepszy_Poster = 1
    FROM Grupy_Członkowie gc
    WHERE Id_Konta IN (SELECT * FROM @NajlepsiPosterzy) AND Id_Grupy = @IdGrupy

    COMMIT
GO


-----------------------------------------------------

