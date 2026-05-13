# pasztor-tibor-szakdolgozat-dss
A szakdolgozatom keretében fejlesztett hitelkártya-portfólió elemzését támogató döntéstámogató rendszer forráskódjai, és az adatvizualizációhoz szükséges Power BI fájl.

Fájlok struktúrája és tartalma

1. Adatbázis inicializálás
* `TABLAGENERALAS.sql`: A relációs adatmodell tábláinak és struktúrájának létrehozása.
* `TORZSADATOK_FELTOLTESE.sql`: Dimenziónkénti törzsadatok betöltése.

2. Adatgenerálás
* `UGYFEL_SZAMLA_KARTYA_GENERALAS.sql`: Véletlenszerű, de piaci sztenderdeknek megfelelő eloszlású ügyfél-, számla- és bankkártya-adatok generálása.
* `TRANZAKCIO_GENERALAS.sql`: A kártyás tranzakciók szimulációja adott időszakra vonatkozóan.

3. Üzleti logika
* `SP_KAMATSZAMITAS.prc`: Havi hitelkamatok kiszámítása.
* `SP_CASHBACKSZAMITAS.prc`: A hűségprogramok alapján visszajáró bónuszok kalkulációja.
* `SP_KPI_SNAPSHOT.prc`: A havi teljesítménymutatók kiszámítása és rögzítése.
* `TRG_EGYENLEG_FRISSITES.trg`: Tranzakciófüggő egyenlegfrissítést végző adatbázis-trigger.

4. Elemzés
* `SZAKDOLGOZAT_ADATVIZUALIZÁCIÓ.pbix`: A kinyert adatokra épülő dashboard. A megnyitásához a Microsoft Power BI Desktop alkalmazás szükséges!
