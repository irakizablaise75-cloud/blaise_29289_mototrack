-- Run this script as SYSDBA in the CDB root container.
-- Archive logging is required for recovery and for an operational Oracle database.
ALTER SESSION SET CONTAINER = CDB$ROOT;

SET SERVEROUTPUT ON;

SELECT log_mode
FROM v$database;

-- If the database is not in ARCHIVELOG mode, run the following commands:
-- SHUTDOWN IMMEDIATE;
-- STARTUP MOUNT;
-- ALTER DATABASE ARCHIVELOG;
-- ALTER DATABASE OPEN;
-- ARCHIVE LOG LIST;

-- The commands above are intentionally explicit because ALTER DATABASE ARCHIVELOG
-- cannot be executed while the database is open in a normal session.
