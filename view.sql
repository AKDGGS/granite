SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;


DROP VIEW IF EXISTS inventory_prospect CASCADE;
CREATE VIEW inventory_prospect AS (
	SELECT DISTINCT ibh.inventory_id, bh.prospect_id
	FROM inventory_borehole AS ibh
	JOIN borehole AS bh ON bh.borehole_id = ibh.borehole_id
);


DROP VIEW IF EXISTS inventory_shotline CASCADE;
CREATE VIEW inventory_shotline AS (
	SELECT DISTINCT isp.inventory_id, sp.shotline_id
	FROM inventory_shotpoint AS isp
	JOIN shotpoint AS sp ON sp.shotpoint_id = isp.shotpoint_id
);


DROP VIEW IF EXISTS inventory_shotline_minmax CASCADE; 
CREATE VIEW inventory_shotline_minmax AS (
	SELECT isp.inventory_id, sp.shotline_id,
		MIN(sp.shotpoint_number) AS shotline_min,
		MAX(sp.shotpoint_number) AS shotline_max
	FROM inventory_shotpoint AS isp
	JOIN shotpoint AS sp
		ON isp.shotpoint_id = sp.shotpoint_id
	WHERE sp.shotpoint_number IS NOT NULL
	GROUP BY isp.inventory_id, sp.shotline_id
);


DROP VIEW IF EXISTS inventory_bin CASCADE;
CREATE VIEW inventory_bin AS (
	SELECT i.inventory_id, CASE
		WHEN i.radiation_msvh > 0 THEN 'Radioactive'
		WHEN il.inventory_id IS NOT NULL THEN 'Light-weight'
		ELSE COALESCE(ig.name, 'Unknown' || COALESCE(' - ' || c.name, '')) END AS bin
	FROM inventory AS i
	LEFT OUTER JOIN collection AS c ON
		c.collection_id = i.collection_id
	LEFT OUTER JOIN (
		SELECT DISTINCT ik.inventory_id
		FROM inventory_keyword AS ik
		JOIN keyword AS k ON k.keyword_id = ik.keyword_id
		WHERE k.name IN (
			'plug','washed','vial',
			'crude','chips','seep'
		)
	) AS il ON il.inventory_id = i.inventory_id
	LEFT OUTER JOIN (
		SELECT DISTINCT ON (inventory_id) ig.inventory_id, g.name
		FROM inventory_geog AS ig
		JOIN gmc_region_geog AS gg ON ST_Intersects(gg.geog, ig.geog)
		JOIN gmc_region AS g ON g.gmc_region_id = gg.gmc_region_id
	) AS ig ON ig.inventory_id = i.inventory_id
);
