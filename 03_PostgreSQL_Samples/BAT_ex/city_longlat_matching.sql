CREATE OR REPLACE FUNCTION bi.mfunc_orderareas(crunchdate date) RETURNS void AS 
$BODY$

DECLARE 
function_name varchar := 'bi.mfunc_orderareas';
start_time timestamp := clock_timestamp() + interval '2 hours';
end_time timestamp;
duration interval;
BEGIN


DELETE FROM bi.orders_in_polygon WHERE Order_Creation__c::date >= (current_date - interval '1 day');

INSERT INTO bi.orders_in_polygon 
SELECT  
    Order_Id__c,
    Order_Creation__c,
    Shippingcity,
    key__c,
ST_Intersects( 
    ST_SetSRID(ST_Point(shippinglongitude, shippinglatitude), 4326), 
    ST_SetSRID(ST_GeomFromGeoJSON(delivery_area__c.polygon__c::json#>>'{features,0,geometry}'), 4326)) as flag_polygon
FROM
    Salesforce.Order,
    salesforce.delivery_area__c
WHERE
     Order_Creation__c::date >= (current_date - interval '1 day')
GROUP BY
    Order_Id__c,
    Order_Creation__c,
    Shippingcity,
    key__c,
    flag_polygon
HAVING
    ST_Intersects( 
    ST_SetSRID(ST_Point(shippinglongitude, shippinglatitude), 4326), 
    ST_SetSRID(ST_GeomFromGeoJSON(delivery_area__c.polygon__c::json#>>'{features,0,geometry}'), 4326)) = true;

DELETE FROM bi.orders_location WHERE Order_Creation__c::date >= (current_date - interval '1 day');

INSERT INTO bi.orders_location 
	SELECT
		t1.order_id__c,
		t3.key__c as delivery_area,
		t3.key__c as efficiency_area,
		t3.key__c as polygon,
		t1.Order_Creation__c
	FROM
	    Salesforce.Order t1
	LEFT JOIn
		bi.orders_in_polygon t3
	ON
		(t1.order_id__c = t3.order_id__c)

	WHERE t1.Order_Creation__c::date >= (current_date - interval '1 day')
;
	
	
end_time := clock_timestamp() + interval '2 hours';
duration := EXTRACT(EPOCH FROM (end_time - start_time));
INSERT INTO main.function_logging values(DEFAULT, function_name, start_time, end_time, duration);

EXCEPTION WHEN others THEN 

	INSERT INTO main.error_logging VALUES (NOW()::timestamp, function_name::text, SQLERRM::text, SQLSTATE::text);
    RAISE NOTICE 'Error detected: transaction was rolled back.';
    RAISE NOTICE '% %', SQLERRM, SQLSTATE;

END;

$BODY$
LANGUAGE 'plpgsql'