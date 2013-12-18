SET ROLE 'gmc';
SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;


CREATE OR REPLACE VIEW inventory_geom_precision AS (
	-- Borehole Point
	(SELECT ib.inventory_id, p.geom
	FROM inventory_borehole AS ib
	JOIN borehole_point AS bp ON bp.borehole_id = ib.borehole_id
	JOIN point AS p ON p.point_id = bp.point_id
	WHERE p.geom IS NOT NULL)

	UNION ALL

	-- Outcrop Point
	(SELECT io.inventory_id, p.geom
	FROM inventory_outcrop AS io
	JOIN outcrop_point AS op ON op.outcrop_id = io.outcrop_id
	JOIN point AS p ON p.point_id = op.point_id
	WHERE p.geom IS NOT NULL)

	UNION ALL

	-- Well Point
	(SELECT iw.inventory_id, p.geom
	FROM inventory_well AS iw
	JOIN well_point AS wp ON wp.well_id = iw.well_id
	JOIN point AS p ON p.point_id = wp.point_id
	WHERE p.geom IS NOT NULL)

	UNION ALL

	-- Outcrop Place
	(SELECT io.inventory_id, p.geom
	FROM inventory_outcrop AS io
	JOIN outcrop_place AS op ON op.outcrop_id = io.outcrop_id
	JOIN place AS p ON p.place_id = op.place_id
	WHERE p.geom IS NOT NULL)

	UNION ALL

	-- Well Place
	(SELECT iw.inventory_id, p.geom
	FROM inventory_well AS iw
	JOIN well_place AS wp ON wp.well_id = iw.well_id
	JOIN place AS p ON p.place_id = wp.place_id
	WHERE p.geom IS NOT NULL)

	UNION ALL

	-- Outcrop PLSS
	(SELECT io.inventory_id, p.geom
	FROM inventory_outcrop AS io
	JOIN outcrop_plss AS op ON op.outcrop_id = io.outcrop_id
	JOIN plss AS p ON p.plss_id = op.plss_id
	WHERE p.geom IS NOT NULL AND township IS NOT NULL)

	UNION ALL

	-- Well PLSS
	(SELECT iw.inventory_id, p.geom
	FROM inventory_well AS iw
	JOIN well_plss AS wp ON wp.well_id = iw.well_id
	JOIN plss AS p ON p.plss_id = wp.plss_id
	WHERE p.geom IS NOT NULL AND township IS NOT NULL)

	UNION ALL

	-- Borehole Quadrangle
	(SELECT ib.inventory_id, q.geom
	FROM inventory_borehole AS ib
	JOIN borehole_quadrangle AS bq ON bq.borehole_id = ib.borehole_id
	JOIN quadrangle AS q ON q.quadrangle_id = bq.quadrangle_id
	WHERE q.geom IS NOT NULL AND q.scale = 63360)

	UNION ALL

	-- Outcrop Quadrangle
	(SELECT io.inventory_id, q.geom
	FROM inventory_outcrop AS io
	JOIN outcrop_quadrangle AS oq ON oq.outcrop_id = io.outcrop_id
	JOIN quadrangle AS q ON q.quadrangle_id = oq.quadrangle_id
	WHERE q.geom IS NOT NULL AND q.scale = 63360)

	UNION ALL

	-- Well Quadrangle
	(SELECT iw.inventory_id, q.geom
	FROM inventory_well AS iw
	JOIN well_quadrangle AS wq ON wq.well_id = iw.well_id
	JOIN quadrangle AS q ON q.quadrangle_id = wq.quadrangle_id
	WHERE q.geom IS NOT NULL AND q.scale = 63360)
);


CREATE OR REPLACE VIEW inventory_geom AS (
	(
		-- Borehole Point
		SELECT ib.inventory_id, p.geom
		FROM inventory_borehole AS ib
		JOIN borehole_point AS bp ON bp.borehole_id = ib.borehole_id
		JOIN point AS p ON p.point_id = bp.point_id
		WHERE p.geom IS NOT NULL
	) UNION ALL (
		-- Outcrop Point
		SELECT io.inventory_id, p.geom
		FROM inventory_outcrop AS io
		JOIN outcrop_point AS op ON op.outcrop_id = io.outcrop_id
		JOIN point AS p ON p.point_id = op.point_id
		WHERE p.geom IS NOT NULL
	) UNION ALL (
		-- Well Point
		SELECT iw.inventory_id, p.geom
		FROM inventory_well AS iw
		JOIN well_point AS wp ON wp.well_id = iw.well_id
		JOIN point AS p ON p.point_id = wp.point_id
		WHERE p.geom IS NOT NULL
	) UNION ALL (
		-- Outcrop Place
		SELECT io.inventory_id, p.geom
		FROM inventory_outcrop AS io
		JOIN outcrop_place AS op ON op.outcrop_id = io.outcrop_id
		JOIN place AS p ON p.place_id = op.place_id
		WHERE p.geom IS NOT NULL
	) UNION ALL (
		-- Well Place
		SELECT iw.inventory_id, p.geom
		FROM inventory_well AS iw
		JOIN well_place AS wp ON wp.well_id = iw.well_id
		JOIN place AS p ON p.place_id = wp.place_id
		WHERE p.geom IS NOT NULL
	) UNION ALL (
		-- Outcrop PLSS
		SELECT io.inventory_id, p.geom
		FROM inventory_outcrop AS io
		JOIN outcrop_plss AS op ON op.outcrop_id = io.outcrop_id
		JOIN plss AS p ON p.plss_id = op.plss_id
		WHERE p.geom IS NOT NULL
	) UNION ALL (
		-- Well PLSS
		SELECT iw.inventory_id, p.geom
		FROM inventory_well AS iw
		JOIN well_plss AS wp ON wp.well_id = iw.well_id
		JOIN plss AS p ON p.plss_id = wp.plss_id
		WHERE p.geom IS NOT NULL
	) UNION ALL (
		-- Borehole Quadrangle
		SELECT ib.inventory_id, q.geom
		FROM inventory_borehole AS ib
		JOIN borehole_quadrangle AS bq ON bq.borehole_id = ib.borehole_id
		JOIN quadrangle AS q ON q.quadrangle_id = bq.quadrangle_id
		WHERE q.geom IS NOT NULL
	) UNION ALL (
		-- Outcrop Quadrangle
		SELECT io.inventory_id, q.geom
		FROM inventory_outcrop AS io
		JOIN outcrop_quadrangle AS oq ON oq.outcrop_id = io.outcrop_id
		JOIN quadrangle AS q ON q.quadrangle_id = oq.quadrangle_id
		WHERE q.geom IS NOT NULL
	) UNION ALL (
		-- Well Quadrangle
		SELECT iw.inventory_id, q.geom
		FROM inventory_well AS iw
		JOIN well_quadrangle AS wq ON wq.well_id = iw.well_id
		JOIN quadrangle AS q ON q.quadrangle_id = wq.quadrangle_id
		WHERE q.geom IS NOT NULL
	) UNION ALL (
		-- Borehole Mining District
		SELECT ib.inventory_id, md.geom
		FROM inventory_borehole AS ib
		JOIN borehole_mining_district AS bmd ON bmd.borehole_id = ib.borehole_id
		JOIN mining_district AS md ON md.mining_district_id = bmd.mining_district_id
		WHERE md.geom IS NOT NULL
	) UNION ALL (
		-- Outcrop Mining District
		SELECT io.inventory_id, md.geom
		FROM inventory_outcrop AS io
		JOIN outcrop_mining_district AS omd ON omd.outcrop_id = io.outcrop_id
		JOIN mining_district AS md ON md.mining_district_id = omd.mining_district_id
		WHERE md.geom IS NOT NULL
	)
);


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


CREATE OR REPLACE VIEW borehole_geom AS (
	(SELECT bp.borehole_id, po.geom
	FROM borehole_point AS bp
	JOIN point AS po ON po.point_id = bp.point_id
	WHERE po.geom IS NOT NULL)

	UNION ALL

	(SELECT bq.borehole_id, qu.geom
	FROM borehole_quadrangle AS bq
	JOIN quadrangle AS qu ON qu.quadrangle_id = bq.quadrangle_id
	WHERE qu.geom IS NOT NULL)
	
	UNION ALL
	
	(SELECT bm.borehole_id, md.geom
	FROM borehole_mining_district AS bm
	JOIN mining_district AS md ON md.mining_district_id = bm.mining_district_id
	WHERE md.geom IS NOT NULL)
);


CREATE OR REPLACE VIEW well_geom AS (
	(
		-- Point
		SELECT wp.well_id, po.geom
		FROM well_point AS wp
		JOIN point AS po ON po.point_id = wp.point_id
		WHERE po.geom IS NOT NULL
	) UNION ALL (
		-- Place
		SELECT wp.well_id, pl.geom
		FROM well_place AS wp
		JOIN place AS pl ON pl.place_id = wp.place_id
		WHERE pl.geom IS NOT NULL
	) UNION ALL (
		-- PLSS
		SELECT wp.well_id, pl.geom
		FROM well_plss AS wp
		JOIN plss AS pl ON pl.plss_id = wp.plss_id
		WHERE pl.geom IS NOT NULL
	) UNION ALL (
		-- Quadrangle
		SELECT wq.well_id, qu.geom
		FROM well_quadrangle AS wq
		JOIN quadrangle AS qu ON qu.quadrangle_id = wq.quadrangle_id
		WHERE qu.geom IS NOT NULL
	)
);


CREATE OR REPLACE VIEW outcrop_geom AS (
	(SELECT op.outcrop_id, po.geom
	FROM outcrop_point AS op
	JOIN point AS po ON po.point_id = op.point_id
	WHERE po.geom IS NOT NULL)
	
	UNION ALL
	
	(SELECT op.outcrop_id, pl.geom
	FROM outcrop_place AS op
	JOIN place AS pl ON pl.place_id = op.place_id
	WHERE pl.geom IS NOT NULL)
	
	UNION ALL
	
	(SELECT op.outcrop_id, pl.geom
	FROM outcrop_plss AS op
	JOIN plss AS pl ON pl.plss_id = op.plss_id
	WHERE pl.geom IS NOT NULL)
	
	UNION ALL
	
	(SELECT oq.outcrop_id, qu.geom
	FROM outcrop_quadrangle AS oq
	JOIN quadrangle AS qu ON qu.quadrangle_id = oq.quadrangle_id
	WHERE qu.geom IS NOT NULL)
	
	UNION ALL
	
	(SELECT om.outcrop_id, md.geom
	FROM outcrop_mining_district AS om
	JOIN mining_district AS md ON md.mining_district_id = om.mining_district_id
	WHERE md.geom IS NOT NULL)
);


CREATE OR REPLACE VIEW well_geom_point AS (
	(
		-- Point
		SELECT wp.well_id, po.geom
		FROM well_point AS wp
		JOIN point AS po ON po.point_id = wp.point_id
		WHERE po.geom IS NOT NULL
	) UNION ALL (
		-- Place
		SELECT wp.well_id, pl.geom
		FROM well_place AS wp
		JOIN place AS pl ON pl.place_id = wp.place_id
		WHERE pl.geom IS NOT NULL
	)
);


CREATE OR REPLACE VIEW inventory_mining_district AS (
	SELECT inventory_id, mining_district_id
	FROM (
		SELECT iw.inventory_id, q.mining_district_id
		FROM (
			SELECT wg.well_id, md.mining_district_id
			FROM well_geom AS wg
			JOIN mining_district AS md ON ST_Intersects(wg.geom, md.geom)
		) AS q
		JOIN inventory_well AS iw ON iw.well_id = q.well_id

		UNION ALL

		SELECT ib.inventory_id, q.mining_district_id
		FROM (
			SELECT bg.borehole_id, md.mining_district_id
			FROM borehole_geom AS bg
			JOIN mining_district AS md ON ST_Intersects(bg.geom, md.geom)
		) AS q
		JOIN inventory_borehole AS ib ON ib.borehole_id = q.borehole_id

		UNION ALL

		SELECT io.inventory_id, q.mining_district_id
		FROM (
			SELECT og.outcrop_id, md.mining_district_id
			FROM outcrop_geom AS og
			JOIN mining_district AS md ON ST_Intersects(og.geom, md.geom)
		) AS q
		JOIN inventory_outcrop AS io ON io.outcrop_id = q.outcrop_id
	) AS q
);
