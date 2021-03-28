--------------------
CREATE OR ALTER FUNCTION PostyZGrupyPoDacie (@Id_Grupy INT, @Data DATETIME)
RETURNS TABLE
AS
RETURN (
    SELECT P.Id, P.Treść, P.Ilość_Polubień, P.Data_dodania
    FROM Posty P
    WHERE P.Id_Grupy = @Id_Grupy AND P.Data_dodania >= @Data
)
GO
------------------

CREATE OR ALTER FUNCTION StatusyUczestnictwaWydarzenia (@Id_Wydarzenia INT)
RETURNS @WydarzeniaStatusy TABLE 
(
    Id INT,
    Nazwa_Wydarzenia VARCHAR(100),
    Opis VARCHAR(MAX),
    Uczestnicy INT,
    Ludzie_którzy_odmówili INT,
    Brak_Odpowiedzi INT,
    Zainteresowani INT
)
AS
BEGIN

    DECLARE @Uczestnicy INT
    SET @Uczestnicy = (
        SELECT COUNT(*) 
        FROM Wydarzenia_Uczestnicy
        WHERE Status_Uczestnictwa = 'uczestniczy' AND Id_Wydarzenia = @Id_Wydarzenia
    )

    DECLARE @Ludzie_którzy_odmówili INT
    SET @Ludzie_którzy_odmówili = (
        SELECT COUNT(*) 
        FROM Wydarzenia_Uczestnicy
        WHERE Status_Uczestnictwa = 'odmówił' AND Id_Wydarzenia = @Id_Wydarzenia
    )

    DECLARE @Brak_Odpowiedzi INT
    SET @Brak_Odpowiedzi = (
        SELECT COUNT(*) 
        FROM Wydarzenia_Uczestnicy
        WHERE Status_Uczestnictwa = 'nie odpowiedział' AND Id_Wydarzenia = @Id_Wydarzenia
    )

    DECLARE @Zainteresowani INT
    SET @Zainteresowani = (
        SELECT COUNT(*) 
        FROM Wydarzenia_Uczestnicy
        WHERE Status_Uczestnictwa = 'zainteresowany' AND Id_Wydarzenia = @Id_Wydarzenia
    )

    INSERT INTO @WydarzeniaStatusy (Id, Nazwa_Wydarzenia, Opis, Uczestnicy, Ludzie_którzy_odmówili, Brak_Odpowiedzi, Zainteresowani)
    SELECT Id, Nazwa_Wydarzenia, Opis, @Uczestnicy, @Ludzie_którzy_odmówili, @Brak_Odpowiedzi, @Zainteresowani 
    FROM Wydarzenia WHERE Id = @Id_Wydarzenia
    

    RETURN
END
GO


----------------------------------------------------

CREATE OR ALTER FUNCTION NajlepsiPosterzyWGrupie (@IdGrupy INT)
RETURNS @NajlepsiPosterzy TABLE
(
    Id_Konta INT,
    Imię VARCHAR(50),
    Nazwisko VARCHAR(50),
    Ilość_Polubień INT
)
AS
BEGIN

    INSERT INTO @NajlepsiPosterzy (Id_Konta, Imię, Nazwisko, Ilość_Polubień)
    SELECT DO.Id_Konta, DO.Imię, DO.Nazwisko, T.Ilość_Polubień
    FROM Dane_Osobowe DO
    INNER JOIN (
        SELECT TOP 5 P.Id_Autora, SUM(Ilość_Polubień) Ilość_Polubień
        FROM Posty P
        GROUP BY Id_Autora
        ORDER BY SUM(Ilość_Polubień) DESC
    ) T ON DO.Id_Konta = T.Id_Autora
    ORDER BY T.Ilość_Polubień DESC

RETURN

END
GO

----------------------------------------------------------

CREATE OR ALTER FUNCTION SzukajUżytkowników (@CiągZnakowy VARCHAR(255))
RETURNS @Użytkownicy TABLE
(
    Id_Konta INT,
    Imię VARCHAR(50),
    Nazwisko VARCHAR(50),
    Id_Zdjęcia_Profilowego INT
)
AS
BEGIN
DECLARE @PoczątekImienia VARCHAR(50)
DECLARE @PoczątekNazwiska VARCHAR(50)
SET @PoczątekImienia = (
    SELECT PARSENAME(REPLACE(@CiągZnakowy, ' ', '.'), 2)
)
SET @PoczątekNazwiska = (
    SELECT PARSENAME(REPLACE(@CiągZnakowy, ' ', '.'), 1)
)

IF(@PoczątekImienia IS NULL)
BEGIN
    SET @PoczątekImienia = @PoczątekNazwiska
    SET @PoczątekNazwiska = ''
END

INSERT INTO @Użytkownicy (Id_Konta, Imię, Nazwisko, Id_Zdjęcia_Profilowego)
SELECT d.Id_Konta, d.Imię, d.Nazwisko, z.Id_Zdjęcia
FROM Dane_Osobowe d
INNER JOIN Zdjęcia_Profilowe z ON z.Id_Konta = d.Id_Konta
WHERE d.Imię LIKE @PoczątekImienia + '%' AND d.Nazwisko LIKE @PoczątekNazwiska + '%'

RETURN

END
GO

------

CREATE OR ALTER FUNCTION ListaZnajomych(@IdKonta INT)
RETURNS @Znajomi TABLE (
    Id_Znajomego INT,
    Imię VARCHAR(50),
    Nazwisko VARCHAR(50),
    Id_Zdjęcia_Profilowego INT
)
AS
BEGIN
    INSERT INTO @Znajomi (Id_Znajomego, Imię, Nazwisko, Id_Zdjęcia_Profilowego)
    SELECT z.Id1, d.Imię, d.Nazwisko, zp.Id_Zdjęcia
    FROM Znajomi z
    LEFT JOIN Dane_Osobowe d ON d.Id_Konta = z.Id1
    LEFT JOIN Zdjęcia_Profilowe zp ON zp.Id_Konta = d.Id_Konta
    WHERE z.Id2 = @IdKonta


    INSERT INTO @Znajomi (Id_Znajomego, Imię, Nazwisko, Id_Zdjęcia_Profilowego)
    SELECT z.Id2, d.Imię, d.Nazwisko, zp.Id_Zdjęcia
    FROM Znajomi z
    LEFT JOIN Dane_Osobowe d ON d.Id_Konta = z.Id2
    LEFT JOIN Zdjęcia_Profilowe zp ON zp.Id_Konta = d.Id_Konta
    WHERE z.Id1 = @IdKonta

    RETURN
END
GO


-------------------------------------------------

CREATE OR ALTER FUNCTION ZnajomiWGrupie (@IdKonta INT, @IdGrupy INT)
RETURNS @ZnajomiWGrupie TABLE (
    Id_Znajomego INT,
    Imię VARCHAR(50),
    Nazwisko VARCHAR(50),
    Id_Zdjęcia_Profilowego INT
)
AS
BEGIN
    DECLARE @ListaZnajomych TABLE (
        Id_Znajomego INT,
        Imię VARCHAR(50),
        Nazwisko VARCHAR(50),
        Id_Zdjęcia_Profilowego INT
    )
    INSERT INTO @ListaZnajomych (Id_Znajomego, Imię, Nazwisko,Id_Zdjęcia_Profilowego) 
    SELECT * FROM dbo.ListaZnajomych(@IdKonta)

    DECLARE @ListaCzłonkówGrupy TABLE (
        Id_Członka INT
    )
    
    INSERT INTO @ListaCzłonkówGrupy (Id_Członka)
    SELECT Id_Konta AS Id_Członka
    FROM Grupy_Członkowie
    WHERE Id_Grupy = @IdGrupy

    INSERT INTO @ZnajomiWGrupie (Id_Znajomego, Imię, Nazwisko, Id_Zdjęcia_Profilowego)
    SELECT lz.Id_Znajomego, lz.Imię, lz.Nazwisko, lz.Id_Zdjęcia_Profilowego
    FROM @ListaZnajomych lz
    WHERE lz.Id_Znajomego IN (SELECT Id_Członka FROM @ListaCzłonkówGrupy)

    RETURN
END
GO
------

CREATE OR ALTER FUNCTION UrodzinyZnajomych(@IdKonta INT)
RETURNS @ZnajomiZUrodzinami TABLE (
    Id_Znajomego INT,
    Imię VARCHAR(50),
    Nazwisko VARCHAR(50),
    Id_Zdjęcia_Profilowego INT
)
AS
BEGIN
    DECLARE @ListaZnajomych TABLE (
        Id_Znajomego INT,
        Imię VARCHAR(50),
        Nazwisko VARCHAR(50),
        Id_Zdjęcia_Profilowego INT
    )

    INSERT INTO @ListaZnajomych (Id_Znajomego, Imię, Nazwisko,Id_Zdjęcia_Profilowego) 
    SELECT * FROM dbo.ListaZnajomych(@IdKonta)

    INSERT INTO @ZnajomiZUrodzinami (Id_Znajomego, Imię, Nazwisko, Id_Zdjęcia_Profilowego)
    SELECT lz.Id_Znajomego, lz.Imię, lz.Nazwisko, lz.Id_Zdjęcia_Profilowego
    FROM @ListaZnajomych lz
    LEFT JOIN Dane_Osobowe d ON d.Id_Konta = lz.Id_Znajomego
    WHERE MONTH(d.Urodziny) = MONTH(GETDATE()) AND DAY(d.Urodziny) = DAY(GETDATE())

    RETURN
END
GO
