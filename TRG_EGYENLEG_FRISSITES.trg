CREATE OR REPLACE TRIGGER trg_egyenleg_frissites
AFTER INSERT ON TRANZAKCIO
FOR EACH ROW
DECLARE
    v_szamla_id NUMBER;
BEGIN
    SELECT szamla_id INTO v_szamla_id
    FROM HITELKARTYA
    WHERE kartya_id = :NEW.kartya_id;

    IF :NEW.tranz_tipus_id IN (1, 2, 4, 5) THEN
        UPDATE HITELSZAMLA
        SET egyenleg = egyenleg + :NEW.osszeg
        WHERE szamla_id = v_szamla_id;

    ELSIF :NEW.tranz_tipus_id IN (3, 6) THEN
        UPDATE HITELSZAMLA
        SET egyenleg = egyenleg - :NEW.osszeg
        WHERE szamla_id = v_szamla_id;
    END IF;
END;
/
