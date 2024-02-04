-- ${flyway:timestamp}
create or replace PACKAGE BODY measurment_service AS
  
   c_package_name CONSTANT VARCHAR2(32) := $$plsql_unit;

  PROCEDURE create_warning (
    p_device_id    IN   devices.device_name%TYPE,
    p_measurment_type  IN measurments.type_code%TYPE,
    p_measurment_value IN measurments.value%TYPE
  ) IS
    c_unit_name CONSTANT VARCHAR2(64) := c_package_name||'.add_warning_to_queue';  
    
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
  
    aq_provider.put_jms_message_to_queue(
      p_queue_name  => 'MEASURMENT_WARNINGS',
      p_message_text => v_message_text,
      p_correlation => p_device_id
    );
  END;
END measurment_service;