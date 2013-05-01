DROP TABLE IF EXISTS file_type CASCADE;
DROP TABLE IF EXISTS file CASCADE;
DROP TABLE IF EXISTS unit CASCADE;
DROP TABLE IF EXISTS person CASCADE;
DROP TABLE IF EXISTS organization_type CASCADE;
DROP TABLE IF EXISTS organization CASCADE;
DROP TABLE IF EXISTS citation CASCADE;
DROP TABLE IF EXISTS citation_person CASCADE;
DROP TABLE IF EXISTS citation_organization CASCADE;
DROP TABLE IF EXISTS core_diameter_alias CASCADE;
DROP TABLE IF EXISTS link CASCADE;
DROP TABLE IF EXISTS collection CASCADE;
DROP TABLE IF EXISTS project CASCADE;
DROP TABLE IF EXISTS header_type CASCADE;
DROP TABLE IF EXISTS header_status CASCADE;
DROP TABLE IF EXISTS header CASCADE;
DROP TABLE IF EXISTS header_note CASCADE;
DROP TABLE IF EXISTS header_organization CASCADE;
DROP TABLE IF EXISTS header_link CASCADE;
DROP TABLE IF EXISTS container_type_material CASCADE;
DROP TABLE IF EXISTS container_type CASCADE;
DROP TABLE IF EXISTS container CASCADE;
DROP TABLE IF EXISTS container_file CASCADE;
DROP TABLE IF EXISTS inventory_form CASCADE;
DROP TABLE IF EXISTS inventory_source CASCADE;
DROP TABLE IF EXISTS inventory_purpose CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS inventory_citation CASCADE;
DROP TABLE IF EXISTS inventory_file CASCADE;
DROP TABLE IF EXISTS inventory_note CASCADE;
DROP TABLE IF EXISTS inventory_header CASCADE;
DROP TABLE IF EXISTS inventory_quality CASCADE;


CREATE TABLE file_type (
	file_type_id SERIAL PRIMARY KEY,
	name VARCHAR(255) -- NEED SIZE
);


CREATE TABLE file (
	file_id BIGSERIAL PRIMARY KEY,
	file_type_id INT REFERENCES file_type(file_type_id) NULL,
	description VARCHAR(255) NULL,
	mimetype VARCHAR(255) NOT NULL DEFAULT 'application/octet-stream',
	size BIGINT NOT NULL,
	filename VARCHAR(255) NOT NULL,
	md5 CHAR(16) NOT NULL
);


CREATE TABLE unit (
	unit_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	description VARCHAR(255) NULL
);


CREATE TABLE person (
	person_id BIGSERIAL PRIMARY KEY,
	first VARCHAR(100) NULL,
	middle VARCHAR(100) NULL,
	last VARCHAR(100) NOT NULL,
	suffix VARCHAR(50) NULL,
	preferred_id BIGINT REFERENCES person(person_id) NULL
);


CREATE TABLE organization_type (
	organization_type_id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL -- NEED SIZE
);


CREATE TABLE organization (
	organization_id BIGSERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	organization_type_id INT REFERENCES organization_type(organization_type_id) NOT NULL
);


CREATE TABLE citation (
	citation_id BIGSERIAL PRIMARY KEY,
	title VARCHAR(150) NOT NULL, -- NEED SIZE
	url VARCHAR(1024) NULL,
	publication_number VARCHAR(50) NULL, -- NULLABLE?
	publication_series VARCHAR(50) NULL, -- NULLABLE?
	publication_year DATE NULL -- NULLABLE?
);


CREATE TABLE citation_person (
	citation_id BIGINT REFERENCES citation(citation_id),
	person_id BIGINT REFERENCES person(person_id),
	PRIMARY KEY(citation_id, person_id)
);


CREATE TABLE citation_organization (
	citation_id BIGINT REFERENCES citation(citation_id),
	organization_id BIGINT REFERENCES organization(organization_id),
	PRIMARY KEY(citation_id, organization_id)
);


CREATE TABLE core_diameter_alias (
	core_diameter_alias_id SERIAL PRIMARY KEY,
	core_diameter NUMERIC(10,2) NOT NULL,
	name VARCHAR(100)
);


CREATE TABLE link (
	link_id BIGSERIAL PRIMARY KEY,
	type VARCHAR(25) NULL,
	url TEXT NOT NULL
);


CREATE TABLE collection (
	collection_id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL
);


CREATE TABLE project (
	project_id BIGSERIAL PRIMARY KEY,
	organization_id BIGINT REFERENCES organization(organization_id) NULL,
	name VARCHAR(100) NOT NULL,
	start_date DATE NULL,
	end_date DATE NULL
);


CREATE TABLE header_type (
	header_type_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NULL
);


CREATE TABLE header_status (
	header_status_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);


-- Merges tables: aogcc_well_header, tbl_hardrock_prospects,
-- tbl_hardrock_borehole, gmc_field_station
CREATE TABLE header (
	-- STILL NEEDS LOCATION DATA:
	-- Lat/Lon/Datum - Multiple - Description of point (Centroid, etc)
	-- Area/Region
	-- Meridian/Township/Range/Section/Quarter Section
	-- Field/Pool
	-- Quadrangle/Quad 64
	-- Mining District
	-- Energy District
	-- UTM
	-- Place Name
	-- Property Name
	-- Prospect Name
	-- Location Remarks
	-- Source
	-- BLM Map Number
	header_id BIGSERIAL PRIMARY KEY,
	project_id BIGINT REFERENCES project(project_id) NULL,
	header_type_id INT REFERENCES header_type(header_type_id) NOT NULL,
	header_status_id INT REFERENCES header_status(header_status_id) NOT NULL,
	api_number INT NULL,
	other_number INT NULL,
	ardf_number VARCHAR(6) NULL, -- NEED SIZE
	name VARCHAR(255) NOT NULL,
	previous_names VARCHAR(255) NULL,
	alias VARCHAR(255) NULL,
	completion_date DATE NULL,
	completion_class VARCHAR(255) NULL, -- NEED SIZE
	completion_status VARCHAR(25) NULL, -- NEED SIZE
	permit_number INT NULL,
	permit_class VARCHAR(255) NULL, -- NEED SIZE
	permit_date DATE NULL,
	measured_depth NUMERIC(10, 2) NULL, -- NEED PRECISION
	measured_depth_unit_id INT REFERENCES unit(unit_id) NULL,
	vertical_depth NUMERIC(10, 2) NULL, -- NEED PRECISION
	vertical_depth_unit_id INT REFERENCES unit(unit_id) NULL,
	field_date DATE NULL,
	elevation NUMERIC(10, 2) NULL,  -- NEED PRECISION
	elevation_unit_id INT REFERENCES unit(unit_id) NULL,
	drill_method VARCHAR(255) NULL, -- NEED SIZE
	lease_number VARCHAR(100) NULL, -- NEED SIZE
	current_class VARCHAR(255) NULL, -- NEED SIZE
	spud_date DATE NULL,
	can_publish BOOLEAN NOT NULL DEFAULT false, -- NEED DEFAULT
	source VARCHAR(255) NULL -- NEED SIZE
);


CREATE TABLE header_note (
	header_note_id BIGSERIAL PRIMARY KEY,
	header_id BIGINT REFERENCES header(header_id) NOT NULL,
	note TEXT NOT NULL,
	note_date DATE NOT NULL DEFAULT NOW(),
	username VARCHAR(25) NOT NULL
);


CREATE TABLE header_organization (
	header_id BIGINT REFERENCES header(header_id),
	organization_id BIGINT REFERENCES organization(organization_id),
	type VARCHAR(100) NULL, -- NEED SIZE / NULLABLE? / WHAT IS THIS?
	PRIMARY KEY(header_id, organization_id)
);


CREATE TABLE header_link (
	header_id BIGINT REFERENCES header(header_id),
	link_id BIGINT REFERENCES link(link_id),
	PRIMARY KEY(header_id, link_id)
);


CREATE TABLE container_type_material (
	container_type_material_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);


CREATE TABLE container_type (
	container_type_id SERIAL PRIMARY KEY,
	container_type_material_id INT REFERENCES container_type_material(container_type_material_id) NULL,
	name VARCHAR(100) NOT NULL,
	width NUMERIC(10,2) NOT NULL,
	length NUMERIC(10,2) NOT NULL,
	height NUMERIC(10,2) NOT NULL,
	unit_id INT REFERENCES unit(unit_id) NOT NULL,
	columns INT NULL,
	remarks TEXT NULL
);


CREATE TABLE container (
	container_id BIGSERIAL PRIMARY KEY,
	parent_container_id BIGINT REFERENCES container(container_id) NULL,
	container_type_id INT REFERENCES container_type(container_type_id) NOT NULL,
	barcode INT NULL,
	name VARCHAR(50) NOT NULL, -- NEED SIZE
	description TEXT NULL
);


CREATE TABLE container_file (
	container_id BIGINT REFERENCES container(container_id),
	file_id BIGINT REFERENCES file(file_id),
	PRIMARY KEY(container_id, file_id)
);


CREATE TABLE inventory_form (
	-- What is this?
	inventory_form_id SERIAL PRIMARY KEY,
	description VARCHAR(200) NOT NULL, -- NEED SIZE
	material VARCHAR(100) NULL,
	abbreviation VARCHAR(12) NULL
);


CREATE TABLE inventory_source (
	inventory_source_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);


CREATE TABLE inventory_purpose (
	inventory_purpose_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);


CREATE TABLE inventory (
	-- STILL NEEDS LOCATION DATA: See header
	-- STILL NEEDS DESCRIPTION OF SAMPLE /w DIMENSIONS
	-- STILL NEEDS SAMPLE AGREEMENT
	inventory_id BIGSERIAL PRIMARY KEY,
	parent_id BIGINT REFERENCES inventory(inventory_id) NULL,
	collector_id BIGINT REFERENCES person(person_id) NULL, -- NULLABLE?
	container_id BIGINT REFERENCES container(container_id) NULL, -- NULLABLE?
	collection_id BIGINT REFERENCES collection(collection_id), -- Support multiple? / NULLABLE?
	inventory_source_id BIGINT REFERENCES inventory_source(inventory_source_id) NULL,
	-- Form Examples: "Core Chips", "Core Center", "Cuttings", "Cutting Auger"
	inventory_form_id BIGINT REFERENCES inventory_form(inventory_form_id) NOT NULL,
	inventory_purpose_id BIGINT REFERENCES inventory_purpose(inventory_purpose_id) NULL,
	sample_number VARCHAR(25) NULL, -- NEED SIZE
	sample_number_prefix VARCHAR(25) NULL,
	alt_sample_number VARCHAR(25) NULL, -- NEED SIZE
	published_sample_number VARCHAR(25) NULL, -- NEED SIZE
	published_number_has_suffix BOOLEAN NOT NULL DEFAULT false,
	published_description TEXT NULL, -- NEED SIZE
	barcode INT NULL,
	other_barcode INT NULL,
	state_number VARCHAR(50) NULL, -- NEED SIZE
	box_number VARCHAR(50) NULL, -- NEED SIZE
	set_number VARCHAR(50) NULL, -- NEED SIZE
	split_number VARCHAR(10) NULL, -- NEED SIZE
	slide_number VARCHAR(10) NULL,
	slip_number INT NULL,
	lab_number VARCHAR(100), -- NEED SIZE
	-- Into remarks: Screen size
	remarks TEXT NULL,
	interval_top INT NULL,
	interval_bottom INT NULL,
	interval INT NULL,
	interval_unit_id INT REFERENCES unit(unit_id) NULL,
	recovery VARCHAR(255) NULL, -- NEED SIZE
	study_area VARCHAR(2) NULL,
	line_number VARCHAR(15) NULL, -- NEED SIZE
	core_number VARCHAR(15) NULL, -- NEED SIZE
	core_diameter NUMERIC(10,2) NULL,
	core_diameter_unit_id INT REFERENCES unit(unit_id) NULL,
	can_publish BOOLEAN NOT NULL DEFAULT false,
	skeleton BOOLEAN NOT NULL DEFAULT false,
	radiation_cps NUMERIC(10, 2) NULL, -- NEED SIZE
	received_date DATE NULL,
	entered_date DATE NULL,
	modified_date DATE NULL,
	weight NUMERIC(10, 2) NULL, -- NEED SIZE
	weight_unit_id INT REFERENCES unit(unit_id) NULL
);


CREATE TABLE inventory_citation (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	citation_id BIGINT REFERENCES citation(citation_id),
	PRIMARY KEY(inventory_id, citation_id)
);


CREATE TABLE inventory_file (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	file_id BIGINT REFERENCES file(file_id),
	PRIMARY KEY(inventory_id, file_id)
);


CREATE TABLE inventory_note (
	inventory_note_id BIGSERIAL PRIMARY KEY,
	inventory_id BIGINT REFERENCES inventory(inventory_id) NOT NULL,
	note TEXT NOT NULL,
	note_date DATE NOT NULL DEFAULT NOW(),
	username VARCHAR(25) NOT NULL
);


CREATE TABLE inventory_header (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	header_id BIGINT REFERENCES header(header_id),
	PRIMARY KEY(inventory_id, header_id)
);


CREATE TABLE inventory_quality (
	inventory_quality_id BIGSERIAL PRIMARY KEY,
	inventory_id BIGINT REFERENCES inventory(inventory_id) NOT NULL,
	note TEXT NULL, -- NULLABLE?
	check_date DATE NOT NULL DEFAULT NOW(), -- REVIEW NAME
	sorted BOOLEAN NOT NULL DEFAULT false, -- REVIEW DEFAULT
	damaged BOOLEAN NOT NULL DEFAULT false,
	box_damaged BOOLEAN NOT NULL DEFAULT false,
	missing BOOLEAN NOT NULL DEFAULT false,
	data_missing BOOLEAN NOT NULL DEFAULT false,
	label_obscured BOOLEAN NOT NULL DEFAULT false,
	username VARCHAR(25) NOT NULL
);


/*
Inventory is checked out, if anything is returned, those items 
are added into inventory, individualy, but sharing a barcode.

Checkouts may be "relocated", "on loan", "sampled"

Relocated and on loan are "exclusive" in that no additional changes may be
made until they are "complete". "Sampled" is non-exclusive and may be 
applied many times to the same inventory without being completed.

Relocated - Who did it, when it was pulled and when it was returned,
where it was returned to

On loan - Who it was loaned to, when it was loaned out, expected return date,
	the actual return date, who authorized the loan

Sampled - who sampled it, when it was sampled, sample agreement,
	due date, completion date, status (complete, pending, open),
  sample agreement id

	- multiple pieces of inventory, allowing the same inventory multiple
	  times - each inventory has it's own comments and wellhole_name,
		material type, analysis type, top depth and bottom depth

	- Link file to sampled so you can attach a scanned signature


* Add sampled source to inventory for inventory that's a product of a checkout

Visits: organziation, person, when

	- barcode examined, date


Break out the barcodes into a seperate table, so that there's a unified query
method for barcodes and what they belong to


** PROCESSED tables next
*/
