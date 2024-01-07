CREATE TABLESPACE sensor_mgr_tablespace
   DATAFILE 'tbs_sensor_mgr_tablespace.dbf' 
   SIZE 1m;

/* use double-quotes so flyway can create migration table*/
CREATE USER "sensor_manager" IDENTIFIED BY  sensor_manager default TABLESPACE sensor_mgr_tablespace;
grant create session, CREATE SEQUENCE, CONNECT, resource to "sensor_manager";
GRANT UNLIMITED TABLESPACE TO "sensor_manager";
 
grant AQ_ADMINISTRATOR_ROLE to "sensor_manager"; 
grant execute on DBMS_AQADM to "sensor_manager";
grant execute on DBMS_AQ to "sensor_manager";