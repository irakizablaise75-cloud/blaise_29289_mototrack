-- Author: Irakiza Blaise
-- Student ID: 29289
-- Group: I
-- Project: MotoTrack
-- Connect directly to the CDB root service as SYSDBA before running this script.
-- ARCHIVELOG mode is configured for the whole CDB, not for individual PDBs.
-- All PDBs share the CDB redo logs and archive destination.
-- Changing the mode therefore affects every PDB and requires restarting the CDB.
-- On the shared lab server, check the mode only; do not change it.

SET PAGESIZE 100;

PROMPT === CURRENT CONTAINER ===
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS container_name
FROM dual;

PROMPT === CDB ARCHIVE LOG MODE ===
SELECT log_mode
FROM v$database;

-- Local installation only: run these as SYSDBA if you choose to enable ARCHIVELOG.
-- SHUTDOWN IMMEDIATE;
-- STARTUP MOUNT;
-- ALTER DATABASE ARCHIVELOG;
-- ALTER DATABASE OPEN;
-- ARCHIVE LOG LIST;
