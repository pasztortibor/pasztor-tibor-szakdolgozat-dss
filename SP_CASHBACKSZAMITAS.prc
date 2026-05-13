CREATE OR REPLACE PROCEDURE SP_CASHBACKSZAMITAS(
    p_szamla_id IN NUMBER, 
    p_datum IN DATE 
) AS
    v_mult_honap_eleje DATE;
    v_mult_honap_vege DATE;
    v_osszes_cashback NUMBER := 0;
    v_kartya_id NUMBER;
    v_huseg_id NUMBER;
    v_alap_szazalek NUMBER;
BEGIN
    v_mult_honap_eleje := ADD_MONTHS(TRUNC(p_datum, 'MM'), -1);
    v_mult_honap_vege  := LAST_DAY(v_mult_honap_eleje);

    SELECT h.huseg_id, hp.alap_cashback INTO v_huseg_id, v_alap_szazalek
    FROM hitelszamla h JOIN HUSEG_PROGRAM hp ON h.huseg_id = hp.huseg_id
    WHERE h.szamla_id = p_szamla_id;

    SELECT kartya_id INTO v_kartya_id FROM (SELECT kartya_id FROM HITELKARTYA WHERE szamla_id = p_szamla_id ORDER BY kartya_id) WHERE ROWNUM = 1;

    SELECT NVL(SUM(t.osszeg * (v_alap_szazalek + NVL(ext.extra_cashback_szazalek, 0)) / 100), 0) INTO v_osszes_cashback
    FROM TRANZAKCIO t
    JOIN HITELKARTYA k ON t.kartya_id = k.kartya_id
    LEFT JOIN HUSEG_PREF_MCC ext ON ext.huseg_id = v_huseg_id AND ext.mcc_id = t.mcc_id
    WHERE k.szamla_id = p_szamla_id AND t.tranz_tipus_id = 1 AND t.datum BETWEEN v_mult_honap_eleje AND v_mult_honap_vege;

    IF v_osszes_cashback >= 100 THEN
        v_osszes_cashback := ROUND(v_osszes_cashback, 0);
        
        IF v_osszes_cashback > 5000 THEN 
            v_osszes_cashback := 5000; 
        END IF;

        INSERT INTO TRANZAKCIO (kartya_id, mcc_id, tranz_tipus_id, deviza_id, akt_arfolyam, datum, osszeg, konvertalt_osszeg) 
        VALUES (v_kartya_id, NULL, 6, 1, 1, p_datum, v_osszes_cashback, v_osszes_cashback);
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN NULL;
    WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE('Hiba: ' || SQLERRM);
END;
/
