-- ${flyway:timestamp}
create or replace PACKAGE aq_provider IS
 
  PROCEDURE create_queues(p_queues_configuration IN aq_common.t_aq_configs);
 
  PROCEDURE drop_queues(p_queues_configuration IN aq_common.t_aq_configs);

  PROCEDURE stop_queues(p_queues_configuration IN aq_common.t_aq_configs);

  PROCEDURE start_queues(p_queues_configuration IN aq_common.t_aq_configs);
  
  FUNCTION get_measument_aq_configs return aq_common.t_aq_configs;

  PROCEDURE add_warning_to_queue (
    p_queue_name   IN   VARCHAR2,
    p_device_id    IN   devices.device_name%TYPE,
    p_measurment_type  IN measurments.type_code%TYPE,
    p_measurment_value IN measurments.value%TYPE
  );
  
  PROCEDURE put_jms_message_to_queue(
     p_queue_name   IN VARCHAR2,
     p_message_text IN VARCHAR2,
     p_correlation IN VARCHAR2 DEFAULT NULL,
     p_delay IN NUMBER DEFAULT 0
  );  

END aq_provider;