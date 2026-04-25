/******************************************************************************************
* task5_load_datamart.sql                                                                 *
* Muhammad Majid                                                                          *
* DATAMART                                                                                *
* Task 5 - Load the DATAMART star schema tables from WBH source tables                    *
******************************************************************************************/

-- clear existing data
DELETE FROM datamart.fact_donation;
DELETE FROM datamart.dim_date;
DELETE FROM datamart.dim_address;   
DELETE FROM datamart.dim_volunteer;

COMMIT;

-- load dim_date
INSERT INTO datamart.dim_date (
    date_key,
    full_date,
    year,
    month_number,
    day_number_in_month,
    day_of_week,
    month_name_long
)
SELECT DISTINCT
    TO_NUMBER(TO_CHAR(d.donation_date, 'YYYYMMDD')) AS date_key,
    d.donation_date AS full_date,
    EXTRACT(YEAR FROM d.donation_date) AS year,
    EXTRACT(MONTH FROM d.donation_date) AS month_number,
    EXTRACT(DAY FROM d.donation_date) AS day_number_in_month,
    TRIM(TO_CHAR(d.donation_date, 'DAY')) AS day_of_week,
    TRIM(TO_CHAR(d.donation_date, 'MONTH')) AS month_name_long
FROM wbh.donation d;

-- load dim_address
INSERT INTO datamart.dim_address (
    address_key,
    address_id,
    postal_code,
    full_address
)
SELECT
    datamart.dim_address_seq.NEXTVAL AS address_key,
    x.address_id,
    x.postal_code,
    x.full_address
FROM (
    SELECT DISTINCT
        a.address_id,
        a.postal_code,
        a.street_number || ' ' || a.street_name ||
        CASE
            WHEN a.street_type IS NOT NULL THEN ' ' || a.street_type
            ELSE ''
        END ||
        CASE
            WHEN a.street_direction IS NOT NULL THEN ' ' || a.street_direction
            ELSE ''
        END ||
        CASE
            WHEN a.unit_num IS NOT NULL THEN ', Unit ' || a.unit_num
            ELSE ''
        END ||
        ', ' || a.city || ', ' || a.province AS full_address
    FROM wbh.address a
    INNER JOIN wbh.donation d
        ON a.address_id = d.address_id
) x;

-- load dim_volunteer
INSERT INTO datamart.dim_volunteer (
    volunteer_key,
    volunteer_id,
    volunteer_name,
    group_leader
)
SELECT
    datamart.dim_volunteer_seq.NEXTVAL AS volunteer_key,
    x.volunteer_id,
    x.volunteer_name,
    x.group_leader
FROM (
    SELECT DISTINCT
        v.volunteer_id,
        TRIM(v.first_name || ' ' || v.last_name) AS volunteer_name,
        v.group_leader
    FROM wbh.volunteer v
    INNER JOIN wbh.donation d
        ON v.volunteer_id = d.volunteer_id
) x;

-- load fact_donation
INSERT INTO datamart.fact_donation (
    date_key,
    address_key,
    volunteer_key,
    donation_count,
    donation_total_amount
)
SELECT
    TO_NUMBER(TO_CHAR(d.donation_date, 'YYYYMMDD')) AS date_key,
    da.address_key,
    dv.volunteer_key,
    COUNT(*) AS donation_count,
    SUM(d.donation_amount) AS donation_total_amount
FROM wbh.donation d
INNER JOIN datamart.dim_address da
    ON da.address_id = d.address_id
INNER JOIN datamart.dim_volunteer dv
    ON dv.volunteer_id = d.volunteer_id
GROUP BY
    TO_NUMBER(TO_CHAR(d.donation_date, 'YYYYMMDD')),
    da.address_key,
    dv.volunteer_key;

COMMIT;

-- validation checks
SELECT COUNT(*) AS dim_date_count
  FROM datamart.dim_date;

SELECT COUNT(*) AS dim_address_count
  FROM datamart.dim_address;

SELECT COUNT(*) AS dim_volunteer_count
  FROM datamart.dim_volunteer;

SELECT COUNT(*) AS fact_donation_count
  FROM datamart.fact_donation;

SELECT *
  FROM datamart.fact_donation
 ORDER BY date_key
         ,address_key
         ,volunteer_key
 FETCH FIRST 10 ROWS ONLY;