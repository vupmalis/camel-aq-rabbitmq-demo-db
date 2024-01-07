-- ${flyway:timestamp}
CREATE OR REPLACE PACKAGE debug_log IS

   c_log_level_debug CONSTANT debug_logs.LOG_TYPE%TYPE := 'DEBUG';
   c_log_level_error CONSTANT debug_logs.LOG_TYPE%TYPE := 'ERROR';
   c_log_level_info CONSTANT debug_logs.LOG_TYPE%TYPE := 'INFO';
   c_log_level_warn CONSTANT debug_logs.LOG_TYPE%TYPE := 'WARN';
 
  PROCEDURE create_message(
     p_LOG_TYPE debug_logs.LOG_TYPE%TYPE
    ,p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  );
  
  PROCEDURE create_debug(
     p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  );  
  
  PROCEDURE create_error(
     p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  ); 
  
  PROCEDURE create_info(
     p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  ); 
  
  PROCEDURE create_warning(
     p_CONTEXT debug_logs.CONTEXT%TYPE
    ,p_MESSAGE debug_logs.MESSAGE%TYPE
    ,p_TABLE_NAME debug_logs.TABLE_NAME%TYPE DEFAULT NULL
    ,p_RECORD_ID debug_logs.RECORD_ID%TYPE DEFAULT NULL
  );   

END debug_log;