-- ${flyway:timestamp}
create or replace PACKAGE aq_common AS

  TYPE t_varchar2 IS TABLE OF VARCHAR2(2000); 

  TYPE t_aq_config IS RECORD (
     queue_name VARCHAR2(32)
    ,full_queue_name VARCHAR2(32)
    ,queue_table_name VARCHAR2(32)
    ,payload_type  VARCHAR2(32)
    ,table_space VARCHAR2(32)
    ,exception_queue_name VARCHAR2(32)
    ,retries NUMBER
    ,retry_delay NUMBER
    ,db_users_assigned t_varchar2 
  );
  
  TYPE t_aq_configs IS TABLE OF t_aq_config;   
  
  C_APP_NAME CONSTANT VARCHAR2(32) := 'AQ_CAMEL_EXAMPLE';
  
END aq_common;