-- Author: Irakiza Blaise
-- Student ID: 29289
-- Group: I
-- Project: MotoTrack
-- Run as SYSDBA after opening i_29289_blaise_mototrack_db.
ALTER SESSION SET CONTAINER = i_29289_blaise_mototrack_db;

GRANT DBA TO blaise_admin;

SELECT username, account_status, default_tablespace, temporary_tablespace
FROM dba_users
WHERE username = 'BLAISE_ADMIN';

PROMPT === CONNECT AS PDB ADMIN ===
ACCEPT pdb_admin_password CHAR PROMPT 'Enter the PDB administrator password (use blaise): ' HIDE
ACCEPT pdb_service CHAR DEFAULT i_29289_blaise_mototrack_db PROMPT 'Enter the PDB service name [i_29289_blaise_mototrack_db]: '
CONNECT blaise_admin/&pdb_admin_password@&pdb_service

SELECT USER AS connected_user, SYS_CONTEXT('USERENV', 'CON_NAME') AS current_container
FROM dual;
