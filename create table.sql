CREATE TABLE Adresy (
    Id INT PRIMARY KEY,
    Województwo VARCHAR(19) NOT NULL,
    Miasto VARCHAR(30) NOT NULL,
    Ulica VARCHAR(30) NOT NULL,
    Kod_Pocztowy VARCHAR(6) NOT NULL,
)

CREATE TABLE Konta (
    Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
    Login VARCHAR(20) NOT NULL UNIQUE CHECK (LEN(Login) > 5 AND LEN(Login) < 21),   
    Hasło VARCHAR(255) NOT NULL,
    Email VARCHAR(30) NOT NULL UNIQUE CHECK (EMAIL LIKE '%_@__%.__%'),
    Liczba_Znajomych INT NOT NULL DEFAULT 0,
);

CREATE TABLE Dane_Osobowe (
    Pesel VARCHAR (11) CHECK (LEN(Pesel) = 11) PRIMARY KEY,
    Imię VARCHAR(50),
    Nazwisko VARCHAR(50),
    Nr_Telefonu VARCHAR(9) CHECK (LEN(Nr_Telefonu) = 9),
    Urodziny DATETIME,
    Id_Adresu INT FOREIGN KEY REFERENCES Adresy(Id),
    Id_Konta INT NOT NULL FOREIGN KEY REFERENCES Konta(Id)
)


CREATE TABLE Zdjęcia (
    Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
    Ścieżka VARCHAR(255) NOT NULL,
    Id_Konta INT NOT NULL REFERENCES Konta(Id),
    Podpis VARCHAR(30),
    Wymiary VARCHAR(11) NOT NULL CHECK (Wymiary LIKE '%x%')
)

CREATE TABLE Zdjęcia_Profilowe (
    Id_Konta INT NOT NULL FOREIGN KEY REFERENCES Konta(Id) PRIMARY KEY,
    Id_Zdjęcia INT FOREIGN KEY REFERENCES Zdjęcia(Id)
)

CREATE TABLE Znajomi (
    Id1 INT NOT NULL REFERENCES Konta(Id),
    Id2 INT NOT NULL REFERENCES Konta(Id),
    PRIMARY KEY(Id1, Id2)
)

CREATE TABLE Kategorie (
    Nazwa VARCHAR(50) NOT NULL PRIMARY KEY
)

CREATE TABLE Grupy (
    Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
    Id_Założyciela INT NOT NULL FOREIGN KEY REFERENCES Konta(Id),
    Nazwa VARCHAR(50) NOT NULL UNIQUE,
    Opis VARCHAR(255)
)

CREATE TABLE Moderatorzy_Grup (
    Id_Grupy INT NOT NULL FOREIGN KEY REFERENCES Grupy(Id),
    Id_Moderatora INT NOT NULL FOREIGN KEY REFERENCES Konta(Id),
    Uprawnienia INT NOT NULL CHECK (Uprawnienia >= 1 AND Uprawnienia <= 3)
    PRIMARY KEY(Id_Grupy, Id_Moderatora)
)

CREATE TABLE Grupy_Kategorie (
    Id_Grupy INT NOT NULL REFERENCES Grupy(Id),
    Nazwa_Kategorii VARCHAR(50) NOT NULL REFERENCES Kategorie(Nazwa),
    PRIMARY KEY(Id_Grupy, Nazwa_Kategorii)
)

CREATE TABLE Grupy_Członkowie (
    Id_Grupy INT NOT NULL REFERENCES Grupy(Id),
    Id_Konta INT NOT NULL REFERENCES Konta(Id),
    Najlepszy_Poster BIT NOT NULL DEFAULT 0
    PRIMARY KEY(Id_Grupy, Id_Konta)
)

CREATE TABLE Posty (
    Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
    Treść VARCHAR(MAX) NOT NULL CHECK (LEN(Treść) > 5),
    Id_Autora INT NOT NULL REFERENCES Konta(Id),
    Id_Grupy INT REFERENCES Grupy(Id),
    Ilość_Polubień INT NOT NULL DEFAULT 0,
    Data_dodania DATETIME NOT NULL
)

CREATE TABLE Komentarze (
    Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
    Treść VARCHAR(MAX) NOT NULL CHECK (LEN(Treść) > 1),
    Id_Postu INT NOT NULL REFERENCES Posty(Id),
    Id_Autora INT NOT NULL REFERENCES Konta(Id),
    Ilość_Polubień INT NOT NULL DEFAULT 0,
    Data_dodania DATETIME NOT NULL,
)


CREATE TABLE Wiadomości (
    Id_Odbiorca INT NOT NULL FOREIGN KEY REFERENCES Konta(Id),
    Id_Nadawca INT NOT NULL FOREIGN KEY REFERENCES Konta(Id),
    Treść VARCHAR(MAX) NOT NULL,
    Data_Wysłania DATETIME NOT NULL,
)

CREATE TABLE Wydarzenia (
    Id INT PRIMARY KEY IDENTITY(1, 1),
    Id_Założyciela INT FOREIGN KEY REFERENCES Konta(Id),
    Nazwa_Wydarzenia VARCHAR(100) NOT NULL CHECK(LEN(Nazwa_Wydarzenia) > 9),
    Godzina_Rozpoczęcia DATETIME NOT NULL,
    Godzina_Zakończenia DATETIME NOT NULL,
    Opis VARCHAR(MAX) NOT NULL CHECK(LEN(Opis) > 20),
    Id_Zdjęcia INT FOREIGN KEY REFERENCES Zdjęcia(Id),
    Id_Adresu INT FOREIGN KEY REFERENCES Adresy(Id)
)

CREATE TABLE Wydarzenia_Kategorie (
    Id_Wydarzenia INT NOT NULL FOREIGN KEY REFERENCES Wydarzenia(Id),
    Nazwa_Kategorii VARCHAR(50) NOT NULL FOREIGN KEY REFERENCES Kategorie(Nazwa),
    PRIMARY KEY(Id_Wydarzenia, Nazwa_Kategorii)
)


CREATE TABLE Wydarzenia_Uczestnicy (
    Id_Wydarzenia INT NOT NULL FOREIGN KEY REFERENCES Wydarzenia(Id),
    Id_Konta INT NOT NULL FOREIGN KEY REFERENCES Konta(Id),
    Status_Uczestnictwa VARCHAR(16) NOT NULL CHECK (Status_Uczestnictwa IN ('uczestniczy', 'odmówił', 'nie odpowiedział', 'zainteresowany')) DEFAULT 'nie odpowiedział'
)

CREATE TABLE Posty_Archiwum (
    Id INT NOT NULL PRIMARY KEY IDENTITY (1,1),
    Treść VARCHAR(MAX) NOT NULL CHECK (LEN(Treść) > 5),
    Id_Autora INT NOT NULL FOREIGN KEY REFERENCES Konta(Id),
    Id_Grupy INT REFERENCES Grupy(Id),
    Ilość_Polubień INT NOT NULL,
    Data_Dodania DATETIME NOT NULL,
    Data_Zmiany DATETIME NOT NULL,
    Stan VARCHAR(9) NOT NULL CHECK (Stan IN ('edycja', 'usunięcie'))
)
