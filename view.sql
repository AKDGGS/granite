SET ROLE 'gmc';
SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;


CREATE OR REPLACE VIEW inventory_geom AS (
	SELECT ib.inventory_id, p.geom
	FROM inventory_borehole AS ib
	JOIN borehole_point AS bp ON bp.borehole_id = ib.borehole_id
	JOIN point AS p ON p.point_id = bp.point_id

	UNION ALL

	SELECT iw.inventory_id, p.geom
	FROM inventory_well AS iw
	JOIN well_point AS wp ON wp.well_id = iw.well_id
	JOIN point AS p ON p.point_id = wp.point_id

	UNION ALL

	SELECT io.inventory_id, p.geom
	FROM inventory_outcrop AS io
	JOIN outcrop_point AS op ON op.outcrop_id = io.outcrop_id
	JOIN point AS p ON p.point_id = op.point_id

	UNION ALL

	SELECT iw.inventory_id, p.geom
	FROM inventory_well AS iw
	JOIN well_place AS wp ON wp.well_id = iw.well_id
	JOIN place AS p ON p.place_id = wp.place_id

	UNION ALL

	SELECT io.inventory_id, p.geom
	FROM inventory_outcrop AS io
	JOIN outcrop_place AS op ON op.outcrop_id = io.outcrop_id
	JOIN place AS p ON p.place_id = op.place_id
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
