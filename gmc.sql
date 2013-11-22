SET ROLE 'gmc';
SET SCHEMA 'public';
SET CLIENT_MIN_MESSAGES TO WARNING;

BEGIN;

DROP TABLE IF EXISTS
	borehole,
	borehole_mining_district,
	borehole_note,
	borehole_organization,
	borehole_point,
	borehole_quadrangle,
	borehole_url,
	borehole_utm,
	collection,
	container,
	container_file,
	container_material,
	container_type,
	core_diameter,
	dimension,
	file,
	file_type,
	stratigraphy_type,
	stratigraphy,
	stratigraphy_organization,
	stratigraphy_person,
	inventory,
	inventory_borehole,
	inventory_container,
	inventory_file,
	inventory_keyword,
	inventory_note,
	inventory_outcrop,
	inventory_publication,
	inventory_quality,
	inventory_url,
	inventory_well,
	keyword,
	keyword_group,
	mining_district,
	note,
	note_type,
	organization,
	organization_type,
	outcrop,
	outcrop_stratigraphy,
	outcrop_mining_district,
	outcrop_note,
	outcrop_organization,
	outcrop_place,
	outcrop_plss,
	outcrop_point,
	outcrop_quadrangle,
	outcrop_utm,
	person,
	person_organization,
	place,
	plss,
	point,
	point_type,
	process,
	project,
	prospect,
	prospect_file,
	publication,
	publication_note,
	publication_organization,
	publication_person,
	publication_url,
	quadrangle,
	sample,
	sample_file,
	sample_process_inventory,
	unit,
	url,
	url_type,
	utm,
	utm_type,
	visitor,
	well,
	well_note,
	well_operator,
	well_place,
	well_plss,
	well_point,
	well_quadrangle,
	well_url,
	well_file,
	well_stratigraphy,
	well_stratigraphy_person,
	well_stratigraphy_organization
CASCADE;


CREATE TABLE note_type (
	note_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	description VARCHAR(255)
);


CREATE TABLE note (
	note_id SERIAL PRIMARY KEY,
	note_type_id INT REFERENCES note_type(note_type_id) NOT NULL,
	note TEXT NOT NULL,
	note_date DATE NOT NULL DEFAULT NOW(),
	is_public BOOLEAN NOT NULL DEFAULT true,
	username VARCHAR(25) NOT NULL,
	active BOOLEAN NOT NULL DEFAULT true,

	temp_original_id BIGINT NULL,
	temp_source VARCHAR(25) NULL
);


CREATE TABLE quadrangle (
	quadrangle_id SERIAL PRIMARY KEY,
	name VARCHAR(30) NOT NULL,
	alt_name VARCHAR(30) NULL,
	abbr VARCHAR(5) NULL,
	alt_abbr VARCHAR(5) NULL,
	scale INT NOT NULL,
	geom GEOMETRY(MultiPolygon, 0) NULL
);


CREATE TABLE place (
	place_id SERIAL PRIMARY KEY,
	name VARCHAR(150) NOT NULL,
	type VARCHAR(20) NOT NULL,
	geom GEOMETRY(Point, 0) NULL
);


CREATE TABLE url_type (
	url_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);


CREATE TABLE url (
	url_id SERIAL PRIMARY KEY,
	url_type_id INT REFERENCES url_type(url_type_id) NULL,
	description VARCHAR(255) NULL,
	url TEXT,
	temp_original_id BIGINT NULL,
	temp_source VARCHAR(25) NULL
);


CREATE TABLE file_type (
	file_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);


CREATE TABLE file (
	file_id SERIAL PRIMARY KEY,
	file_type_id INT REFERENCES file_type(file_type_id) NULL,
	description VARCHAR(255) NULL,
	mimetype VARCHAR(255) NOT NULL DEFAULT 'application/octet-stream',
	size INT NOT NULL,
	filename VARCHAR(255) NOT NULL,
	md5 CHAR(16) NOT NULL,
	content BYTEA NOT NULL
);


CREATE TABLE unit (
	unit_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	abbr VARCHAR(5) NOT NULL,
	description VARCHAR(255) NULL
);


CREATE TABLE dimension (
	dimension_id SERIAL PRIMARY KEY,
	unit_id INT REFERENCES unit(unit_id) NOT NULL,

	name VARCHAR(50) NOT NULL,
	height NUMERIC(10,2) NOT NULL,
	width NUMERIC(10,2) NOT NULL,
	depth NUMERIC(10,2) NOT NULL,
	remark TEXT NULL,

	temp_type VARCHAR(50) NULL
);


CREATE TABLE utm_type (
	utm_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);


CREATE TABLE utm (
	utm_id SERIAL PRIMARY KEY,
	utm_type_id INT REFERENCES utm_type(utm_type_id) NULL,
	unit_id INT REFERENCES unit(unit_id) NULL,
	description VARCHAR(255) NULL,
	zone VARCHAR(3) NULL,
	easting INT NULL,
	northing INT NULL,
	srid INT NULL,
	geom GEOMETRY(MultiPolygon, 0) NULL,

	temp_original_id BIGINT NULL
);


CREATE TABLE mining_district (
	mining_district_id SERIAL PRIMARY KEY,
	name VARCHAR(35) NULL,
	region VARCHAR(30) NULL,
	geom GEOMETRY(MultiPolygon, 0) NULL
);


CREATE TABLE plss (
	plss_id SERIAL PRIMARY KEY,
	meridian VARCHAR(4) NOT NULL,
	township INT NULL,
	township_dir VARCHAR(2) NULL,
	range INT NULL,
	range_dir VARCHAR(2) NULL,
	section INT NULL,
	quadrant VARCHAR(6) NULL,
	geom GEOMETRY(MultiPolygon, 0) NULL
);


CREATE TABLE point_type (
	point_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);


CREATE TABLE point (
	point_id SERIAL PRIMARY KEY,
	point_type_id INT REFERENCES point_type(point_type_id) NULL,
	description VARCHAR(255) NULL,
	geom GEOMETRY(Point, 0) NOT NULL,

	temp_original_id BIGINT NULL
);


CREATE TABLE organization_type (
	organization_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);


CREATE TABLE organization (
	organization_id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	abbr VARCHAR(25) NULL,
	organization_type_id INT REFERENCES organization_type(organization_type_id) NOT NULL,
	remark TEXT NULL,

	temp_original_id BIGINT NULL
);


CREATE TABLE person (
	person_id SERIAL PRIMARY KEY,
	first VARCHAR(100) NULL,
	middle VARCHAR(100) NULL,
	last VARCHAR(100) NOT NULL,
	suffix VARCHAR(50) NULL,

	phone VARCHAR(25) NULL,
	email VARCHAR(255) NULL,

	preferred_id INT REFERENCES person(person_id) NULL,

	-- Used for referencing the user in the short-term during the import
	temp_fullname VARCHAR(150) NULL,
	temp_organization VARCHAR(255) NULL,
	temp_original_id BIGINT NULL
);


CREATE TABLE person_organization (
	person_id INT REFERENCES person(person_id), 
	organization_id INT REFERENCES organization(organization_id),
	log_date TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW(),
	PRIMARY KEY(person_id, organization_id, log_date)
);


CREATE TABLE publication (
	publication_id SERIAL PRIMARY KEY,
	citation_id INT NULL,
	title TEXT NOT NULL,
	year INT NULL,
	publication_number VARCHAR(50) NULL,
	publication_series VARCHAR(50) NULL,
	can_publish BOOLEAN NOT NULL DEFAULT false,

	temp_original_id BIGINT NULL,
	temp_source VARCHAR(30) NULL
); 


CREATE TABLE publication_url (
	publication_id INT REFERENCES publication(publication_id) NOT NULL,
	url_id INT REFERENCES url(url_id) NOT NULL,
	PRIMARY KEY(publication_id, url_id)
);


CREATE TABLE publication_person (
	publication_id INT REFERENCES publication(publication_id),
	person_id INT REFERENCES person(person_id),
	PRIMARY KEY(publication_id, person_id)
);


CREATE TABLE publication_organization (
	publication_id INT REFERENCES publication(publication_id),
	organization_id INT REFERENCES organization(organization_id),
	PRIMARY KEY(publication_id, organization_id)
);


CREATE TABLE publication_note (
	publication_id INT REFERENCES publication(publication_id) NOT NULL,
	note_id INT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(publication_id, note_id)
);


CREATE TABLE core_diameter (
	core_diameter_id SERIAL PRIMARY KEY,
	core_diameter NUMERIC(10,2) NOT NULL,
	name VARCHAR(100) NULL,
	unit_id INT REFERENCES unit(unit_id) NULL
);


CREATE TABLE collection (
	collection_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255) NULL,
	organization_id INT REFERENCES organization(organization_id) NULL
);


CREATE TABLE project (
	project_id SERIAL PRIMARY KEY,
	organization_id INT REFERENCES organization(organization_id) NULL,
	name VARCHAR(100) NOT NULL,
	start_date DATE NULL,
	end_date DATE NULL,

	temp_original_id BIGINT NULL
);


CREATE TABLE stratigraphy_type (
	stratigraphy_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);


CREATE TABLE stratigraphy (
	stratigraphy_id SERIAL PRIMARY KEY,
	parent_id INT REFERENCES stratigraphy(stratigraphy_id) NULL,
	stratigraphy_type_id INT REFERENCES stratigraphy_type(stratigraphy_type_id) NOT NULL,
	name VARCHAR(50) NOT NULL,
	alt_names VARCHAR(1024) NULL,
	remark TEXT NULL,

	temp_original_id BIGINT NULL
);


CREATE TABLE well (
	well_id SERIAL PRIMARY KEY,

	name VARCHAR(255) NOT NULL,
	alt_names VARCHAR(1024) NULL,

	well_number VARCHAR(50) NULL,
	api_number VARCHAR(14) NULL,
	is_onshore BOOLEAN NOT NULL DEFAULT true,
	is_federal BOOLEAN NOT NULL DEFAULT false,
	
	spud_date DATE NULL,
	completion_date DATE NULL,

	measured_depth NUMERIC(10, 2) NULL,
	vertical_depth NUMERIC(10, 2) NULL,
	elevation NUMERIC(10, 2) NULL,
	elevation_kb NUMERIC(10, 2) NULL,
	unit_id INT REFERENCES unit(unit_id) NULL,

	permit_status VARCHAR(6) NULL,
	completion_status VARCHAR(6) NULL,
	stash JSON NULL,

	temp_source VARCHAR(25) NULL,
	temp_original_id BIGINT NULL,
	temp_link VARCHAR(255) NULL
);


CREATE TABLE well_place (
	well_id INT REFERENCES well(well_id) NOT NULL,
	place_id INT REFERENCES place(place_id) NOT NULL,
	PRIMARY KEY(well_id, place_id)
);


CREATE TABLE well_quadrangle (
	well_id INT REFERENCES well(well_id) NOT NULL,
	quadrangle_id INT REFERENCES quadrangle(quadrangle_id) NOT NULL,
	PRIMARY KEY(well_id, quadrangle_id)
);


CREATE TABLE well_point (
	well_id INT REFERENCES well(well_id) NOT NULL,
	point_id INT REFERENCES point(point_id) NOT NULL,
	PRIMARY KEY(well_id, point_id)
);


CREATE TABLE well_operator (
	well_id INT REFERENCES well(well_id) NOT NULL,
	organization_id INT REFERENCES organization(organization_id) NOT NULL,
	is_current BOOLEAN NOT NULL DEFAULT true,
	PRIMARY KEY(well_id, organization_id)
);


CREATE TABLE well_url (
	well_id INT REFERENCES well(well_id) NOT NULL,
	url_id INT REFERENCES url(url_id) NOT NULL,
	PRIMARY KEY(well_id, url_id)
);


CREATE TABLE well_note (
	well_id INT REFERENCES well(well_id) NOT NULL,
	note_id INT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(well_id, note_id)
);


CREATE TABLE well_plss (
	well_id INT REFERENCES well(well_id) NOT NULL,
	plss_id INT REFERENCES plss(plss_id) NOT NULL,
	PRIMARY KEY(well_id, plss_id)
);


CREATE TABLE well_file (
	well_id INT REFERENCES well(well_id),
	file_id INT REFERENCES file(file_id),
	PRIMARY KEY(well_id, file_id)
);


CREATE TABLE well_stratigraphy (
	well_stratigraphy_id SERIAL PRIMARY KEY,
	stratigraphy_id INT REFERENCES stratigraphy(stratigraphy_id) NOT NULL,
	well_id INT REFERENCES well(well_id) NOT NULL,
	measured_depth_top NUMERIC(8, 2) NULL,
	measured_depth_bottom NUMERIC(8, 2) NULL,
	vertical_depth_top NUMERIC(8, 2) NULL,
	vertical_depth_bottom NUMERIC(8, 2) NULL,
	unit_id INT REFERENCES unit(unit_id) NULL,
	published_date DATE NULL,
	remark TEXT NULL
);


CREATE TABLE well_stratigraphy_person (
	well_stratigraphy_id INT REFERENCES well_stratigraphy(well_stratigraphy_id),
	person_id INT REFERENCES person(person_id),
	PRIMARY KEY(well_stratigraphy_id, person_id)
);


CREATE TABLE well_stratigraphy_organization (
	well_stratigraphy_id INT REFERENCES well_stratigraphy(well_stratigraphy_id),
	organization_id INT REFERENCES organization(organization_id),
	PRIMARY KEY(well_stratigraphy_id, organization_id)
);


CREATE TABLE outcrop (
	outcrop_id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	outcrop_number VARCHAR(50) NULL, -- datatype?
	is_onshore BOOLEAN NOT NULL DEFAULT true,
	year SMALLINT NULL,
	stash JSON NULL,

	temp_source VARCHAR(25) NULL,
	temp_original_id BIGINT NULL,
	temp_link VARCHAR(255) NULL,
	temp_publication_link INT NULL
);


CREATE TABLE outcrop_quadrangle (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	quadrangle_id INT REFERENCES quadrangle(quadrangle_id) NOT NULL,
	PRIMARY KEY(outcrop_id, quadrangle_id)
);


CREATE TABLE outcrop_point (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	point_id INT REFERENCES point(point_id) NOT NULL,
	PRIMARY KEY(outcrop_id, point_id)
);


CREATE TABLE outcrop_utm (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	utm_id INT REFERENCES utm(utm_id) NOT NULL,
	PRIMARY KEY(outcrop_id, utm_id)
);


CREATE TABLE outcrop_stratigraphy (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	stratigraphy_id INT REFERENCES stratigraphy(stratigraphy_id) NOT NULL,
	PRIMARY KEY(outcrop_id, stratigraphy_id)
);


CREATE TABLE outcrop_note (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	note_id INT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(outcrop_id, note_id)
);


CREATE TABLE outcrop_organization (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	organization_id INT REFERENCES organization(organization_id) NOT NULL,
	PRIMARY KEY(outcrop_id, organization_id)
);


CREATE TABLE outcrop_place (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	place_id INT REFERENCES place(place_id) NOT NULL,
	PRIMARY KEY(outcrop_id, place_id)
);


CREATE TABLE outcrop_plss (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	plss_id INT REFERENCES plss(plss_id) NOT NULL,
	PRIMARY KEY(outcrop_id, plss_id)
);


CREATE TABLE outcrop_mining_district (
	outcrop_id INT REFERENCES outcrop(outcrop_id) NOT NULL,
	mining_district_id INT REFERENCES mining_district(mining_district_id) NOT NULL,
	PRIMARY KEY(outcrop_id, mining_district_id)
);


CREATE TABLE prospect (
	prospect_id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	alt_names VARCHAR(1024) NULL,
	ardf_number VARCHAR(25) NULL,

	temp_source VARCHAR(25) NULL,
	temp_original_id BIGINT NULL
);


CREATE TABLE prospect_file (
	prospect_id INT REFERENCES prospect(prospect_id),
	file_id INT REFERENCES file(file_id),
	PRIMARY KEY(prospect_id, file_id)
);


CREATE TABLE borehole (
	borehole_id SERIAL PRIMARY KEY,
	prospect_id INT REFERENCES prospect(prospect_id) NULL,

	name VARCHAR(50) NOT NULL,
	alt_names VARCHAR(1024) NULL,

	is_onshore BOOLEAN NOT NULL DEFAULT true,
	completion_date DATE NULL,
	measured_depth NUMERIC(10, 2) NULL, -- NEED PRECISION
	measured_depth_unit_id INT REFERENCES unit(unit_id) NULL,
	elevation NUMERIC(10, 2) NULL,  -- NEED PRECISION
	elevation_unit_id INT REFERENCES unit(unit_id) NULL,
	stash JSON NULL,

	temp_source VARCHAR(25) NULL,
	temp_original_id BIGINT NULL,
	temp_link VARCHAR(255) NULL,
	temp_publication_link INT NULL
);


CREATE TABLE borehole_quadrangle (
	borehole_id INT REFERENCES borehole(borehole_id) NOT NULL,
	quadrangle_id INT REFERENCES quadrangle(quadrangle_id) NOT NULL,
	PRIMARY KEY(borehole_id, quadrangle_id)
);


CREATE TABLE borehole_point (
	borehole_id INT REFERENCES borehole(borehole_id) NOT NULL,
	point_id INT REFERENCES point(point_id) NOT NULL,
	PRIMARY KEY(borehole_id, point_id)
);


CREATE TABLE borehole_utm (
	borehole_id INT REFERENCES borehole(borehole_id) NOT NULL,
	utm_id INT REFERENCES utm(utm_id) NOT NULL,
	PRIMARY KEY(borehole_id, utm_id)
);


CREATE TABLE borehole_url (
	borehole_id INT REFERENCES borehole(borehole_id) NOT NULL,
	url_id INT REFERENCES url(url_id) NOT NULL,
	PRIMARY KEY(borehole_id, url_id)
);


CREATE TABLE borehole_mining_district (
	borehole_id INT REFERENCES borehole(borehole_id) NOT NULL,
	mining_district_id INT REFERENCES mining_district(mining_district_id) NOT NULL,
	PRIMARY KEY(borehole_id, mining_district_id)
);


CREATE TABLE borehole_note (
	borehole_id INT REFERENCES borehole(borehole_id) NOT NULL,
	note_id INT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(borehole_id, note_id)
);


CREATE TABLE borehole_organization (
	borehole_id INT REFERENCES borehole(borehole_id) NOT NULL,
	organization_id INT REFERENCES organization(organization_id) NOT NULL,
	PRIMARY KEY(borehole_id, organization_id)
);


CREATE TABLE container_material (
	container_material_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);


CREATE TABLE container_type (
	container_type_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);


CREATE TABLE container (
	container_id SERIAL PRIMARY KEY,
	parent_container_id INT REFERENCES container(container_id) NULL,
	container_type_id INT REFERENCES container_type(container_type_id) NULL,
	container_material_id INT REFERENCES container_material(container_material_id) NULL,

	name VARCHAR(50) NOT NULL,
	description VARCHAR(255) NULL,

	dimension_id INT REFERENCES dimension(dimension_id) NULL,

	barcode VARCHAR(25) NULL,
	alt_barcode VARCHAR(25) NULL,

	active BOOLEAN NOT NULL DEFAULT true,

	temp_parent VARCHAR(20) NULL,
	temp_type VARCHAR(100) NULL,
	temp_shelf_idx VARCHAR(35) NULL
);


CREATE TABLE container_file (
	container_id INT REFERENCES container(container_id),
	file_id INT REFERENCES file(file_id),
	PRIMARY KEY(container_id, file_id)
);


CREATE TABLE keyword_group (
	keyword_group_id SERIAL PRIMARY KEY,
	name VARCHAR(150) NOT NULL
);


CREATE TABLE keyword (
	keyword_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	alias VARCHAR(150) NULL,
	description VARCHAR(255) NULL,
	keyword_group_id INT REFERENCES keyword_group(keyword_group_id),

	temp_code VARCHAR(8) NULL
);


CREATE TABLE inventory (
	inventory_id SERIAL PRIMARY KEY,
	parent_id INT REFERENCES inventory(inventory_id) NULL,
	collection_id INT REFERENCES collection(collection_id) NULL,
	project_id INT REFERENCES project(project_id) NULL,
	dimension_id INT REFERENCES dimension(dimension_id) NULL,
	container_material_id INT REFERENCES container_material(container_material_id) NULL,

	sample_number VARCHAR(25) NULL,
	sample_number_prefix VARCHAR(25) NULL,
	alt_sample_number VARCHAR(25) NULL,
	published_sample_number VARCHAR(25) NULL,
	published_number_has_suffix BOOLEAN NOT NULL DEFAULT false,
	published_description TEXT NULL,
	barcode VARCHAR(25) NULL,
	alt_barcode VARCHAR(25) NULL,
	state_number VARCHAR(50) NULL,
	box_number VARCHAR(50) NULL,
	set_number VARCHAR(50) NULL,
	split_number VARCHAR(10) NULL,
	slide_number VARCHAR(10) NULL,
	slip_number INT NULL,
	lab_number VARCHAR(100),
	map_number VARCHAR(25), -- Stores BLM map number
	-- Into remark: Screen size
	remark TEXT NULL,

	tray SMALLINT NULL DEFAULT 1,

	interval_top INT NULL,
	interval_bottom INT NULL,
	interval_unit_id INT REFERENCES unit(unit_id) NULL,

	core_number VARCHAR(25) NULL,
	core_diameter_id INT REFERENCES core_diameter(core_diameter_id) NULL,

	weight NUMERIC(10, 2) NULL,
	weight_unit_id INT REFERENCES unit(unit_id) NULL,

	sample_frequency VARCHAR(25) NULL,
	recovery VARCHAR(25) NULL,
	can_publish BOOLEAN NOT NULL DEFAULT false,
	skeleton BOOLEAN NOT NULL DEFAULT false,
	radiation_cps NUMERIC(10, 2) NULL, -- NEED SIZE
	radiation_msv NUMERIC(10, 2) NULL, -- NEED SIZE
	received_date DATE NULL,
	entered_date DATE NULL,
	modified_date DATE NULL,

	stash JSON NULL,
	active BOOLEAN NOT NULL DEFAULT true,

	temp_original_id BIGINT NULL,
	temp_shelf_idx VARCHAR(25) NULL,
	temp_sample_form VARCHAR(20) NULL,
	temp_source VARCHAR(25) NULL,
	temp_location_id BIGINT NULL,
	temp_drawer VARCHAR(50) NULL
);


CREATE TABLE inventory_collector (
	inventory_id INT REFERENCES inventory(inventory_id) NOT NULL,
	collector_id INT REFERENCES person(person_id) NOT NULL,
	PRIMARY KEY(inventory_id, collector_id)
);


CREATE TABLE inventory_url (
	inventory_id INT REFERENCES inventory(inventory_id) NOT NULL,
	url_id INT REFERENCES url(url_id) NOT NULL,
	PRIMARY KEY(inventory_id, url_id)
);


CREATE TABLE inventory_keyword (
	inventory_id INT REFERENCES inventory(inventory_id),
	keyword_id INT REFERENCES keyword(keyword_id),
	PRIMARY KEY(inventory_id, keyword_id)
);


CREATE TABLE inventory_container (
	inventory_container_id SERIAL PRIMARY KEY,
	inventory_id INT REFERENCES inventory(inventory_id) NOT NULL,
	container_id INT REFERENCES container(container_id) NOT NULL,
	log_date TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);


CREATE TABLE inventory_publication (
	inventory_id INT REFERENCES inventory(inventory_id),
	publication_id INT REFERENCES publication(publication_id),
	PRIMARY KEY(inventory_id, publication_id)
);


CREATE TABLE inventory_file (
	inventory_id INT REFERENCES inventory(inventory_id),
	file_id INT REFERENCES file(file_id),
	PRIMARY KEY(inventory_id, file_id)
);


CREATE TABLE inventory_note (
	inventory_id INT REFERENCES inventory(inventory_id) NOT NULL,
	note_id INT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(inventory_id, note_id)
);


CREATE TABLE inventory_borehole (
	inventory_id INT REFERENCES inventory(inventory_id),
	borehole_id INT REFERENCES borehole(borehole_id),
	PRIMARY KEY(inventory_id, borehole_id)
);


CREATE TABLE inventory_well (
	inventory_id INT REFERENCES inventory(inventory_id),
	well_id INT REFERENCES well(well_id),
	PRIMARY KEY(inventory_id, well_id)
);


CREATE TABLE inventory_outcrop (
	inventory_id INT REFERENCES inventory(inventory_id),
	outcrop_id INT REFERENCES outcrop(outcrop_id),
	PRIMARY KEY(inventory_id, outcrop_id)
);


CREATE TABLE inventory_quality (
	inventory_quality_id SERIAL PRIMARY KEY,
	inventory_id INT REFERENCES inventory(inventory_id) NOT NULL,
	check_date DATE NOT NULL DEFAULT NOW(),
	remark TEXT NULL,
	needs_detail BOOLEAN NOT NULL DEFAULT false,
	unsorted BOOLEAN NOT NULL DEFAULT false,
	possible_radiation BOOLEAN NOT NULL DEFAULT false,
	damaged BOOLEAN NOT NULL DEFAULT false,
	box_damaged BOOLEAN NOT NULL DEFAULT false,
	missing BOOLEAN NOT NULL DEFAULT false,
	data_missing BOOLEAN NOT NULL DEFAULT false,
	barcode_missing BOOLEAN NOT NULL DEFAULT false,
	label_obscured BOOLEAN NOT NULL DEFAULT false,
	username VARCHAR(25) NOT NULL
);


CREATE TABLE process (
	process_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(255) NULL
);


CREATE TABLE sample (
	sample_id SERIAL PRIMARY KEY,
	sample_agreement_id INT NULL,
	sample_date DATE NOT NULL,
	due_date DATE NOT NULL
);


CREATE TABLE sample_file (
	sample_id INT REFERENCES sample(sample_id),
	file_id INT REFERENCES file(file_id),
	PRIMARY KEY(sample_id, file_id)
);


CREATE TABLE sample_process_inventory (
	sample_id INT REFERENCES sample(sample_id),
	inventory_id INT REFERENCES inventory(inventory_id),
	process_id INT REFERENCES process(process_id),

	completion_date DATE NULL,
	purpose VARCHAR(500) NULL,
	comments TEXT NULL,

	publication_id INT REFERENCES publication(publication_id) NULL,
	PRIMARY KEY(sample_id, inventory_id, process_id)
);


CREATE TABLE visitor (
	visitor_id SERIAL PRIMARY KEY,
	person_id INT REFERENCES person(person_id) NOT NULL,
	log_date TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);

COMMIT;
