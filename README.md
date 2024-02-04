# camel-aq-rabbitmq-demo-db

Database part for Oracle AQ -> RabbitMQ demo using Camel

# SETUP

1. Create DB user by running as system user script [system.create_sensor_manager.sql](src/main/resources/db/scripts/system.create_sensor_manager.sql)(if need, change username, password etc..)

2. Prepare environment to run Flyway database migration tool using gradle (FlyWay 8.0.3)

3. Create gradle.properties file and set properties coresponding to target database and user created at step 1:

```properties
flyway.user=SENSORMANAGER
flyway.password=<password>
flyway.url=<connection to db JDBC url>

flyway.createSchemas=false
flyway.defaultSchema=SENSORMANAGER
flyway.schemas=SENSORMANAGER

```

4. Run ./gradlew flywayMigrate
5. Run as SENSORMANAGER user script to create queues for example:

```sql
DECLARE
  v_queue_configs  aq_common.t_aq_configs := aq_provider.get_measument_aq_configs();
BEGIN
  aq_provider.create_queues(p_queues_configuration=> v_queue_configs);
  aq_provider.start_queues(p_queues_configuration=>aq_provider.get_measument_aq_configs());
END;

```

# Usage example

Create device, create measurment made by device.
If temperature drops below 5 degress, warning is sent via AQ to RabbitMQ

```sql
DECLARE
  v_device_id devices.id%type;
BEGIN
  BEGIN
    SELECT id
    INTO v_device_id
    FROM devices
    WHERE device_name='TEMP_SENSOR_GARTEN';

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
        INSERT INTO devices (id, device_name, description, serial_number)
        VALUES (devices_seq.nextval, 'TEMP_SENSOR_GARTEN', 'Sensor placed in garten', 'G123')
        RETURNING id into v_device_id;
  END;

  INSERT INTO measurments(id, device_id, type_code, value)
  VALUES(measurments_seq.nextval, v_device_id, measurment_service.C_MEASURMENT_TYPE_TEMP, -1);
END;
```
