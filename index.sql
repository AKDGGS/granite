SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;

BEGIN;


DROP INDEX IF EXISTS borehole_prospect_id_idx;
CREATE INDEX borehole_prospect_id_idx ON borehole(prospect_id);

DROP INDEX IF EXISTS borehole_point_borehole_id_idx;
CREATE INDEX borehole_point_borehole_id_idx ON borehole_point(borehole_id);

DROP INDEX IF EXISTS borehole_point_point_id_idx;
CREATE INDEX borehole_point_point_id_idx ON borehole_point(point_id);

DROP INDEX IF EXISTS collection_name_idx;
CREATE INDEX collection_name_idx ON collection(name);

DROP INDEX IF EXISTS container_barcode_idx;
CREATE INDEX container_barcode_idx ON container(barcode);

DROP INDEX IF EXISTS container_container_type_id_idx;
CREATE INDEX container_container_type_id_idx ON container(container_type_id);

DROP INDEX IF EXISTS container_name_idx;
CREATE INDEX container_name_idx ON container(name);

DROP INDEX IF EXISTS container_alt_barcode_idx;
CREATE INDEX container_alt_barcode_idx ON container(alt_barcode);

DROP INDEX IF EXISTS container_active_idx;
CREATE INDEX container_active_idx ON container(active);

DROP INDEX IF EXISTS container_parent_container_id_idx;
CREATE INDEX container_parent_container_id_idx ON container(parent_container_id);

DROP INDEX IF EXISTS container_material_name_idx;
CREATE INDEX container_material_name_idx ON container_material(name);

DROP INDEX IF EXISTS container_type_name_idx;
CREATE INDEX container_type_name_idx ON container_type(name);

DROP INDEX IF EXISTS core_diameter_name_idx;
CREATE INDEX core_diameter_name_idx ON core_diameter(name);

DROP INDEX IF EXISTS core_diameter_core_diameter_idx;
CREATE INDEX core_diameter_core_diameter_idx ON core_diameter(core_diameter);

DROP INDEX IF EXISTS inventory_active_idx;
CREATE INDEX inventory_active_idx ON inventory(active);

DROP INDEX IF EXISTS inventory_parent_id_idx;
CREATE INDEX inventory_parent_id_idx ON inventory(parent_id);

DROP INDEX IF EXISTS inventory_dimension_id_idx;
CREATE INDEX inventory_dimension_id_idx ON inventory(dimension_id);

DROP INDEX IF EXISTS inventory_collection_id_idx;
CREATE INDEX inventory_collection_id_idx ON inventory(collection_id);

DROP INDEX IF EXISTS inventory_project_id_idx;
CREATE INDEX inventory_project_id_idx ON inventory(project_id);

DROP INDEX IF EXISTS inventory_barcode_idx;
CREATE INDEX inventory_barcode_idx ON inventory(barcode);

DROP INDEX IF EXISTS inventory_alt_barcode_idx;
CREATE INDEX inventory_alt_barcode_idx ON inventory(alt_barcode);

DROP INDEX IF EXISTS inventory_coalesce_barcode_idx;
CREATE INDEX inventory_coalesce_barcode_idx ON inventory(coalesce(barcode, alt_barcode));

DROP INDEX IF EXISTS inventory_container_id_idx;
CREATE INDEX inventory_container_id_idx ON inventory(container_id);

DROP INDEX IF EXISTS inventory_container_material_id_idx;
CREATE INDEX inventory_container_material_id_idx ON inventory(container_material_id);


-- inventory_container
DROP INDEX IF EXISTS inventory_container_log_inventory_id_idx;
CREATE INDEX inventory_container_log_inventory_id_idx
	ON inventory_container_log(inventory_id);

DROP INDEX IF EXISTS inventory_container_log_destination_idx;
CREATE INDEX inventory_container_log_destination_idx
	ON inventory_container_log(destination);

DROP INDEX IF EXISTS inventory_container_log_log_date_idx;
CREATE INDEX inventory_container_log_log_date_idx
	ON inventory_container_log(log_date DESC);


-- container_log
DROP INDEX IF EXISTS container_log_container_id_idx;
CREATE INDEX container_log_container_id_idx
	ON container_log(container_id);

DROP INDEX IF EXISTS container_log_destination_idx;
CREATE INDEX container_log_destination_idx
	ON container_log(destination);

DROP INDEX IF EXISTS container_log_log_date_idx;
CREATE INDEX container_log_log_date_idx
	ON container_log(log_date DESC);


DROP INDEX IF EXISTS inventory_borehole_borehole_id_idx;
CREATE INDEX inventory_borehole_borehole_id_idx ON inventory_borehole(borehole_id);

DROP INDEX IF EXISTS inventory_borehole_inventory_id_idx;
CREATE INDEX inventory_borehole_inventory_id_idx ON inventory_borehole(inventory_id);

DROP INDEX IF EXISTS inventory_outcrop_inventory_id_idx;
CREATE INDEX inventory_outcrop_inventory_id_idx ON inventory_outcrop(inventory_id);

DROP INDEX IF EXISTS inventory_outcrop_outcrop_id_idx;
CREATE INDEX inventory_outcrop_outcrop_id_idx ON inventory_outcrop(outcrop_id);

DROP INDEX IF EXISTS inventory_publication_publication_id_idx;
CREATE INDEX inventory_publication_publication_id_idx ON inventory_publication(publication_id);

DROP INDEX IF EXISTS inventory_publication_inventory_id_idx;
CREATE INDEX inventory_publication_inventory_id_idx ON inventory_publication(inventory_id);

DROP INDEX IF EXISTS inventory_well_well_id_idx;
CREATE INDEX inventory_well_well_id_idx ON inventory_well(well_id);

DROP INDEX IF EXISTS inventory_well_inventory_id_idx;
CREATE INDEX inventory_well_inventory_id_idx ON inventory_well(inventory_id);

DROP INDEX IF EXISTS keyword_lower_name_idx;
CREATE INDEX keyword_lower_name_idx ON keyword(LOWER(name));

DROP INDEX IF EXISTS keyword_name_idx;
CREATE INDEX keyword_name_idx ON keyword(name);

DROP INDEX IF EXISTS keyword_description_idx;
CREATE INDEX keyword_description_idx ON keyword(description);

DROP INDEX IF EXISTS outcrop_point_outcrop_id_idx;
CREATE INDEX outcrop_point_outcrop_id_idx ON outcrop_point(outcrop_id);

DROP INDEX IF EXISTS outcrop_point_point_id_idx;
CREATE INDEX outcrop_point_point_id_idx ON outcrop_point(point_id);

DROP INDEX IF EXISTS outcrop_place_place_id_idx;
CREATE INDEX outcrop_place_place_id_idx ON outcrop_place(place_id);

DROP INDEX IF EXISTS outcrop_place_outcrop_id_idx;
CREATE INDEX outcrop_place_outcrop_id_idx ON outcrop_place(outcrop_id);

DROP INDEX IF EXISTS organization_name_idx;
CREATE INDEX organization_name_idx ON organization(name);

DROP INDEX IF EXISTS organization_abbr_idx;
CREATE INDEX organization_abbr_idx ON organization(abbr);

DROP INDEX IF EXISTS organization_organization_type_id_idx;
CREATE INDEX organization_organization_type_id_idx ON organization(organization_type_id);

DROP INDEX IF EXISTS publication_citation_id_idx;
CREATE INDEX publication_citation_id_idx ON publication(citation_id);

DROP INDEX IF EXISTS unit_name_idx;
CREATE INDEX unit_name_idx ON unit(name);

DROP INDEX IF EXISTS unit_abbr_idx;
CREATE INDEX unit_abbr_idx ON unit(abbr);

DROP INDEX IF EXISTS place_name_idx;
CREATE INDEX place_name_idx ON place(name);

DROP INDEX IF EXISTS place_type_idx;
CREATE INDEX place_type_idx ON place(type);

DROP INDEX IF EXISTS quadrangle_name_idx;
CREATE INDEX quadrangle_name_idx ON quadrangle(name);

DROP INDEX IF EXISTS mining_district_name_idx;
CREATE INDEX mining_district_name_idx ON mining_district(name);

DROP INDEX IF EXISTS mining_district_lower_name_idx;
CREATE INDEX mining_district_lower_name_idx ON mining_district(LOWER(name));

DROP INDEX IF EXISTS quadrangle_scale_idx;
CREATE INDEX quadrangle_scale_idx ON quadrangle(scale);

DROP INDEX IF EXISTS note_active_idx;
CREATE INDEX note_active_idx ON note(active);

DROP INDEX IF EXISTS note_note_date_idx;
CREATE INDEX note_note_date_idx ON note(note_date);

DROP INDEX IF EXISTS note_note_type_id_idx;
CREATE INDEX note_note_type_id_idx ON note(note_type_id);

DROP INDEX IF EXISTS note_type_name_idx;
CREATE INDEX note_type_name_idx ON note_type(name);

DROP INDEX IF EXISTS dimension_name_idx;
CREATE INDEX dimension_name_idx ON dimension(name);

DROP INDEX IF EXISTS inventory_keyword_keyword_id_idx;
CREATE INDEX inventory_keyword_keyword_id_idx ON inventory_keyword(keyword_id);

DROP INDEX IF EXISTS inventory_quality_check_date_idx;
CREATE INDEX inventory_quality_check_date_idx ON inventory_quality(check_date);

DROP INDEX IF EXISTS prospect_ardf_number_idx;
CREATE INDEX prospect_ardf_number_idx ON prospect(ardf_number);

DROP INDEX IF EXISTS prospect_lower_ardf_number_idx;
CREATE INDEX prospect_lower_ardf_number_idx ON prospect(LOWER(ardf_number));

DROP INDEX IF EXISTS well_api_number_idx;
CREATE INDEX well_api_number_idx ON well(api_number);

DROP INDEX IF EXISTS well_name_idx;
CREATE INDEX well_name_idx ON well(name);

DROP INDEX IF EXISTS well_well_number_idx;
CREATE INDEX well_well_number_idx ON well(well_number);

DROP INDEX IF EXISTS well_api_number_int_idx;
CREATE INDEX well_api_number_int_idx ON well(CAST (api_number AS bigint));

DROP INDEX IF EXISTS well_point_point_id_idx;
CREATE INDEX well_point_point_id_idx ON well_point(point_id);

DROP INDEX IF EXISTS well_point_well_id_idx;
CREATE INDEX well_point_well_id_idx ON well_point(well_id);

DROP INDEX IF EXISTS well_place_place_id_idx;
CREATE INDEX well_place_place_id_idx ON well_place(place_id);

DROP INDEX IF EXISTS well_place_well_id_idx;
CREATE INDEX well_place_well_id_idx ON well_place(well_id);

DROP INDEX IF EXISTS shotpoint_shotline_id_idx;
CREATE INDEX shotpoint_shotline_id_idx ON shotpoint(shotline_id);

DROP INDEX IF EXISTS shotpoint_shotpoint_number_idx;
CREATE INDEX shotpoint_shotpoint_number_idx ON shotpoint(shotpoint_number);

DROP INDEX IF EXISTS inventory_shotpoint_inventory_id_idx;
CREATE INDEX inventory_shotpoint_inventory_id_idx ON inventory_shotpoint(inventory_id);

DROP INDEX IF EXISTS inventory_shotpoint_shotpoint_id_idx;
CREATE INDEX inventory_shotpoint_shotpoint_id_idx ON inventory_shotpoint(shotpoint_id);

DROP INDEX IF EXISTS audit_barcode_idx;
CREATE INDEX audit_barcode_idx ON audit(barcode);


DROP INDEX IF EXISTS plss_geog_idx;
CREATE INDEX plss_geog_idx ON plss USING GIST(geog);

DROP INDEX IF EXISTS point_geog_idx;
CREATE INDEX point_geog_idx ON point USING GIST(geog);

-- B-tree to optimize against IS NULL/IS NOT NULL
DROP INDEX IF EXISTS point_geog_btree_idx;
CREATE INDEX point_geog_btree_idx ON point(geog);

DROP INDEX IF EXISTS place_geog_idx;
CREATE INDEX place_geog_idx ON place USING GIST(geog);

-- B-tree to optimize against IS NULL/IS NOT NULL
DROP INDEX IF EXISTS place_geog_btree_idx;
CREATE INDEX place_geog_btree_idx ON place(geog);

DROP INDEX IF EXISTS region_geog_idx;
CREATE INDEX region_geog_idx ON region USING GIST(geog);

DROP INDEX IF EXISTS quadrangle_geog_idx;
CREATE INDEX quadrangle_geog_idx ON quadrangle USING GIST(geog);

DROP INDEX IF EXISTS energy_district_geog_idx;
CREATE INDEX energy_district_geog_idx ON energy_district USING GIST(geog);

DROP INDEX IF EXISTS mining_district_geog_idx;
CREATE INDEX mining_district_geog_idx ON mining_district USING GIST(geog);

DROP INDEX IF EXISTS gmc_region_geog_idx;
CREATE INDEX gmc_region_geog_idx  ON gmc_region USING GIST(geog);

DROP INDEX IF EXISTS utm_geog_idx;
CREATE INDEX utm_geog_idx ON utm USING GIST(geog);

CREATE OPERATOR CLASS _keyword_ops DEFAULT FOR TYPE public.keyword[] USING gin
	family array_ops AS
		function 1 enum_cmp(anyenum,anyenum),
		function 2 pg_catalog.ginarrayextract(anyarray, internal),
		function 3 ginqueryarrayextract(
			anyarray, internal, smallint, internal,
			internal, internal, internal
		),
		function 4 ginarrayconsistent(
			internal, smallint, anyarray, integer, internal,
			internal, internal, internal
		),
		function 6 ginarraytriconsistent(
			internal, smallint, anyarray, integer, internal,
			internal, internal
		),
	storage oid;

CREATE INDEX ON inventory USING gin(keywords);

COMMIT;
