-- Author: Irakiza Blaise
-- Student ID: 29289
-- Group: I
-- Project: MotoTrack
-- Run once as SYSDBA in CDB$ROOT.
-- Oracle Managed Files must be configured (DB_CREATE_FILE_DEST).
-- If the PDB already exists, skip this script and continue with 02_create_user.sql.
ACCEPT pdb_admin_password CHAR PROMPT 'Enter the PDB administrator password (use blaise): ' HIDE

CREATE PLUGGABLE DATABASE i_29289_blaise_mototrack_db
    ADMIN USER blaise_admin IDENTIFIED BY "&pdb_admin_password"
    FILE_NAME_CONVERT = (
        'C:\APP\ORADATA\ORCL\PDBSEED',
        'C:\APP\ORADATA\ORCL\I_29289_BLAISE_MOTOTRACK_DB'
    );

ALTER PLUGGABLE DATABASE i_29289_blaise_mototrack_db OPEN READ WRITE;
ALTER PLUGGABLE DATABASE i_29289_blaise_mototrack_db SAVE STATE;
ALTER SESSION SET CONTAINER = i_29289_blaise_mototrack_db;

SELECT name, open_mode
FROM v$pdbs
WHERE name = 'I_29289_BLAISE_MOTOTRACK_DB';
