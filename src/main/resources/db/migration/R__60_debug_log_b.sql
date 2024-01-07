-- ${flyway:timestamp}
CREATE OR REPLACE PACKAGE BODY debug_log AS

  G_USER_CONTEXT debug_logs.user_context%TYPE := SYS_CONTEXT ('USERENV', 'OS_USER')||'@'||SYS_CONTEXT ('USERENV', 'HOST')||' from '||SYS_CONTEXT ('USERENV', 'MODULE')||';'||SYS_CONTEXT ('USERENV', 'SESSION_USER')||';'||SYS_CONTEXT ('USERENV', 'SID');
  
  PROCEDURE create_message(
     p_LOG_TYPE debug_logs.LOG_TYPE%TYPE
    ,p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  ) IS
  PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN
    INSERT INTO debug_logs(id, log_type, message, log_date, context, user_context, table_name, record_id)
    VALUES(debug_logs_seq.nextval, p_LOG_TYPE, p_MESSAGE, SYSTIMESTAMP, p_CONTEXT, G_USER_CONTEXT, p_TABLE_NAME, p_RECORD_ID);    
    
    commit;
    
    dbms_output.put_line('['||p_LOG_TYPE||']'||p_CONTEXT||': '||p_MESSAGE);
  EXCEPTION 
    WHEN OTHERS THEN
      ROLLBACK;
      dbms_output.put_line('Unexpected error by creating log: '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE );
  END;
    
  PROCEDURE create_debug(
     p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  ) IS
  BEGIN
    create_message(
       p_LOG_TYPE => c_log_level_debug
      ,p_CONTEXT => p_CONTEXT
      ,p_MESSAGE => p_MESSAGE
      ,p_TABLE_NAME => p_TABLE_NAME
      ,p_RECORD_ID => p_RECORD_ID
    ); 
  END;
  
  PROCEDURE create_error(
     p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  ) IS
  BEGIN
    create_message(
       p_LOG_TYPE => c_log_level_error
      ,p_CONTEXT => p_CONTEXT
      ,p_MESSAGE => p_MESSAGE
      ,p_TABLE_NAME => p_TABLE_NAME
      ,p_RECORD_ID => p_RECORD_ID
    ); 
  END; 
  
  PROCEDURE create_info(
     p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  ) IS
  BEGIN
    create_message(
       p_LOG_TYPE => c_log_level_info
      ,p_CONTEXT => p_CONTEXT
      ,p_MESSAGE => p_MESSAGE
      ,p_TABLE_NAME => p_TABLE_NAME
      ,p_RECORD_ID => p_RECORD_ID
    ); 
  END; 
  
  PROCEDURE create_warning(
     p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  ) IS
  BEGIN
    create_message(
       p_LOG_TYPE => c_log_level_warn
      ,p_CONTEXT => p_CONTEXT
      ,p_MESSAGE => p_MESSAGE
      ,p_TABLE_NAME => p_TABLE_NAME
      ,p_RECORD_ID => p_RECORD_ID
    ); 
  END;  
  
END debug_log;