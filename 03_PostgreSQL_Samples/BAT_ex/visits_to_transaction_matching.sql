CREATE OR REPLACE FUNCTION bi.trig_visits_transaction_matching() RETURNS SETOF bi.trig_transaction_attribution AS
$BODY$

DECLARE
	rows bi.trig_transaction_attribution%rowtype;
	last_visitor_id text;
	attributed_transaction_id text;
	transact_time text;
	converting_visit_id text;
	visitnum int;
	rownum int;

BEGIN

---------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------- FIRST DATA PROCESSING, IN DESCENDING CHRONOLOGICAL ORDER

rownum:= 0;
visitnum:= 0;
last_visitor_id := NULL;
attributed_transaction_id := NULL;
transact_time := NULL;
converting_visit_id:= NULL;

FOR rows IN
			(
				SELECT
					t1.*,
					t2.url as first_visit_url,
					CASE WHEN t2.url LIKE ('%bt=b2b%') THEN 'b2b'
							 WHEN t2.url LIKE ('%bt=tig%') THEN 'job'
					ELSE 'b2c' END 
					as business_type

				FROM bi.trig_transaction_attribution t1
				LEFT JOIN

					(SELECT 
						visit_id,
						MIN(server_date) as serverdate,
						MIN(unixtime) as serverunixtime, 
						MIN(url) as url

					FROM external_data.piwik_actions

					GROUP BY visit_id

					ORDER BY serverunixtime desc, visit_id asc) as t2

				ON t1.visit_id = t2.visit_id

				ORDER BY t1.visitor_id asc, t1.firstaction_unixtime desc
		)

LOOP

	rownum:= rownum + 1;

	IF rownum = 1 THEN /* <=> IF we are at the first row of the table */

			IF rows.transaction_id IS NOT NULL AND rows.transaction_id !='' THEN /* <=> IF the first row of the table is a transaction THEN DO YOUR THINGY*/

				attributed_transaction_id := rows.transaction_id;
				transact_time := rows.firstaction_unixtime;
				converting_visit_id:= rows.visit_id;
				rows.attributed_transaction := rows.transaction_id;
				rows.transaction_timestamp := rows.firstaction_unixtime;
				rows.converting_visit:= rows.visit_id;

			END IF;

	ELSEIF rownum > 1 AND rows.visitor_id <> last_visitor_id THEN /* <=> IF we are NOT on the same visitor_id as previous row */

			attributed_transaction_id := NULL; /*We reset all variables to avoid fuckups*/
			transact_time := NULL;
			converting_visit_id:= NULL;

			IF rows.transaction_id IS NOT NULL AND rows.transaction_id !='' THEN /* <=> IF the LAST visit of the new visitor WAS a transaction */

				attributed_transaction_id := rows.transaction_id;
				transact_time := rows.firstaction_unixtime;
				converting_visit_id:= rows.visit_id;
				rows.attributed_transaction := rows.transaction_id;
				rows.transaction_timestamp := rows.firstaction_unixtime;
				rows.converting_visit:= rows.visit_id;

			END IF;

	ELSEIF rownum > 1 AND rows.visitor_id = last_visitor_id THEN /* <=> IF we are on the same visitor_id as previous row */

			IF attributed_transaction_id IS NOT NULL AND rows.transaction_id IS NULL THEN /* <=> IF we have a transaction recorded for this visitor's previous visit(s) */

				rows.attributed_transaction := attributed_transaction_id;
				rows.transaction_timestamp := transact_time;
				rows.converting_visit:= converting_visit_id;

			ELSEIF attributed_transaction_id IS NOT NULL AND rows.transaction_id IS NOT NULL AND rows.transaction_id != attributed_transaction_id THEN

				attributed_transaction_id := rows.transaction_id;
				transact_time := rows.firstaction_unixtime;
				converting_visit_id:= rows.visit_id;
				rows.attributed_transaction := rows.transaction_id;
				rows.transaction_timestamp := rows.firstaction_unixtime;
				rows.converting_visit:= rows.visit_id;

			ELSEIF attributed_transaction_id IS NOT NULL AND rows.transaction_id IS NOT NULL AND rows.transaction_id = attributed_transaction_id THEN

				rows.attributed_transaction := attributed_transaction_id;
				rows.transaction_timestamp := transact_time;
				rows.converting_visit:= converting_visit_id;	

			ELSEIF attributed_transaction_id IS NULL AND rows.transaction_id IS NOT NULL AND rows.transaction_id != '' THEN

				attributed_transaction_id := rows.transaction_id;
				transact_time := rows.firstaction_unixtime;
				converting_visit_id:= rows.visit_id;
				rows.attributed_transaction := rows.transaction_id;
				rows.transaction_timestamp := rows.firstaction_unixtime;
				rows.converting_visit:= rows.visit_id;

			END IF;

	END IF;

last_visitor_id:= rows.visitor_id;

RETURN NEXT rows;
END LOOP;


END;
$BODY$ 
LANGUAGE 'plpgsql'