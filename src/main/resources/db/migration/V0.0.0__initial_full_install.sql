CREATE SEQUENCE devices_seq;

CREATE SEQUENCE measurments_seq;

CREATE SEQUENCE debug_logs_seq  INCREMENT BY 1 START WITH 1 CACHE 5;

CREATE TABLE devices (
    id            NUMBER(12) NOT NULL,
    device_name   VARCHAR2(64 CHAR) NOT NULL,
    description   VARCHAR2(200 CHAR),
    serial_number VARCHAR2(200 CHAR),
    created       TIMESTAMP WITH TIME ZONE DEFAULT systimestamp NOT NULL,
    modified      TIMESTAMP WITH TIME ZONE DEFAULT systimestamp NOT NULL
)
TABLESPACE sensor_mgr_tablespace LOGGING;

ALTER TABLE devices ADD CONSTRAINT devices_pk PRIMARY KEY ( id );

ALTER TABLE devices ADD CONSTRAINT devices__uk1 UNIQUE ( device_name );

ALTER TABLE devices ADD CONSTRAINT devices__un2 UNIQUE ( serial_number );

CREATE TABLE measurments (
    id        NUMBER NOT NULL,
    type_code VARCHAR2(32 CHAR) NOT NULL,
    value     NUMBER NOT NULL,
    latitude  NUMBER,
    longitude NUMBER,
    created   TIMESTAMP DEFAULT systimestamp NOT NULL,
    device_id NUMBER(12) NOT NULL
)
TABLESPACE sensor_mgr_tablespace LOGGING;

ALTER TABLE measurments ADD CONSTRAINT measurments_pk PRIMARY KEY ( id );

ALTER TABLE measurments
    ADD CONSTRAINT measurments__uk1 UNIQUE ( type_code,
                                             device_id,
                                             created );

ALTER TABLE measurments
    ADD CONSTRAINT measurments_devices_fk FOREIGN KEY ( device_id )
        REFERENCES devices ( id )
    NOT DEFERRABLE;

CREATE TABLE debug_logs (
    id             NUMBER NOT NULL,
    log_type       VARCHAR2(32 CHAR) NOT NULL,
    message        VARCHAR2(2000 CHAR) NOT NULL,
    log_date       TIMESTAMP DEFAULT systimestamp NOT NULL,
    context        VARCHAR2(200 CHAR) NOT NULL,
    user_context   VARCHAR2(200 CHAR) NOT NULL,
    table_name     VARCHAR2(32 CHAR),
    record_id      NUMBER
);

ALTER TABLE debug_logs
    ADD CHECK ( log_type IN (
        'DEBUG',
        'ERROR',
        'INFO',
        'WARN'
    ) );

ALTER TABLE debug_logs ADD CONSTRAINT debug_logs_pk PRIMARY KEY ( id );    