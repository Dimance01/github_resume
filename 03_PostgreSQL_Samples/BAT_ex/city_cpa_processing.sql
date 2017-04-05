CREATE OR REPLACE FUNCTION bi.sfunc_costs_b2c(crunchdate date) RETURNS void AS

$BODY$
DECLARE 
function_name varchar := 'bi.sfunc_costs_b2c';
start_time timestamp := clock_timestamp() + interval '2 hours';
end_time timestamp;
duration interval;

BEGIN

---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS bi.etl_facebook_costsperdistrict;
CREATE TABLE bi.etl_facebook_costsperdistrict AS

	SELECT
				date as date,
				LOWER(LEFT(ad_account,2)) as locale,
		
				(CASE 
					WHEN LOWER(LEFT(ad_account,2)) = 'at' THEN 'Vienna'
		
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Baden-Württemberg') THEN 'Baden-Wurttemberg'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Bayern') THEN 'Bavaria'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Berlin', 'Brandenburg') THEN 'Berlin'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN  ('Bremen', 'Niedersachsen') THEN 'Lower Saxony & Bremen'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Hamburg', 'Schleswig-Holstein') THEN 'Hamburg & Schleswig-Holstein'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Rheinland-Pfalz', 'Saarland') THEN 'Rhineland-Palatinate & Saarland'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Hessen') THEN 'Hesse'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Mecklenburg-Vorpommern') THEN 'Mecklenburg-Vorpommern'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Nordrhein-Westfalen') THEN 'North Rhine-Westphalia'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Sachsen', 'Saxony-Anhalt') THEN 'Saxony & Saxony-Anhalt'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Thüringen') THEN 'Thuringia'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region NOT IN ('Baden-Württemberg', 'Bayern', 'Berlin', 'Brandenburg', 'Bremen', 'Niedersachsen', 'Hamburg', 'Schleswig-Holstein', 'Rheinland-Pfalz', 'Saarland', 'Hessen', 'Mecklenburg-Vorpommern', 'Nordrhein-Westfalen', 'Sachsen', 'Saxony-Anhalt', 'Thüringen') THEN 'Other'
		
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Basel-City', 'Basel-Landschaft') THEN 'Basel-Stadt'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Bern') THEN 'Canton of Bern'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Canton of Geneva') THEN 'Canton of Geneva'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN  ('Vaud') THEN 'Canton of Vaud'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Luzern') THEN 'Canton of Lucerne'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Canton of St. Gallen') THEN 'Canton of St. Gallen'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Zürich') THEN 'Canton of Zurich'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region NOT IN ('Basel-City', 'Basel-Landschaft', 'Bern', 'Canton of Geneva', 'Vaud', 'Luzern','Canton of St. Gallen', 'Zürich') THEN 'Other'
		
					WHEN LOWER(LEFT(ad_account,2)) = 'nl' THEN 'Amsterdam'
		
					ELSE 'Other' END)::text
		
				as region,
		
				ad_account as ad_account,
				campaign as campaign,
				ad_set as ad_set,
				ad as ad,
				SUM(spend) as spend
		
		
				FROM external_data.facebook_campaigns
		
				GROUP BY 

					date, 
					LOWER(LEFT(ad_account,2)), 
		
					(CASE 
					WHEN LOWER(LEFT(ad_account,2)) = 'at' THEN 'Vienna'
		
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Baden-Württemberg') THEN 'Baden-Wurttemberg'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Bayern') THEN 'Bavaria'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Berlin', 'Brandenburg') THEN 'Berlin'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN  ('Bremen', 'Niedersachsen') THEN 'Lower Saxony & Bremen'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Hamburg', 'Schleswig-Holstein') THEN 'Hamburg & Schleswig-Holstein'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Rheinland-Pfalz', 'Saarland') THEN 'Rhineland-Palatinate & Saarland'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Hessen') THEN 'Hesse'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Mecklenburg-Vorpommern') THEN 'Mecklenburg-Vorpommern'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Nordrhein-Westfalen') THEN 'North Rhine-Westphalia'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Sachsen', 'Saxony-Anhalt') THEN 'Saxony & Saxony-Anhalt'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region IN ('Thüringen') THEN 'Thuringia'
					WHEN LOWER(LEFT(ad_account,2)) = 'de' AND region NOT IN ('Baden-Württemberg', 'Bayern', 'Berlin', 'Brandenburg', 'Bremen', 'Niedersachsen', 'Hamburg', 'Schleswig-Holstein', 'Rheinland-Pfalz', 'Saarland', 'Hessen', 'Mecklenburg-Vorpommern', 'Nordrhein-Westfalen', 'Sachsen', 'Saxony-Anhalt', 'Thüringen') THEN 'Other'
		
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Basel-City', 'Basel-Landschaft') THEN 'Basel-Stadt'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Bern') THEN 'Canton of Bern'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Canton of Geneva') THEN 'Canton of Geneva'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN  ('Vaud') THEN 'Canton of Vaud'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Luzern') THEN 'Canton of Lucerne'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Canton of St. Gallen') THEN 'Canton of St. Gallen'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region IN ('Zürich') THEN 'Canton of Zurich'
					WHEN LOWER(LEFT(ad_account,2)) = 'ch' AND region NOT IN ('Basel-City', 'Basel-Landschaft', 'Bern', 'Canton of Geneva', 'Vaud', 'Luzern','Canton of St. Gallen', 'Zürich') THEN 'Other'
		
					WHEN LOWER(LEFT(ad_account,2)) = 'nl' THEN 'Amsterdam'
		
					ELSE 'Other' END)::text,

					ad_account,
					campaign,
					ad_set,
					ad

				ORDER BY date desc, locale asc, region asc, ad_account asc, campaign asc, ad_set asc, ad asc

;


DROP TABLE IF EXISTS bi.etl_adwords_costsperpolygon;
CREATE TABLE bi.etl_adwords_costsperpolygon AS

	SELECT
		t1.date::date as date,
		t4.country_code::text as locale,

		(CASE 
			WHEN t4.country_code = 'at' THEN 'Vienna'

			WHEN t4.country_code = 'de' AND t3.name IN ('Baden-Wurttemberg') THEN 'Baden-Wurttemberg'
			WHEN t4.country_code = 'de' AND t3.name IN ('Bavaria') THEN 'Bavaria'
			WHEN t4.country_code = 'de' AND (t3.name IN ('Berlin', 'Brandeburg') OR t2.name IN ('Berlin', 'Ahrensfelde','Falkensee','Glienicke/Nordbahn','Hoppegarten','Kleinmachnow','Muhlenbecker Land','Panketal','Schonefeld','Teltow', 'Potsdam')) THEN 'Berlin'
			WHEN t4.country_code = 'de' AND t3.name IN ('Bremen', 'Lower Saxony') THEN 'Lower Saxony & Bremen'
			WHEN t4.country_code = 'de' AND t3.name IN ('Hamburg', 'Schleswig-Holstein') THEN 'Hamburg & Schleswig-Holstein'
			WHEN t4.country_code = 'de' AND t3.name IN ('Saarland', 'Rhineland-Palatinate') THEN 'Rhineland-Palatinate & Saarland'
			WHEN t4.country_code = 'de' AND t3.name IN ('Hesse') THEN 'Hesse'
			WHEN t4.country_code = 'de' AND t3.name IN ('Mecklenburg-Vorpommern') THEN 'Mecklenburg-Vorpommern'
			WHEN t4.country_code = 'de' AND t3.name IN ('North Rhine-Westphalia') THEN 'North Rhine-Westphalia'
			WHEN t4.country_code = 'de' AND t3.name IN ('Saxony', 'Saxony-Anhalt') THEN 'Saxony & Saxony-Anhalt'
			WHEN t4.country_code = 'de' AND t3.name IN ('Thuringia') THEN 'Thuringia'
			WHEN t4.country_code = 'de' AND t3.name NOT IN ('Baden-Wurttemberg', 'Bavaria', 'Berlin', 'Brandeburg', 'Bremen', 'Lower Saxony', 'Hamburg', 'Schleswig-Holstein', 'Saarland', 'Rhineland-Palatinate', 'Hesse','Mecklenburg-Vorpommern', 'North Rhine-Westphalia', 'Saxony', 'Saxony-Anhalt', 'Thuringia') THEN 'Other'

			WHEN t4.country_code = 'ch' AND t2.name IN ('Aesch','Allschwil','Arlesheim','Basel','Binningen','Birsfelden','Dornach','Frenkendorf','Kaiseraugst','Laufen','Liestal','Mohlin','Munchenstein','Muttenz','Oberwil','Pratteln','Reinach','Rheinfelden','Riehen','Sissach','Therwil') THEN 'Basel-Stadt'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Aarberg','Belp','Bern','Biel/Bienne','Grenchen','Grossaffoltern','Ittigen','Kehrsatz','Koniz','Lyss','Munchenbuchsee','Munsingen','Muri bei Bern','Nidau','Ostermundigen','Pieterlen','Solothurn','Urtenen-Schonbuhl','Worb','Zollikofen','Zuchwil') THEN 'Canton of Bern'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Geneva', 'Carouge', 'Meyrin', 'Lancy', 'Jussy', 'Grand-Saconnex', 'Plan-les-Ouates', 'Presinge', 'Thonex', 'Vernier', 'Versoix', 'Veyrier','Bellevue', 'Carouge', 'Pregny-Chambesy', 'Chene-Bougeries', 'Chene-Bourg', 'Collonge-Bellerive', 'Cologny', 'Versoix') THEN 'Canton of Geneva'
			WHEN t4.country_code = 'ch' AND t2.name IN  ('Lausanne', 'Aubonne', 'Morges', 'Bussigny-pres-Lausanne', 'Cheseaux-sur-Lausanne', 'Crissier', 'Ecublens', 'Nyon', 'Preverenges', 'Vevey', 'Saint-Sulpice', 'Renens', 'Prilly', 'Pully', 'Penthalaz', 'Aubonne','Cheseaux-sur-Lausanne','Crissier','Daillens','Ecublens','Epalinges','Gland','La Tour-de-Peilz','Lausanne','Le Mont-sur-Lausanne','Lutry','Montreux','Morges','Nyon','Penthalaz','Prangins','Preverenges','Prilly','Pully','Renens','Rolle','Saint-Prex','Saint-Sulpice','Vevey') THEN 'Canton of Vaud'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Lucerne', 'Ebikon', 'Emmen', 'Hochdorf', 'Horw', 'Kriens', 'Kussnacht', 'Lucerne', 'Meggen', 'Nottwil', 'Root', 'Rothenburg', 'Sempach', 'Stans', 'Stansstad', 'Sursee', 'Weggis', 'Ebikon','Emmen','Hochdorf','Horw','Kriens','Kussnacht','Meggen','Nottwil','Root','Rothenburg','Sempach','Stans','Stansstad','Sursee','Weggis') THEN 'Canton of Lucerne'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Saint Gallen', 'Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil', 'Altstatten','Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil') THEN 'Canton of St. Gallen'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Zurich', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon','Zurich') THEN 'Canton of Zurich'
			WHEN t4.country_code = 'ch' AND t2.name NOT IN ('Aesch','Allschwil','Arlesheim','Basel','Binningen','Birsfelden','Dornach','Frenkendorf','Kaiseraugst','Laufen','Liestal','Mohlin','Munchenstein','Muttenz','Oberwil','Pratteln','Reinach','Rheinfelden','Riehen','Sissach','Therwil','Aarberg','Belp','Bern','Biel/Bienne','Grenchen','Grossaffoltern','Ittigen','Kehrsatz','Koniz','Lyss','Munchenbuchsee','Munsingen','Muri bei Bern','Nidau','Ostermundigen','Pieterlen','Solothurn','Urtenen-Schonbuhl','Worb','Zollikofen','Zuchwil','Geneva', 'Carouge', 'Meyrin', 'Lancy', 'Jussy', 'Grand-Saconnex', 'Plan-les-Ouates', 'Presinge', 'Thonex', 'Vernier', 'Versoix', 'Veyrier','Bellevue', 'Carouge', 'Pregny-Chambesy', 'Chene-Bougeries', 'Chene-Bourg', 'Collonge-Bellerive', 'Cologny', 'Versoix','Lausanne', 'Aubonne', 'Morges', 'Bussigny-pres-Lausanne', 'Cheseaux-sur-Lausanne', 'Crissier', 'Ecublens', 'Nyon', 'Preverenges', 'Vevey', 'Saint-Sulpice', 'Renens', 'Prilly', 'Pully', 'Penthalaz', 'Aubonne','Cheseaux-sur-Lausanne','Crissier','Daillens','Ecublens','Epalinges','Gland','La Tour-de-Peilz','Lausanne','Le Mont-sur-Lausanne','Lutry','Montreux','Morges','Nyon','Penthalaz','Prangins','Preverenges','Prilly','Pully','Renens','Rolle','Saint-Prex','Saint-Sulpice','Vevey','Lucerne', 'Ebikon', 'Emmen', 'Hochdorf', 'Horw', 'Kriens', 'Kussnacht', 'Lucerne', 'Meggen', 'Nottwil', 'Root', 'Rothenburg', 'Sempach', 'Stans', 'Stansstad', 'Sursee', 'Weggis', 'Ebikon','Emmen','Hochdorf','Horw','Kriens','Kussnacht','Meggen','Nottwil','Root','Rothenburg','Sempach','Stans','Stansstad','Sursee','Weggis','Saint Gallen', 'Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil', 'Altstatten','Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil','Zurich', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon','Zurich') THEN 'Other'

			WHEN t4.country_code = 'nl' AND t2.name IN ('Amsterdam', 'Amsterdam Airport Schiphol', 'Government of Amsterdam', 'Aalsmeer','Abcoude','Amstelveen','Amsterdam','Amsterdam-Zuidoost','Bennebroek','Bussum','Diemen','Duivendrecht','Haarlem','Heemstede','Hilversum','Hoofddorp','Weesp') THEN 'Region of Amsterdam'
			WHEN t4.country_code = 'nl' AND t2.name IN ('The Hague', 'Delft','The Hague','Leiden','Leidschendam','Nootdorp','Pijnacker','Rijswijk','Voorburg','Voorschoten') THEN 'Region of South Holland'
			WHEN t4.country_code = 'nl' AND t2.name NOT IN ('Amsterdam', 'Amsterdam Airport Schiphol', 'Government of Amsterdam', 'Aalsmeer','Abcoude','Amstelveen','Amsterdam','Amsterdam-Zuidoost','Bennebroek','Bussum','Diemen','Duivendrecht','Haarlem','Heemstede','Hilversum','Hoofddorp','Weesp', 'The Hague', 'Delft','The Hague','Leiden','Leidschendam','Nootdorp','Pijnacker','Rijswijk','Voorburg','Voorschoten') THEN 'Other'

			ELSE 'Other' END

		)::text as district,


		(CASE 
			WHEN t4.country_code = 'at' THEN 'at-vienna'

			WHEN t4.country_code = 'ch' AND t2.name IN ('Aesch','Allschwil','Arlesheim','Basel','Binningen','Birsfelden','Dornach','Frenkendorf','Kaiseraugst','Laufen','Liestal','Mohlin','Munchenstein','Muttenz','Oberwil','Pratteln','Reinach','Rheinfelden','Riehen','Sissach','Therwil') THEN 'ch-basel'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Aarberg','Belp','Bern','Biel/Bienne','Grenchen','Grossaffoltern','Ittigen','Kehrsatz','Koniz','Lyss','Munchenbuchsee','Munsingen','Muri bei Bern','Nidau','Ostermundigen','Pieterlen','Solothurn','Urtenen-Schonbuhl','Worb','Zollikofen','Zuchwil') THEN 'ch-bern'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Geneva', 'Carouge', 'Meyrin', 'Lancy', 'Jussy', 'Grand-Saconnex', 'Plan-les-Ouates', 'Presinge', 'Thonex', 'Vernier', 'Versoix', 'Veyrier','Bellevue', 'Carouge', 'Pregny-Chambesy', 'Chene-Bougeries', 'Chene-Bourg', 'Collonge-Bellerive', 'Cologny', 'Versoix') THEN 'ch-geneva'
			WHEN t4.country_code = 'ch' AND t2.name IN  ('Lausanne', 'Aubonne', 'Morges', 'Bussigny-pres-Lausanne', 'Cheseaux-sur-Lausanne', 'Crissier', 'Ecublens', 'Nyon', 'Preverenges', 'Vevey', 'Saint-Sulpice', 'Renens', 'Prilly', 'Pully', 'Penthalaz', 'Aubonne','Cheseaux-sur-Lausanne','Crissier','Daillens','Ecublens','Epalinges','Gland','La Tour-de-Peilz','Lausanne','Le Mont-sur-Lausanne','Lutry','Montreux','Morges','Nyon','Penthalaz','Prangins','Preverenges','Prilly','Pully','Renens','Rolle','Saint-Prex','Saint-Sulpice','Vevey') THEN 'ch-lausanne'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Lucerne', 'Ebikon', 'Emmen', 'Hochdorf', 'Horw', 'Kriens', 'Kussnacht', 'Lucerne', 'Meggen', 'Nottwil', 'Root', 'Rothenburg', 'Sempach', 'Stans', 'Stansstad', 'Sursee', 'Weggis', 'Ebikon','Emmen','Hochdorf','Horw','Kriens','Kussnacht','Meggen','Nottwil','Root','Rothenburg','Sempach','Stans','Stansstad','Sursee','Weggis') THEN 'ch-lucerne'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Saint Gallen', 'Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil', 'Altstatten','Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil') THEN 'ch-stgallen'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Zurich', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon','Zurich') THEN 'ch-zurich'
			WHEN t4.country_code = 'ch' AND t2.name NOT IN ('Aesch','Allschwil','Arlesheim','Basel','Binningen','Birsfelden','Dornach','Frenkendorf','Kaiseraugst','Laufen','Liestal','Mohlin','Munchenstein','Muttenz','Oberwil','Pratteln','Reinach','Rheinfelden','Riehen','Sissach','Therwil','Aarberg','Belp','Bern','Biel/Bienne','Grenchen','Grossaffoltern','Ittigen','Kehrsatz','Koniz','Lyss','Munchenbuchsee','Munsingen','Muri bei Bern','Nidau','Ostermundigen','Pieterlen','Solothurn','Urtenen-Schonbuhl','Worb','Zollikofen','Zuchwil','Geneva', 'Carouge', 'Meyrin', 'Lancy', 'Jussy', 'Grand-Saconnex', 'Plan-les-Ouates', 'Presinge', 'Thonex', 'Vernier', 'Versoix', 'Veyrier','Bellevue', 'Carouge', 'Pregny-Chambesy', 'Chene-Bougeries', 'Chene-Bourg', 'Collonge-Bellerive', 'Cologny', 'Versoix','Lausanne', 'Aubonne', 'Morges', 'Bussigny-pres-Lausanne', 'Cheseaux-sur-Lausanne', 'Crissier', 'Ecublens', 'Nyon', 'Preverenges', 'Vevey', 'Saint-Sulpice', 'Renens', 'Prilly', 'Pully', 'Penthalaz', 'Aubonne','Cheseaux-sur-Lausanne','Crissier','Daillens','Ecublens','Epalinges','Gland','La Tour-de-Peilz','Lausanne','Le Mont-sur-Lausanne','Lutry','Montreux','Morges','Nyon','Penthalaz','Prangins','Preverenges','Prilly','Pully','Renens','Rolle','Saint-Prex','Saint-Sulpice','Vevey','Lucerne', 'Ebikon', 'Emmen', 'Hochdorf', 'Horw', 'Kriens', 'Kussnacht', 'Lucerne', 'Meggen', 'Nottwil', 'Root', 'Rothenburg', 'Sempach', 'Stans', 'Stansstad', 'Sursee', 'Weggis', 'Ebikon','Emmen','Hochdorf','Horw','Kriens','Kussnacht','Meggen','Nottwil','Root','Rothenburg','Sempach','Stans','Stansstad','Sursee','Weggis','Saint Gallen', 'Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil', 'Altstatten','Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil','Zurich', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon','Zurich') THEN 'ch-other'

			WHEN t4.country_code = 'de' AND t2.name IN ('Berlin', 'Ahrensfelde','Falkensee','Glienicke/Nordbahn','Hoppegarten','Kleinmachnow','Muhlenbecker Land','Panketal','Schonefeld','Teltow', 'Potsdam') THEN 'de-berlin'
			WHEN t4.country_code = 'de' AND t2.name IN ('Bonn','Alfter','Bad Honnef','Bonn','Bornheim','Konigswinter','Niederkassel','Sankt Augustin','Siegburg','Troisdorf','Wesseling') THEN 'de-bonn'
			WHEN t4.country_code = 'de' AND t2.name IN  ('Cologne', 'Bergisch Gladbach','Bornheim','Bruhl','Frechen','Hurth','Leverkusen','Pulheim','Rosrath','Wesseling') THEN 'de-cologne'
			WHEN t4.country_code = 'de' AND t2.name IN ('Dusseldorf', 'Erkrath','Hilden','Kaarst','Langenfeld','Meerbusch','Monheim am Rhein','Neuss','Ratingen') THEN 'de-dusseldorf'
			WHEN t4.country_code = 'de' AND t2.name IN ('Essen', 'Bochum','Bottrop','Essen','Gelsenkirchen','Gladbeck','Hattingen','Mulheim','Oberhausen') THEN 'de-essen'
			WHEN t4.country_code = 'de' AND t2.name IN ('Frankfurt', 'Bad Vilbel','Eschborn','Hattersheim am Main','Heusenstamm','Kelsterbach','Konigstein im Taunus','Kriftel','Maintal','Muhlheim am Main','Neu-Isenburg','Obertshausen','Schwalbach am Taunus') THEN 'de-frankfurt'
			WHEN t4.country_code = 'de' AND t2.name IN ('Hamburg','Ahrensburg','Halstenbek','Hamburg','Norderstedt','Pinneberg','Rellingen','Schenefeld','Wedel') THEN 'de-hamburg'
			WHEN t4.country_code = 'de' AND t2.name IN ('Hanover', 'Garbsen','Hemmingen','Isernhagen','Laatzen','Langenhagen','Ronnenberg','Sarstedt','Seelze','Wunstorf') THEN 'de-hannover'
			WHEN t4.country_code = 'de' AND t2.name IN ('Leipzig') THEN 'de-leipzig'
			WHEN t4.country_code = 'de' AND t2.name IN ('Mainz', 'Bodenheim','Florsheim am Main','Ginsheim-Gustavsburg','Hochheim am Main','Ingelheim am Rhein','Mainz','Nieder-Olm','Raunheim','Russelsheim','Walluf','Wiesbaden') THEN 'de-mainz'
			WHEN t4.country_code = 'de' AND t2.name IN ('Mannheim') THEN 'de-manheim'
			WHEN t4.country_code = 'de' AND t2.name IN ('Munich', 'Aschheim','Baierbrunn','Brunnthal','Dachau','Eching','Feldkirchen','Gauting','Germering','Gilching','Grafelfing','Grasbrunn','Grobenzell','Grunwald','Haar','Hohenbrunn','Hohenkirchen-Siegertsbrunn','Ismaning','Kirchheim bei Munchen','Markt Schwaben','Neubiberg','Neufahrn bei Freising','Oberhaching','Oberschleißheim','Ottobrunn','Planegg','Poing','Puchheim','Putzbrunn','Taufkirchen','Unterfohring','Unterhaching','Unterschleißheim','Vaterstetten') THEN 'de-munich'
			WHEN t4.country_code = 'de' AND t2.name IN ('Nuremberg', 'Erlangen','Furth','Lauf an der Pegnitz','Schwabach','Stein','Zirndorf') THEN 'de-nuremberg'
			WHEN t4.country_code = 'de' AND t2.name IN ('Stuttgart', 'Asperg','Denkendorf','Esslingen','Fellbach','Filderstadt','Gerlingen','Korntal-Munchingen','Kornwestheim','Leinfelden-Echterdingen','Ludwigsburg','Neuhausen auf den Fildern','Ostfildern','Stuttgart','Waiblingen') THEN 'de-stuttgart'
			WHEN t4.country_code = 'de' AND t2.name NOT IN ('Berlin', 'Bonn', 'Cologne', 'Dusseldorf', 'Essen', 'Frankfurt', 'Hamburg','Hanover', 'Leipzig', 'Mainz', 'Mannheim', 'Munich', 'Nuremberg', 'Potsdam', 'Stuttgart', 'Ahrensfelde','Berlin','Falkensee','Glienicke/Nordbahn','Hoppegarten','Kleinmachnow','Muhlenbecker Land','Panketal','Schonefeld','Teltow','Alfter','Bad Honnef','Bonn','Bornheim','Konigswinter','Niederkassel','Sankt Augustin','Siegburg','Troisdorf','Wesseling','Bergisch Gladbach','Bornheim','Bruhl','Frechen','Hurth','Leverkusen','Pulheim','Rosrath','Wesseling','Dormagen','Dusseldorf','Erkrath','Hilden','Kaarst','Leverkusen','Meerbusch','Monheim am Rhein','Neuss','Ratingen','Bochum','Bottrop','Essen','Gelsenkirchen','Gladbeck','Hattingen','Oberhausen','Bad Vilbel','Eschborn','Hattersheim am Main','Heusenstamm','Kelsterbach','Konigstein im Taunus','Kriftel','Maintal','Muhlheim am Main','Neu-Isenburg','Obertshausen','Schwalbach am Taunus','Ahrensburg','Halstenbek','Hamburg','Norderstedt','Pinneberg','Rellingen','Schenefeld','Wedel','Garbsen','Hemmingen','Isernhagen','Laatzen','Langenhagen','Ronnenberg','Sarstedt','Seelze','Wunstorf','Bodenheim','Florsheim am Main','Ginsheim-Gustavsburg','Hochheim am Main','Ingelheim am Rhein','Mainz','Nieder-Olm','Raunheim','Russelsheim','Walluf','Wiesbaden','Aschheim','Baierbrunn','Brunnthal','Dachau','Eching','Feldkirchen','Gauting','Germering','Gilching','Grafelfing','Grasbrunn','Grobenzell','Grunwald','Haar','Hohenbrunn','Hohenkirchen-Siegertsbrunn','Ismaning','Kirchheim bei Munchen','Markt Schwaben','Neubiberg','Neufahrn bei Freising','Oberhaching','Oberschleißheim','Ottobrunn','Planegg','Poing','Puchheim','Putzbrunn','Taufkirchen','Unterfohring','Unterhaching','Unterschleißheim','Vaterstetten','Erlangen','Furth','Lauf an der Pegnitz','Schwabach','Stein','Zirndorf','Asperg','Denkendorf','Fellbach','Filderstadt','Gerlingen','Korntal-Munchingen','Kornwestheim','Leinfelden-Echterdingen','Ludwigsburg','Neuhausen auf den Fildern','Ostfildern','Stuttgart','Waiblingen') THEN 'de-other'

			WHEN t4.country_code = 'nl' AND t2.name IN ('Amsterdam', 'Amsterdam Airport Schiphol', 'Government of Amsterdam', 'Aalsmeer','Abcoude','Amstelveen','Amsterdam','Amsterdam-Zuidoost','Bennebroek','Bussum','Diemen','Duivendrecht','Haarlem','Heemstede','Hilversum','Hoofddorp','Weesp') THEN 'nl-amsterdam'
			WHEN t4.country_code = 'nl' AND t2.name IN ('The Hague', 'Delft','The Hague','Leiden','Leidschendam','Nootdorp','Pijnacker','Rijswijk','Voorburg','Voorschoten') THEN 'nl-hague'
			WHEN t4.country_code = 'nl' AND t2.name NOT IN ('Amsterdam', 'Amsterdam Airport Schiphol', 'Government of Amsterdam', 'Aalsmeer','Abcoude','Amstelveen','Amsterdam','Amsterdam-Zuidoost','Bennebroek','Bussum','Diemen','Duivendrecht','Haarlem','Heemstede','Hilversum','Hoofddorp','Weesp','Delft','The Hague','Leiden','Leidschendam','Nootdorp','Pijnacker','Rijswijk','Voorburg','Voorschoten') THEN 'nl-other'

			ELSE 'no-polygon' END)::text

		as city,


		t1.account::text as account,
		t1.campaign::text as campaign,
		t1.ad_group::text as ad_group,
		SUM(t1.impressions)::numeric as impressions,
		SUM(t1.clicks)::numeric as clicks,
		SUM(t1.conversions)::numeric as conversions,
		CASE WHEN t4.country_code = 'ch' THEN SUM(t1.cost)::numeric*0.92/1000000 ELSE SUM(t1.cost)::numeric/1000000 END as cost

	FROM external_data.adwords_city t1

		LEFT JOIN external_data.adwords_locations_matching t2 ON t1.city = t2.criteria_id
		LEFT JOIN external_data.adwords_locations_matching t3 ON t1.region = t3.criteria_id

		LEFT JOIN external_data.adwords_locations_matching t4 ON t1.country = t4.criteria_id

	GROUP BY date, locale, 


		(CASE 
			WHEN t4.country_code = 'at' THEN 'Vienna'

			WHEN t4.country_code = 'de' AND t3.name IN ('Baden-Wurttemberg') THEN 'Baden-Wurttemberg'
			WHEN t4.country_code = 'de' AND t3.name IN ('Bavaria') THEN 'Bavaria'
			WHEN t4.country_code = 'de' AND (t3.name IN ('Berlin', 'Brandeburg') OR t2.name IN ('Berlin', 'Ahrensfelde','Falkensee','Glienicke/Nordbahn','Hoppegarten','Kleinmachnow','Muhlenbecker Land','Panketal','Schonefeld','Teltow', 'Potsdam')) THEN 'Berlin'
			WHEN t4.country_code = 'de' AND t3.name IN ('Bremen', 'Lower Saxony') THEN 'Lower Saxony & Bremen'
			WHEN t4.country_code = 'de' AND t3.name IN ('Hamburg', 'Schleswig-Holstein') THEN 'Hamburg & Schleswig-Holstein'
			WHEN t4.country_code = 'de' AND t3.name IN ('Saarland', 'Rhineland-Palatinate') THEN 'Rhineland-Palatinate & Saarland'
			WHEN t4.country_code = 'de' AND t3.name IN ('Hesse') THEN 'Hesse'
			WHEN t4.country_code = 'de' AND t3.name IN ('Mecklenburg-Vorpommern') THEN 'Mecklenburg-Vorpommern'
			WHEN t4.country_code = 'de' AND t3.name IN ('North Rhine-Westphalia') THEN 'North Rhine-Westphalia'
			WHEN t4.country_code = 'de' AND t3.name IN ('Saxony', 'Saxony-Anhalt') THEN 'Saxony & Saxony-Anhalt'
			WHEN t4.country_code = 'de' AND t3.name IN ('Thuringia') THEN 'Thuringia'
			WHEN t4.country_code = 'de' AND t3.name NOT IN ('Baden-Wurttemberg', 'Bavaria', 'Berlin', 'Brandeburg', 'Bremen', 'Lower Saxony', 'Hamburg', 'Schleswig-Holstein', 'Saarland', 'Rhineland-Palatinate', 'Hesse','Mecklenburg-Vorpommern', 'North Rhine-Westphalia', 'Saxony', 'Saxony-Anhalt', 'Thuringia') THEN 'Other'

			WHEN t4.country_code = 'ch' AND t2.name IN ('Aesch','Allschwil','Arlesheim','Basel','Binningen','Birsfelden','Dornach','Frenkendorf','Kaiseraugst','Laufen','Liestal','Mohlin','Munchenstein','Muttenz','Oberwil','Pratteln','Reinach','Rheinfelden','Riehen','Sissach','Therwil') THEN 'Basel-Stadt'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Aarberg','Belp','Bern','Biel/Bienne','Grenchen','Grossaffoltern','Ittigen','Kehrsatz','Koniz','Lyss','Munchenbuchsee','Munsingen','Muri bei Bern','Nidau','Ostermundigen','Pieterlen','Solothurn','Urtenen-Schonbuhl','Worb','Zollikofen','Zuchwil') THEN 'Canton of Bern'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Geneva', 'Carouge', 'Meyrin', 'Lancy', 'Jussy', 'Grand-Saconnex', 'Plan-les-Ouates', 'Presinge', 'Thonex', 'Vernier', 'Versoix', 'Veyrier','Bellevue', 'Carouge', 'Pregny-Chambesy', 'Chene-Bougeries', 'Chene-Bourg', 'Collonge-Bellerive', 'Cologny', 'Versoix') THEN 'Canton of Geneva'
			WHEN t4.country_code = 'ch' AND t2.name IN  ('Lausanne', 'Aubonne', 'Morges', 'Bussigny-pres-Lausanne', 'Cheseaux-sur-Lausanne', 'Crissier', 'Ecublens', 'Nyon', 'Preverenges', 'Vevey', 'Saint-Sulpice', 'Renens', 'Prilly', 'Pully', 'Penthalaz', 'Aubonne','Cheseaux-sur-Lausanne','Crissier','Daillens','Ecublens','Epalinges','Gland','La Tour-de-Peilz','Lausanne','Le Mont-sur-Lausanne','Lutry','Montreux','Morges','Nyon','Penthalaz','Prangins','Preverenges','Prilly','Pully','Renens','Rolle','Saint-Prex','Saint-Sulpice','Vevey') THEN 'Canton of Vaud'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Lucerne', 'Ebikon', 'Emmen', 'Hochdorf', 'Horw', 'Kriens', 'Kussnacht', 'Lucerne', 'Meggen', 'Nottwil', 'Root', 'Rothenburg', 'Sempach', 'Stans', 'Stansstad', 'Sursee', 'Weggis', 'Ebikon','Emmen','Hochdorf','Horw','Kriens','Kussnacht','Meggen','Nottwil','Root','Rothenburg','Sempach','Stans','Stansstad','Sursee','Weggis') THEN 'Canton of Lucerne'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Saint Gallen', 'Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil', 'Altstatten','Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil') THEN 'Canton of St. Gallen'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Zurich', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon','Zurich') THEN 'Canton of Zurich'
			WHEN t4.country_code = 'ch' AND t2.name NOT IN ('Aesch','Allschwil','Arlesheim','Basel','Binningen','Birsfelden','Dornach','Frenkendorf','Kaiseraugst','Laufen','Liestal','Mohlin','Munchenstein','Muttenz','Oberwil','Pratteln','Reinach','Rheinfelden','Riehen','Sissach','Therwil','Aarberg','Belp','Bern','Biel/Bienne','Grenchen','Grossaffoltern','Ittigen','Kehrsatz','Koniz','Lyss','Munchenbuchsee','Munsingen','Muri bei Bern','Nidau','Ostermundigen','Pieterlen','Solothurn','Urtenen-Schonbuhl','Worb','Zollikofen','Zuchwil','Geneva', 'Carouge', 'Meyrin', 'Lancy', 'Jussy', 'Grand-Saconnex', 'Plan-les-Ouates', 'Presinge', 'Thonex', 'Vernier', 'Versoix', 'Veyrier','Bellevue', 'Carouge', 'Pregny-Chambesy', 'Chene-Bougeries', 'Chene-Bourg', 'Collonge-Bellerive', 'Cologny', 'Versoix','Lausanne', 'Aubonne', 'Morges', 'Bussigny-pres-Lausanne', 'Cheseaux-sur-Lausanne', 'Crissier', 'Ecublens', 'Nyon', 'Preverenges', 'Vevey', 'Saint-Sulpice', 'Renens', 'Prilly', 'Pully', 'Penthalaz', 'Aubonne','Cheseaux-sur-Lausanne','Crissier','Daillens','Ecublens','Epalinges','Gland','La Tour-de-Peilz','Lausanne','Le Mont-sur-Lausanne','Lutry','Montreux','Morges','Nyon','Penthalaz','Prangins','Preverenges','Prilly','Pully','Renens','Rolle','Saint-Prex','Saint-Sulpice','Vevey','Lucerne', 'Ebikon', 'Emmen', 'Hochdorf', 'Horw', 'Kriens', 'Kussnacht', 'Lucerne', 'Meggen', 'Nottwil', 'Root', 'Rothenburg', 'Sempach', 'Stans', 'Stansstad', 'Sursee', 'Weggis', 'Ebikon','Emmen','Hochdorf','Horw','Kriens','Kussnacht','Meggen','Nottwil','Root','Rothenburg','Sempach','Stans','Stansstad','Sursee','Weggis','Saint Gallen', 'Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil', 'Altstatten','Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil','Zurich', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon','Zurich') THEN 'Other'

			WHEN t4.country_code = 'nl' AND t2.name IN ('Amsterdam', 'Amsterdam Airport Schiphol', 'Government of Amsterdam', 'Aalsmeer','Abcoude','Amstelveen','Amsterdam','Amsterdam-Zuidoost','Bennebroek','Bussum','Diemen','Duivendrecht','Haarlem','Heemstede','Hilversum','Hoofddorp','Weesp') THEN 'Region of Amsterdam'
			WHEN t4.country_code = 'nl' AND t2.name IN ('The Hague', 'Delft','The Hague','Leiden','Leidschendam','Nootdorp','Pijnacker','Rijswijk','Voorburg','Voorschoten') THEN 'Region of South Holland'
			WHEN t4.country_code = 'nl' AND t2.name NOT IN ('Amsterdam', 'Amsterdam Airport Schiphol', 'Government of Amsterdam', 'Aalsmeer','Abcoude','Amstelveen','Amsterdam','Amsterdam-Zuidoost','Bennebroek','Bussum','Diemen','Duivendrecht','Haarlem','Heemstede','Hilversum','Hoofddorp','Weesp', 'The Hague', 'Delft','The Hague','Leiden','Leidschendam','Nootdorp','Pijnacker','Rijswijk','Voorburg','Voorschoten') THEN 'Other'

			ELSE 'Other' END

		), 

		(CASE 
			WHEN t4.country_code = 'at' THEN 'at-vienna'

			WHEN t4.country_code = 'ch' AND t2.name IN ('Aesch','Allschwil','Arlesheim','Basel','Binningen','Birsfelden','Dornach','Frenkendorf','Kaiseraugst','Laufen','Liestal','Mohlin','Munchenstein','Muttenz','Oberwil','Pratteln','Reinach','Rheinfelden','Riehen','Sissach','Therwil') THEN 'ch-basel'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Aarberg','Belp','Bern','Biel/Bienne','Grenchen','Grossaffoltern','Ittigen','Kehrsatz','Koniz','Lyss','Munchenbuchsee','Munsingen','Muri bei Bern','Nidau','Ostermundigen','Pieterlen','Solothurn','Urtenen-Schonbuhl','Worb','Zollikofen','Zuchwil') THEN 'ch-bern'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Geneva', 'Carouge', 'Meyrin', 'Lancy', 'Jussy', 'Grand-Saconnex', 'Plan-les-Ouates', 'Presinge', 'Thonex', 'Vernier', 'Versoix', 'Veyrier','Bellevue', 'Carouge', 'Pregny-Chambesy', 'Chene-Bougeries', 'Chene-Bourg', 'Collonge-Bellerive', 'Cologny', 'Versoix') THEN 'ch-geneva'
			WHEN t4.country_code = 'ch' AND t2.name IN  ('Lausanne', 'Aubonne', 'Morges', 'Bussigny-pres-Lausanne', 'Cheseaux-sur-Lausanne', 'Crissier', 'Ecublens', 'Nyon', 'Preverenges', 'Vevey', 'Saint-Sulpice', 'Renens', 'Prilly', 'Pully', 'Penthalaz', 'Aubonne','Cheseaux-sur-Lausanne','Crissier','Daillens','Ecublens','Epalinges','Gland','La Tour-de-Peilz','Lausanne','Le Mont-sur-Lausanne','Lutry','Montreux','Morges','Nyon','Penthalaz','Prangins','Preverenges','Prilly','Pully','Renens','Rolle','Saint-Prex','Saint-Sulpice','Vevey') THEN 'ch-lausanne'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Lucerne', 'Ebikon', 'Emmen', 'Hochdorf', 'Horw', 'Kriens', 'Kussnacht', 'Lucerne', 'Meggen', 'Nottwil', 'Root', 'Rothenburg', 'Sempach', 'Stans', 'Stansstad', 'Sursee', 'Weggis', 'Ebikon','Emmen','Hochdorf','Horw','Kriens','Kussnacht','Meggen','Nottwil','Root','Rothenburg','Sempach','Stans','Stansstad','Sursee','Weggis') THEN 'ch-lucerne'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Saint Gallen', 'Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil', 'Altstatten','Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil') THEN 'ch-stgallen'
			WHEN t4.country_code = 'ch' AND t2.name IN ('Zurich', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon','Zurich') THEN 'ch-zurich'
			WHEN t4.country_code = 'ch' AND t2.name NOT IN ('Aesch','Allschwil','Arlesheim','Basel','Binningen','Birsfelden','Dornach','Frenkendorf','Kaiseraugst','Laufen','Liestal','Mohlin','Munchenstein','Muttenz','Oberwil','Pratteln','Reinach','Rheinfelden','Riehen','Sissach','Therwil','Aarberg','Belp','Bern','Biel/Bienne','Grenchen','Grossaffoltern','Ittigen','Kehrsatz','Koniz','Lyss','Munchenbuchsee','Munsingen','Muri bei Bern','Nidau','Ostermundigen','Pieterlen','Solothurn','Urtenen-Schonbuhl','Worb','Zollikofen','Zuchwil','Geneva', 'Carouge', 'Meyrin', 'Lancy', 'Jussy', 'Grand-Saconnex', 'Plan-les-Ouates', 'Presinge', 'Thonex', 'Vernier', 'Versoix', 'Veyrier','Bellevue', 'Carouge', 'Pregny-Chambesy', 'Chene-Bougeries', 'Chene-Bourg', 'Collonge-Bellerive', 'Cologny', 'Versoix','Lausanne', 'Aubonne', 'Morges', 'Bussigny-pres-Lausanne', 'Cheseaux-sur-Lausanne', 'Crissier', 'Ecublens', 'Nyon', 'Preverenges', 'Vevey', 'Saint-Sulpice', 'Renens', 'Prilly', 'Pully', 'Penthalaz', 'Aubonne','Cheseaux-sur-Lausanne','Crissier','Daillens','Ecublens','Epalinges','Gland','La Tour-de-Peilz','Lausanne','Le Mont-sur-Lausanne','Lutry','Montreux','Morges','Nyon','Penthalaz','Prangins','Preverenges','Prilly','Pully','Renens','Rolle','Saint-Prex','Saint-Sulpice','Vevey','Lucerne', 'Ebikon', 'Emmen', 'Hochdorf', 'Horw', 'Kriens', 'Kussnacht', 'Lucerne', 'Meggen', 'Nottwil', 'Root', 'Rothenburg', 'Sempach', 'Stans', 'Stansstad', 'Sursee', 'Weggis', 'Ebikon','Emmen','Hochdorf','Horw','Kriens','Kussnacht','Meggen','Nottwil','Root','Rothenburg','Sempach','Stans','Stansstad','Sursee','Weggis','Saint Gallen', 'Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil', 'Altstatten','Amriswil','Arbon','Balgach','Diepoldsau','Flawil','Gais','Gaiserwald','Goldach','Gossau','Heiden','Herisau','Horn','Kreuzlingen','Muolen','Oberriet','Rorschach','Rorschacherberg','Sankt Gallen','Teufen','Uzwil','Wald','Walzenhausen','Weinfelden','Widnau','Wil','Zuzwil','Zurich', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon', 'Adliswil','Aesch','Affoltern am Albis','Baar','Baden','Bassersdorf','Bergdietikon','Berikon','Binz','Birmensdorf','Bonstetten','Bremgarten','Bubikon','Buchs','Bulach','Cham','Dallikon','Dielsdorf','Dietikon','Dietlikon','Dubendorf','Durnten','Eglisau','Embrach','Erlenbach','Fallanden','Fehraltorf','Feusisberg','Freienbach','Gossau','Greifensee','Gruningen','Hedingen','Herrliberg','Hettlingen','Hinwil','Hittnau','Hombrechtikon','Horgen','Hunenberg','Kaltbrunn','Kilchberg','Kloten','Kusnacht','Lachen','Langnau am Albis','Lindau','Mannedorf','Maur','Meilen','Monchaltorf','Neerach','Neftenbach','Neuenhof','Neuheim','Niederhasli','Nurensdorf','Oberglatt','Opfikon','Otelfingen','Ottenbach','Pfaffikon','Rafz','Rapperswil-Jona','Regensdorf','Richterswil','Risch-Rotkreuz','Rumlang','Ruschlikon','Ruti','Schlieren','Schwerzenbach','Seuzach','Spreitenbach','Stafa','Stallikon','Steinhausen','Sulzbach','Teufen','Thalwil','Urdorf','Uster','Volketswil','Wadenswil','Wallisellen','Wettingen','Wetzikon','Wil','Winkel','Winterthur','Wollerau','Wurenlos','Zell','Zollikon','Zufikon','Zug','Zumikon','Zurich') THEN 'ch-other'

			WHEN t4.country_code = 'de' AND t2.name IN ('Berlin', 'Ahrensfelde','Falkensee','Glienicke/Nordbahn','Hoppegarten','Kleinmachnow','Muhlenbecker Land','Panketal','Schonefeld','Teltow', 'Potsdam') THEN 'de-berlin'
			WHEN t4.country_code = 'de' AND t2.name IN ('Bonn','Alfter','Bad Honnef','Bonn','Bornheim','Konigswinter','Niederkassel','Sankt Augustin','Siegburg','Troisdorf','Wesseling') THEN 'de-bonn'
			WHEN t4.country_code = 'de' AND t2.name IN  ('Cologne', 'Bergisch Gladbach','Bornheim','Bruhl','Frechen','Hurth','Leverkusen','Pulheim','Rosrath','Wesseling') THEN 'de-cologne'
			WHEN t4.country_code = 'de' AND t2.name IN ('Dusseldorf', 'Erkrath','Hilden','Kaarst','Langenfeld','Meerbusch','Monheim am Rhein','Neuss','Ratingen') THEN 'de-dusseldorf'
			WHEN t4.country_code = 'de' AND t2.name IN ('Essen', 'Bochum','Bottrop','Essen','Gelsenkirchen','Gladbeck','Hattingen','Mulheim','Oberhausen') THEN 'de-essen'
			WHEN t4.country_code = 'de' AND t2.name IN ('Frankfurt', 'Bad Vilbel','Eschborn','Hattersheim am Main','Heusenstamm','Kelsterbach','Konigstein im Taunus','Kriftel','Maintal','Muhlheim am Main','Neu-Isenburg','Obertshausen','Schwalbach am Taunus') THEN 'de-frankfurt'
			WHEN t4.country_code = 'de' AND t2.name IN ('Hamburg','Ahrensburg','Halstenbek','Hamburg','Norderstedt','Pinneberg','Rellingen','Schenefeld','Wedel') THEN 'de-hamburg'
			WHEN t4.country_code = 'de' AND t2.name IN ('Hanover', 'Garbsen','Hemmingen','Isernhagen','Laatzen','Langenhagen','Ronnenberg','Sarstedt','Seelze','Wunstorf') THEN 'de-hannover'
			WHEN t4.country_code = 'de' AND t2.name IN ('Leipzig') THEN 'de-leipzig'
			WHEN t4.country_code = 'de' AND t2.name IN ('Mainz', 'Bodenheim','Florsheim am Main','Ginsheim-Gustavsburg','Hochheim am Main','Ingelheim am Rhein','Mainz','Nieder-Olm','Raunheim','Russelsheim','Walluf','Wiesbaden') THEN 'de-mainz'
			WHEN t4.country_code = 'de' AND t2.name IN ('Mannheim') THEN 'de-manheim'
			WHEN t4.country_code = 'de' AND t2.name IN ('Munich', 'Aschheim','Baierbrunn','Brunnthal','Dachau','Eching','Feldkirchen','Gauting','Germering','Gilching','Grafelfing','Grasbrunn','Grobenzell','Grunwald','Haar','Hohenbrunn','Hohenkirchen-Siegertsbrunn','Ismaning','Kirchheim bei Munchen','Markt Schwaben','Neubiberg','Neufahrn bei Freising','Oberhaching','Oberschleißheim','Ottobrunn','Planegg','Poing','Puchheim','Putzbrunn','Taufkirchen','Unterfohring','Unterhaching','Unterschleißheim','Vaterstetten') THEN 'de-munich'
			WHEN t4.country_code = 'de' AND t2.name IN ('Nuremberg', 'Erlangen','Furth','Lauf an der Pegnitz','Schwabach','Stein','Zirndorf') THEN 'de-nuremberg'
			WHEN t4.country_code = 'de' AND t2.name IN ('Stuttgart', 'Asperg','Denkendorf','Esslingen','Fellbach','Filderstadt','Gerlingen','Korntal-Munchingen','Kornwestheim','Leinfelden-Echterdingen','Ludwigsburg','Neuhausen auf den Fildern','Ostfildern','Stuttgart','Waiblingen') THEN 'de-stuttgart'
			WHEN t4.country_code = 'de' AND t2.name NOT IN ('Berlin', 'Bonn', 'Cologne', 'Dusseldorf', 'Essen', 'Frankfurt', 'Hamburg','Hanover', 'Leipzig', 'Mainz', 'Mannheim', 'Munich', 'Nuremberg', 'Potsdam', 'Stuttgart', 'Ahrensfelde','Berlin','Falkensee','Glienicke/Nordbahn','Hoppegarten','Kleinmachnow','Muhlenbecker Land','Panketal','Schonefeld','Teltow','Alfter','Bad Honnef','Bonn','Bornheim','Konigswinter','Niederkassel','Sankt Augustin','Siegburg','Troisdorf','Wesseling','Bergisch Gladbach','Bornheim','Bruhl','Frechen','Hurth','Leverkusen','Pulheim','Rosrath','Wesseling','Dormagen','Dusseldorf','Erkrath','Hilden','Kaarst','Leverkusen','Meerbusch','Monheim am Rhein','Neuss','Ratingen','Bochum','Bottrop','Essen','Gelsenkirchen','Gladbeck','Hattingen','Oberhausen','Bad Vilbel','Eschborn','Hattersheim am Main','Heusenstamm','Kelsterbach','Konigstein im Taunus','Kriftel','Maintal','Muhlheim am Main','Neu-Isenburg','Obertshausen','Schwalbach am Taunus','Ahrensburg','Halstenbek','Hamburg','Norderstedt','Pinneberg','Rellingen','Schenefeld','Wedel','Garbsen','Hemmingen','Isernhagen','Laatzen','Langenhagen','Ronnenberg','Sarstedt','Seelze','Wunstorf','Bodenheim','Florsheim am Main','Ginsheim-Gustavsburg','Hochheim am Main','Ingelheim am Rhein','Mainz','Nieder-Olm','Raunheim','Russelsheim','Walluf','Wiesbaden','Aschheim','Baierbrunn','Brunnthal','Dachau','Eching','Feldkirchen','Gauting','Germering','Gilching','Grafelfing','Grasbrunn','Grobenzell','Grunwald','Haar','Hohenbrunn','Hohenkirchen-Siegertsbrunn','Ismaning','Kirchheim bei Munchen','Markt Schwaben','Neubiberg','Neufahrn bei Freising','Oberhaching','Oberschleißheim','Ottobrunn','Planegg','Poing','Puchheim','Putzbrunn','Taufkirchen','Unterfohring','Unterhaching','Unterschleißheim','Vaterstetten','Erlangen','Furth','Lauf an der Pegnitz','Schwabach','Stein','Zirndorf','Asperg','Denkendorf','Fellbach','Filderstadt','Gerlingen','Korntal-Munchingen','Kornwestheim','Leinfelden-Echterdingen','Ludwigsburg','Neuhausen auf den Fildern','Ostfildern','Stuttgart','Waiblingen') THEN 'de-other'

			WHEN t4.country_code = 'nl' AND t2.name IN ('Amsterdam', 'Amsterdam Airport Schiphol', 'Government of Amsterdam', 'Aalsmeer','Abcoude','Amstelveen','Amsterdam','Amsterdam-Zuidoost','Bennebroek','Bussum','Diemen','Duivendrecht','Haarlem','Heemstede','Hilversum','Hoofddorp','Weesp') THEN 'nl-amsterdam'
			WHEN t4.country_code = 'nl' AND t2.name IN ('The Hague', 'Delft','The Hague','Leiden','Leidschendam','Nootdorp','Pijnacker','Rijswijk','Voorburg','Voorschoten') THEN 'nl-hague'
			WHEN t4.country_code = 'nl' AND t2.name NOT IN ('Amsterdam', 'Amsterdam Airport Schiphol', 'Government of Amsterdam', 'Aalsmeer','Abcoude','Amstelveen','Amsterdam','Amsterdam-Zuidoost','Bennebroek','Bussum','Diemen','Duivendrecht','Haarlem','Heemstede','Hilversum','Hoofddorp','Weesp','Delft','The Hague','Leiden','Leidschendam','Nootdorp','Pijnacker','Rijswijk','Voorburg','Voorschoten') THEN 'nl-other'

			ELSE 'no-polygon' END), account, campaign, ad_group

	ORDER BY date desc, locale asc, district asc, city asc, account asc, campaign asc, ad_group asc

;


DROP TABLE IF EXISTS bi.temp_cpa_citysplit;
CREATE TABLE bi.temp_cpa_citysplit AS
	
	SELECT 
		t1.locale::text, 
		t1.district::text, 
		t1.city::text,
		SUM(t1.cost) as city_cost

	FROM bi.etl_adwords_costsperpolygon t1

	WHERE t1.date >= (current_date - interval '30 days') AND t1.city NOT LIKE ('%-other') AND t1.city NOT IN ('no-polygon')

	GROUP BY t1.locale, t1.district, t1.city
	ORDER BY t1.locale asc, t1.district asc, t1.city asc

;

DROP TABLE IF EXISTS bi.temp_cpa_regionsplit;
CREATE TABLE bi.temp_cpa_regionsplit AS

	SELECT 
		t1.locale::text, 
		t1.district::text,
		SUM(t1.cost) as district_cost

	FROM bi.etl_adwords_costsperpolygon t1

	WHERE t1.date >= (current_date - interval '30 days') AND t1.city NOT LIKE ('%-other') AND t1.city NOT IN ('no-polygon')

	GROUP BY t1.locale, t1.district
	ORDER BY t1.locale asc, t1.district asc

;

DROP TABLE IF EXISTS bi.temp_pcentofdistrict;
CREATE TABLE bi.temp_pcentofdistrict AS

	SELECT

		t1.locale::text,
		t1.district::text,
		t1.city::text,
		CASE WHEN SUM(t2.district_cost) > 0 THEN SUM(t1.city_cost)::numeric/SUM(t2.district_cost) ELSE 1 END as pcent_of_districtcost

	FROM bi.temp_cpa_citysplit t1

	JOIN bi.temp_cpa_regionsplit t2 

	ON (t1.district = t2.district AND t1.locale = t2.locale)

	GROUP BY t1.locale, t1.district, t1.city, t2.locale, t2.district

	ORDER BY t1.locale asc, t1.district asc, t1.city asc

;

DROP TABLE IF EXISTS bi.costsgrouping_adwords;
CREATE TABLE bi.costsgrouping_adwords AS

	SELECT 
		t1.date::date,
		t1.locale::text,
		t1.district::text,
		t1.city::text as polygon,
		SUM(CASE WHEN t1.account IN ('Bookatiger AT Booking Search', 'Bookatiger CH Booking Search DE', 'Bookatiger CH Booking Search FR', 'Bookatiger DE Booking Search', 'Bookatiger NL Booking Search') AND t1.campaign NOT LIKE '%Brand%' THEN t1.cost ELSE 0 END) as adwords_cost,

		SUM(CASE WHEN t1.account IN ('Bookatiger AT Booking Search', 'Bookatiger CH Booking Search DE', 'Bookatiger CH Booking Search FR', 'Bookatiger DE Booking Search', 'Bookatiger NL Booking Search') AND t1.campaign LIKE '%Brand%' THEN t1.cost ELSE 0 END) as adwords_brand_cost,

		SUM(CASE WHEN t1.account IN ('Bookatiger AT Booking GDN', 'Bookatiger CH Booking GDN', 'Bookatiger DE Booking GDN', 'Bookatiger NL Booking GDN') THEN t1.cost ELSE 0 END) as display_cost,

		SUM(CASE WHEN t1.account IN ('Bookatiger Business DE Search', 'Bookatiger Business CH Search', 'Bookatiger Business NL Search', 'Bookatiger Business AT Search') THEN t1.cost ELSE 0 END) as adwords_cost_b2b,
		SUM(CASE WHEN t1.account IN ('Bookatiger Business DE GDN', 'Bookatiger Business AT GDN', 'Bookatiger Business CH GDN', 'Bookatiger Business NL GDN') THEN t1.cost ELSE 0 END) as display_cost_b2b,

		SUM(CASE WHEN t1.account IN ('Bookatiger DE Signup Search', 'Bookatiger NL Signup Search', 'Bookatiger CH Signup Search', 'Bookatiger AT Signup Search') THEN t1.cost ELSE 0 END) as adwords_cost_signup,
		SUM(CASE WHEN t1.account IN ('Bookatiger DE Signup GDN', 'Bookatiger NL Signup GDN', 'Bookatiger AT Signup GDN', 'Bookatiger CH Signup GDN') THEN t1.cost ELSE 0 END) as display_cost_signup,

		SUM(CASE WHEN t1.account IN ('Bookatiger DE YouTube', 'Bookatiger CH YouTube', 'Bookatiger AT YouTube', 'Bookatiger NL YouTube') THEN t1.cost ELSE 0 END) as youtube_cost

	FROM bi.etl_adwords_costsperpolygon t1

	GROUP BY 
	t1.date,
	t1.locale,
	t1.district,
	t1.city

	ORDER BY
	t1.date desc,
	t1.locale asc,
	t1.district asc,
	t1.city asc

;

DROP TABLE IF EXISTS bi.temp_costsgrouping_facebook;
CREATE TABLE bi.temp_costsgrouping_facebook AS

	SELECT 
		t1.date::date,
		t1.locale::text,
		t1.region::text,
		SUM(t1.spend) as facebook_costs

	FROM bi.etl_facebook_costsperdistrict t1

	GROUP BY 
	t1.date,
	t1.locale,
	t1.region

	ORDER BY
	t1.date desc,
	t1.locale asc,
	t1.region asc

;

DROP TABLE IF EXISTS bi.temp_costsgrouping_fbleverate;
CREATE TABLE bi.temp_costsgrouping_fbleverate AS

	SELECT 
		t1.cost_date::date as date,
		LOWER(t1.locale)::text as locale,
		
		(CASE WHEN
			region IN ('Baden-Württemberg') THEN 'Baden-Wurttemberg'
			WHEN region IN ('Bayern') THEN 'Bavaria'
			WHEN region IN ('Berlin', 'Brandenburg') THEN 'Berlin'
			WHEN region IN  ('Bremen', 'Niedersachsen') THEN 'Lower Saxony & Bremen'
			WHEN region IN ('Hamburg', 'Schleswig-Holstein') THEN 'Hamburg & Schleswig-Holstein'
			WHEN region IN ('Rheinland-Pfalz', 'Saarland') THEN 'Rhineland-Palatinate & Saarland'
			WHEN region IN ('Hessen') THEN 'Hesse'
			WHEN region IN ('Mecklenburg-Vorpommern') THEN 'Mecklenburg-Vorpommern'
			WHEN region IN ('Nordrhein-Westfalen') THEN 'North Rhine-Westphalia'
			WHEN region IN ('Sachsen', 'Saxony-Anhalt') THEN 'Saxony & Saxony-Anhalt'
			WHEN region IN ('Thüringen') THEN 'Thuringia'

			WHEN region IN ('Basel-City', 'Basel-Landschaft') THEN 'Basel-Stadt'
			WHEN region IN ('Bern') THEN 'Canton of Bern'
			WHEN region IN ('Canton of Geneva') THEN 'Canton of Geneva'
			WHEN region IN  ('Vaud') THEN 'Canton of Vaud'
			WHEN region IN ('Luzern') THEN 'Canton of Lucerne'
			WHEN region IN ('Canton of St. Gallen') THEN 'Canton of St. Gallen'
			WHEN region IN ('Zürich') THEN 'Canton of Zurich'

			WHEN region LIKE ('%Amsterdam%') THEN 'Amsterdam'
			WHEN region LIKE ('%Vienna%') THEN 'Vienna'

			WHEN region NOT IN ('Basel-City', 'Basel-Landschaft', 'Bern', 'Canton of Geneva', 'Vaud', 'Luzern','Canton of St. Gallen', 'Zürich', 'Baden-Württemberg', 'Bayern', 'Berlin', 'Brandenburg', 'Bremen', 'Niedersachsen', 'Hamburg', 'Schleswig-Holstein', 'Rheinland-Pfalz', 'Saarland', 'Hessen', 'Mecklenburg-Vorpommern', 'Nordrhein-Westfalen', 'Sachsen', 'Saxony-Anhalt', 'Thüringen') THEN 'Other'
			ELSE 'Other' END)::text

		as region,

		SUM(t1.cost) as fbleverate_costs

	FROM external_data.zapier_fbleverate t1

	GROUP BY 
	t1.cost_date,
	LOWER(t1.locale),
		(CASE WHEN
			region IN ('Baden-Württemberg') THEN 'Baden-Wurttemberg'
			WHEN region IN ('Bayern') THEN 'Bavaria'
			WHEN region IN ('Berlin', 'Brandenburg') THEN 'Berlin'
			WHEN region IN  ('Bremen', 'Niedersachsen') THEN 'Lower Saxony & Bremen'
			WHEN region IN ('Hamburg', 'Schleswig-Holstein') THEN 'Hamburg & Schleswig-Holstein'
			WHEN region IN ('Rheinland-Pfalz', 'Saarland') THEN 'Rhineland-Palatinate & Saarland'
			WHEN region IN ('Hessen') THEN 'Hesse'
			WHEN region IN ('Mecklenburg-Vorpommern') THEN 'Mecklenburg-Vorpommern'
			WHEN region IN ('Nordrhein-Westfalen') THEN 'North Rhine-Westphalia'
			WHEN region IN ('Sachsen', 'Saxony-Anhalt') THEN 'Saxony & Saxony-Anhalt'
			WHEN region IN ('Thüringen') THEN 'Thuringia'

			WHEN region IN ('Basel-City', 'Basel-Landschaft') THEN 'Basel-Stadt'
			WHEN region IN ('Bern') THEN 'Canton of Bern'
			WHEN region IN ('Canton of Geneva') THEN 'Canton of Geneva'
			WHEN region IN  ('Vaud') THEN 'Canton of Vaud'
			WHEN region IN ('Luzern') THEN 'Canton of Lucerne'
			WHEN region IN ('Canton of St. Gallen') THEN 'Canton of St. Gallen'
			WHEN region IN ('Zürich') THEN 'Canton of Zurich'

			WHEN region LIKE ('%Amsterdam%') THEN 'Amsterdam'
			WHEN region LIKE ('%Vienna%') THEN 'Vienna'

			WHEN region NOT IN ('Basel-City', 'Basel-Landschaft', 'Bern', 'Canton of Geneva', 'Vaud', 'Luzern','Canton of St. Gallen', 'Zürich', 'Baden-Württemberg', 'Bayern', 'Berlin', 'Brandenburg', 'Bremen', 'Niedersachsen', 'Hamburg', 'Schleswig-Holstein', 'Rheinland-Pfalz', 'Saarland', 'Hessen', 'Mecklenburg-Vorpommern', 'Nordrhein-Westfalen', 'Sachsen', 'Saxony-Anhalt', 'Thüringen') THEN 'Other'
			ELSE 'Other' END)::text
	
	ORDER BY
	date desc,
	locale asc,
	region asc

;

DROP TABLE IF EXISTS bi.temp_costsgrouping_offline;
CREATE TABLE bi.temp_costsgrouping_offline AS

	SELECT 
		date::date,
		LEFT(t1.polygon, 2) as locale,
		CASE WHEN t1.polygon like '%-other' THEN 'no-polygon' ELSE t1.polygon END as polygon,
		SUM(CASE WHEN t1.daily_costs_eur IS NULL THEN 0 ELSE t1.daily_costs_eur END) as offline_cost

	FROM generate_series(
	  '2016-08-01'::date,
	  current_date::date,
	  '1 day'::interval
	) date

	LEFT JOIN external_data.zapier_offlinecosts t1
		ON date >= t1.start_date
		AND date <= t1.end_date
		AND t1.manual_validation = 'Yes'
		AND t1.formula_validation = 'Yes'

	GROUP BY date::date, 
		LEFT(t1.polygon, 2),
		t1.polygon

	ORDER BY date::date asc,
		t1.polygon asc


;


DROP TABLE IF EXISTS bi.temp_channels_acq_discounts;
CREATE TABLE bi.temp_channels_acq_discounts AS

	SELECT
		t5.order_creation__c::date as date,
		CASE WHEN LEFT(t5.locale__c, 2) IS NOT NULL THEN LEFT(t5.locale__c, 2) ELSE 'No locale' END as locale,
		CASE WHEN t5.polygon IS NULL THEN 'no-polygon' ELSE t5.polygon END as polygon,

		SUM(CASE WHEN t5.marketing_channel = 'SEM' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as sem_discount,
		SUM(CASE WHEN t5.marketing_channel = 'SEM Brand' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as sem_brand_discount,
		SUM(CASE WHEN t5.marketing_channel = 'Display' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as display_discount,
		SUM(CASE WHEN t5.marketing_channel = 'Facebook' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as facebook_discount,
		SUM(CASE WHEN t5.marketing_channel = 'Facebook Organic' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as facebook_organic_discount,
		SUM(CASE WHEN t5.marketing_channel = 'Brand Marketing Offline' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as offline_discount,
		SUM(CASE WHEN t5.marketing_channel = 'Voucher Campaigns' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as vouchers_cost,
		SUM(CASE WHEN t5.marketing_channel = 'Newsletter' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as newsletter_discount,
		SUM(CASE WHEN t5.marketing_channel = 'SEO' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as seo_discount,
		SUM(CASE WHEN t5.marketing_channel = 'SEO Brand' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as seo_brand_discount,
		SUM(CASE WHEN t5.marketing_channel = 'Youtube Paid' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as youtube_discount,

		SUM(CASE WHEN t5.marketing_channel = 'SEM' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as sem_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'SEM Brand' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as sem_brand_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'Display' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as display_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'Facebook' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as facebook_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'Facebook Organic' AND t5.acquisition_new_customer__c = '0'  AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as facebook_organic_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'Brand Marketing Offline' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as offline_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'Voucher Campaigns' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as vouchers_cost_reb,
		SUM(CASE WHEN t5.marketing_channel = 'Newsletter' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as newsletter_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'SEO' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as seo_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'SEO Brand' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as seo_brand_discount_reb,
		SUM(CASE WHEN t5.marketing_channel = 'Youtube Paid' AND t5.acquisition_new_customer__c = '0' AND t5.status NOT LIKE ('%CANCELLED%') THEN discount__c ELSE 0 END)::numeric as youtube_discount_reb,

		SUM(CASE WHEN t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as all_acq,
		SUM(CASE WHEN t5.marketing_channel = 'SEM' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as sem_acq,
		SUM(CASE WHEN t5.marketing_channel = 'SEM Brand' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as sem_brand_acq,
		SUM(CASE WHEN t5.marketing_channel = 'Display' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as display_acq,
		SUM(CASE WHEN t5.marketing_channel = 'Facebook' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as facebook_acq,
		SUM(CASE WHEN t5.marketing_channel = 'Facebook Organic' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as facebook_organic_acq,
		SUM(CASE WHEN t5.marketing_channel = 'Brand Marketing Offline' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as offline_acq,
		SUM(CASE WHEN t5.marketing_channel = 'Voucher Campaigns' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as vouchers_acq,
		SUM(CASE WHEN t5.marketing_channel = 'DTI' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as dti_acq,
		SUM(CASE WHEN t5.marketing_channel = 'Newsletter' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as newsletter_acq,
		SUM(CASE WHEN t5.marketing_channel = 'SEO' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as seo_acq,
		SUM(CASE WHEN t5.marketing_channel = 'SEO Brand' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as seo_brand_acq,
		SUM(CASE WHEN t5.marketing_channel = 'Youtube Paid' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as youtube_acq,
		SUM(CASE WHEN t5.marketing_channel = 'Unattributed' AND t5.acquisition_new_customer__c = '1' AND t5.order_creation__c::date = t5.customer_creation_date::date THEN 1 ELSE 0 END)::numeric as other_acq,
		MAX(new_subscribers) as all_subscribers
	FROM bi.orders t5
	LEFT JOIn
		(SELECT
	mindate as date,
	locale,
	polygon,
	COUNT(DISTINCT(contact__c)) as new_subscribers
FROM(
SELECT
	contact__c,
	polygon,
	LEFT(locale__c,2) as locale,
	min(order_Creation__c::date) as mindate
FROM
	bi.orders
WHERE
	status not in ('CANCELLED FAKED','CANCELLED MISTAKE')
	and recurrency__c > '0'
GROUP BY
	contact__c,
	polygon,
	locale) as a
GROUP BY
	Date,
	polygon,
	locale) as t2
ON
	(LEFT(t5.locale__c,2) = t2.locale and t5.polygon = t2.polygon and t5.order_creation__c::date = t2.date)

	WHERE t5.test__c = '0'
		AND t5.status NOT IN ('CANCELLED FAKED', 'CANCELLED MISTAKE')
		AND t5.order_creation__c::date >= '2016-08-01'
		AND t5.order_type = '1'

	GROUP BY t5.order_creation__c::date,
		LEFT(t5.locale__c, 2),
		t5.polygon

	ORDER BY t5.order_creation__c::date desc,
		LEFT(t5.locale__c, 2) asc,
		t5.polygon asc	
;


DROP TABLE IF EXISTS bi.temp_timeseries_w_polygons;
CREATE TABLE bi.temp_timeseries_w_polygons AS

	SELECT 
		date::date as date,
		t2.locale,
		t2.polygon
	FROM generate_series(
	  '2016-08-01'::date,
	  current_date::date,
	  '1 day'::interval
	) date

	JOIN 
	(SELECT DISTINCT
		LEFT(locale__c, 2) as locale,
		CASE WHEN polygon IS NULL THEN 'no-polygon' ELSE polygon END as polygon
	FROM bi.orders
	WHERE test__c = '0' AND order_type = '1'
	ORDER BY locale asc, polygon asc) t2 
	ON 1=1
;


DROP TABLE IF EXISTS bi.temp_groupall_step_1;
CREATE TABLE bi.temp_groupall_step_1 AS

	SELECT
		t1.date,
		t1.locale,
		CASE WHEN t2.district IS NULL THEN 'Other' ELSE t2.district END as district,
		t1.polygon

	FROM bi.temp_timeseries_w_polygons t1

	LEFT JOIN bi.costsgrouping_adwords t2
		ON t1.date = t2.date 
		AND t1.locale = t2.locale 
		AND t1.polygon = t2.polygon

	WHERE t1.date <= t2.date

	ORDER BY date asc, locale asc, polygon asc
;

DROP TABLE IF EXISTS bi.etl_display_costsperlocale;
CREATE TABLE bi.etl_display_costsperlocale AS

	SELECT
		date::date,
		t1.locale as locale,
		CASE WHEN t1.locale IN ('de', 'ch') THEN 'Other'
				WHEN t1.locale = 'at' THEN 'Vienna'
				WHEN t1.locale = 'nl' THEN 'Region of Amsterdam'
				ELSE NULL END::text
		as district,
		CASE WHEN t1.polygon LIKE ('%-other') THEN 'no-polygon' ELSE t1.polygon END::text as polygon,
		SUM(CASE WHEN t1.daily_costs_eur IS NULL THEN 0 ELSE t1.daily_costs_eur END) as cost

	FROM generate_series(
		'2016-07-01'::date,
		current_date::date,
		'1 day'::interval
	) date

	LEFT JOIN external_data.zapier_displaycosts t1
			ON date >= t1.start_date
			AND date <= t1.end_date
			AND t1.manual_validation = 'Yes'
			AND t1.formula_validation = 'Yes'

	GROUP BY date::date, t1.locale, 	CASE WHEN t1.locale IN ('de', 'ch') THEN 'Other'
				WHEN t1.locale = 'at' THEN 'Vienna'
				WHEN t1.locale = 'nl' THEN 'Region of Amsterdam'
				ELSE NULL END::text, CASE WHEN t1.polygon LIKE ('%-other') THEN 'no-polygon' ELSE t1.polygon END::text
	ORDER BY date::date desc, polygon asc

;

DROP TABLE IF EXISTS bi.etl_seo_costsperlocale;
CREATE TABLE bi.etl_seo_costsperlocale AS

	SELECT
		date::date,
		LEFT(t1.polygon,2) as locale,
		'Other'::text as district,
		'No-polygon'::text as polygon,
		SUM(CASE WHEN t1.daily_costs_eur IS NULL THEN 0 ELSE t1.daily_costs_eur END) as cost

	FROM generate_series(
		'2016-07-01'::date,
		current_date::date,
		'1 day'::interval
	) date

	LEFT JOIN external_data.zapier_seocosts t1
			ON date >= t1.start_date
			AND date <= t1.end_date
			AND t1.manual_validation = 'Yes'
			AND t1.formula_validation = 'Yes'

	GROUP BY date::date, LEFT(t1.polygon,2), district, polygon 
	ORDER BY date::date desc, polygon asc, locale asc

;


DROP TABLE IF EXISTS bi.cpacalcpolygon;
CREATE TABLE bi.cpacalcpolygon AS

	SELECT

		t0.date::date,
		CASE WHEN t0.locale::text IS NULL THEN 'No locale' ELSE t0.locale::text END as locale,
		CASE WHEN t0.polygon = 'no-polygon' THEN 'Other'::text ELSE t0.district::text END as district,
		t0.polygon::text,

		SUM(CASE WHEN t1.adwords_cost IS NULL THEN 0 ELSE t1.adwords_cost END) as sem_cost,
		SUM(CASE WHEN t1.adwords_brand_cost IS NULL THEN 0 ELSE t1.adwords_brand_cost END) as sem_brand_cost,
		SUM(CASE WHEN t7.cost IS NULL THEN 0 ELSE t7.cost END) as seo_cost,
		SUM(CASE WHEN t1.display_cost IS NULL THEN 0 ELSE t1.display_cost END) + AVG(CASE WHEN t6.cost IS NULL THEN 0 ELSE t6.cost END) as display_cost,
		
		SUM(CASE WHEN t2.facebook_costs IS NULL THEN 0 ELSE t2.facebook_costs END)*SUM(CASE WHEN (t3.pcent_of_districtcost) IS NULL THEN 0 ELSE t3.pcent_of_districtcost END)
		+ SUM(CASE WHEN t8.fbleverate_costs IS NULL THEN 0 ELSE t8.fbleverate_costs END)*SUM(CASE WHEN (t3.pcent_of_districtcost) IS NULL THEN 0 ELSE t3.pcent_of_districtcost END)
		as facebook_cost,

		SUM(CASE WHEN t4.offline_cost IS NULL THEN 0 ELSE t4.offline_cost END) as offline_cost,
		SUM(CASE WHEN t5.vouchers_cost IS NULL THEN 0 ELSE t5.vouchers_cost END) as vouchers_cost,
		SUM(CASE WHEN t5.vouchers_cost_reb IS NULL THEN 0 ELSE t5.vouchers_cost_reb END) as vouchers_cost_reb,
		SUM(CASE WHEN t1.youtube_cost IS NULL THEN 0 ELSE t1.youtube_cost END) as youtube_cost,

		SUM(CASE WHEN t5.sem_discount IS NULL THEN 0 ELSE t5.sem_discount END) as sem_discount,
		SUM(CASE WHEN t5.sem_brand_discount IS NULL THEN 0 ELSE t5.sem_brand_discount END) as sem_brand_discount,
		SUM(CASE WHEN t5.display_discount IS NULL THEN 0 ELSE t5.display_discount END) as display_discount,
		SUM(CASE WHEN t5.facebook_discount IS NULL THEN 0 ELSE t5.facebook_discount END) as facebook_discount,
		SUM(CASE WHEN t5.facebook_organic_discount IS NULL THEN 0 ELSE t5.facebook_organic_discount END) as facebook_organic_discount,
		SUM(CASE WHEN t5.offline_discount IS NULL THEN 0 ELSE t5.offline_discount END) as offline_discount,
		SUM(CASE WHEN t5.newsletter_discount IS NULL THEN 0 ELSE t5.newsletter_discount END) as newsletter_discount,
		SUM(CASE WHEN t5.seo_discount IS NULL THEN 0 ELSE t5.seo_discount END) as seo_discount,
		SUM(CASE WHEN t5.seo_brand_discount IS NULL THEN 0 ELSE t5.seo_brand_discount END) as seo_brand_discount,
		SUM(CASE WHEN t5.youtube_discount IS NULL THEN 0 ELSE t5.youtube_discount END) as youtube_discount,

		SUM(CASE WHEN t5.sem_discount_reb IS NULL THEN 0 ELSE t5.sem_discount_reb END) as sem_discount_reb,
		SUM(CASE WHEN t5.sem_brand_discount_reb IS NULL THEN 0 ELSE t5.sem_brand_discount_reb END) as sem_brand_discount_reb,
		SUM(CASE WHEN t5.display_discount_reb IS NULL THEN 0 ELSE t5.display_discount_reb END) as display_discount_reb,
		SUM(CASE WHEN t5.facebook_discount_reb IS NULL THEN 0 ELSE t5.facebook_discount_reb END) as facebook_discount_reb,
		SUM(CASE WHEN t5.facebook_organic_discount_reb IS NULL THEN 0 ELSE t5.facebook_organic_discount_reb END) as facebook_organic_discount_reb,
		SUM(CASE WHEN t5.offline_discount_reb IS NULL THEN 0 ELSE t5.offline_discount_reb END) as offline_discount_reb,
		SUM(CASE WHEN t5.newsletter_discount_reb IS NULL THEN 0 ELSE t5.newsletter_discount_reb END) as newsletter_discount_reb,
		SUM(CASE WHEN t5.seo_discount_reb IS NULL THEN 0 ELSE t5.seo_discount_reb END) as seo_discount_reb,
		SUM(CASE WHEN t5.seo_brand_discount_reb IS NULL THEN 0 ELSE t5.seo_brand_discount_reb END) as seo_brand_discount_reb,
		SUM(CASE WHEN t5.youtube_discount_reb IS NULL THEN 0 ELSE t5.youtube_discount_reb END) as youtube_discount_reb,

		SUM(CASE WHEN t5.all_acq IS NULL THEN 0 ELSE t5.all_acq END) as all_acq,
		SUM(CASE WHEN t5.sem_acq IS NULL THEN 0 ELSE t5.sem_acq END) as sem_acq,
		SUM(CASE WHEN t5.sem_brand_acq IS NULL THEN 0 ELSE t5.sem_brand_acq END) as sem_brand_acq,
		SUM(CASE WHEN t5.display_acq IS NULL THEN 0 ELSE t5.display_acq END) as display_acq,
		SUM(CASE WHEN t5.facebook_acq IS NULL THEN 0 ELSE t5.facebook_acq END) as facebook_acq,
		SUM(CASE WHEN t5.facebook_organic_acq IS NULL THEN 0 ELSE t5.facebook_organic_acq END) as facebook_organic_acq,
		SUM(CASE WHEN t5.offline_acq IS NULL THEN 0 ELSE t5.offline_acq END) as offline_acq,
		SUM(CASE WHEN t5.vouchers_acq IS NULL THEN 0 ELSE t5.vouchers_acq END) as vouchers_acq,
		SUM(CASE WHEN t5.dti_acq IS NULL THEN 0 ELSE t5.dti_acq END) as dti_acq,
		SUM(CASE WHEN t5.newsletter_acq IS NULL THEN 0 ELSE t5.newsletter_acq END) as newsletter_acq,
		SUM(CASE WHEN t5.seo_acq IS NULL THEN 0 ELSE t5.seo_acq END) as seo_acq,
		SUM(CASE WHEN t5.seo_brand_acq IS NULL THEN 0 ELSE t5.seo_brand_acq END) as seo_brand_acq,
		SUM(CASE WHEN t5.youtube_acq IS NULL THEN 0 ELSE t5.youtube_acq END) as youtube_acq,
		SUM(CASE WHEN t5.other_acq IS NULL THEN 0 ELSE t5.other_acq END) as other_acq,
		SUM(CASE WHEN t5.all_subscribers is NULL THEN 0 ELSE t5.all_subscribers END) all_subscribers

	FROM bi.temp_groupall_step_1 t0

	LEFT JOIN bi.costsgrouping_adwords t1
		ON t0.date = t1.date 
		AND t0.locale = t1.locale
		AND t0.district = t1.district
		AND t0.polygon = t1.polygon

	LEFT JOIN bi.temp_costsgrouping_facebook t2 
		ON t0.date = t2.date
		AND t0.locale = t2.locale
		AND t0.district = t2.region

	LEFT JOIN bi.temp_costsgrouping_fbleverate t8 
		ON t0.date = t8.date
		AND t0.locale = t8.locale
		AND t0.district = t8.region

	LEFT JOIN bi.temp_pcentofdistrict t3
		ON t0.locale = t3.locale
		AND t0.district = t3.district
		AND t0.polygon = t3.city

	LEFT JOIN bi.temp_costsgrouping_offline t4
		ON t0.date = t4.date
		AND t0.locale = t4.locale
		AND t0.polygon = t4.polygon

	LEFT JOIN bi.temp_channels_acq_discounts t5
		ON t0.date = t5.date
		AND t0.locale = t5.locale
		AND t0.polygon = t5.polygon

	LEFT JOIN bi.etl_display_costsperlocale t6
		ON t0.date = t6.date
		AND t0.locale = t6.locale
		AND (CASE WHEN t0.polygon = 'no-polygon' THEN 'Other'::text ELSE t0.district::text END) = t6.district
		AND t0.polygon = t6.polygon

	LEFT JOIN bi.etl_seo_costsperlocale t7
		ON t0.date = t7.date
		AND t0.locale = t7.locale
		AND (CASE WHEN t0.polygon = 'no-polygon' THEN 'Other'::text ELSE t0.district::text END) = t7.district
		AND t0.polygon = t7.polygon



	GROUP BY 
		t0.date,
		t0.locale,
		CASE WHEN t0.polygon = 'no-polygon' THEN 'Other'::text ELSE t0.district::text END,
		t0.polygon

	ORDER BY
		t0.date desc,
		t0.locale asc,
		district asc,
		t0.polygon asc

;

DROP TABLE IF EXISTS bi.temp_cpa_citysplit;
DROP TABLE IF EXISTS bi.temp_cpa_regionsplit;
DROP TABLE IF EXISTS bi.temp_pcentofdistrict;
DROP TABLE IF EXISTS bi.temp_costsgrouping_facebook;
DROP TABLE IF EXISTS bi.temp_costsgrouping_offline;
DROP TABLE IF EXISTS bi.temp_channels_acq_discounts;
DROP TABLE IF EXISTS bi.temp_timeseries_w_polygons;
DROP TABLE IF EXISTS bi.temp_groupall_step_1;


---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

end_time := clock_timestamp() + interval '2 hours';
duration := EXTRACT(EPOCH FROM (end_time - start_time));
INSERT INTO main.function_logging values(DEFAULT, function_name, start_time, end_time, duration);

EXCEPTION WHEN others THEN 

	INSERT INTO main.error_logging VALUES (NOW()::timestamp, function_name::text, SQLERRM::text, SQLSTATE::text);
    RAISE NOTICE 'Error detected: transaction was rolled back.';
    RAISE NOTICE '% %', SQLERRM, SQLSTATE;

END;


$BODY$ LANGUAGE 'plpgsql'