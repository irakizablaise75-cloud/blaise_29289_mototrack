SET SERVEROUTPUT ON;

-- This test updates one existing daily record and should create an audit row.
DECLARE
    v_daily_id NUMBER;
BEGIN
    SELECT daily_id INTO v_daily_id
    FROM daily_operations
    WHERE ROWNUM = 1;

    UPDATE daily_operations
    SET revenue_kes = revenue_kes
    WHERE daily_id = v_daily_id;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Updated DAILY_OPERATIONS row ' || v_daily_id);
END;
/

SELECT * FROM audit_log
ORDER BY changed_at DESC
FETCH FIRST 10 ROWS ONLY;
