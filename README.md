# camel-aq-rabbitmq-demo-db

Database part for Oracle AQ -> RabbitMQ demo using Camel

# SETUP

1. Create DB user by running as system user script ./src/main/resources/db/scripts/system.drop_user.sql (if need, change username, password etc..)

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
5. Run as SENSORMANAGER user:

```sql
DECLARE
  v_queue_configs  aq_common.t_aq_configs := aq_provider.get_measument_aq_configs();
BEGIN
  aq_provider.create_queues(p_queues_configuration=> v_queue_configs);
  aq_provider.start_queues(p_queues_configuration=>aq_provider.get_measument_aq_configs());
END;

```
