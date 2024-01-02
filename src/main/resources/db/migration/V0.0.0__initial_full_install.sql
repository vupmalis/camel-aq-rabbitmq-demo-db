CREATE SEQUENCE devices_seq;

CREATE SEQUENCE measurments_seq;

CREATE TABLE devices (
    id            NUMBER(12) NOT NULL,
    device_name   VARCHAR2(64 CHAR) NOT NULL,
    description   VARCHAR2(200 CHAR),
    serial_number VARCHAR2(200 CHAR)
)
LOGGING;

ALTER TABLE devices ADD CONSTRAINT devices_pk PRIMARY KEY ( id );

ALTER TABLE devices ADD CONSTRAINT devices__uk1 UNIQUE ( device_name );

ALTER TABLE devices ADD CONSTRAINT devices__un2 UNIQUE ( serial_number );

CREATE TABLE measurments (
    id        NUMBER NOT NULL,
    type_code VARCHAR2(32 CHAR) NOT NULL,
    value     NUMBER NOT NULL,
    latitude  NUMBER,
    longitude NUMBER,
    time      DATE NOT NULL,
    device_id NUMBER(12) NOT NULL
)
LOGGING;

ALTER TABLE measurments ADD CONSTRAINT measurments_pk PRIMARY KEY ( id );

ALTER TABLE measurments
    ADD CONSTRAINT measurments__uk1 UNIQUE ( type_code,
                                             device_id,
                                             time );

ALTER TABLE measurments
    ADD CONSTRAINT measurments_devices_fk FOREIGN KEY ( device_id )
        REFERENCES devices ( id )
    NOT DEFERRABLE;