-- Szegmensek
INSERT INTO SZEGMENTUMOK (nev, leiras) VALUES ('Lakossági', 'MASS, Lakossági ügyfelek');
INSERT INTO SZEGMENTUMOK (nev, leiras) VALUES ('Prémium', 'Magasabb jövedelemmel rendelkezõ ügyfelek');
INSERT INTO SZEGMENTUMOK (nev, leiras) VALUES ('Private Banking', 'Kiemelt vagyonnal rendelkezõ ügyfelek');

-- Devizák
INSERT INTO DEVIZA (devizanem, arfolyam) VALUES ('HUF', 1);
INSERT INTO DEVIZA (devizanem, arfolyam) VALUES ('EUR', 395.5);
INSERT INTO DEVIZA (devizanem, arfolyam) VALUES ('USD', 370.2);
INSERT INTO DEVIZA (devizanem, arfolyam) VALUES ('CHF', 405.8);

-- MCC Kódok
INSERT INTO MCC_KOD (kod, megnevezes) VALUES ('5411', 'Élelmiszer');
INSERT INTO MCC_KOD (kod, megnevezes) VALUES ('5541', 'Benzinkút');
INSERT INTO MCC_KOD (kod, megnevezes) VALUES ('5812', 'Étterem');
INSERT INTO MCC_KOD (kod, megnevezes) VALUES ('4111', 'Tömegközlekedés');
INSERT INTO MCC_KOD (kod, megnevezes) VALUES ('5732', 'Elektronika');
INSERT INTO MCC_KOD (kod, megnevezes) VALUES ('4900', 'Közüzem');
INSERT INTO MCC_KOD (kod, megnevezes) VALUES ('6011', 'ATM, pénzügyi szolgáltatások');
INSERT INTO MCC_KOD (kod, megnevezes) VALUES ('7011', 'Szállás');

-- Tranzakció típusok
INSERT INTO TRANZ_TIPUS (nev) VALUES ('Vásárlás');
INSERT INTO TRANZ_TIPUS (nev) VALUES ('ATM készpénzfelvétel');
INSERT INTO TRANZ_TIPUS (nev) VALUES ('Befizetés');
INSERT INTO TRANZ_TIPUS (nev) VALUES ('Kamat');
INSERT INTO TRANZ_TIPUS (nev) VALUES ('Díj');
INSERT INTO TRANZ_TIPUS (nev) VALUES ('Cashback');

-- Hûségprogramok
INSERT INTO HUSEG_PROGRAM (nev, alap_cashback) VALUES ('Általános', 2);
INSERT INTO HUSEG_PROGRAM (nev, alap_cashback) VALUES ('Utazó', 1);
INSERT INTO HUSEG_PROGRAM (nev, alap_cashback) VALUES ('Gasztro', 1);
INSERT INTO HUSEG_PROGRAM (nev, alap_cashback) VALUES ('Turista', 1);
INSERT INTO HUSEG_PROGRAM (nev, alap_cashback) VALUES ('Geek', 1);

-- Preferált MCC-k
INSERT INTO HUSEG_PREF_MCC (huseg_id, mcc_id, extra_cashback_szazalek) VALUES (2, 2, 3);
INSERT INTO HUSEG_PREF_MCC (huseg_id, mcc_id, extra_cashback_szazalek) VALUES (3, 3, 4);
INSERT INTO HUSEG_PREF_MCC (huseg_id, mcc_id, extra_cashback_szazalek) VALUES (4, 8, 3);
INSERT INTO HUSEG_PREF_MCC (huseg_id, mcc_id, extra_cashback_szazalek) VALUES (5, 5, 4);

-- Kártyatípusok
INSERT INTO KARTYA_TIPUS (megnevezes, kibocsato, kartyadij, keret_min, keret_max) VALUES ('Mastercard Standard', 'Mastercard', 6000, 200000, 800000);
INSERT INTO KARTYA_TIPUS (megnevezes, kibocsato, kartyadij, keret_min, keret_max) VALUES ('Visa Classic', 'Visa', 6000, 300000, 1000000);
INSERT INTO KARTYA_TIPUS (megnevezes, kibocsato, kartyadij, keret_min, keret_max) VALUES ('Mastercard Gold', 'Mastercard', 17000, 700000, 2000000);
INSERT INTO KARTYA_TIPUS (megnevezes, kibocsato, kartyadij, keret_min, keret_max) VALUES ('Visa Platinum', 'Visa', 25000, 1500000, 5000000);
INSERT INTO KARTYA_TIPUS (megnevezes, kibocsato, kartyadij, keret_min, keret_max) VALUES ('Mastercard World Elite', 'Mastercard', 52000, 3000000, 15000000);


COMMIT;
