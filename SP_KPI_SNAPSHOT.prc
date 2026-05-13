CREATE OR REPLACE PROCEDURE SP_KPI_SNAPSHOT(
    p_szamla_id IN NUMBER, 
    p_datum IN DATE
) AS
    v_zaro_egyenleg NUMBER;
    v_hitelkeret NUMBER;
    v_kihasznaltsag NUMBER(10,2);
    v_honap_id NUMBER(6);
    v_szamla_statusz VARCHAR2(20);

    v_havi_kamat NUMBER := 0;
    v_havi_dijak NUMBER := 0;
    v_havi_cashback NUMBER := 0;

    v_tranz_szam NUMBER := 0;
    v_vasarlas_volumen NUMBER := 0;
    v_kp_volumen NUMBER := 0;
    v_befizetes_osszeg NUMBER := 0;

    v_mult_honap_id NUMBER(6);
    v_mult_havi_zaro NUMBER := 0;
    v_fizetesi_hanyad NUMBER(5,2) := 0;
    v_kesedelmes_napok NUMBER := 0;

    v_honap_eleje DATE := TRUNC(p_datum, 'MM');
    v_honap_vege DATE := LAST_DAY(p_datum);
BEGIN
    SELECT egyenleg, hitelkeret, statusz 
    INTO v_zaro_egyenleg, v_hitelkeret, v_szamla_statusz
    FROM hitelszamla 
    WHERE szamla_id = p_szamla_id;

    SELECT 
        NVL(SUM(CASE WHEN t.tranz_tipus_id = 4 THEN t.osszeg ELSE 0 END), 0),
        NVL(SUM(CASE WHEN t.tranz_tipus_id = 5 THEN t.osszeg ELSE 0 END), 0),
        NVL(SUM(CASE WHEN t.tranz_tipus_id = 6 THEN t.osszeg ELSE 0 END), 0),
        COUNT(CASE WHEN t.tranz_tipus_id IN (1, 2) THEN t.tranz_id END),
        NVL(SUM(CASE WHEN t.tranz_tipus_id = 1 THEN t.osszeg ELSE 0 END), 0),
        NVL(SUM(CASE WHEN t.tranz_tipus_id = 2 THEN t.osszeg ELSE 0 END), 0),
        NVL(SUM(CASE WHEN t.tranz_tipus_id = 3 THEN t.osszeg ELSE 0 END), 0)
    INTO 
        v_havi_kamat, v_havi_dijak, v_havi_cashback,
        v_tranz_szam, v_vasarlas_volumen, v_kp_volumen, v_befizetes_osszeg
    FROM TRANZAKCIO t
    JOIN HITELKARTYA k ON t.kartya_id = k.kartya_id
    WHERE k.szamla_id = p_szamla_id 
      AND t.datum BETWEEN v_honap_eleje AND v_honap_vege;

    v_honap_id := TO_NUMBER(TO_CHAR(p_datum, 'YYYYMM'));
    v_mult_honap_id := TO_NUMBER(TO_CHAR(ADD_MONTHS(p_datum, -1), 'YYYYMM'));

    BEGIN
        SELECT zaro_egyenleg_huf, kesedelmes_napok INTO v_mult_havi_zaro, v_kesedelmes_napok 
        FROM HAVI_KPI 
        WHERE szamla_id = p_szamla_id AND honap = v_mult_honap_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN 
            v_mult_havi_zaro := 0;
            v_kesedelmes_napok := 0;
    END;

    IF v_mult_havi_zaro > 0 THEN
        v_fizetesi_hanyad := ROUND((v_befizetes_osszeg / v_mult_havi_zaro) * 100, 2);
    ELSE
        v_fizetesi_hanyad := 0;
    END IF;

    IF v_mult_havi_zaro > 0 THEN
        IF v_fizetesi_hanyad < 5 THEN
            v_kesedelmes_napok := v_kesedelmes_napok + 30;
            
        ELSIF v_fizetesi_hanyad >= 100 THEN
            v_kesedelmes_napok := 0;
            
        ELSE
          
            v_kesedelmes_napok := v_kesedelmes_napok; 
        END IF;
    ELSE
        v_kesedelmes_napok := 0; 
    END IF;

    IF v_hitelkeret > 0 THEN 
        v_kihasznaltsag := ROUND((v_zaro_egyenleg / v_hitelkeret) * 100, 2);
    ELSE 
        v_kihasznaltsag := 0; 
    END IF;

    INSERT INTO HAVI_KPI (
        szamla_id, honap, zaro_egyenleg_huf, keretkihaszn_index, 
        kalkulalt_kamat, kalkulalt_dijak, kalkulalt_cashback,
        tranzakciok_szama, vasarlasi_volumen, kp_felvetel_volumen,
        befizetett_osszeg, fizetesi_hanyad, kesedelmes_napok, szamla_statusz
    ) VALUES (
        p_szamla_id, v_honap_id, v_zaro_egyenleg, v_kihasznaltsag, 
        v_havi_kamat, v_havi_dijak, v_havi_cashback,
        v_tranz_szam, v_vasarlas_volumen, v_kp_volumen,
        v_befizetes_osszeg, v_fizetesi_hanyad, v_kesedelmes_napok, v_szamla_statusz
    );

EXCEPTION
    WHEN OTHERS THEN 
        DBMS_OUTPUT.PUT_LINE('Hiba a KPI mentésnél (Számla ID: ' || p_szamla_id || '): ' || SQLERRM);
END;
/
