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
