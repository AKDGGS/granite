DROP VIEW IF EXISTS inventory_prospect, inventory_shotline, inventory_shotline_minmax;

DROP MATERIALIZED VIEW IF EXISTS borehole_geog, energy_district_geog, gmc_region_geog, inventory_geog, inventory_mining_district, inventory_quadrangle, inventory_search, mining_district_geog, outcrop_geog, quadrangle_geog, shotline_geog, shotpoint_geog, well_geog;

ALTER TABLE plss ALTER COLUMN geog SET DATA TYPE geography;

WITH t AS (
	SELECT plss_id, ((geom).geom)::GEOGRAPHY AS geog
	FROM (
		SELECT plss_id, ST_DUMP(geog::GEOMETRY) AS geom
		FROM plss
		WHERE ST_IsCollection(geog::GEOMETRY)
			AND ST_NumGeometries(geog::GEOMETRY) = 1
	) AS q
	WHERE (geom).path='{1}'
)
UPDATE plss AS p SET geog = t.geog
FROM t WHERE p.plss_id = t.plss_id;

ALTER TABLE quadrangle ALTER COLUMN geog SET DATA TYPE geography;

WITH t AS (
	SELECT quadrangle_id, ((geom).geom)::GEOGRAPHY AS geog
	FROM (
		SELECT quadrangle_id, ST_DUMP(geog::GEOMETRY) AS geom
		FROM quadrangle
		WHERE ST_IsCollection(geog::GEOMETRY)
			AND ST_NumGeometries(geog::GEOMETRY) = 1
	) AS q
	WHERE (geom).path='{1}'
)
UPDATE quadrangle AS q SET geog = t.geog
FROM t WHERE q.quadrangle_id = t.quadrangle_id;
