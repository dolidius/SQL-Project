CREATE OR ALTER VIEW IlośćKomentarzyPost AS
SELECT P.Id, P.Treść, P.Ilość_Polubień, ISNULL(A.IlośćKomentarzy,0) AS IlośćKomentarzy
FROM Posty P
LEFT JOIN (
    SELECT K.Id_Postu, COUNT(*) IlośćKomentarzy 
    FROM Komentarze K
    GROUP BY K.Id_Postu
) A ON A.Id_Postu = P.Id
GO

-----

CREATE OR ALTER VIEW TrwająceWydarzeniaSzczegóły AS
SELECT W.Nazwa_Wydarzenia, W.Opis, Z.Ścieżka, A.Miasto, A.Ulica
FROM Wydarzenia W
LEFT JOIN Zdjęcia Z ON Z.Id = W.Id_Zdjęcia
LEFT JOIN Adresy A ON A.Id = W.Id_Adresu 
WHERE Godzina_Rozpoczęcia <= GETDATE() AND Godzina_Zakończenia >= GETDATE()
GO

---------

CREATE OR ALTER VIEW ŚredniaWiekuWGrupach AS
SELECT G.Nazwa, G.Opis, AV.ŚredniWiek
FROM Grupy G
INNER JOIN (
    SELECT GC.Id_Grupy, AVG(YEAR(GETDATE()) - YEAR(DO.Urodziny)) AS ŚredniWiek
    FROM Grupy_Członkowie GC
    LEFT JOIN Dane_Osobowe DO ON DO.Id_Konta = GC.Id_Konta
    GROUP BY Id_Grupy
) AV ON AV.Id_Grupy = G.Id
GO

-----------

CREATE OR ALTER VIEW ŚredniaWiekuWydarzenia AS
SELECT W.Nazwa_Wydarzenia, W.Opis, W.Godzina_Rozpoczęcia, W.Godzina_Zakończenia, AD.ŚredniWiek
FROM Wydarzenia W
INNER JOIN (
    SELECT WU.Id_Wydarzenia, AVG(YEAR(GETDATE()) - YEAR(DO.Urodziny)) AS ŚredniWiek
    FROM Wydarzenia_Uczestnicy WU
    LEFT JOIN Dane_Osobowe DO ON WU.Id_Konta =  DO.Id_Konta
    WHERE WU.Status_Uczestnictwa = 'uczestniczy'
    GROUP BY WU.Id_Wydarzenia
) AD ON AD.Id_Wydarzenia = W.Id
GO

--------------------------------------

CREATE OR ALTER VIEW IlośćGrupWKategorii AS
SELECT Nazwa_Kategorii, COUNT(*) AS Ilość_Grup
FROM Grupy_Kategorie
GROUP BY Nazwa_Kategorii
GO

----------
CREATE OR ALTER VIEW IlośćOsóbPodJednymAdresem
AS
SELECT DO.Id_Adresu, a.Województwo, a.Miasto, a.Ulica, a.Kod_Pocztowy, 
COUNT(*) OVER(PARTITION BY DO.Id_Adresu) AS Ilość_Osób
FROM Dane_Osobowe DO
INNER JOIN Adresy a ON a.Id = DO.Id_Adresu
GO

