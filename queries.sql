INSERT INTO Konta(Login, Hasło, Email) VALUES ('nickname', 'abcd123', 'ktos@gmail.com')
SELECT * FROM Konta

INSERT INTO Dane_Osobowe (Pesel, Imię, Nazwisko, Nr_Telefonu, Urodziny, Id_Konta) VALUES ('97021904864', 'Kamil', 'Brzozowski', '607749742', GETDATE(), 10 )

SELECT * FROM Dane_Osobowe

EXEC DodajAdresOsobie @IdOsoby=10, @Województwo='Mazowieckie', @Miasto='Zwoleń', @Ulica='Św. Anny 29', @KodPocztowy='26-700'

SELECT * FROM Adresy

INSERT INTO Zdjęcia(Ścieżka, Id_Konta, Podpis, Wymiary) VALUES('/assets/imgs/konto2/zdj.png', 10, 'hej to ja', '375x294')

SELECT * FROM Zdjęcia

EXEC ZmieńZdjęcieProfilowe @IdKonta = 10, @IdNowegoProfilowego = 2

SELECT * FROM Zdjęcia_Profilowe

UPDATE Konta
SET Hasło = 'abcde123'

INSERT INTO Kategorie VALUES('sport'), ('rekreacja'), ('informatyka'), ('rozrywka'), ('matematyka')

SELECT * FROM Kategorie

INSERT INTO Grupy (Id_Założyciela, Nazwa, Opis) VALUES(10, 'Grupa o piłce nożnej', 
'Zapraszamy wszystkich zainteresowanych piłką nożną')

SELECT * FROM Grupy

INSERT INTO Grupy_Kategorie(Id_Grupy, Nazwa_Kategorii) VALUES(1, 'sport')

SELECT * FROM Grupy_Kategorie

INSERT INTO Grupy_Członkowie(Id_Grupy, Id_Konta) VALUES(1, 10)

SELECT * FROM Grupy_Członkowie

INSERT INTO Posty(Treść, Id_Autora, Id_Grupy, Data_Dodania) VALUES(
    'wrzucam posta', 10, 1, GETDATE()
)

INSERT INTO Posty(Treść, Id_Autora, Id_Grupy, Data_Dodania) VALUES(
    'wrzucam drugiego posta', 10, 1, GETDATE()
)

EXEC UsuńPost 10, 2

SELECT * FROM Posty

SELECT * FROM Posty_Archiwum

EXEC PrzywróćUsuniętyPost 1

SELECT * FROM Posty

INSERT INTO Komentarze (Treść, Id_Postu, Id_Autora, Data_dodania) VALUES(
    'Dodaję komentarz!', 1, 10, GETDATE()
)

SELECT * FROM Komentarze

INSERT INTO Konta(Login, Hasło, Email) VALUES ('john12', 'kispiK12', 'emails@gmail.com')
INSERT INTO Grupy_Członkowie(Id_Grupy, Id_Konta) VALUES(1, 14)

INSERT INTO Moderatorzy_Grup(Id_Grupy, Id_Moderatora, Uprawnienia) VALUES(
    1, 14, 2
)


INSERT INTO Znajomi (Id1, Id2) VALUES(10, 14)

SELECT * FROM Znajomi
SELECT * FROM Konta

INSERT INTO Wiadomości (Id_Odbiorca, Id_Nadawca, Treść, Data_Wysłania) VALUES(
    10, 14, 'hej', GETDATE()
)

SELECT * FROM Wiadomości

INSERT INTO Wydarzenia (Id_Założyciela, Nazwa_Wydarzenia, Godzina_Rozpoczęcia, Godzina_Zakończenia,
Opis) VALUES(10, 'fajne wydarzenie', GETDATE(), GETDATE() + 20, 'naprawde fajne wydarzenie wpadajcie')

SELECT * FROM Wydarzenia

INSERT INTO Wydarzenia_Kategorie(Id_Wydarzenia, Nazwa_Kategorii) VALUES(2, 'rozrywka')

SELECT * FROM Wydarzenia_Kategorie

INSERT INTO Wydarzenia_Uczestnicy(Id_Wydarzenia, Id_Konta, Status_Uczestnictwa) VALUES(
    2, 14, 'uczestniczy'
)

SELECT * FROM Wydarzenia_Uczestnicy
EXEC ZaktualizujNajlepszychPosterówGrupy 1

SELECT * FROM Grupy_Członkowie

SELECT * FROM dbo.PostyZGrupyPoDacie(1, GETDATE() - 50)

SELECT * FROM dbo.StatusyUczestnictwaWydarzenia(2)

SELECT * FROM dbo.SzukajUżytkowników('Kam Brz')

SELECT * FROM dbo.ListaZnajomych(14)

SELECT * FROM dbo.ZnajomiWGrupie(10, 1)

SELECT * FROM IlośćKomentarzyPost



SELECT * FROM TrwająceWydarzeniaSzczegóły


SELECT * FROM ŚredniaWiekuWGrupach

SELECT * FROM IlośćOsóbPodJednymAdresem