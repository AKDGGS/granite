DROP MATERIALIZED VIEW IF EXISTS inventory_search;
CREATE MATERIALIZED VIEW inventory_search AS (
	SELECT
		i.inventory_id,
		
		i.interval_top AS top,
		i.interval_bottom AS bottom,
		numrange(
			LEAST(i.interval_bottom, i.interval_top),
			GREATEST(i.interval_bottom, i.interval_top),
			'[]'
		) AS intervalrange,
		
		k.keyword_ids,
		
		COALESCE(i.barcode, i.alt_barcode) AS barcode_sort,
		SUBSTRING(b.borehole_name FOR 25)::varchar AS borehole_sort,
		i.box_number AS box_sort,
		cl.name AS collection_sort,
		i.core_number AS core_sort,
		ct.path_cache AS location_sort,
		SUBSTRING(b.prospect_name FOR 25)::varchar AS prospect_sort,
		i.sample_number AS sample_sort,
		i.set_number AS set_sort,
		SUBSTRING(w.well_name FOR 25)::varchar AS well_sort,
		SUBSTRING(w.well_number FOR 25)::varchar AS well_number_sort,
		
		TO_TSVECTOR('simple', i.sample_number) AS sample,
		TO_TSVECTOR('simple', i.core_number) AS core,
		TO_TSVECTOR('simple', i.set_number) AS set,
		TO_TSVECTOR('simple', i.box_number) AS box,
		TO_TSVECTOR('simple', COALESCE(cl.name, '')) AS collection,
		TO_TSVECTOR('simple', COALESCE(pr.name, '')) AS project,
		(
			TO_TSVECTOR('simple', COALESCE(i.barcode, ''))
			|| TO_TSVECTOR('simple', COALESCE(i.alt_barcode, ''))
			|| TO_TSVECTOR('simple', REGEXP_REPLACE(COALESCE(i.barcode, ''), '[^\d]', '', 'g'))
		) AS barcode,
		(
			TO_TSVECTOR('simple', ct.path_cache)
			|| TO_TSVECTOR('simple', REPLACE(ct.path_cache, '/', ''))
		) AS location, 
		(
			TO_TSVECTOR('simple', COALESCE(w.well_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(w.well_name_alt, ''))
		) AS well,
		TO_TSVECTOR('simple', w.well_number) AS wellnumber,
		TO_TSVECTOR('simple', w.api_number) AS api,
		(
			TO_TSVECTOR('simple', COALESCE(b.borehole_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(b.borehole_name_alt, ''))
		) AS borehole,
		(
			TO_TSVECTOR('simple', COALESCE(b.prospect_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(b.prospect_name_alt, ''))		
		) AS prospect,
		TO_TSVECTOR('simple', b.ardf_number) AS ardf,
		TO_TSVECTOR('simple', o.outcrop_name) AS outcrop,
		TO_TSVECTOR('simple', o.outcrop_number) AS outcropnumber,
		(
			TO_TSVECTOR('simple', COALESCE(s.shotline_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(s.shotline_name_alt, ''))
		) AS shotline, (
			TO_TSVECTOR('simple', COALESCE(k.keyword, ''))
			|| TO_TSVECTOR('simple', COALESCE(k.keyword_alias, ''))
		) AS keyword, (
			TO_TSVECTOR('simple', i.inventory_id::varchar)
			|| TO_TSVECTOR('simple', COALESCE(i.barcode, ''))
			|| TO_TSVECTOR('simple', COALESCE(i.alt_barcode, ''))
			|| TO_TSVECTOR('simple', REGEXP_REPLACE(COALESCE(i.barcode, ''), '[^\d]', '', 'g'))
			|| TO_TSVECTOR('simple', COALESCE(i.sample_number, ''))
			|| TO_TSVECTOR('simple', COALESCE(i.core_number, ''))
			|| TO_TSVECTOR('simple', COALESCE(i.set_number, ''))
			|| TO_TSVECTOR('simple', COALESCE(i.box_number, ''))
			|| TO_TSVECTOR('english', COALESCE(i.remark, ''))
			|| TO_TSVECTOR('simple', COALESCE(w.well_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(w.well_name_alt, ''))
			|| TO_TSVECTOR('simple', COALESCE(w.well_number, ''))
			|| TO_TSVECTOR('simple', COALESCE(w.api_number, ''))
			|| TO_TSVECTOR('simple', COALESCE(b.borehole_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(b.borehole_name_alt, ''))
			|| TO_TSVECTOR('simple', COALESCE(b.prospect_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(b.prospect_name_alt, ''))
			|| TO_TSVECTOR('simple', COALESCE(b.ardf_number, ''))
			|| TO_TSVECTOR('simple', COALESCE(o.outcrop_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(o.outcrop_number, ''))
			|| TO_TSVECTOR('simple', COALESCE(s.shotline_name, ''))
			|| TO_TSVECTOR('simple', COALESCE(s.shotline_name_alt, ''))
			|| TO_TSVECTOR('simple', COALESCE(k.keyword, ''))
			|| TO_TSVECTOR('simple', COALESCE(k.keyword_alias, ''))
			|| TO_TSVECTOR('simple', COALESCE(ct.path_cache, ''))
			|| TO_TSVECTOR('simple', REPLACE(COALESCE(ct.path_cache, ''), '/', ''))
			|| TO_TSVECTOR('simple', COALESCE(cl.name, ''))
			|| TO_TSVECTOR('simple', COALESCE(pr.name, ''))
		) AS everything,
		g.geog
	FROM inventory AS i
	LEFT OUTER JOIN (
		SELECT iw.inventory_id,
			STRING_AGG(w.name, ' ' ORDER BY w.name) AS well_name,
			STRING_AGG(w.alt_names, ' ') AS well_name_alt,
			STRING_AGG(w.well_number, ' ' ORDER BY w.well_number) AS well_number,
			STRING_AGG(w.api_number, ' ') AS api_number
		FROM inventory_well AS iw
		JOIN well AS w ON w.well_id = iw.well_id
		GROUP BY iw.inventory_id
	) AS w ON w.inventory_id = i.inventory_id
	LEFT OUTER JOIN (
		SELECT inventory_id,
			STRING_AGG(b.name, ' ' ORDER BY b.name) AS borehole_name,
			STRING_AGG(b.alt_names, ' ') AS borehole_name_alt,
			STRING_AGG(p.name, ' ' ORDER BY p.name) AS prospect_name,
			STRING_AGG(p.alt_names, ' ') AS prospect_name_alt,
			STRING_AGG(p.ardf_number, ' ') AS ardf_number
		FROM inventory_borehole AS ib
		JOIN borehole AS b ON b.borehole_id = ib.borehole_id
		LEFT OUTER JOIN prospect AS p ON p.prospect_id = b.prospect_id
		GROUP BY inventory_id
	) AS b ON b.inventory_id = i.inventory_id
	LEFT OUTER JOIN (
		SELECT io.inventory_id,
			STRING_AGG(o.name, ' ' ORDER BY o.name) AS outcrop_name,
			STRING_AGG(o.outcrop_number, ' ') AS outcrop_number
		FROM inventory_outcrop AS io
		JOIN outcrop AS o ON o.outcrop_id = io.outcrop_id
		GROUP BY io.inventory_id
	) AS o ON o.inventory_id = i.inventory_id
	LEFT OUTER JOIN (
		SELECT inventory_id,
			STRING_AGG(name, ' ' ORDER BY name) AS shotline_name,
			STRING_AGG(alt_names, ' ') AS shotline_name_alt
		FROM (
			SELECT DISTINCT isp.inventory_id, sl.name, sl.alt_names
			FROM inventory_shotpoint AS isp
			JOIN shotpoint AS sp ON sp.shotpoint_id = isp.shotpoint_id
			JOIN shotline AS sl ON sl.shotline_id = sp.shotline_id
		) AS q
		GROUP BY inventory_id
	) AS s ON s.inventory_id = i.inventory_id
	LEFT OUTER JOIN (
		SELECT ik.inventory_id,
			ARRAY_AGG(k.keyword_id ORDER BY k.keyword_id) AS keyword_ids,
			STRING_AGG(k.name, ' ') AS keyword,
			STRING_AGG(k.alias, ' ') AS keyword_alias
		FROM inventory_keyword AS ik
		JOIN keyword AS k ON k.keyword_id = ik.keyword_id
		GROUP BY ik.inventory_id
	) AS k ON k.inventory_id = i.inventory_id
	LEFT OUTER JOIN (
		SELECT DISTINCT(inventory_id) inventory_id, geog
		FROM inventory_geog
	) AS g ON g.inventory_id = i.inventory_id
	LEFT OUTER JOIN container AS ct ON ct.container_id = i.container_id
	LEFT OUTER JOIN collection AS cl ON cl.collection_id = i.collection_id
	LEFT OUTER JOIN project AS pr ON pr.project_id = i.project_id
	WHERE i.active
);

CREATE INDEX inventory_search_inventory_id_idx
	ON inventory_search(inventory_id);
CREATE INDEX inventory_search_top_a_idx
	ON inventory_search(top ASC NULLS LAST);
CREATE INDEX inventory_search_top_d_idx
	ON inventory_search(top DESC NULLS LAST);

CREATE INDEX inventory_search_bottom_a_idx
	ON inventory_search(bottom ASC NULLS LAST);
CREATE INDEX inventory_search_bottom_d_idx
	ON inventory_search(bottom DESC NULLS LAST);

CREATE INDEX inventory_search_keyword_ids_idx
	ON inventory_search USING GIN(keyword_ids);
CREATE INDEX inventory_search_intervalrange_idx
	ON inventory_search USING GIST(intervalrange);

CREATE INDEX inventory_search_barcode_sort_a_idx
	ON inventory_search(barcode_sort ASC NULLS LAST);
CREATE INDEX inventory_search_barcode_sort_d_idx
	ON inventory_search(barcode_sort DESC NULLS LAST);

CREATE INDEX inventory_search_borehole_a_sort_idx
	ON inventory_search(borehole_sort ASC NULLS LAST);
CREATE INDEX inventory_search_borehole_d_sort_idx
	ON inventory_search(borehole_sort DESC NULLS LAST);

CREATE INDEX inventory_search_box_sort_a_idx
	ON inventory_search(box_sort ASC NULLS LAST);
CREATE INDEX inventory_search_box_sort_d_idx
	ON inventory_search(box_sort DESC NULLS LAST);

CREATE INDEX inventory_search_collection_sort_a_idx
	ON inventory_search(collection_sort ASC NULLS LAST);
CREATE INDEX inventory_search_collection_sort_d_idx
	ON inventory_search(collection_sort DESC NULLS LAST);

CREATE INDEX inventory_search_core_sort_a_idx
	ON inventory_search(core_sort ASC NULLS LAST);
CREATE INDEX inventory_search_core_sort_d_idx
	ON inventory_search(core_sort DESC NULLS LAST);

CREATE INDEX inventory_search_location_sort_a_idx
	ON inventory_search(location_sort ASC NULLS LAST);
CREATE INDEX inventory_search_location_sort_d_idx
	ON inventory_search(location_sort DESC NULLS LAST);

CREATE INDEX inventory_search_prospect_sort_a_idx
	ON inventory_search(prospect_sort ASC NULLS LAST);
CREATE INDEX inventory_search_prospect_sort_d_idx
	ON inventory_search(prospect_sort DESC NULLS LAST);

CREATE INDEX inventory_search_sample_sort_a_idx
	ON inventory_search(sample_sort ASC NULLS LAST);
CREATE INDEX inventory_search_sample_sort_d_idx
	ON inventory_search(sample_sort DESC NULLS LAST);

CREATE INDEX inventory_search_set_sort_a_idx
	ON inventory_search(set_sort ASC NULLS LAST);
CREATE INDEX inventory_search_set_sort_d_idx
	ON inventory_search(set_sort DESC NULLS LAST);

CREATE INDEX inventory_search_well_sort_a_idx
	ON inventory_search(well_sort ASC NULLS LAST);
CREATE INDEX inventory_search_well_sort_d_idx
	ON inventory_search(well_sort DESC NULLS LAST);

CREATE INDEX inventory_search_well_number_a_idx
	ON inventory_search(well_number_sort ASC NULLS LAST);
CREATE INDEX inventory_search_well_number_d_idx
	ON inventory_search(well_number_sort DESC NULLS LAST);

CREATE INDEX inventory_search_sample_idx
	ON inventory_search USING GIN(sample);
CREATE INDEX inventory_search_core_idx
	ON inventory_search USING GIN(core);
CREATE INDEX inventory_search_set_idx
	ON inventory_search USING GIN(set);
CREATE INDEX inventory_search_box_idx
	ON inventory_search USING GIN(box);
CREATE INDEX inventory_search_collection_idx
	ON inventory_search USING GIN(collection);
CREATE INDEX inventory_search_project_idx
	ON inventory_search USING GIN(project);
CREATE INDEX inventory_search_barcode_idx
	ON inventory_search USING GIN(barcode);
CREATE INDEX inventory_search_location_idx
	ON inventory_search USING GIN(location);
CREATE INDEX inventory_search_well_idx
	ON inventory_search USING GIN(well);
CREATE INDEX inventory_search_wellnumber_idx
	ON inventory_search USING GIN(wellnumber);
CREATE INDEX inventory_search_api_idx
	ON inventory_search USING GIN(api);
CREATE INDEX inventory_search_borehole_idx
	ON inventory_search USING GIN(borehole);
CREATE INDEX inventory_search_prospect_idx
	ON inventory_search USING GIN(prospect);
CREATE INDEX inventory_search_ardf_idx
	ON inventory_search USING GIN(ardf);
CREATE INDEX inventory_search_outcrop_idx
	ON inventory_search USING GIN(outcrop);
CREATE INDEX inventory_search_outcropnumber_idx
	ON inventory_search USING GIN(outcropnumber);
CREATE INDEX inventory_search_shotline_idx
	ON inventory_search USING GIN(shotline);
CREATE INDEX inventory_search_keyword_idx
	ON inventory_search USING GIN(keyword);
CREATE INDEX inventory_search_everything_idx
	ON inventory_search USING GIN(everything);
CREATE INDEX inventory_search_geog_idx
	ON inventory_search USING GIST(geog);
