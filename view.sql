SET ROLE 'gmc';
SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;


CREATE OR REPLACE VIEW inventory_point AS (
	SELECT ib.inventory_id, p.geom
	FROM inventory_borehole AS ib
	JOIN borehole_point AS bp ON bp.borehole_id = ib.borehole_id
	JOIN point AS p ON p.point_id = bp.point_id
	WHERE p.geom IS NOT NULL

	UNION ALL

	SELECT iw.inventory_id, p.geom
	FROM inventory_well AS iw
	JOIN well_point AS wp ON wp.well_id = iw.well_id
	JOIN point AS p ON p.point_id = wp.point_id
	WHERE p.geom IS NOT NULL

	UNION ALL

	SELECT io.inventory_id, p.geom
	FROM inventory_outcrop AS io
	JOIN outcrop_point AS op ON op.outcrop_id = io.outcrop_id
	JOIN point AS p ON p.point_id = op.point_id
	WHERE p.geom IS NOT NULL

	UNION ALL

	SELECT iw.inventory_id, p.geom
	FROM inventory_well AS iw
	JOIN well_place AS wp ON wp.well_id = iw.well_id
	JOIN place AS p ON p.place_id = wp.place_id
	WHERE p.geom IS NOT NULL

	UNION ALL

	SELECT io.inventory_id, p.geom
	FROM inventory_outcrop AS io
	JOIN outcrop_place AS op ON op.outcrop_id = io.outcrop_id
	JOIN place AS p ON p.place_id = op.place_id
	WHERE p.geom IS NOT NULL
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
	SELECT bp.borehole_id, po.geom
	FROM borehole_point AS bp
	JOIN point AS po ON po.point_id = bp.point_id
	WHERE po.geom IS NOT NULL

	UNION ALL

	SELECT bq.borehole_id, qu.geom
	FROM borehole_quadrangle AS bq
	JOIN quadrangle AS qu ON qu.quadrangle_id = bq.quadrangle_id
	WHERE qu.geom IS NOT NULL
	
	UNION ALL
	
	SELECT bm.borehole_id, md.geom
	FROM borehole_mining_district AS bm
	JOIN mining_district AS md ON md.mining_district_id = bm.mining_district_id
	WHERE md.geom IS NOT NULL
);


CREATE OR REPLACE VIEW well_geom AS (
	SELECT wp.well_id, po.geom
	FROM well_point AS wp
	JOIN point AS po ON po.point_id = wp.well_id
	WHERE po.geom IS NOT NULL
	
	UNION ALL
	
	SELECT wp.well_id, pl.geom
	FROM well_place AS wp
	JOIN place AS pl ON pl.place_id = wp.place_id
	WHERE pl.geom IS NOT NULL
	
	UNION ALL
	
	SELECT wp.well_id, pl.geom
	FROM well_plss AS wp
	JOIN plss AS pl ON pl.plss_id = wp.plss_id
	WHERE pl.geom IS NOT NULL
	
	UNION ALL
	
	SELECT wq.well_id, qu.geom
	FROM well_quadrangle AS wq
	JOIN quadrangle AS qu ON qu.quadrangle_id = wq.quadrangle_id
	WHERE qu.geom IS NOT NULL
);


CREATE OR REPLACE VIEW outcrop_geom AS (
	SELECT op.outcrop_id, po.geom
	FROM outcrop_point AS op
	JOIN point AS po ON po.point_id = op.point_id
	WHERE po.geom IS NOT NULL
	
	UNION ALL
	
	SELECT op.outcrop_id, pl.geom
	FROM outcrop_place AS op
	JOIN place AS pl ON pl.place_id = op.place_id
	WHERE pl.geom IS NOT NULL
	
	UNION ALL
	
	SELECT op.outcrop_id, pl.geom
	FROM outcrop_plss AS op
	JOIN plss AS pl ON pl.plss_id = op.plss_id
	WHERE pl.geom IS NOT NULL
	
	UNION ALL
	
	SELECT oq.outcrop_id, qu.geom
	FROM outcrop_quadrangle AS oq
	JOIN quadrangle AS qu ON qu.quadrangle_id = oq.quadrangle_id
	WHERE qu.geom IS NOT NULL
	
	UNION ALL
	
	SELECT om.outcrop_id, md.geom
	FROM outcrop_mining_district AS om
	JOIN mining_district AS md ON md.mining_district_id = om.mining_district_id
	WHERE md.geom IS NOT NULL
);
