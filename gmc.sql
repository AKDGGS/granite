DROP SCHEMA public CASCADE;
CREATE SCHEMA public AUTHORIZATION gmc;

CREATE TABLE file_type (
	file_type_id SERIAL PRIMARY KEY,
	name VARCHAR(255) -- NEED SIZE
);
ALTER TABLE file_type OWNER TO gmc;


CREATE TABLE file (
	file_id BIGSERIAL PRIMARY KEY,
	file_type_id INT REFERENCES file_type(file_type_id) NULL,
	description VARCHAR(255) NULL,
	mimetype VARCHAR(255) NOT NULL DEFAULT 'application/octet-stream',
	size BIGINT NOT NULL,
	filename VARCHAR(255) NOT NULL,
	md5 CHAR(16) NOT NULL
);
ALTER TABLE file OWNER TO gmc;


CREATE TABLE unit (
	unit_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	description VARCHAR(255) NULL
);
ALTER TABLE unit OWNER TO gmc;


CREATE TABLE region (
	region_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);
ALTER TABLE region OWNER TO gmc;


CREATE TABLE person (
	person_id BIGSERIAL PRIMARY KEY,
	first VARCHAR(100) NULL,
	middle VARCHAR(100) NULL,
	last VARCHAR(100) NOT NULL,
	suffix VARCHAR(50) NULL,
	preferred_id BIGINT REFERENCES person(person_id) NULL
);
ALTER TABLE person OWNER TO gmc;


CREATE TABLE organization_type (
	organization_type_id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL -- NEED SIZE
);
ALTER TABLE organization_type OWNER TO gmc;


CREATE TABLE organization (
	organization_id BIGSERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	abbreviation VARCHAR(25) NOT NULL,
	organization_type_id INT REFERENCES organization_type(organization_type_id) NOT NULL
);
ALTER TABLE organization OWNER TO gmc;


CREATE TABLE citation (
	citation_id BIGSERIAL PRIMARY KEY,
	title VARCHAR(150) NOT NULL, -- NEED SIZE
	url VARCHAR(1024) NULL,
	publication_number VARCHAR(50) NULL, -- NULLABLE?
	publication_series VARCHAR(50) NULL, -- NULLABLE?
	publication_year DATE NULL -- NULLABLE?
); 
ALTER TABLE citation OWNER TO gmc;


CREATE TABLE citation_person (
	citation_id BIGINT REFERENCES citation(citation_id),
	person_id BIGINT REFERENCES person(person_id),
	PRIMARY KEY(citation_id, person_id)
);
ALTER TABLE citation_person OWNER TO gmc;


CREATE TABLE citation_organization (
	citation_id BIGINT REFERENCES citation(citation_id),
	organization_id BIGINT REFERENCES organization(organization_id),
	PRIMARY KEY(citation_id, organization_id)
);
ALTER TABLE citation_organization OWNER TO gmc;


CREATE TABLE core_diameter_alias (
	core_diameter_alias_id SERIAL PRIMARY KEY,
	core_diameter NUMERIC(10,2) NOT NULL,
	name VARCHAR(100)
);
ALTER TABLE core_diameter_alias OWNER TO gmc;


CREATE TABLE link (
	link_id BIGSERIAL PRIMARY KEY,
	type VARCHAR(25) NULL,
	url TEXT NOT NULL
);
ALTER TABLE link OWNER TO gmc;


CREATE TABLE collection (
	collection_id SERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL
);
ALTER TABLE collection OWNER TO gmc;


CREATE TABLE project (
	project_id BIGSERIAL PRIMARY KEY,
	organization_id BIGINT REFERENCES organization(organization_id) NULL,
	name VARCHAR(100) NOT NULL,
	start_date DATE NULL,
	end_date DATE NULL
);
ALTER TABLE project OWNER TO gmc;


CREATE TABLE metadata_type (
	metadata_type_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NULL
);
ALTER TABLE metadata_type OWNER TO gmc;


CREATE TABLE metadata_status (
	metadata_status_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);
ALTER TABLE metadata_status OWNER TO gmc;

-- Merges tables: aogcc_well_header, tbl_hardrock_prospects,
-- tbl_hardrock_borehole, gmc_field_station
CREATE TABLE metadata (
	-- STILL NEEDS LOCATION DATA:
	-- Lat/Lon/Datum - Description of point (Centroid, etc)
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
	metadata_id BIGSERIAL PRIMARY KEY,
	metadata_type_id INT REFERENCES metadata_type(metadata_type_id) NOT NULL,
	metadata_status_id INT REFERENCES metadata_status(metadata_status_id) NOT NULL,

	-- Begin Spatial Data
	region_id INT REFERENCES region(region_id) NULL,
	-- End Spatial Start

	-- Begin Identifying Fields
	identity_name VARCHAR(255) NOT NULL,
	identity_number VARCHAR(50) NULL,
	identity_station VARCHAR(50) NULL,
	identity_year DATE NULL,
	-- End Identifying Fields

	api_number INT NULL,
	ardf_number VARCHAR(6) NULL, -- NEED SIZE
	alternate_names VARCHAR(1024) NULL,
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
	elevation NUMERIC(10, 2) NULL,  -- NEED PRECISION
	elevation_unit_id INT REFERENCES unit(unit_id) NULL,
	drill_method VARCHAR(255) NULL, -- NEED SIZE
	lease_number VARCHAR(100) NULL, -- NEED SIZE
	current_class VARCHAR(255) NULL, -- NEED SIZE
	spud_date DATE NULL,
	can_publish BOOLEAN NOT NULL DEFAULT false, -- NEED DEFAULT
	source VARCHAR(255) NULL -- NEED SIZE
);
ALTER TABLE metadata OWNER TO gmc;


CREATE TABLE metadata_note (
	metadata_note_id BIGSERIAL PRIMARY KEY,
	metadata_id BIGINT REFERENCES metadata(metadata_id) NOT NULL,
	note TEXT NOT NULL,
	note_date DATE NOT NULL DEFAULT NOW(),
	username VARCHAR(25) NOT NULL
);
ALTER TABLE metadata_note OWNER TO gmc;


CREATE TABLE metadata_organization (
	metadata_id BIGINT REFERENCES metadata(metadata_id),
	organization_id BIGINT REFERENCES organization(organization_id),
	type VARCHAR(100) NULL, -- NEED SIZE / NULLABLE? / WHAT IS THIS?
	PRIMARY KEY(metadata_id, organization_id)
);
ALTER TABLE metadata_organization OWNER TO gmc;


CREATE TABLE metadata_link (
	metadata_id BIGINT REFERENCES metadata(metadata_id),
	link_id BIGINT REFERENCES link(link_id),
	PRIMARY KEY(metadata_id, link_id)
);
ALTER TABLE metadata_link OWNER TO gmc;


CREATE TABLE container_type_material (
	container_type_material_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);
ALTER TABLE container_type_material OWNER TO gmc;


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
ALTER TABLE container_type OWNER TO gmc;


CREATE TABLE container (
	container_id BIGSERIAL PRIMARY KEY,
	parent_container_id BIGINT REFERENCES container(container_id) NULL,
	container_type_id INT REFERENCES container_type(container_type_id) NOT NULL,
	barcode INT NULL,
	name VARCHAR(50) NOT NULL, -- NEED SIZE
	description TEXT NULL
);
ALTER TABLE container OWNER TO gmc;


CREATE TABLE container_file (
	container_id BIGINT REFERENCES container(container_id),
	file_id BIGINT REFERENCES file(file_id),
	PRIMARY KEY(container_id, file_id)
);
ALTER TABLE container_file OWNER TO gmc;


CREATE TABLE inventory_form (
	-- What is this?
	inventory_form_id SERIAL PRIMARY KEY,
	description VARCHAR(200) NOT NULL, -- NEED SIZE
	material VARCHAR(100) NULL,
	abbreviation VARCHAR(12) NULL
);
ALTER TABLE inventory_Form OWNER TO gmc;


CREATE TABLE inventory_source (
	inventory_source_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);
ALTER TABLE inventory_source OWNER TO gmc;


CREATE TABLE inventory_purpose (
	inventory_purpose_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);
ALTER TABLE inventory_purpose OWNER TO gmc;


CREATE TABLE inventory (
	-- STILL NEEDS DESCRIPTION OF SAMPLE /w DIMENSIONS
	-- STILL NEEDS SAMPLE AGREEMENT
	-- STILL NEEDS SPATIAL DATA (See: metadata table)
	inventory_id BIGSERIAL PRIMARY KEY,
	metadata_id BIGINT REFERENCES metadata(metadata_id) NULL,
	parent_id BIGINT REFERENCES inventory(inventory_id) NULL,
	collector_id BIGINT REFERENCES person(person_id) NULL,
	container_id BIGINT REFERENCES container(container_id) NULL,
	collection_id BIGINT REFERENCES collection(collection_id) NULL,
	project_id BIGINT REFERENCES project(project_id) NULL,
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
ALTER TABLE inventory OWNER TO gmc;


CREATE TABLE inventory_citation (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	citation_id BIGINT REFERENCES citation(citation_id),
	PRIMARY KEY(inventory_id, citation_id)
);
ALTER TABLE inventory_citation OWNER TO gmc;


CREATE TABLE inventory_file (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	file_id BIGINT REFERENCES file(file_id),
	PRIMARY KEY(inventory_id, file_id)
);
ALTER TABLE inventory_file OWNER TO gmc;


CREATE TABLE inventory_note (
	inventory_note_id BIGSERIAL PRIMARY KEY,
	inventory_id BIGINT REFERENCES inventory(inventory_id) NOT NULL,
	note TEXT NOT NULL,
	note_date DATE NOT NULL DEFAULT NOW(),
	username VARCHAR(25) NOT NULL
);
ALTER TABLE inventory_note OWNER TO gmc;


CREATE TABLE inventory_metadata (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	metadata_id BIGINT REFERENCES metadata(metadata_id),
	PRIMARY KEY(inventory_id, metadata_id)
);
ALTER TABLE inventory_metadata OWNER TO gmc;


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
ALTER TABLE inventory_quality OWNER TO gmc;


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
*/
