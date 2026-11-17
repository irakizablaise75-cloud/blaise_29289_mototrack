-- Audit trigger for daily_operations: logs INSERT/UPDATE/DELETE with summaries.
SET SERVEROUTPUT ON;

CREATE OR REPLACE TRIGGER trg_daily_operations_audit
AFTER INSERT OR UPDATE OR DELETE ON daily_operations
FOR EACH ROW
DECLARE
    l_action VARCHAR2(10);
    l_key    VARCHAR2(100);
BEGIN
    IF INSERTING THEN
        l_action := 'INSERT';
        l_key := :NEW.rider_id || ':' || :NEW.source_group || ':'
            || TO_CHAR(:NEW.operating_date, 'YYYY-MM-DD');
    ELSIF UPDATING THEN
        l_action := 'UPDATE';
        l_key := :NEW.rider_id || ':' || :NEW.source_group || ':'
            || TO_CHAR(:NEW.operating_date, 'YYYY-MM-DD');
    ELSE
        l_action := 'DELETE';
        l_key := :OLD.rider_id || ':' || :OLD.source_group || ':'
            || TO_CHAR(:OLD.operating_date, 'YYYY-MM-DD');
    END IF;

    INSERT INTO audit_log (
        table_name, record_key, action_type, changed_by, old_summary, new_summary)
    VALUES (
        'DAILY_OPERATIONS',
        l_key,
        l_action,
        NVL(SYS_CONTEXT('USERENV', 'SESSION_USER'), USER),
        CASE WHEN DELETING THEN
            'revenue=' || :OLD.revenue_kes || ', fuel=' || :OLD.fuel_cost_kes
            || ', battery=' || :OLD.battery_swap_cost_kes
            || ', maint=' || :OLD.maintenance_kes
        END,
        CASE WHEN INSERTING OR UPDATING THEN
            'revenue=' || :NEW.revenue_kes || ', fuel=' || :NEW.fuel_cost_kes
            || ', battery=' || :NEW.battery_swap_cost_kes
            || ', maint=' || :NEW.maintenance_kes
        END);
END;
/

PROMPT Audit trigger created.
