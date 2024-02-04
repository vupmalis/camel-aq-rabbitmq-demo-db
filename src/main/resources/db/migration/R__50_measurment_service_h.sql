-- ${flyway:timestamp}
create or replace PACKAGE measurment_service IS
  
  C_MEASURMENT_TYPE_TEMP CONSTANT measurments.type_code%TYPE := 'TEMP';

  PROCEDURE create_warning (
    p_device_id    IN   devices.device_name%TYPE,
    p_measurment_type  IN measurments.type_code%TYPE,
    p_measurment_value IN measurments.value%TYPE
  );

END measurment_service;