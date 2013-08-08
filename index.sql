SET ROLE 'gmc';
SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;

BEGIN;

DROP INDEX IF EXISTS temp_container_temp_shelf_idx_idx, temp_dimension_hwdt_idx,
	temp_person_temp_fullname_idx, temp_inventory_temp_original_id_idx,
	collection_name_idx, container_material_name_idx, container_type_name_idx,
	core_diameter_name_idx, core_diameter_core_diameter_idx,
	inventory_branch_name_idx, organization_name_idx, organization_abbr_idx,
	organization_organization_type_idx, unit_name_idx, unit_abbr_idx,
	place_name_idx, place_type_idx, quadrangle_name_idx,
	note_note_date_idx, note_note_type_id_idx, note_type_name_idx,
	dimension_name_idx;

CREATE INDEX temp_container_temp_shelf_idx_idx ON container(temp_shelf_idx);
CREATE INDEX temp_dimension_hwdt_idx ON dimension(height, width, depth, temp_type);
CREATE INDEX temp_person_temp_fullname_idx ON person(temp_fullname);
CREATE INDEX temp_inventory_temp_original_id_idx ON inventory(temp_original_id);

CREATE INDEX collection_name_idx ON collection(name);
CREATE INDEX container_material_name_idx ON container_material(name);
CREATE INDEX container_type_name_idx ON container_type(name);
CREATE INDEX core_diameter_name_idx ON core_diameter(name);
CREATE INDEX core_diameter_core_diameter_idx ON core_diameter(core_diameter);
CREATE INDEX inventory_branch_name_idx ON inventory_branch(name);
CREATE INDEX organization_name_idx ON organization(name);
CREATE INDEX organization_abbr_idx ON organization(abbr);
CREATE INDEX organization_organization_type_id_idx ON organization(organization_type_id);
CREATE INDEX unit_name_idx ON unit(name);
CREATE INDEX unit_abbr_idx ON unit(abbr);
CREATE INDEX place_name_idx ON place(name);
CREATE INDEX place_type_idx ON place(type);
CREATE INDEX quadrangle_name_idx ON quadrangle(name);
CREATE INDEX note_note_date_idx ON note(note_date);
CREATE INDEX note_note_type_id_idx ON note(note_type_id);
CREATE INDEX note_type_name_idx ON note_type(name);
CREATE INDEX dimension_name_idx ON dimension(name);

COMMIT;
