-- ${flyway:timestamp}
create or replace TRIGGER MEASURMENTS_AIU 
AFTER INSERT OR UPDATE ON MEASURMENTS FOR EACH ROW
BEGIN
  -- send warning if temperature drop below 5 degrees 
  IF :NEW.TYPE_CODE = measurment_service.C_MEASURMENT_TYPE_TEMP
     AND :NEW.VALUE < 5 
  THEN
    measurment_service.create_warning (     
      p_device_id    => :NEW.device_id,
      p_measurment_type  => :NEW.TYPE_CODE,
      p_measurment_value => :NEW.VALUE
    );   
  END IF;
   
END;