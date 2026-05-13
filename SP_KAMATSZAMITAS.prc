CREATE OR REPLACE PROCEDURE SP_KAMATSZAMITAS(p_szamla_id IN NUMBER, p_datum IN DATE) AS
    v_mult_havi_zaro_huf NUMBER(12,2);
    v_targyhavi_befizetesek NUMBER(12,2);
    v_kamat_alap NUMBER(12,2);
    v_kamat_osszeg NUMBER(12,2);
    v_kartya_id NUMBER;
    v_mult_honap_id NUMBER(6);
BEGIN
    v_mult_honap_id := TO_NUMBER(TO_CHAR(ADD_MONTHS(p_datum, -1), 'YYYYMM'));
    SELECT kartya_id INTO v_kartya_id FROM (SELECT kartya_id FROM HITELKARTYA WHERE szamla_id = p_szamla_id ORDER BY kartya_id) WHERE ROWNUM = 1;

    BEGIN
        SELECT zaro_egyenleg_huf INTO v_mult_havi_zaro_huf FROM HAVI_KPI WHERE szamla_id = p_szamla_id AND honap = v_mult_honap_id;
    EXCEPTION WHEN NO_DATA_FOUND THEN v_mult_havi_zaro_huf := 0; END;

    SELECT NVL(SUM(t.osszeg), 0) INTO v_targyhavi_befizetesek
    FROM TRANZAKCIO t JOIN HITELKARTYA k ON t.kartya_id = k.kartya_id
    WHERE k.szamla_id = p_szamla_id AND t.tranz_tipus_id = 3 AND t.datum BETWEEN TRUNC(p_datum, 'MM') AND p_datum;

    IF v_mult_havi_zaro_huf > 0 THEN
        v_kamat_alap := v_mult_havi_zaro_huf - v_targyhavi_befizetesek;
        
        IF v_kamat_alap > 0 THEN
            v_kamat_osszeg := ROUND(v_kamat_alap * 0.04, 0); 
            INSERT INTO TRANZAKCIO (kartya_id, mcc_id, tranz_tipus_id, deviza_id, akt_arfolyam, datum, osszeg, konvertalt_osszeg)
            VALUES (v_kartya_id, NULL, 4, 1, 1, p_datum, v_kamat_osszeg, v_kamat_osszeg);
        END IF;

        IF v_targyhavi_befizetesek < (v_mult_havi_zaro_huf * 0.05) THEN
            INSERT INTO TRANZAKCIO (kartya_id, mcc_id, tranz_tipus_id, deviza_id, akt_arfolyam, datum, osszeg, konvertalt_osszeg)
            VALUES (v_kartya_id, NULL, 5, 1, 1, p_datum, 5432, 5432);
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Hiba: ' || SQLERRM);
END;
/
