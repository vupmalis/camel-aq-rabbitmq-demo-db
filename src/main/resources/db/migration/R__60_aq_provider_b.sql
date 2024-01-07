-- ${flyway:timestamp}
create or replace PACKAGE BODY aq_provider AS
  
   c_package_name CONSTANT VARCHAR2(32) := $$plsql_unit;

  PROCEDURE create_queue_table (
    p_queue_configuration IN aq_common.t_aq_config
  ) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.create_queue_table';
    
    --ORA-24001: cannot create QUEUE_TABLE, <table> already exists
    e_queue_table_exists EXCEPTION;
    PRAGMA exception_init ( e_queue_table_exists, -24001 );
    
  BEGIN
    dbms_aqadm.create_queue_table(
      queue_table => p_queue_configuration.queue_table_name
     ,queue_payload_type => p_queue_configuration.payload_type
     ,storage_clause => 'TABLESPACE '||p_queue_configuration.table_space
     ,sort_list => 'PRIORITY,ENQ_TIME'
    );
  EXCEPTION
    WHEN e_queue_table_exists THEN
      debug_log.create_warning(p_CONTEXT => c_unit_name, p_MESSAGE => 'Queue table '||p_queue_configuration.queue_table_name||' already created');
  END;

  PROCEDURE create_queue_objects (
    p_queue_configuration IN aq_common.t_aq_config
  ) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.create_queue_objects';
  
    --ORA-24006: cannot create QUEUE, <queue name> already exists
    e_queue_exists EXCEPTION;
    PRAGMA exception_init ( e_queue_exists, -24006 );
  BEGIN
    create_queue_table(p_queue_configuration => p_queue_configuration);
    dbms_aqadm.create_queue(queue_name => p_queue_configuration.queue_name, queue_table => p_queue_configuration.queue_table_name);
  EXCEPTION
    WHEN e_queue_exists THEN
      debug_log.create_error(p_CONTEXT => c_unit_name, p_MESSAGE => 'Queue '||p_queue_configuration.queue_name||' already exists');
  END;

  PROCEDURE stop_queue (
    p_queue_name IN VARCHAR2
  ) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.stop_queue';
    -- ORA-24010: QUEUE <queue> does not exist
    e_queue_does_not_exists EXCEPTION;
    PRAGMA exception_init ( e_queue_does_not_exists, -24010 );
  BEGIN
    dbms_aqadm.stop_queue(queue_name => p_queue_name);
  EXCEPTION
    WHEN e_queue_does_not_exists THEN
      debug_log.create_error(p_CONTEXT => c_unit_name, p_MESSAGE => 'Queue '||p_queue_name||' does not exists');
  END;

  PROCEDURE start_queue (
    p_queue_name IN VARCHAR2
  ) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.start_queue';
    -- ORA-24010: QUEUE <queue> does not exist
    e_queue_does_not_exists EXCEPTION;
    PRAGMA exception_init ( e_queue_does_not_exists, -24010 );
  BEGIN
    dbms_aqadm.start_queue(queue_name => p_queue_name);
  EXCEPTION
    WHEN e_queue_does_not_exists THEN
      debug_log.create_error(p_CONTEXT => c_unit_name, p_MESSAGE => 'Queue '||p_queue_name||' does not exists');
  END;

  PROCEDURE drop_queue (
    p_queue_configuration IN aq_common.t_aq_config
  ) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.drop_queue';
    -- ORA-24010: QUEUE <queue> does not exist

    e_queue_does_not_exists EXCEPTION;
    PRAGMA exception_init ( e_queue_does_not_exists, -24010 );    

    --ORA-24002: QUEUE_TABLE <table> does not exist
    e_queue_table_not_exists EXCEPTION;
    PRAGMA exception_init ( e_queue_table_not_exists, -24002 );
  BEGIN
    BEGIN
      stop_queue(p_queue_name => p_queue_configuration.queue_name);
      dbms_aqadm.drop_queue(queue_name => p_queue_configuration.queue_name);
    EXCEPTION
      WHEN e_queue_does_not_exists THEN
        NULL;
    END;

    BEGIN
      dbms_aqadm.drop_queue_table(queue_table => p_queue_configuration.queue_table_name);
    EXCEPTION
      WHEN e_queue_table_not_exists THEN
        debug_log.create_warning(p_CONTEXT => c_unit_name, p_MESSAGE => 'Queue table '||p_queue_configuration.queue_table_name||' does not exists');
    END;

  END;

  PROCEDURE create_queues(p_queues_configuration IN aq_common.t_aq_configs) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.create_queues';
  BEGIN
    FOR i IN p_queues_configuration.first..p_queues_configuration.last LOOP
      create_queue_objects(p_queue_configuration => p_queues_configuration(i));
    END LOOP;
  END;

  PROCEDURE drop_queues(p_queues_configuration IN aq_common.t_aq_configs) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.drop_queues';
  BEGIN
    FOR i IN p_queues_configuration.first..p_queues_configuration.last LOOP
      drop_queue(p_queue_configuration => p_queues_configuration(i));
    END LOOP;
  END;

  PROCEDURE stop_queues(p_queues_configuration IN aq_common.t_aq_configs) IS
  BEGIN
    FOR i IN p_queues_configuration.first..p_queues_configuration.last LOOP 
      stop_queue(p_queue_name => p_queues_configuration(i).queue_name);
    END LOOP;
  END;

  PROCEDURE start_queues(p_queues_configuration IN aq_common.t_aq_configs) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.start_queues';
  BEGIN   
    FOR i IN p_queues_configuration.first..p_queues_configuration.last LOOP      
      start_queue(p_queue_name => p_queues_configuration(i).queue_name);
    END LOOP;    
  END;
  
  PROCEDURE put_jms_message_to_queue(
     p_queue_name   IN VARCHAR2,
     p_message_text IN VARCHAR2,
     p_correlation IN VARCHAR2 DEFAULT NULL,
     p_delay IN NUMBER DEFAULT 0
  ) IS
    c_unit_name CONSTANT VARCHAR2(64) := c_package_name||'.put_jms_message_to_queue';
    
    v_message sys.aq$_jms_text_message;
    v_enqueue_options      dbms_aq.enqueue_options_t;
    v_message_properties   dbms_aq.message_properties_t;
    v_msg_id               RAW(16);    
  BEGIN
    v_message := sys.aq$_jms_text_message.construct;
    v_message.set_appid(AQ_COMMON.C_APP_NAME);
    v_message.set_text(p_message_text);
    
    v_message_properties.delay := p_delay;
    v_message_properties.correlation := p_correlation;
    
    dbms_aq.enqueue(
        queue_name => p_queue_name,
        enqueue_options => v_enqueue_options,
        message_properties => v_message_properties,
        payload => v_message,
        msgid => v_msg_id    
    );
  END;

  PROCEDURE add_warning_to_queue (
    p_queue_name   IN   VARCHAR2,
    p_device_id    IN   devices.device_name%TYPE,
    p_measurment_type  IN measurments.type_code%TYPE,
    p_measurment_value IN measurments.value%TYPE
  ) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.add_warning_to_queue';  
    
    v_message_text VARCHAR2(32767);
    v_device_details devices%rowtype;
  BEGIN
  
   SELECT *
   INTO v_device_details
   FROM devices dvc
   WHERE dvc.id = p_device_id;
   
   v_message_text := '{'||
     '"deviceName": "'||v_device_details.device_name||'",'||
     '"measurmentType": "'||p_measurment_type||'",'||
     '"value": "'||p_measurment_value||'"'||
   '}';
  
   put_jms_message_to_queue(
     p_queue_name  => p_queue_name,
     p_message_text => v_message_text,
     p_correlation => p_device_id
    );
  END;

  PROCEDURE create_queue (
    p_queue_configuration IN aq_common.t_aq_config
  ) IS
    c_unit_name CONSTANT VARCHAR2(32) := c_package_name||'.create_queue';
    --ORA-24006: cannot create QUEUE, <queue name> already exists
    e_queue_exists EXCEPTION;
    PRAGMA exception_init ( e_queue_exists, -24006 );
  BEGIN
    create_queue_table(p_queue_configuration => p_queue_configuration);
    dbms_aqadm.create_queue(queue_name => p_queue_configuration.queue_name, queue_table => p_queue_configuration.queue_table_name);
  EXCEPTION
    WHEN e_queue_exists THEN    
      debug_log.create_warning(p_CONTEXT => c_unit_name, p_MESSAGE => 'Queue '||p_queue_configuration.queue_name||' already exists');
  END;
  
  FUNCTION get_measument_aq_configs return aq_common.t_aq_configs IS 
    v_aq_config aq_common.t_aq_config;
  BEGIN
    v_aq_config.queue_name := 'MEASURMENT_WARNING';
    v_aq_config.full_queue_name := user ||'.MEASURMENT_WARNING';
    v_aq_config.queue_table_name := 'AQ_MEASURMENT_EVENTS';
    v_aq_config.payload_type := 'SYS.AQ$_JMS_TEXT_MESSAGE';
    v_aq_config.table_space := 'sensor_mgr_tablespace';
    v_aq_config.exception_queue_name := 'E_MEASURMENT_WARNING';
    v_aq_config.retries := 1;
    v_aq_config.retry_delay := 1;
    
    RETURN aq_common.t_aq_configs(v_aq_config);
  END;
  
END aq_provider;