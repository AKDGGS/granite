SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;


CREATE OR REPLACE VIEW container_building AS ( 
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


CREATE OR REPLACE VIEW container_path AS (
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


CREATE OR REPLACE VIEW inventory_shotline AS (
	SELECT DISTINCT isp.inventory_id, sp.shotline_id
	FROM inventory_shotpoint AS isp
	JOIN shotpoint AS sp ON sp.shotpoint_id = isp.shotpoint_id
);


CREATE OR REPLACE VIEW inventory_shotline_minmax AS (
	SELECT isp.inventory_id, sp.shotline_id,
		MIN(sp.shotpoint_number) AS shotline_min,
		MAX(sp.shotpoint_number) AS shotline_max
	FROM inventory_shotpoint AS isp
	JOIN shotpoint AS sp
		ON isp.shotpoint_id = sp.shotpoint_id
	WHERE sp.shotpoint_number IS NOT NULL
	GROUP BY isp.inventory_id, sp.shotline_id
);
