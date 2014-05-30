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


-- Temporary views for doing quality checking against
-- access data
DROP VIEW IF EXISTS random_borehole;
CREATE VIEW random_borehole AS
SELECT 	
	i.temp_source,
	col.name AS collection,
	c.path_cache,
	i.barcode,
	ps.name || ': ' || bh.name AS borehole,
	kwd.name AS form, 
	i.remark,
	n.note AS curator_remark,
	ps.ardf_number AS ardf,
	ST_Y(pt.geog::geometry) AS latitude, 
	ST_X(pt.geog::geometry) AS longitude, 
	org.name AS organization, 
	n2.note AS point_source,
	d.width || 'x' || d.height || 'x' || d.depth AS box_type, 
	i.tray,
	cm.name AS material,
	i.box_number,
	i.set_number,
	i.interval_top AS top,
	i.interval_bottom AS bottom,
	i.interval_unit_id,
	i.core_number AS core,
	cd.core_diameter AS diameter,
	i.skeleton,
	i.can_publish,
	i.modified_date,
	i.active,
	i.weight AS weight,
	i.weight_unit_id,
	iq.remark AS quality_remark,
	iq.needs_detail,
	iq.unsorted,
	iq.possible_radiation,
	iq.damaged,
	iq.box_damaged,
	iq.missing,
	iq.data_missing,
	iq.barcode_missing,
	iq.label_obscured,
	iq.insufficient_material,
--	u.url AS ardf,
	i.temp_original_id AS access_id

FROM inventory i 
LEFT JOIN container c ON i.container_id = c.container_id
LEFT JOIN collection col ON i.collection_id = col.collection_id
-- inventory keywords
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ik.inventory_id)
		ik.inventory_id, k.name
	FROM inventory_keyword ik 
	LEFT JOIN keyword k ON ik.keyword_id = k.keyword_id
	LEFT JOIN keyword_group kg ON k.keyword_group_id = kg.keyword_group_id
	WHERE kg.name = 'form'
	ORDER BY ik.inventory_id, k.name DESC
) AS kwd ON kwd.inventory_id = i.inventory_id

LEFT JOIN core_diameter cd ON i.core_diameter_id = cd.core_diameter_id
LEFT JOIN inventory_collector ic ON i.inventory_id = ic.inventory_id
LEFT JOIN person p ON ic.collector_id = p.person_id
LEFT JOIN dimension d ON i.dimension_id = d.dimension_id
LEFT JOIN container_material cm ON i.container_material_id = cm.container_material_id
LEFT JOIN inventory_quality iq ON i.inventory_id = iq.inventory_id
-- inventory notes
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ivn.inventory_id)
		ivn.inventory_id, n.note
	FROM inventory_note AS ivn
	LEFT JOIN note AS n ON ivn.note_id = n.note_id
	LEFT JOIN note_type AS nt ON n.note_type_id = nt.note_type_id
	WHERE nt.name = 'curator'
	ORDER BY ivn.inventory_id, n.note_date DESC
) AS n ON n.inventory_id = i.inventory_id
	
LEFT JOIN inventory_borehole ib ON i.inventory_id = ib.inventory_id
LEFT JOIN borehole bh ON ib.borehole_id = bh.borehole_id
LEFT JOIN prospect ps ON bh.prospect_id = ps.prospect_id
LEFT JOIN borehole_point bp ON bh.borehole_id = bp.borehole_id
LEFT JOIN point pt ON bp.point_id = pt.point_id
LEFT JOIN borehole_organization bo ON bh.borehole_id = bo.borehole_id
LEFT JOIN organization org ON bo.organization_id = org.organization_id
-- ardf urls ???
LEFT JOIN borehole_url bu ON bh.borehole_id = bu.borehole_id
LEFT JOIN url u ON bu.url_id = u.url_id
-- borehole notes
LEFT OUTER JOIN (
	SELECT DISTINCT ON (bn.borehole_id)
		bn.borehole_id, nte.note
	FROM borehole_note bn
	LEFT JOIN note nte ON bn.note_id = nte.note_id
	LEFT JOIN note_type nty ON nte.note_type_id = nty.note_type_id
	WHERE nty.name = 'location'
	ORDER BY bn.borehole_id, nte.note_date DESC
) AS n2 ON n2.borehole_id = bh.borehole_id
	
WHERE 	position( 'hardrock' in i.temp_source) > 0 AND
	i.inventory_id IN 
		(SELECT inventory_id FROM inventory
		WHERE position( 'hardrock' in temp_source) > 0
		ORDER BY random() LIMIT 50)
ORDER BY col.name, ps.name
LIMIT 50;


DROP VIEW IF EXISTS random_outcrop;
CREATE VIEW random_outcrop AS
SELECT 	
	i.temp_source,
	col.name AS collection,
	c.path_cache,
	i.barcode,
	i.alt_barcode,
	i.sample_number,
	i.alt_sample_number,
	otc.name AS field_station,
	otc.outcrop_number,
	p.last || ', ' || p.first AS collector,
	kwd.name AS form, 
	i.remark,
	n.note AS curator_remark,
	ST_Y(pt.geog::geometry) AS latitude, 
	ST_X(pt.geog::geometry) AS longitude, 
	org.name AS organization, 
	n2.note AS random_location_remarks,
	d.width || 'x' || d.height || 'x' || d.depth AS post_box_type, 
	i.tray,
	cm.name AS material,
	i.box_number,
	i.set_number,
	i.can_publish,
	i.received_date,
	i.entered_date,
	i.modified_date,
	i.active,
	iq.remark AS quality_remark,
	iq.needs_detail,
	iq.unsorted,
	iq.possible_radiation,
	iq.damaged,
	iq.box_damaged,
	iq.missing,
	iq.data_missing,
	iq.barcode_missing,
	iq.label_obscured,
	iq.insufficient_material,
	i.temp_original_id AS access_id

FROM inventory i 
LEFT JOIN container c ON i.container_id = c.container_id
LEFT JOIN collection col ON i.collection_id = col.collection_id
-- inventory keywords
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ik.inventory_id)
		ik.inventory_id, k.name
	FROM inventory_keyword ik 
	LEFT JOIN keyword k ON ik.keyword_id = k.keyword_id
	LEFT JOIN keyword_group kg ON k.keyword_group_id = kg.keyword_group_id
	WHERE kg.name = 'form'
	ORDER BY ik.inventory_id, k.name DESC
) AS kwd ON kwd.inventory_id = i.inventory_id

LEFT JOIN inventory_collector ic ON i.inventory_id = ic.inventory_id
LEFT JOIN person p ON ic.collector_id = p.person_id
LEFT JOIN dimension d ON i.dimension_id = d.dimension_id
LEFT JOIN container_material cm ON i.container_material_id = cm.container_material_id
LEFT JOIN inventory_quality iq ON i.inventory_id = iq.inventory_id
-- inventory notes
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ivn.inventory_id)
		ivn.inventory_id, n.note
	FROM inventory_note AS ivn
	LEFT JOIN note AS n ON ivn.note_id = n.note_id
	LEFT JOIN note_type AS nt ON n.note_type_id = nt.note_type_id
	WHERE nt.name = 'curator'
	ORDER BY ivn.inventory_id, n.note_date DESC
) AS n ON n.inventory_id = i.inventory_id
	
LEFT JOIN inventory_outcrop io ON i.inventory_id = io.inventory_id
LEFT JOIN outcrop otc ON io.outcrop_id = otc.outcrop_id
LEFT JOIN outcrop_point op ON otc.outcrop_id = op.outcrop_id
LEFT JOIN point pt ON op.point_id = pt.point_id
LEFT JOIN outcrop_organization oo ON otc.outcrop_id = oo.outcrop_id
LEFT JOIN organization org ON oo.organization_id = org.organization_id
-- outcrop notes
LEFT OUTER JOIN (
	SELECT DISTINCT ON (otn.outcrop_id)
		otn.outcrop_id, nte.note
	FROM outcrop_note otn
	LEFT JOIN note nte ON otn.note_id = nte.note_id
	LEFT JOIN note_type nty ON nte.note_type_id = nty.note_type_id
	WHERE nty.name = 'location'
	ORDER BY otn.outcrop_id, nte.note_date DESC
) AS n2 ON n2.outcrop_id = otc.outcrop_id
	
WHERE 	position( 'outcrop' in i.temp_source ) > 0 AND
	i.inventory_id IN 
		(SELECT inventory_id FROM inventory
		WHERE position( 'outcrop' in temp_source ) > 0
		ORDER BY random() LIMIT 50)
ORDER BY i.temp_source, col.name, otc.name
LIMIT 50;


DROP VIEW IF EXISTS random_seismic;
CREATE VIEW random_seismic AS
SELECT 	
	i.temp_source,
	col.name AS collection,
	c.path_cache,
	i.barcode,
	kwd.name AS form, 
	i.remark,
	n.note AS curator_remark,
	sl.name || ': ' || sp.shotpoint_number AS shotpoint,
	ST_Y(pt.geog::geometry) AS latitude, 
	ST_X(pt.geog::geometry) AS longitude, 
	d.width || 'x' || d.height || 'x' || d.depth AS box_type, 
	i.tray,
	cm.name AS material,
	i.box_number,
	i.set_number,
	i.can_publish,
	i.modified_date,
	i.active,
	iq.remark AS quality_remark,
	iq.needs_detail,
	iq.unsorted,
	iq.possible_radiation,
	iq.damaged,
	iq.box_damaged,
	iq.missing,
	iq.data_missing,
	iq.barcode_missing,
	iq.label_obscured,
	iq.insufficient_material,
	i.temp_original_id AS access_id

FROM inventory i 
LEFT JOIN container c ON i.container_id = c.container_id
LEFT JOIN collection col ON i.collection_id = col.collection_id
-- inventory keywords
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ik.inventory_id)
		ik.inventory_id, k.name
	FROM inventory_keyword ik 
	LEFT JOIN keyword k ON ik.keyword_id = k.keyword_id
	LEFT JOIN keyword_group kg ON k.keyword_group_id = kg.keyword_group_id
	WHERE kg.name = 'form'
	ORDER BY ik.inventory_id, k.name DESC
) AS kwd ON kwd.inventory_id = i.inventory_id

LEFT JOIN core_diameter cd ON i.core_diameter_id = cd.core_diameter_id
LEFT JOIN inventory_collector ic ON i.inventory_id = ic.inventory_id
LEFT JOIN person p ON ic.collector_id = p.person_id
LEFT JOIN dimension d ON i.dimension_id = d.dimension_id
LEFT JOIN container_material cm ON i.container_material_id = cm.container_material_id
LEFT JOIN inventory_quality iq ON i.inventory_id = iq.inventory_id
-- inventory notes
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ivn.inventory_id)
		ivn.inventory_id, n.note
	FROM inventory_note AS ivn
	LEFT JOIN note AS n ON ivn.note_id = n.note_id
	LEFT JOIN note_type AS nt ON n.note_type_id = nt.note_type_id
	WHERE nt.name = 'curator'
	ORDER BY ivn.inventory_id, n.note_date DESC
) AS n ON n.inventory_id = i.inventory_id
	
LEFT JOIN inventory_shotpoint isp ON i.inventory_id = isp.inventory_id
LEFT JOIN shotpoint sp ON isp.shotpoint_id = sp.shotpoint_id
LEFT JOIN shotline sl ON sp.shotline_id = sl.shotline_id
LEFT JOIN shotpoint_point spp ON sp.shotpoint_id = spp.shotpoint_id
LEFT JOIN point pt ON spp.point_id = pt.point_id
	
WHERE 	position( 'seismic' in i.temp_source ) > 0 AND
	i.inventory_id IN 
		(SELECT inventory_id FROM inventory
		WHERE position( 'seismic' in temp_source ) > 0
		ORDER BY random() LIMIT 50)
ORDER BY col.name, sl.name
LIMIT 50;


DROP VIEW IF EXISTS random_well;
CREATE VIEW random_well AS
SELECT 	
	i.temp_source,
	col.name AS collection,
	c.path_cache,
	i.temp_shelf_idx,
	i.temp_drawer,
	i.barcode,
	i.alt_barcode,
	w.api_number,
	w.name || ': ' || w.well_number AS well,
	kwd.name AS form, 
	i.remark,
	n.note AS curator_remark,
	ST_Y(pt.geog::geometry) AS latitude, 
	ST_X(pt.geog::geometry) AS longitude, 
	pl.meridian || ' ' || pl.township || ' ' || pl.range AS plss, 
	plc.name AS basin,
	org.name AS operator, 
	u.url, 
	n2.note AS area_basin,
	d.width || 'x' || d.height || 'x' || d.depth AS box_type, 
	i.tray,
	cm.name AS material,
	i.box_number,
	i.set_number,
	i.split_number,
	i.state_number,
	i.interval_top AS top,
	i.interval_bottom AS bottom,
	i.interval_unit_id,
	i.core_number AS core,
	cd.core_diameter AS diameter,
	i.sample_frequency,
	i.recovery AS recovery,
	i.can_publish,
	i.received_date AS received,
	i.modified_date,
	i.active,
	i.weight,
	i.weight_unit_id,
	iq.remark AS quality_remark,
	iq.needs_detail,
	iq.unsorted,
	iq.possible_radiation,
	iq.damaged,
	iq.box_damaged,
	iq.missing,
	iq.data_missing,
	iq.barcode_missing,
	iq.label_obscured,
	iq.insufficient_material,
	i.temp_original_id AS access_id

FROM inventory i 
LEFT JOIN container c ON i.container_id = c.container_id
LEFT JOIN collection col ON i.collection_id = col.collection_id
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ik.inventory_id)
		ik.inventory_id, k.name
	FROM inventory_keyword ik 
	LEFT JOIN keyword k ON ik.keyword_id = k.keyword_id
	LEFT JOIN keyword_group kg ON k.keyword_group_id = kg.keyword_group_id
	WHERE kg.name = 'form'
	ORDER BY ik.inventory_id, k.name DESC
) AS kwd ON kwd.inventory_id = i.inventory_id

LEFT JOIN core_diameter cd ON i.core_diameter_id = cd.core_diameter_id
LEFT JOIN dimension d ON i.dimension_id = d.dimension_id
LEFT JOIN container_material cm ON i.container_material_id = cm.container_material_id
LEFT JOIN inventory_quality iq ON i.inventory_id = iq.inventory_id
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ivn.inventory_id)
		ivn.inventory_id, n.note
	FROM inventory_note AS ivn
	LEFT JOIN note AS n ON ivn.note_id = n.note_id
	LEFT JOIN note_type AS nt ON n.note_type_id = nt.note_type_id
	WHERE nt.name = 'curator'
	ORDER BY ivn.inventory_id, n.note_date DESC
) AS n ON n.inventory_id = i.inventory_id

LEFT JOIN inventory_well iw ON i.inventory_id = iw.inventory_id
LEFT JOIN well w ON iw.well_id = w.well_id
LEFT JOIN well_point wp ON w.well_id = wp.well_id
LEFT JOIN point pt ON wp.point_id = pt.point_id
LEFT JOIN well_plss wps ON w.well_id = wps.well_id
LEFT JOIN plss pl ON wps.plss_id = pl.plss_id
LEFT JOIN well_place wpl ON w.well_id = wpl.well_id
LEFT JOIN place plc ON wpl.place_id = plc.place_id
	LEFT JOIN well_operator wo ON w.well_id = wo.well_id
	LEFT JOIN organization org ON wo.organization_id = org.organization_id
	LEFT JOIN well_url wu ON w.well_id = wu.well_id
	LEFT JOIN url u ON wu.url_id = u.url_id
	LEFT JOIN url_type ut ON u.url_type_id = ut.url_type_id
-- inventory notes
LEFT OUTER JOIN (
	SELECT DISTINCT ON (wn.well_id)
		wn.well_id, nte.note
	FROM well_note wn
	LEFT JOIN note nte ON wn.note_id = nte.note_id
	LEFT JOIN note_type nty ON nte.note_type_id = nty.note_type_id
	WHERE nty.name = 'location'
	ORDER BY wn.well_id, nte.note_date DESC
) AS n2 ON n2.well_id = w.well_id

WHERE 	i.temp_source = 'well' AND
	wo.is_current AND
	ut.name = 'well history' AND 
	i.inventory_id IN 
		(SELECT inventory_id FROM inventory
		WHERE temp_source = 'well'
		ORDER BY random() LIMIT 60)
ORDER BY col.name, w.api_number, i.temp_sample_form
LIMIT 50;                        -- trim surplus


DROP VIEW IF EXISTS random_well_processed;
CREATE VIEW random_well_processed AS
SELECT 	
	i.temp_source,
	col.name AS collection,
	c.path_cache,
	i.barcode,
	w.api_number,
	kwd.name AS form, 
	i.remark,
	n.note AS curator_remark,
	n2.note AS area_basin,
	d.width || 'x' || d.height || 'x' || d.depth AS box_type, 
	i.tray,
	cm.name AS material,
	i.box_number,
	i.set_number,
	i.slide_number AS slide_num,
	i.slip_number AS slip_num,
	i.interval_top AS top,
	i.interval_bottom AS bottom,
	i.interval_unit_id,
	i.can_publish,
	i.received_date AS received,
	i.modified_date,
	i.active,
	iq.remark AS quality_remark,
	iq.needs_detail,
	iq.unsorted,
	iq.possible_radiation,
	iq.damaged,
	iq.box_damaged,
	iq.missing,
	iq.data_missing,
	iq.barcode_missing,
	iq.label_obscured,
	iq.insufficient_material,
	i.temp_original_id AS access_id

FROM inventory i 
LEFT JOIN container c ON i.container_id = c.container_id
LEFT JOIN collection col ON i.collection_id = col.collection_id
-- keyword
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ik.inventory_id)
		ik.inventory_id, k.name
	FROM inventory_keyword ik 
	LEFT JOIN keyword k ON ik.keyword_id = k.keyword_id
	LEFT JOIN keyword_group kg ON k.keyword_group_id = kg.keyword_group_id
	WHERE kg.name = 'analysis'
	ORDER BY ik.inventory_id, k.name DESC
) AS kwd ON kwd.inventory_id = i.inventory_id

LEFT JOIN core_diameter cd ON i.core_diameter_id = cd.core_diameter_id
LEFT JOIN dimension d ON i.dimension_id = d.dimension_id
LEFT JOIN container_material cm ON i.container_material_id = cm.container_material_id
LEFT JOIN inventory_quality iq ON i.inventory_id = iq.inventory_id
-- inventory notes
LEFT OUTER JOIN (
	SELECT DISTINCT ON (ivn.inventory_id)
		ivn.inventory_id, n.note
	FROM inventory_note AS ivn
	LEFT JOIN note AS n ON ivn.note_id = n.note_id
	LEFT JOIN note_type AS nt ON n.note_type_id = nt.note_type_id
	WHERE nt.name = 'curator'
	ORDER BY ivn.inventory_id, n.note_date DESC
) AS n ON n.inventory_id = i.inventory_id

LEFT JOIN inventory_well iw ON i.inventory_id = iw.inventory_id
LEFT JOIN well w ON iw.well_id = w.well_id
LEFT JOIN well_point wp ON w.well_id = wp.well_id
LEFT JOIN point pt ON wp.point_id = pt.point_id
LEFT JOIN well_plss wps ON w.well_id = wps.well_id
LEFT JOIN plss pl ON wps.plss_id = pl.plss_id
LEFT JOIN well_place wpl ON w.well_id = wpl.well_id
LEFT JOIN place plc ON wpl.place_id = plc.place_id
	LEFT JOIN well_url wu ON w.well_id = wu.well_id
	LEFT JOIN url u ON wu.url_id = u.url_id
	LEFT JOIN url_type ut ON u.url_type_id = ut.url_type_id
-- well notes
LEFT OUTER JOIN (
	SELECT DISTINCT ON (wn.well_id)
		wn.well_id, nte.note
	FROM well_note wn
	LEFT JOIN note nte ON wn.note_id = nte.note_id
	LEFT JOIN note_type nty ON nte.note_type_id = nty.note_type_id
	WHERE nty.name = 'location'
	ORDER BY wn.well_id, nte.note_date DESC
) AS n2 ON n2.well_id = w.well_id

WHERE 	i.temp_source = 'well processed' AND
	ut.name = 'well history' AND 
	i.inventory_id IN 
		(SELECT inventory_id FROM inventory
		WHERE temp_source = 'well processed'
		ORDER BY random() LIMIT 60)
ORDER BY col.name, w.api_number, i.temp_sample_form
LIMIT 50;                        -- trim surplus
