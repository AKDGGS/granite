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


CREATE OR REPLACE VIEW inventory_location AS (
	SELECT iv.inventory_id, (
		SELECT STRING_AGG(name, '/') FROM (
			WITH RECURSIVE t AS (
				(
					SELECT 0 AS level, co.container_id,
						co.parent_container_id, co.name
					FROM inventory_container AS ic
					JOIN container AS co ON co.container_id = ic.container_id
					WHERE ic.inventory_id = iv.inventory_id
					ORDER BY log_date DESC
					LIMIT 1
				) UNION ALL (
					SELECT level+1, c.container_id,
						c.parent_container_id, c.name
					FROM container AS c
					JOIN t AS t ON c.container_id = t.parent_container_id)
			) SELECT name FROM t ORDER BY level DESC
		) AS tree
	) AS location
	FROM inventory AS iv
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

