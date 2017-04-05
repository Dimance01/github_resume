
CREATE OR REPLACE FUNCTION bi.mfunc_retention(crunchdate date) RETURNS void AS 

$BODY$

DECLARE 

function_name varchar := 'bi.mfunc_retention';
start_time timestamp := clock_timestamp() + interval '2 hours';
end_time timestamp;
duration interval;

BEGIN

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 05_cohortstableau


DROP TABLE IF EXISTS bi.TEMP_acquisition_list;
CREATE TABLE bi.TEMP_acquisition_list AS

  SELECT DISTINCT

    o.effectivedate::date as acquisition_date,
    o.customer_id__c::text as customer_id,
    LEFT(o.locale__c,2)::text as locale,
    o.polygon::text as polygon,
    o.marketing_channel::text as acquisition_channel,
    o.recurrency__c::text as acquisition_recurrency,
    CASE WHEN (o.voucher__c <> '' AND o.voucher__c IS NOT NULL AND o.voucher__c <> '0') THEN o.voucher__c ELSE 'No Voucher' END as acquisition_voucher

    FROM bi.orders o
    JOIN salesforce.contact c
    ON (o.contact__c = c.sfid)

    WHERE o.test__c = '0'
      AND o.order_type = '1'
      AND o.acquisition_new_customer__c = '1'
      AND o.status = 'INVOICED'
      AND o.effectivedate::date <= (current_date - interval '60 days')
      AND o.order_creation__c::date = c.createddate::date

    ORDER BY acquisition_date desc, locale asc, polygon asc, acquisition_channel asc, acquisition_recurrency asc, acquisition_voucher asc

;

CREATE INDEX cust_id_index ON bi.TEMP_acquisition_list(customer_id);

DROP TABLE IF EXISTS bi.retention_data;
CREATE TABLE bi.retention_data AS

  SELECT
    a.acquisition_date,
    a.customer_id,
    a.locale,
    a.polygon,
    a.acquisition_channel,
    a.acquisition_recurrency,
    a.acquisition_voucher, --Replace days by days
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '31 days') and (a.acquisition_date + interval '60 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m1,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '61 days') and (a.acquisition_date + interval '90 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m2,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '91 days') and (a.acquisition_date + interval '120 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m3,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '121 days') and (a.acquisition_date + interval '150 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m4,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '151 days') and (a.acquisition_date + interval '180 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m5,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '181 days') and (a.acquisition_date + interval '210 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m6,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '211 days') and (a.acquisition_date + interval '240 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m7,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '241 days') and (a.acquisition_date + interval '270 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m8,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '271 days') and (a.acquisition_date + interval '300 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m9,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '301 days') and (a.acquisition_date + interval '330 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m10,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '331 days') and (a.acquisition_date + interval '360 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m11,
    CASE WHEN (SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '361 days') and (a.acquisition_date + interval '390 days') THEN 1 ELSE 0 END) > 0) THEN 1 ELSE 0 END as rebooking_m12,

    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '31 days') and (a.acquisition_date + interval '60 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m1,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '61 days') and (a.acquisition_date + interval '90 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m2,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '91 days') and (a.acquisition_date + interval '120 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m3,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '121 days') and (a.acquisition_date + interval '150 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m4,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '151 days') and (a.acquisition_date + interval '180 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m5,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '181 days') and (a.acquisition_date + interval '210 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m6,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '211 days') and (a.acquisition_date + interval '240 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m7,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '241 days') and (a.acquisition_date + interval '270 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m8,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '271 days') and (a.acquisition_date + interval '300 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m9,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '301 days') and (a.acquisition_date + interval '330 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m10,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '331 days') and (a.acquisition_date + interval '360 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m11,
    SUM(CASE WHEN o.effectivedate between (a.acquisition_date + interval '361 days') and (a.acquisition_date + interval '390 days') THEN o.order_duration__c ELSE 0 END) as invoiced_hours_m12

  FROM bi.TEMP_acquisition_list a

  LEFT JOIN bi.orders o 
    ON (a.customer_id = o.customer_id__c
    AND o.test__c = '0'
    AND o.order_type = '1'
    AND o.acquisition_new_customer__c = '0'
    AND o.effectivedate < (current_date)
    AND o.status IN ('INVOICED'))


  GROUP BY
    a.acquisition_date, a.customer_id, a.locale, a.polygon, a.acquisition_channel, a.acquisition_recurrency, a.acquisition_voucher

  ORDER BY acquisition_date desc, locale asc, polygon asc, acquisition_channel asc, acquisition_recurrency asc, acquisition_voucher asc

;


DROP TABLE IF EXISTS bi.TEMP_acquisition_list;

-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------

end_time := clock_timestamp() + interval '2 hours';
duration := EXTRACT(EPOCH FROM (end_time - start_time));
INSERT INTO main.function_logging values(DEFAULT, function_name, start_time, end_time, duration);

EXCEPTION WHEN others THEN 

  INSERT INTO main.error_logging VALUES (NOW()::timestamp, function_name::text, SQLERRM::text, SQLSTATE::text);
  RAISE NOTICE 'Error detected: transaction was rolled back.';
  RAISE NOTICE '% %', SQLERRM, SQLSTATE;

END;

$BODY$ LANGUAGE 'plpgsql'