DROP TABLE DATAMART.fact_donation;
DROP TABLE DATAMART.dim_date;
DROP TABLE DATAMART.dim_address;
DROP TABLE DATAMART.dim_volunteer;

DROP SEQUENCE DATAMART.dim_address_seq;
DROP SEQUENCE DATAMART.dim_volunteer_seq;

CREATE SEQUENCE DATAMART.dim_address_seq START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE DATAMART.dim_volunteer_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE DATAMART.dim_date (
    date_key              NUMBER PRIMARY KEY,
    full_date             DATE NOT NULL,
    year                  NUMBER NOT NULL,
    month_number          NUMBER NOT NULL,
    day_number_in_month   NUMBER NOT NULL,
    day_of_week           VARCHAR2(15) NOT NULL,
    month_name_long       VARCHAR2(15) NOT NULL
);


CREATE TABLE DATAMART.dim_address (
    address_key        NUMBER PRIMARY KEY,
    address_id         NUMBER NOT NULL,
    postal_code           CHAR(7),
    full_address       VARCHAR2(100) NOT NULL
);


CREATE TABLE DATAMART.dim_volunteer (
    volunteer_key     NUMBER PRIMARY KEY,
    volunteer_id      NUMBER NOT NULL,
    volunteer_name    VARCHAR2(40) NOT NULL,
    group_leader      NUMBER
);


CREATE TABLE DATAMART.fact_donation (
    date_key                NUMBER NOT NULL,
    address_key             NUMBER NOT NULL,
    volunteer_key           NUMBER NOT NULL,
    donation_count          NUMBER NOT NULL,
    donation_total_amount   NUMBER(10,2) NOT NULL,

    CONSTRAINT pk_fact_donation 
        PRIMARY KEY (date_key, address_key, volunteer_key),

    CONSTRAINT fk_fact_date 
        FOREIGN KEY (date_key)
        REFERENCES DATAMART.dim_date (date_key),

    CONSTRAINT fk_fact_address 
        FOREIGN KEY (address_key)
        REFERENCES DATAMART.dim_address (address_key),

    CONSTRAINT fk_fact_volunteer 
        FOREIGN KEY (volunteer_key)
        REFERENCES DATAMART.dim_volunteer (volunteer_key)
);