SET ROLE 'gmc';

DROP TABLE IF EXISTS 
	inventory_quality, inventory_location_metadata, inventory_note,
	inventory_file, inventory_publication, inventory_container, 
	inventory, inventory_branch, inventory_source, inventory_form,
	container_file, container, container_type, container_material,
	location_metadata_organization, location_metadata_note,
	location_metadata, location_metadata_status, location_metadata_type,
	project, collection, core_diameter, publication_note, 
	publication_organization, publication_person, publication,
	person, organization, organization_type, region, unit, file,
	file_type, place, note, note_type
CASCADE;


CREATE TABLE note_type (
	note_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50)
);


CREATE TABLE note (
	note_id BIGSERIAL PRIMARY KEY,
	note_type_id INT REFERENCES note_type(note_type_id) NOT NULL,
	note TEXT NOT NULL,
	note_date DATE NOT NULL DEFAULT NOW(),
	username VARCHAR(25) NOT NULL
);


CREATE TABLE place (
	place_id BIGSERIAL PRIMARY KEY,
	name VARCHAR(150) NOT NULL,
	type VARCHAR(20) NOT NULL,
	geom GEOMETRY(Point, 0) NULL
);


CREATE TABLE file_type (
	file_type_id SERIAL PRIMARY KEY,
	name VARCHAR(255) -- NEED SIZE
);


CREATE TABLE file (
	file_id BIGSERIAL PRIMARY KEY,
	file_type_id INT REFERENCES file_type(file_type_id) NULL,
	description VARCHAR(100) NULL,
	mimetype VARCHAR(255) NOT NULL DEFAULT 'application/octet-stream',
	size BIGINT NOT NULL,
	filename VARCHAR(255) NOT NULL,
	md5 CHAR(16) NOT NULL
);


CREATE TABLE unit (
	unit_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL,
	abbreviation VARCHAR(5) NULL,
	description VARCHAR(100) NULL
);


CREATE TABLE region (
	region_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);


CREATE TABLE organization_type (
	organization_type_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL
);


CREATE TABLE organization (
	organization_id BIGSERIAL PRIMARY KEY,
	name VARCHAR(255) NOT NULL,
	abbreviation VARCHAR(25) NOT NULL,
	organization_type_id INT REFERENCES organization_type(organization_type_id) NOT NULL,
	remarks TEXT NULL,
	temp_original_id INT NULL

);


CREATE TABLE person (
	person_id BIGSERIAL PRIMARY KEY,
	first VARCHAR(100) NULL,
	middle VARCHAR(100) NULL,
	last VARCHAR(100) NOT NULL,
	suffix VARCHAR(50) NULL,

	organization_id BIGINT REFERENCES organization(organization_id) NULL,
	preferred_id BIGINT REFERENCES person(person_id) NULL,

	-- Used for referencing the user in the short-term during the import
	temp_fullname VARCHAR(150) NULL
);


CREATE TABLE publication (
	publication_id BIGSERIAL PRIMARY KEY,
	citation_id BIGINT NULL,
	title VARCHAR(250) NOT NULL,
	url VARCHAR(1024) NULL,
	year INT NULL,
	publication_number VARCHAR(50) NULL,
	publication_series VARCHAR(50) NULL,
	temp_original_id INT NULL
); 


CREATE TABLE publication_person (
	publication_id BIGINT REFERENCES publication(publication_id),
	person_id BIGINT REFERENCES person(person_id),
	PRIMARY KEY(publication_id, person_id)
);


CREATE TABLE publication_organization (
	publication_id BIGINT REFERENCES publication(publication_id),
	organization_id BIGINT REFERENCES organization(organization_id),
	PRIMARY KEY(publication_id, organization_id)
);


CREATE TABLE publication_note (
	publication_id BIGINT REFERENCES publication(publication_id) NOT NULL,
	note_id BIGINT REFERENCES note(note_id) NOT NULL,
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
	organization_id BIGINT REFERENCES organization(organization_id) NULL
);


CREATE TABLE project (
	project_id BIGSERIAL PRIMARY KEY,
	organization_id BIGINT REFERENCES organization(organization_id) NULL,
	name VARCHAR(100) NOT NULL,
	start_date DATE NULL,
	end_date DATE NULL,

	temp_original_id INT NULL
);


CREATE TABLE location_metadata_type (
	location_metadata_type_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NULL
);


CREATE TABLE location_metadata_status (
	location_metadata_status_id SERIAL PRIMARY KEY,
	name VARCHAR(100) NOT NULL
);

-- Well:
-- * well_name
-- * api_number
-- * well_number
-- * alternate_names
-- * lease_number
-- * spud_date
-- * completion_date
-- * measured_depth
-- * vertical_depth
-- * elevation
-- * permit status
-- * completion_status
-- * stash
-- * geo_aqusition_source
-- * geo_aqusition_type
-- * notes
-- * Spatial: Only one of each
-- * * lat/lon surface
-- * * field/pool/basin
-- * * section/township/range

-- Field Station/Outcrop
-- * name
-- * number TEXT NULLABLE
-- * year
-- * stash
-- * geo_aqusition_source
-- * geo_aqusition_type
-- * notes
-- * Spatial: Only one of each
-- * * lon/lat
-- * * section/township/range
-- * * UTM
-- * * region
-- * * place
-- * * property
-- * * quadrangle
-- * * mining district

-- Borehole:
-- * prospect_name
-- * borehole_number (TEXT)
-- * alternate_names
-- * completion_date
-- * measured_depth
-- * stash
-- * geo_aqusition_source
-- * geo_aqusition_type
-- * notes
-- * Spatial: Only one of each
-- * * lat/lon
-- * * UTM

--CREATE TABLE plss (
--	plss_id SERIAL PRIMARY KEY,
--	meridian VARCHAR(100) NULL,
--	township VARCHAR(4) NULL,
--	range VARCHAR(4) NULL,
--	section INT,
--);

-- Merges tables: aogcc_well_header, tbl_hardrock_prospects,
-- tbl_hardrock_borehole, gmc_field_station
CREATE TABLE location_metadata (
	-- STILL NEEDS LOCATION DATA:
	-- Lat/Lon/Datum - Description of point (Centroid, etc)
	-- Meridian/Township/Range/Section/Quarter Section
	-- -- Meridian VARCHAR(100)
	-- -- Township VARCHAR(4)
	-- -- Range VARCHAR(4)
	-- -- Section INT
	-- -- QuarterQuarterSection VARCHAR(4)
	-- Field/Pool -- Wells Publc Header Data - AreaOrBasin, FieldOrUnit, FieldPoolName
	-- Quadrangle/Quad 64 -- Inherit from DGGS
	-- Mining District -- Inherit from DGGS -- How precise is your mining district? 
	-- -- Keep separate, they claim DGGS has descrete polys for these
	-- Energy District -- SR66 Energy District Jean started using this, likes it
	-- UTM -- UTM Easting, UTM Northing, UTM Zone, Units, srid
	-- Property Name - BLM Property names and ARDF records
	-- Prospect Name - Inherit from DGGS
	-- Location Remarks
	-- Location Type (id, name, description) specifies the kind of geospatial data 
	-- -- (drill collar, field station, map estimate, property centroid)
	-- Location Source (id, name), specifies the original source of the spatial data
	-- -- (blm spreadsheet, published reports, DGGS map scans, AOGCC, ardf)
	-- Geological Formation - Use PaleoDB like Formations
	-- -- Needs support for points and polys
	location_metadata_id BIGSERIAL PRIMARY KEY,
	location_metadata_type_id INT REFERENCES location_metadata_type(location_metadata_type_id) NOT NULL,
	location_metadata_status_id INT REFERENCES location_metadata_status(location_metadata_status_id) NOT NULL,

	-- Begin Spatial Data
	region_id INT REFERENCES region(region_id) NULL,
	place_id BIGINT REFERENCES place(place_id) NULL, -- Should this be many-to-many?
	-- End Spatial Start

	-- Begin Identifying Fields
	identity_name VARCHAR(255) NOT NULL,
	identity_number VARCHAR(50) NULL,
	identity_station VARCHAR(50) NULL,
	identity_year DATE NULL,
	-- End Identifying Fields

	api_number VARCHAR(14) NULL,
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
	source VARCHAR(255) NULL, -- NEED SIZE
	stash JSON NULL,
	url TEXT NOT NULL,

	temp_original_id INT NULL
);


CREATE TABLE location_metadata_note (
	location_metadata_id BIGINT REFERENCES location_metadata(location_metadata_id) NOT NULL,
	note_id BIGINT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(location_metadata_id, note_id)
);


CREATE TABLE location_metadata_organization (
	location_metadata_id BIGINT REFERENCES location_metadata(location_metadata_id),
	organization_id BIGINT REFERENCES organization(organization_id),
	type VARCHAR(100) NULL, -- NEED SIZE / NULLABLE? / WHAT IS THIS?
	PRIMARY KEY(location_metadata_id, organization_id)
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
	-- Add lon/lat spatial data to container
	container_id BIGSERIAL PRIMARY KEY,
	parent_container_id BIGINT REFERENCES container(container_id) NULL,
	container_type_id INT REFERENCES container_type(container_type_id) NULL,
	container_material_id INT REFERENCES container_material(container_material_id) NULL,

	name VARCHAR(50) NOT NULL,
	description VARCHAR(100) NULL,

	-- Optional container dimensions
	height NUMERIC(10,2) NULL,
	width NUMERIC(10,2) NULL,
	depth NUMERIC(10,2) NULL,
	unit_id INT REFERENCES unit(unit_id) NULL,

	barcode VARCHAR(25) NULL,
	temp_shelf_idx VARCHAR(35) NULL
);


CREATE TABLE container_file (
	container_id BIGINT REFERENCES container(container_id),
	file_id BIGINT REFERENCES file(file_id),
	PRIMARY KEY(container_id, file_id)
);


CREATE TABLE inventory_form (
	-- Form Examples: "Core Chips", "Core Center", "Cuttings", "Cutting Auger"
	inventory_form_id SERIAL PRIMARY KEY,
	description VARCHAR(100) NOT NULL, -- NEED SIZE
	material VARCHAR(100) NULL,
	abbreviation VARCHAR(8) NULL
	-- Tags for better searching
);


CREATE TABLE inventory_source (
	-- Where the inventory was original acquired from
	-- Example: Needs review
	inventory_source_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	preferred_id INT REFERENCES inventory_source(inventory_source_id) NULL
);


CREATE TABLE inventory_branch (
	-- Branch of geology e.g. ""Seismic", "Oil and Gas", "Processed", 
	inventory_branch_id SERIAL PRIMARY KEY,
	name VARCHAR(50) NOT NULL,
	description VARCHAR(100) NULL
);


CREATE TABLE inventory (
	-- STILL NEEDS SPATIAL DATA (See: location_metadata table)
	inventory_id BIGSERIAL PRIMARY KEY,
	location_metadata_id BIGINT REFERENCES location_metadata(location_metadata_id) NULL,
	parent_id BIGINT REFERENCES inventory(inventory_id) NULL,
	collector_id BIGINT REFERENCES person(person_id) NULL,
	container_id BIGINT REFERENCES container(container_id) NULL,
	collection_id BIGINT REFERENCES collection(collection_id) NULL,
	project_id BIGINT REFERENCES project(project_id) NULL,
	inventory_source_id BIGINT REFERENCES inventory_source(inventory_source_id) NULL,
	inventory_form_id BIGINT REFERENCES inventory_form(inventory_form_id) NOT NULL,
	sample_number VARCHAR(25) NULL, -- NEED SIZE
	sample_number_prefix VARCHAR(25) NULL,
	alt_sample_number VARCHAR(25) NULL, -- NEED SIZE
	published_sample_number VARCHAR(25) NULL, -- NEED SIZE
	published_number_has_suffix BOOLEAN NOT NULL DEFAULT false,
	published_description TEXT NULL, -- NEED SIZE
	barcode VARCHAR(25) NULL,
	other_barcode VARCHAR(25) NULL,
	state_number VARCHAR(50) NULL, -- NEED SIZE
	box_number VARCHAR(50) NULL, -- NEED SIZE
	set_number VARCHAR(50) NULL, -- NEED SIZE
	split_number VARCHAR(10) NULL, -- NEED SIZE
	slide_number VARCHAR(10) NULL,
	slip_number INT NULL,
	lab_number VARCHAR(100), -- NEED SIZE
	map_number VARCHAR(25), -- Stores BLM map number
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
	core_diameter_id INT REFERENCES core_diameter(core_diameter_id) NULL,
	can_publish BOOLEAN NOT NULL DEFAULT false,
	skeleton BOOLEAN NOT NULL DEFAULT false,
	radiation_cps NUMERIC(10, 2) NULL, -- NEED SIZE
	received_date DATE NULL,
	entered_date DATE NULL,
	modified_date DATE NULL,

	-- Dimension data
	height NUMERIC(10,2) NULL,
	width NUMERIC(10,2) NULL,
	depth NUMERIC(10,2) NULL,
	dimension_unit_id INT REFERENCES unit(unit_id) NULL,

	weight NUMERIC(10, 2) NULL, -- NEED SIZE
	weight_unit_id INT REFERENCES unit(unit_id) NULL,

	stash JSON NULL,

	temp_original_id INT NULL
);


CREATE TABLE inventory_container (
	inventory_container_id BIGSERIAL PRIMARY KEY,
	inventory_id BIGINT REFERENCES inventory(inventory_id) NOT NULL,
	container_id BIGINT REFERENCES container(container_id) NOT NULL,
	log_date TIMESTAMP WITHOUT TIME ZONE NOT NULL DEFAULT NOW()
);


CREATE TABLE inventory_publication (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	publication_id BIGINT REFERENCES publication(publication_id),
	PRIMARY KEY(inventory_id, publication_id)
);


CREATE TABLE inventory_file (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	file_id BIGINT REFERENCES file(file_id),
	PRIMARY KEY(inventory_id, file_id)
);


CREATE TABLE inventory_note (
	inventory_id BIGINT REFERENCES inventory(inventory_id) NOT NULL,
	note_id BIGINT REFERENCES note(note_id) NOT NULL,
	PRIMARY KEY(inventory_id, note_id)
);


CREATE TABLE inventory_location_metadata (
	inventory_id BIGINT REFERENCES inventory(inventory_id),
	location_metadata_id BIGINT REFERENCES location_metadata(location_metadata_id),
	PRIMARY KEY(inventory_id, location_metadata_id)
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
