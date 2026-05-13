DECLARE
    v_aktualis_datum DATE := TO_DATE('2025-01-01', 'YYYY-MM-DD');
    v_vegs_datum     DATE := TO_DATE('2025-12-31', 'YYYY-MM-DD');
    v_kartya_id      NUMBER;
    v_mcc_id         NUMBER;
    v_osszeg         NUMBER;
    v_napi_tx_szam   NUMBER;
    v_rand_esely     NUMBER;
    v_torlesztes     NUMBER;
    v_mult_havi_zaro NUMBER;
    v_mult_honap_id  NUMBER;
    v_tranz_tipus    NUMBER;

    TYPE t_profil_lista IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_ugyfel_profilok t_profil_lista;
    
    TYPE t_fizetesi_nap IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    v_fizetesi_napok t_fizetesi_nap;

    v_valtozas_honap NUMBER := 7; 
    v_aktualis_honap NUMBER;

BEGIN
    -- Profilok és fizetési napok sorsolása
    FOR rec IN (SELECT szamla_id FROM HITELSZAMLA) LOOP
        v_rand_esely := DBMS_RANDOM.VALUE(1, 100);
        IF v_rand_esely <= 80 THEN v_ugyfel_profilok(rec.szamla_id) := 1; 
        ELSIF v_rand_esely <= 90 THEN v_ugyfel_profilok(rec.szamla_id) := 2; 
        ELSE v_ugyfel_profilok(rec.szamla_id) := 3; 
        END IF;
        
        v_fizetesi_napok(rec.szamla_id) := TRUNC(DBMS_RANDOM.VALUE(1, 24));
    END LOOP;

    -- Fõ ciklus, napról napra iterálva
    WHILE v_aktualis_datum <= v_vegs_datum LOOP
        v_aktualis_honap := TO_NUMBER(TO_CHAR(v_aktualis_datum, 'MM'));

        FOR rec IN (
            SELECT s.szamla_id, s.egyenleg, s.hitelkeret, s.huseg_id, u.szegmens_id 
            FROM HITELSZAMLA s JOIN UGYFEL u ON s.ugyfel_id = u.ugyfel_id
            WHERE s.statusz = 'AKTIV'
        ) LOOP
            SELECT MIN(kartya_id) INTO v_kartya_id FROM HITELKARTYA WHERE szamla_id = rec.szamla_id;

            -- Cashback jóváírás
            IF TO_CHAR(v_aktualis_datum, 'DD') = '01' THEN
                SP_CASHBACKSZAMITAS(rec.szamla_id, v_aktualis_datum);
            END IF;

            -- Napi tranzakciós szám meghatározása
            v_napi_tx_szam := 0;
            v_rand_esely := DBMS_RANDOM.VALUE(1, 100);
            
            
            IF rec.szegmens_id = 1 THEN IF v_rand_esely <= 80 THEN v_napi_tx_szam := 1; END IF;
            ELSIF rec.szegmens_id = 2 THEN IF v_rand_esely <= 20 THEN v_napi_tx_szam := 2; ELSIF v_rand_esely <= 80 THEN v_napi_tx_szam := 1; END IF;
            ELSIF rec.szegmens_id = 3 THEN IF v_rand_esely <= 50 THEN v_napi_tx_szam := 2; ELSIF v_rand_esely <= 80 THEN v_napi_tx_szam := 1; END IF;
            END IF;

            -- Lemorzsolódás logikája
            IF v_ugyfel_profilok(rec.szamla_id) = 2 AND v_aktualis_honap >= v_valtozas_honap THEN
                IF DBMS_RANDOM.VALUE(1, 100) > 10 THEN v_napi_tx_szam := 0; END IF; 
            END IF;

            -- Tranzakció létrehozása
            FOR j IN 1..v_napi_tx_szam LOOP
                IF rec.egyenleg < rec.hitelkeret THEN
                    
                    IF DBMS_RANDOM.VALUE(1, 100) <= 3 THEN
                        v_tranz_tipus := 2;
                        v_mcc_id := 7;
                        v_osszeg := ROUND(DBMS_RANDOM.VALUE(5000, 150000) / 1000) * 1000;
                    ELSE
                        v_tranz_tipus := 1;
                        v_osszeg := TRUNC(DBMS_RANDOM.VALUE(2000, 45000));
                        
                        IF DBMS_RANDOM.VALUE(1, 100) <= 35 THEN
                            BEGIN
                                SELECT mcc_id INTO v_mcc_id FROM (
                                    SELECT mcc_id FROM HUSEG_PREF_MCC 
                                    WHERE huseg_id = rec.huseg_id ORDER BY DBMS_RANDOM.VALUE
                                ) WHERE ROWNUM = 1;
                            EXCEPTION WHEN NO_DATA_FOUND THEN
                                v_mcc_id := TRUNC(DBMS_RANDOM.VALUE(1, 8));
                                IF v_mcc_id = 7 THEN v_mcc_id := 8; END IF;
                            END;
                        ELSE
                            v_mcc_id := TRUNC(DBMS_RANDOM.VALUE(1, 8));
                            IF v_mcc_id = 7 THEN v_mcc_id := 8; END IF;
                        END IF;
                    END IF;
                    
                    IF (rec.egyenleg + v_osszeg) <= rec.hitelkeret THEN
                        INSERT INTO TRANZAKCIO (
                            kartya_id, mcc_id, tranz_tipus_id, deviza_id, 
                            akt_arfolyam, datum, osszeg, konvertalt_osszeg
                        ) VALUES (
                            v_kartya_id, v_mcc_id, v_tranz_tipus, 1, 
                            1, v_aktualis_datum, v_osszeg, v_osszeg
                        );
                    END IF;
                    
                END IF;
            END LOOP;

            -- Törlesztési logika
            IF TO_NUMBER(TO_CHAR(v_aktualis_datum, 'DD')) = v_fizetesi_napok(rec.szamla_id) THEN
                v_mult_honap_id := TO_NUMBER(TO_CHAR(ADD_MONTHS(v_aktualis_datum, -1), 'YYYYMM'));
                
                BEGIN
                    SELECT zaro_egyenleg_huf INTO v_mult_havi_zaro FROM HAVI_KPI WHERE szamla_id = rec.szamla_id AND honap = v_mult_honap_id;
                EXCEPTION WHEN NO_DATA_FOUND THEN v_mult_havi_zaro := 0; END;

                IF v_mult_havi_zaro > 0 THEN
                    v_torlesztes := v_mult_havi_zaro; 
                    
                    IF v_ugyfel_profilok(rec.szamla_id) = 3 AND v_aktualis_honap >= v_valtozas_honap THEN
                         v_rand_esely := DBMS_RANDOM.VALUE(1,100);
                         IF v_rand_esely <= 70 THEN v_torlesztes := 0; 
                         ELSE v_torlesztes := ROUND(v_mult_havi_zaro * 0.05); 
                         END IF;
                    END IF;

                    IF v_torlesztes > 0 THEN
                        INSERT INTO TRANZAKCIO (kartya_id, mcc_id, tranz_tipus_id, deviza_id, akt_arfolyam, datum, osszeg, konvertalt_osszeg)
                        VALUES (v_kartya_id, NULL, 3, 1, 1, v_aktualis_datum, v_torlesztes, v_torlesztes);
                    END IF;
                END IF;
            END IF;

            -- Kamatszámítás
            IF TO_CHAR(v_aktualis_datum, 'DD') = '24' THEN
                SP_KAMATSZAMITAS(rec.szamla_id, v_aktualis_datum);
            END IF;

            -- KPI-ok generálása
            IF v_aktualis_datum = LAST_DAY(v_aktualis_datum) THEN
                
                IF v_ugyfel_profilok(rec.szamla_id) = 2 AND v_aktualis_honap > v_valtozas_honap + 2 THEN
                     UPDATE HITELSZAMLA 
                     SET statusz = 'INAKTIV', 
                         bezar_datum = v_aktualis_datum 
                     WHERE szamla_id = rec.szamla_id 
                       AND egyenleg <= 0;
                END IF;

                SP_KPI_SNAPSHOT(rec.szamla_id, v_aktualis_datum);
            END IF;
        END LOOP;
        
        v_aktualis_datum := v_aktualis_datum + 1;
    END LOOP;
    
    COMMIT;
END;
/
