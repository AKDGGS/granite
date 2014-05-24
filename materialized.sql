SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;


-- Materialized spatial view for inventory
DROP MATERIALIZED VIEW IF EXISTS inventory_geog;

CREATE MATERIALIZED VIEW inventory_geog AS (
	-- Boreholes
	SELECT DISTINCT ON (inventory_id, borehole_id) inventory_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM ((
		-- Borehole Point
		SELECT ib.inventory_id, ib.borehole_id, p.geog
		FROM inventory_borehole AS ib
		JOIN borehole_point AS bp ON bp.borehole_id = ib.borehole_id
		JOIN point AS p ON p.point_id = bp.point_id
		WHERE p.geog IS NOT NULL

		) UNION ALL (

		-- Borehole Quadrangle
		SELECT ib.inventory_id, ib.borehole_id, q.geog
		FROM inventory_borehole AS ib
		JOIN borehole_quadrangle AS bq ON bq.borehole_id = ib.borehole_id
		JOIN quadrangle AS q ON q.quadrangle_id = bq.quadrangle_id
		WHERE q.geog IS NOT NULL
		ORDER BY q.scale ASC

		) UNION ALL (

		-- Borehole Mining District
		SELECT ib.inventory_id, ib.borehole_id, md.geog
		FROM inventory_borehole AS ib
		JOIN borehole_mining_district AS bmd ON
			bmd.borehole_id = ib.borehole_id
		JOIN mining_district AS md ON
			md.mining_district_id = bmd.mining_district_id
		WHERE md.geog IS NOT NULL
	)) AS q

	UNION ALL

	-- Outcrops
	SELECT DISTINCT ON (inventory_id, outcrop_id) inventory_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM ((
		-- Outcrop Point
		SELECT io.inventory_id, io.outcrop_id, p.geog
		FROM inventory_outcrop AS io
		JOIN outcrop_point AS op ON op.outcrop_id = io.outcrop_id
		JOIN point AS p ON p.point_id = op.point_id
		WHERE p.geog IS NOT NULL

		) UNION ALL (

		-- Outcrop Place
		SELECT io.inventory_id, io.outcrop_id, p.geog
		FROM inventory_outcrop AS io
		JOIN outcrop_place AS op ON op.outcrop_id = io.outcrop_id
		JOIN place AS p ON p.place_id = op.place_id
		WHERE p.geog IS NOT NULL

		) UNION ALL (

		-- Outcrop PLSS
		SELECT io.inventory_id, io.outcrop_id, p.geog
		FROM inventory_outcrop AS io
		JOIN outcrop_plss AS op ON op.outcrop_id = io.outcrop_id
		JOIN plss AS p ON p.plss_id = op.plss_id
		WHERE p.geog IS NOT NULL

		) UNION ALL (

		-- Outcrop Quadrangle
		SELECT io.inventory_id, io.outcrop_id, q.geog
		FROM inventory_outcrop AS io
		JOIN outcrop_quadrangle AS oq ON oq.outcrop_id = io.outcrop_id
		JOIN quadrangle AS q ON q.quadrangle_id = oq.quadrangle_id
		WHERE q.geog IS NOT NULL
		ORDER BY q.scale ASC

		) UNION ALL (

		-- Outcrop Mining District
		SELECT io.inventory_id, io.outcrop_id, md.geog
		FROM inventory_outcrop AS io
		JOIN outcrop_mining_district AS omd ON
			omd.outcrop_id = io.outcrop_id
		JOIN mining_district AS md ON
			md.mining_district_id = omd.mining_district_id
		WHERE md.geog IS NOT NULL
	)) AS q

	UNION ALL

	SELECT DISTINCT ON (inventory_id, well_id) inventory_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM ((
		-- Well Point
		SELECT iw.inventory_id, iw.well_id, p.geog
		FROM inventory_well AS iw
		JOIN well_point AS wp ON wp.well_id = iw.well_id
		JOIN point AS p ON p.point_id = wp.point_id
		WHERE p.geog IS NOT NULL

		) UNION ALL (

		-- Well Place
		SELECT iw.inventory_id, iw.well_id, p.geog
		FROM inventory_well AS iw
		JOIN well_place AS wp ON wp.well_id = iw.well_id
		JOIN place AS p ON p.place_id = wp.place_id
		WHERE p.geog IS NOT NULL

		) UNION ALL (

		-- Well PLSS
		SELECT iw.inventory_id, iw.well_id, p.geog
		FROM inventory_well AS iw
		JOIN well_plss AS wp ON wp.well_id = iw.well_id
		JOIN plss AS p ON p.plss_id = wp.plss_id
		WHERE p.geog IS NOT NULL

		) UNION ALL (

		-- Well Quadrangle
		SELECT iw.inventory_id, iw.well_id, q.geog
		FROM inventory_well AS iw
		JOIN well_quadrangle AS wq ON wq.well_id = iw.well_id
		JOIN quadrangle AS q ON q.quadrangle_id = wq.quadrangle_id
		WHERE q.geog IS NOT NULL
		ORDER BY q.scale ASC	
	)) AS q

	UNION ALL

	-- Handle shotline(s) for inventory
	SELECT DISTINCT inventory_id,
		ST_Makeline(geog::geometry)::geography AS geog
	FROM (
		SELECT isp.inventory_id, sp.shotline_id, p.geog
		FROM inventory_shotpoint AS isp
		JOIN shotpoint AS sp ON sp.shotpoint_id = isp.shotpoint_id
		JOIN shotpoint_point AS spp ON spp.shotpoint_id = sp.shotpoint_id
		JOIN point AS p ON p.point_id = spp.point_id
		ORDER BY isp.inventory_id, sp.shotline_id, sp.shotpoint_number
	) AS q
	GROUP BY inventory_id, shotline_id
);

CREATE INDEX inventory_geog_inventory_id_idx ON inventory_geog(inventory_id);

CREATE INDEX inventory_geog_geog_idx ON inventory_geog USING GIST(geog);


-- Materialized spatial view for well
DROP MATERIALIZED VIEW IF EXISTS well_geog;

CREATE MATERIALIZED VIEW well_geog AS (
	SELECT DISTINCT ON (well_id) well_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM (
		-- Point
		SELECT wp.well_id, po.geog
		FROM well_point AS wp
		JOIN point AS po ON po.point_id = wp.point_id
		WHERE po.geog IS NOT NULL
	
		UNION ALL
	
		-- Place
		SELECT wp.well_id, pl.geog
		FROM well_place AS wp
		JOIN place AS pl ON pl.place_id = wp.place_id
		WHERE pl.geog IS NOT NULL
	
		UNION ALL
	
		-- PLSS
		SELECT wp.well_id, pl.geog
		FROM well_plss AS wp
		JOIN plss AS pl ON pl.plss_id = wp.plss_id
		WHERE pl.geog IS NOT NULL
	
		UNION ALL
	
		-- Quadrangle
		SELECT wq.well_id, qu.geog
		FROM well_quadrangle AS wq
		JOIN quadrangle AS qu ON qu.quadrangle_id = wq.quadrangle_id
		WHERE qu.geog IS NOT NULL
	) AS v
);

CREATE INDEX well_geog_well_id_idx ON well_geog(well_id);

CREATE INDEX well_geog_geog_idx ON well_geog USING GIST(geog);


-- Materialized spatial view for borehole
DROP MATERIALIZED VIEW IF EXISTS borehole_geog;

CREATE MATERIALIZED VIEW borehole_geog AS (
	SELECT DISTINCT ON (borehole_id) borehole_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM (
		-- Point
		SELECT bp.borehole_id, po.geog
		FROM borehole_point AS bp
		JOIN point AS po ON po.point_id = bp.point_id
		WHERE po.geog IS NOT NULL
	
		UNION ALL
	
		-- Quadrangle
		SELECT bq.borehole_id, qu.geog
		FROM borehole_quadrangle AS bq
		JOIN quadrangle AS qu ON
			qu.quadrangle_id = bq.quadrangle_id
		WHERE qu.geog IS NOT NULL
	
		UNION ALL
	
		-- Mining District
		SELECT bm.borehole_id, md.geog
		FROM borehole_mining_district AS bm
		JOIN mining_district AS md ON
			md.mining_district_id = bm.mining_district_id
		WHERE md.geog IS NOT NULL
	
		UNION ALL
	
		-- UTM
		SELECT bu.borehole_id, u.geog
		FROM borehole_utm AS bu
		JOIN utm AS u ON u.utm_id = bu.utm_id
		WHERE u.geog IS NOT NULL
	) AS v
);

CREATE INDEX borehole_geog_borehole_id_idx ON borehole_geog(borehole_id);

CREATE INDEX borehole_geog_geog_idx ON borehole_geog USING GIST(geog);


-- Materialized spatial view for outcrop
DROP MATERIALIZED VIEW IF EXISTS outcrop_geog;

CREATE MATERIALIZED VIEW outcrop_geog AS (
	SELECT DISTINCT ON (outcrop_id) outcrop_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM (
		-- Point
		SELECT op.outcrop_id, po.geog
		FROM outcrop_point AS op
		JOIN point AS po ON po.point_id = op.point_id
		WHERE po.geog IS NOT NULL

		UNION ALL

		-- Place
		SELECT op.outcrop_id, pl.geog
		FROM outcrop_place AS op
		JOIN place AS pl ON pl.place_id = op.place_id
		WHERE pl.geog IS NOT NULL

		UNION ALL

		-- PLSS
		SELECT op.outcrop_id, pl.geog
		FROM outcrop_plss AS op
		JOIN plss AS pl ON pl.plss_id = op.plss_id
		WHERE pl.geog IS NOT NULL

		UNION ALL

		-- Quadrangle
		SELECT oq.outcrop_id, qu.geog
		FROM outcrop_quadrangle AS oq
		JOIN quadrangle AS qu ON qu.quadrangle_id = oq.quadrangle_id
		WHERE qu.geog IS NOT NULL

		UNION ALL

		-- Mining District
		SELECT om.outcrop_id, md.geog
		FROM outcrop_mining_district AS om
		JOIN mining_district AS md ON md.mining_district_id = om.mining_district_id
		WHERE md.geog IS NOT NULL

		UNION ALL

		-- UTM
		SELECT ou.outcrop_id, u.geog
		FROM outcrop_utm AS ou
		JOIN utm AS u ON u.utm_id = ou.utm_id
		WHERE u.geog IS NOT NULL
	) AS v
);

CREATE INDEX outcrop_geog_outcrop_id_idx ON outcrop_geog(outcrop_id);

CREATE INDEX outcrop_geog_geog_idx ON outcrop_geog USING GIST(geog);


-- Materialized spatial view for shotpoint
DROP MATERIALIZED VIEW IF EXISTS shotpoint_geog;

CREATE MATERIALIZED VIEW shotpoint_geog AS (
	SELECT DISTINCT ON (shotpoint_id) shotpoint_id,
		geog
	FROM (
		-- Point
		SELECT sp.shotpoint_id, po.geog
		FROM shotpoint_point AS sp
		JOIN point AS po ON po.point_id = sp.point_id
		WHERE po.geog IS NOT NULL

		UNION ALL

		-- Place
		SELECT sp.shotpoint_id, pl.geog
		FROM shotpoint_place AS sp
		JOIN place AS pl ON pl.place_id = sp.place_id
		WHERE pl.geog IS NOT NULL
	) AS v
);

CREATE INDEX shotpoint_geog_shotpoint_id_idx ON shotpoint_geog(shotpoint_id);

CREATE INDEX shotpoint_geog_geog_idx ON shotpoint_geog USING GIST(geog);


-- Materialized spatial view for quadrangle
DROP MATERIALIZED VIEW IF EXISTS quadrangle_geog;

CREATE MATERIALIZED VIEW quadrangle_geog AS (
	SELECT quadrangle_id, scale,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM quadrangle
);

CREATE INDEX quadrangle_geog_quadrangle_id_idx ON quadrangle_geog(quadrangle_id);

CREATE INDEX quadrangle_geog_scale_idx ON quadrangle_geog(scale);

CREATE INDEX quadrangle_geog_geom_idx ON quadrangle_geog USING GIST(geog);


-- Materialized spatial view for mining_district
DROP MATERIALIZED VIEW IF EXISTS mining_district_geog;

CREATE MATERIALIZED VIEW mining_district_geog AS (
	SELECT mining_district_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM mining_district
);

CREATE INDEX mining_district_geog_mining_district_id_idx ON mining_district_geog(mining_district_id);

CREATE INDEX mining_district_geog_geom_idx ON mining_district_geog USING GIST(geog);


-- Materialized spatial view for energy_district
DROP MATERIALIZED VIEW IF EXISTS energy_district_geog;

CREATE MATERIALIZED VIEW energy_district_geog AS (
	SELECT energy_district_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM energy_district
);

CREATE INDEX energy_district_geog_energy_district_id_idx ON energy_district_geog(energy_district_id);

CREATE INDEX energy_district_geog_geom_idx ON energy_district_geog USING GIST(geog);


-- Materialized spatial view for gmc_region
DROP MATERIALIZED VIEW IF EXISTS gmc_region_geog;

CREATE MATERIALIZED VIEW gmc_region_geog AS (
	SELECT gmc_region_id,
		ST_Simplify(geog::geometry, 0.01)::geography AS geog
	FROM gmc_region
);

CREATE INDEX gmc_region_geog_gmc_region_id_idx ON gmc_region_geog(gmc_region_id);

CREATE INDEX gmc_region_geog_geom_idx ON gmc_region_geog USING GIST(geog);
