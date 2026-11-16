-- Run once as SYSDBA in CDB$ROOT.
-- Oracle Managed Files must be configured (DB_CREATE_FILE_DEST).
-- If the PDB already exists, skip this script and continue with 02_create_user.sql.
ACCEPT pdb_admin_password CHAR PROMPT 'Enter a password for the PDB administrator: ' HIDE

CREATE PLUGGABLE DATABASE MOTOTRACKPDB
    ADMIN USER mototrack_admin IDENTIFIED BY "&pdb_admin_password";

ALTER PLUGGABLE DATABASE MOTOTRACKPDB OPEN READ WRITE;
ALTER PLUGGABLE DATABASE MOTOTRACKPDB SAVE STATE;
ALTER SESSION SET CONTAINER = MOTOTRACKPDB;

SELECT name, open_mode
FROM v$pdbs
WHERE name = 'MOTOTRACKPDB';
