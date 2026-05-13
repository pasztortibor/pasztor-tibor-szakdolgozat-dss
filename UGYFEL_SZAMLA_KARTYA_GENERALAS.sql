DECLARE
    v_ugyfel_id NUMBER;
    v_szamla_id NUMBER;
    v_szegmens_esely NUMBER;
    v_szegmens_id NUMBER;
    v_kartya_tipus_id NUMBER;
    v_keret_min NUMBER;
    v_keret_max NUMBER;
    v_huseg_id NUMBER;
    v_keret NUMBER;
    v_kartyaszam_prefix VARCHAR2(1);
    v_kartyaszam VARCHAR2(16);
    v_szamlaszam VARCHAR2(24);
    v_vezeteknev VARCHAR2(100);
    v_keresztnev VARCHAR2(100);
    v_nem NUMBER;
    v_kartya_esely NUMBER; 
    v_nyitas_datum DATE;
    v_gyartas_datum DATE;
    v_aktivalas_datum DATE;
    v_ervenyesseg_datum DATE;

    TYPE t_szoveg_lista IS TABLE OF VARCHAR2(50);
    v_vezeteknevek t_szoveg_lista := t_szoveg_lista('Kovács', 'Nagy', 'Tóth', 'Szabó', 'Horváth', 'Varga', 'Kiss', 'Molnár', 'Németh', 'Farkas', 'Balogh', 'Papp');
    v_ferfi_nevek t_szoveg_lista := t_szoveg_lista('Bence', 'Máté', 'Gábor', 'Dávid', 'Balázs', 'Attila', 'Péter', 'Tamás', 'Zoltán', 'László');
    v_noi_nevek t_szoveg_lista := t_szoveg_lista('Anna', 'Boglárka', 'Zsófia', 'Réka', 'Viktória', 'Eszter', 'Laura', 'Dóra', 'Katalin', 'Éva');
    v_varosok t_szoveg_lista := t_szoveg_lista('Budapest', 'Debrecen', 'Szeged', 'Miskolc', 'Pécs', 'Gyõr', 'Nyíregyháza', 'Kecskemét');

BEGIN
  
    FOR i IN 1..100 LOOP
        
        v_szegmens_esely := DBMS_RANDOM.VALUE(1, 100);
        
        IF v_szegmens_esely <= 75 THEN
            v_szegmens_id := 1;
            v_kartya_tipus_id := TRUNC(DBMS_RANDOM.VALUE(1, 3));
            
        ELSIF v_szegmens_esely <= 95 THEN
            v_szegmens_id := 2;
            v_kartya_tipus_id := TRUNC(DBMS_RANDOM.VALUE(3, 5));
            
        ELSE
            v_szegmens_id := 3;
            v_kartya_tipus_id := 5;
        END IF;

        IF v_kartya_tipus_id IN (1, 3, 5) THEN v_kartyaszam_prefix := '5';
        ELSE v_kartyaszam_prefix := '4'; END IF;

        v_vezeteknev := v_vezeteknevek(TRUNC(DBMS_RANDOM.VALUE(1, 13)));
        v_nem := TRUNC(DBMS_RANDOM.VALUE(1, 3));
        IF v_nem = 1 THEN v_keresztnev := v_ferfi_nevek(TRUNC(DBMS_RANDOM.VALUE(1, 11)));
        ELSE v_keresztnev := v_noi_nevek(TRUNC(DBMS_RANDOM.VALUE(1, 11))); END IF;

        INSERT INTO UGYFEL (szegmens_id, vezeteknev, keresztnev, szul_datum, irszam, varos, utca, hazszam)
        VALUES (
            v_szegmens_id, v_vezeteknev, v_keresztnev,
            ADD_MONTHS(SYSDATE, -TRUNC(DBMS_RANDOM.VALUE(240, 840))),
            TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1000, 9999))),
            v_varosok(TRUNC(DBMS_RANDOM.VALUE(1, 9))),
            'Fõ utca', TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(1, 150)))
        ) RETURNING ugyfel_id INTO v_ugyfel_id;

        v_huseg_id := TRUNC(DBMS_RANDOM.VALUE(1, 6));
        v_szamlaszam := '117' || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 999999999999999999999)), 21, '0'); 
        v_nyitas_datum := ADD_MONTHS(SYSDATE, -TRUNC(DBMS_RANDOM.VALUE(12, 60)));

        SELECT keret_min, keret_max INTO v_keret_min, v_keret_max 
        FROM KARTYA_TIPUS WHERE kartya_tipus_id = v_kartya_tipus_id;

        v_keret := ROUND(DBMS_RANDOM.VALUE(v_keret_min, v_keret_max) / 10000) * 10000;

        INSERT INTO HITELSZAMLA (szamlaszam, ugyfel_id, huseg_id, nyitas_datum, hitelkeret, egyenleg)
        VALUES (v_szamlaszam, v_ugyfel_id, v_huseg_id, v_nyitas_datum, v_keret, 0) 
        RETURNING szamla_id INTO v_szamla_id;

        v_gyartas_datum := v_nyitas_datum + TRUNC(DBMS_RANDOM.VALUE(1, 3)); 
        v_aktivalas_datum := v_gyartas_datum + TRUNC(DBMS_RANDOM.VALUE(5, 16)); 
        v_ervenyesseg_datum := ADD_MONTHS(v_gyartas_datum, 60); 

        v_kartyaszam := v_kartyaszam_prefix || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 999999999999999)), 15, '0');

        INSERT INTO HITELKARTYA (szamla_id, kartya_tipus_id, kartyaszam, gyartas, aktivalas, ervenyesseg)
        VALUES (v_szamla_id, v_kartya_tipus_id, v_kartyaszam, v_gyartas_datum, v_aktivalas_datum, v_ervenyesseg_datum);

        v_kartya_esely := DBMS_RANDOM.VALUE(1, 100);
        IF v_kartya_esely <= 20 THEN

            v_kartyaszam := v_kartyaszam_prefix || LPAD(TRUNC(DBMS_RANDOM.VALUE(1, 999999999999999)), 15, '0');

            INSERT INTO HITELKARTYA (szamla_id, kartya_tipus_id, kartyaszam, gyartas, aktivalas, ervenyesseg)
            VALUES (v_szamla_id, v_kartya_tipus_id, v_kartyaszam, v_gyartas_datum, v_aktivalas_datum, v_ervenyesseg_datum);
        END IF;

    END LOOP;
    
    COMMIT;
    
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END;
/
