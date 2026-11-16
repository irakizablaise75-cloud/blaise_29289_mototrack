-- Validate that the PDB, user, and tablespaces are ready for the MotoTrack schema.
-- Run as SYSDBA.
ALTER SESSION SET CONTAINER = MOTOTRACKPDB;

SET PAGESIZE 200;
COLUMN pdb_name FORMAT A20;
COLUMN open_mode FORMAT A12;
COLUMN username FORMAT A20;
COLUMN default_tablespace FORMAT A20;
COLUMN temporary_tablespace FORMAT A20;
COLUMN tablespace_name FORMAT A20;

PROMPT === PDB STATUS ===
SELECT name AS pdb_name, open_mode
FROM v$pdbs
WHERE name = 'MOTOTRACKPDB';

PROMPT === USER STATUS ===
SELECT username, account_status, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username = 'MOTOTRACK';

PROMPT === TABLESPACE STATUS ===
SELECT tablespace_name, status, contents
FROM dba_tablespaces
WHERE tablespace_name IN ('MOTOTRACK_DATA', 'MOTOTRACK_IDX', 'MOTOTRACK_TMP')
ORDER BY tablespace_name;

PROMPT === PRIVILEGES ===
SELECT privilege
FROM dba_sys_privs
WHERE grantee = 'MOTOTRACK'
ORDER BY privilege;

DECLARE
    l_user_count       NUMBER;
    l_data_count       NUMBER;
    l_index_count      NUMBER;
    l_temp_count       NUMBER;
    l_default_count    NUMBER;
    l_privilege_count  NUMBER;
BEGIN
    IF SYS_CONTEXT('USERENV', 'CON_NAME') <> 'MOTOTRACKPDB' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Current container is not MOTOTRACKPDB.');
    END IF;

    SELECT COUNT(*)
      INTO l_user_count
      FROM dba_users
     WHERE username = 'MOTOTRACK'
       AND account_status = 'OPEN';

    SELECT COUNT(*)
      INTO l_data_count
      FROM dba_tablespaces
     WHERE tablespace_name = 'MOTOTRACK_DATA'
       AND contents = 'PERMANENT'
       AND status = 'ONLINE';

    SELECT COUNT(*)
      INTO l_index_count
      FROM dba_tablespaces
     WHERE tablespace_name = 'MOTOTRACK_IDX'
       AND contents = 'PERMANENT'
       AND status = 'ONLINE';

    SELECT COUNT(*)
      INTO l_temp_count
      FROM dba_tablespaces
     WHERE tablespace_name = 'MOTOTRACK_TMP'
       AND contents = 'TEMPORARY'
       AND status = 'ONLINE';

    SELECT COUNT(*)
      INTO l_default_count
      FROM dba_users
     WHERE username = 'MOTOTRACK'
       AND default_tablespace = 'MOTOTRACK_DATA'
       AND temporary_tablespace = 'MOTOTRACK_TMP';

    SELECT COUNT(*)
      INTO l_privilege_count
      FROM dba_sys_privs
     WHERE grantee = 'MOTOTRACK'
       AND privilege IN (
           'CREATE SESSION',
           'CREATE TABLE',
           'CREATE VIEW',
           'CREATE PROCEDURE',
           'CREATE TRIGGER'
       );

    IF l_user_count <> 1
       OR l_data_count <> 1
       OR l_index_count <> 1
       OR l_temp_count <> 1
       OR l_default_count <> 1
       OR l_privilege_count <> 5 THEN
        RAISE_APPLICATION_ERROR(-20002, 'MotoTrack setup verification failed; review the results above.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('MotoTrack PDB setup verified.');
END;
/
