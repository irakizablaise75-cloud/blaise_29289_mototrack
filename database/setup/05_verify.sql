-- Author: Irakiza Blaise
-- Student ID: 29289
-- Group: I
-- Project: MotoTrack
-- Validate that the PDB, PDB administrator, and tablespaces are ready.
-- Run as SYSDBA.
ALTER SESSION SET CONTAINER = i_29289_blaise_mototrack_db;
SET SERVEROUTPUT ON;

BEGIN
    DBMS_XDB_CONFIG.SETHTTPSPORT(5589);
END;
/

SET PAGESIZE 200;
COLUMN pdb_name FORMAT A20;
COLUMN connected_user FORMAT A20;
COLUMN captured_at FORMAT A20;
COLUMN open_mode FORMAT A12;
COLUMN username FORMAT A20;
COLUMN default_tablespace FORMAT A20;
COLUMN temporary_tablespace FORMAT A20;
COLUMN tablespace_name FORMAT A20;

PROMPT === EVIDENCE TIMESTAMP ===
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS pdb_name,
       USER AS connected_user,
       TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') AS captured_at
FROM dual;

PROMPT === PDB LIST ===
SHOW PDBS;

PROMPT === PDB STATUS ===
SELECT name AS pdb_name, open_mode
FROM v$pdbs
WHERE name = 'I_29289_BLAISE_MOTOTRACK_DB';

PROMPT === USER STATUS ===
SELECT username, account_status, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username = 'BLAISE_ADMIN';

PROMPT === TABLESPACE STATUS ===
SELECT tablespace_name, status, contents
FROM dba_tablespaces
WHERE tablespace_name IN ('MOTOTRACK_DATA', 'MOTOTRACK_IDX', 'MOTOTRACK_TEMP')
ORDER BY tablespace_name;

PROMPT === DBA ROLE ===
SELECT granted_role
FROM dba_role_privs
WHERE grantee = 'BLAISE_ADMIN'
  AND granted_role = 'DBA';

PROMPT === TABLESPACE FILE SETTINGS ===
SELECT tablespace_name,
       ROUND(bytes / 1024 / 1024) AS size_mb,
       autoextensible,
       ROUND(maxbytes / 1024 / 1024) AS max_size_mb,
       file_name
FROM dba_data_files
WHERE tablespace_name IN ('MOTOTRACK_DATA', 'MOTOTRACK_IDX');

PROMPT === TEMPORARY TABLESPACE FILE SETTINGS ===
SELECT tablespace_name,
       ROUND(bytes / 1024 / 1024) AS size_mb,
       autoextensible,
       ROUND(maxbytes / 1024 / 1024) AS max_size_mb,
       file_name
FROM dba_temp_files
WHERE tablespace_name = 'MOTOTRACK_TEMP';

PROMPT === UNLIMITED QUOTAS ===
SELECT username,
       tablespace_name,
       max_bytes
FROM dba_ts_quotas
WHERE username = 'BLAISE_ADMIN'
  AND tablespace_name IN ('MOTOTRACK_DATA', 'MOTOTRACK_IDX');

PROMPT === HTTPS PORT ===
SELECT dbms_xdb_config.gethttpsport AS em_https_port FROM dual;

PROMPT === ARCHIVE LOG MODE ===
SELECT log_mode FROM v$database;

DECLARE
    l_user_count       NUMBER;
    l_data_count       NUMBER;
    l_index_count      NUMBER;
    l_temp_count       NUMBER;
    l_default_count    NUMBER;
    l_dba_role_count   NUMBER;
    l_quota_count      NUMBER;
BEGIN
    IF SYS_CONTEXT('USERENV', 'CON_NAME') <> 'I_29289_BLAISE_MOTOTRACK_DB' THEN
        RAISE_APPLICATION_ERROR(-20001, 'Current container is not I_29289_BLAISE_MOTOTRACK_DB.');
    END IF;

    SELECT COUNT(*)
      INTO l_user_count
      FROM dba_users
     WHERE username = 'BLAISE_ADMIN'
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
     WHERE tablespace_name = 'MOTOTRACK_TEMP'
       AND contents = 'TEMPORARY'
       AND status = 'ONLINE';

    SELECT COUNT(*)
      INTO l_default_count
      FROM dba_users
     WHERE username = 'BLAISE_ADMIN'
       AND default_tablespace = 'MOTOTRACK_DATA'
       AND temporary_tablespace = 'MOTOTRACK_TEMP';

    SELECT COUNT(*)
      INTO l_dba_role_count
      FROM dba_role_privs
     WHERE grantee = 'BLAISE_ADMIN'
       AND granted_role = 'DBA';

    SELECT COUNT(*)
      INTO l_quota_count
      FROM dba_ts_quotas
     WHERE username = 'BLAISE_ADMIN'
       AND tablespace_name IN ('MOTOTRACK_DATA', 'MOTOTRACK_IDX')
       AND max_bytes = -1;

    IF l_user_count <> 1
       OR l_data_count <> 1
       OR l_index_count <> 1
       OR l_temp_count <> 1
       OR l_default_count <> 1
       OR l_dba_role_count <> 1
       OR l_quota_count <> 2 THEN
        RAISE_APPLICATION_ERROR(-20002, 'MotoTrack setup verification failed; review the results above.');
    END IF;

    DBMS_OUTPUT.PUT_LINE('MotoTrack PDB setup verified.');
END;
/
