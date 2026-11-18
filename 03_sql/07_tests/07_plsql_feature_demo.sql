SET SERVEROUTPUT ON;

-- RECORD type and collection (BULK COLLECT) demonstration.
DECLARE
    TYPE t_op_record IS RECORD (
        rider_code     riders.rider_code%TYPE,
        operating_date daily_operations.operating_date%TYPE,
        revenue_kes    daily_operations.revenue_kes%TYPE
    );
    TYPE t_op_collection IS TABLE OF t_op_record;
    v_ops t_op_collection;
BEGIN
    SELECT r.rider_code, d.operating_date, d.revenue_kes
    BULK COLLECT INTO v_ops
    FROM daily_operations d
    JOIN riders r ON r.rider_id = d.rider_id
    WHERE ROWNUM <= 10;

    DBMS_OUTPUT.PUT_LINE('BULK COLLECT records: ' || v_ops.COUNT);
    FOR i IN 1..v_ops.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE(v_ops(i).rider_code || ' '
            || TO_CHAR(v_ops(i).operating_date, 'YYYY-MM-DD')
            || ' revenue=' || NVL(TO_CHAR(v_ops(i).revenue_kes), 'NULL'));
    END LOOP;
END;
/

-- Explicit cursor demonstration.
DECLARE
    CURSOR c_riders IS
        SELECT rider_code FROM riders ORDER BY rider_code;
BEGIN
    FOR r IN c_riders LOOP
        DBMS_OUTPUT.PUT_LINE('Rider ' || r.rider_code);
        EXIT WHEN c_riders%ROWCOUNT >= 5;
    END LOOP;
END;
/

-- Implicit cursor demonstration.
BEGIN
    UPDATE riders SET created_at = created_at WHERE 1=0;
    DBMS_OUTPUT.PUT_LINE('Rows affected by last DML: ' || SQL%ROWCOUNT);
END;
/

-- FORALL demonstration in a small isolated demo table.
-- Create this table once before running the block.
CREATE TABLE mototrack_bulk_demo (
    demo_id NUMBER PRIMARY KEY,
    demo_value VARCHAR2(40)
);

DECLARE
    TYPE t_ids IS TABLE OF NUMBER;
    TYPE t_values IS TABLE OF VARCHAR2(40);
    v_ids t_ids := t_ids(1,2,3);
    v_values t_values := t_values('Daily batch A','Daily batch B','Daily batch C');
BEGIN
    FORALL i IN 1..v_ids.COUNT
        INSERT INTO mototrack_bulk_demo(demo_id,demo_value)
        VALUES(v_ids(i),v_values(i));

    DBMS_OUTPUT.PUT_LINE('FORALL processed ' || SQL%ROWCOUNT || ' demo rows.');
END;
/
SELECT * FROM mototrack_bulk_demo ORDER BY demo_id;
