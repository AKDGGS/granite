SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;


DROP VIEW IF EXISTS container_building CASCADE;
CREATE VIEW container_building AS ( 
	WITH RECURSIVE t AS (
		(
			SELECT c.container_id, c.container_id AS building_id,
				c.parent_container_id, c.container_type_id
			FROM container AS c
		) UNION ALL (
			SELECT t.container_id, c.container_id AS building_id,
				c.parent_container_id, c.container_type_id
			FROM container AS c
			JOIN t ON t.parent_container_id = c.container_id
		)
	)
	SELECT container_id, building_id
	FROM t
	WHERE container_type_id IN (
		SELECT container_type_id
		FROM container_type
		WHERE name = 'connex'
			OR name = 'out building'
			OR name = 'main warehouse'
	)
);


DROP VIEW IF EXISTS container_path CASCADE;
CREATE VIEW container_path AS (
	WITH RECURSIVE t AS (
		(
			SELECT 0 AS level, c1.name,
			c1.container_id, c1.parent_container_id
			FROM container AS c1
		) UNION ALL (
			SELECT t.level+1 AS level, c2.name,
			t.container_id, c2.parent_container_id
			FROM container AS c2
			JOIN t ON t.parent_container_id = c2.container_id
		)
	)
	SELECT container_id,
		STRING_AGG(name, '/' ORDER BY level DESC) AS path
	FROM t
	GROUP BY container_id
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
		WHEN i.radiation_msv > 0 THEN 'Radioactive'
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
